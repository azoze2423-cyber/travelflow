import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../store/app_store.dart';
import '../widgets/common.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key, required this.store});
  final AppStore store;

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  String query = '';

  String paymentStatus(Invoice invoice) {
    final paid = widget.store.paidForBooking(invoice.bookingId);
    if (invoice.status == 'Cancelled') return 'Cancelled';
    if (paid >= invoice.amount && invoice.amount > 0) return 'Paid';
    if (paid > 0) return 'Partial';
    final due = DateTime.tryParse(invoice.dueDate);
    if (due != null && due.isBefore(DateTime.now())) return 'Overdue';
    return invoice.status;
  }

  @override
  Widget build(BuildContext context) {
    final rows = widget.store.invoices.where((invoice) {
      final booking = widget.store.bookingById(invoice.bookingId);
      final customer = booking == null ? null : widget.store.customerById(booking.customerId);
      return (invoice.number + ' ' + (customer?.name ?? '') + ' ' + (booking?.reference ?? ''))
          .toLowerCase()
          .contains(query.toLowerCase());
    }).toList().reversed.toList();

    return Column(children: [
      PageHeader(
        title: 'Invoices',
        subtitle: 'Create, print and share customer invoices',
        action: FilledButton.icon(
          onPressed: widget.store.bookings.isEmpty ? null : () => _edit(),
          icon: const Icon(Icons.add),
          label: const Text('New invoice'),
        ),
      ),
      const SizedBox(height: 18),
      TextField(
        decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search invoices'),
        onChanged: (v) => setState(() => query = v),
      ),
      const SizedBox(height: 16),
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: rows.isEmpty
              ? const Center(child: Text('No invoices yet'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final invoice = rows[i];
                    final booking = widget.store.bookingById(invoice.bookingId);
                    final customer = booking == null ? null : widget.store.customerById(booking.customerId);
                    final paid = widget.store.paidForBooking(invoice.bookingId);
                    final balance = invoice.amount - paid;
                    final state = paymentStatus(invoice);
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.receipt_long_outlined)),
                      title: Row(children: [
                        Expanded(
                          child: Text(
                            invoice.number + ' — ' + (customer?.name ?? 'Unknown customer'),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        StatusPill(state),
                      ]),
                      subtitle: Text(
                        (booking?.type ?? '') + ' • ' + (booking?.destination ?? '') + ' • Due ' + invoice.dueDate + '\n'
                        + 'Invoice: ' + money(invoice.amount, widget.store.currency)
                        + ' • Paid: ' + money(paid, widget.store.currency)
                        + ' • Balance: ' + money(balance, widget.store.currency),
                      ),
                      isThreeLine: true,
                      trailing: Wrap(children: [
                        IconButton(tooltip: 'View invoice', onPressed: () => _view(invoice), icon: const Icon(Icons.visibility_outlined)),
                        IconButton(tooltip: 'Print / PDF', onPressed: () => _printInvoice(invoice), icon: const Icon(Icons.print_outlined)),
                        IconButton(tooltip: 'Send to WhatsApp', onPressed: () => _sendWhatsApp(invoice), icon: const Icon(Icons.chat_outlined, color: Color(0xFF16A34A))),
                        IconButton(tooltip: 'Edit', onPressed: () => _edit(invoice), icon: const Icon(Icons.edit_outlined)),
                        IconButton(onPressed: () => _delete(invoice), icon: const Icon(Icons.delete_outline, color: Colors.red)),
                      ]),
                    );
                  },
                ),
        ),
      ),
    ]);
  }

  Future<Uint8List> _buildInvoicePdf(Invoice invoice) async {
    final booking = widget.store.bookingById(invoice.bookingId);
    final customer = booking == null ? null : widget.store.customerById(booking.customerId);
    final paid = widget.store.paidForBooking(invoice.bookingId);
    final balance = invoice.amount - paid;

    final regular = await PdfGoogleFonts.notoSansArabicRegular();
    final bold = await PdfGoogleFonts.notoSansArabicBold();
    final document = pw.Document();

    pw.Widget detail(String label, String value, {bool emphasize = false}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 125,
              child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Expanded(
              child: pw.Text(
                value,
                style: emphasize ? pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12) : null,
              ),
            ),
          ],
        ),
      );
    }

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        build: (_) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(widget.store.agencyName, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                    if (widget.store.address.isNotEmpty) pw.Text(widget.store.address),
                    if (widget.store.phone.isNotEmpty) pw.Text(widget.store.phone),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('INVOICE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text(invoice.number),
                  pw.Text(paymentStatus(invoice)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.SizedBox(height: 8),
          detail('Customer', customer?.name ?? 'Unknown customer'),
          if ((customer?.phone ?? '').isNotEmpty) detail('Phone', customer!.phone),
          if ((customer?.email ?? '').isNotEmpty) detail('Email', customer!.email),
          detail('Service', (booking?.type ?? '') + ((booking?.destination ?? '').isEmpty ? '' : ' — ' + booking!.destination)),
          detail('Booking reference', booking?.reference ?? ''),
          detail('Travel date', booking?.travelDate ?? ''),
          detail('Issue date', invoice.issueDate),
          detail('Due date', invoice.dueDate),
          pw.SizedBox(height: 14),
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Column(
              children: [
                detail('Invoice amount', money(invoice.amount, widget.store.currency), emphasize: true),
                detail('Paid', money(paid, widget.store.currency)),
                detail('Balance', money(balance, widget.store.currency), emphasize: true),
              ],
            ),
          ),
          if (invoice.notes.isNotEmpty) ...[
            pw.SizedBox(height: 18),
            pw.Text('Notes', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(invoice.notes),
          ],
          pw.SizedBox(height: 30),
          pw.Divider(),
          pw.Text('Thank you for choosing ' + widget.store.agencyName + '.', style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );

    return document.save();
  }

  Future<void> _printInvoice(Invoice invoice) async {
    try {
      await Printing.layoutPdf(
        name: invoice.number.isEmpty ? 'TravelFlow Invoice' : invoice.number,
        onLayout: (_) => _buildInvoicePdf(invoice),
      );
    } catch (e) {
      _showMessage('Could not open print/PDF: $e');
    }
  }

  Future<void> _sharePdf(Invoice invoice) async {
    try {
      final bytes = await _buildInvoicePdf(invoice);
      final safeName = invoice.number.isEmpty
          ? 'invoice'
          : invoice.number.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
      await Printing.sharePdf(bytes: bytes, filename: '$safeName.pdf');
    } catch (e) {
      _showMessage('Could not share PDF: $e');
    }
  }

  Future<void> _sendWhatsApp(Invoice invoice) async {
    final booking = widget.store.bookingById(invoice.bookingId);
    final customer = booking == null ? null : widget.store.customerById(booking.customerId);
    final paid = widget.store.paidForBooking(invoice.bookingId);
    final balance = invoice.amount - paid;
    final phone = (customer?.phone ?? '').replaceAll(RegExp(r'[^0-9]'), '');

    if (phone.isEmpty) {
      _showMessage('Add the customer phone number first, then try WhatsApp again.');
      return;
    }

    final message = [
      widget.store.agencyName,
      'Invoice ${invoice.number}',
      'Customer: ${customer?.name ?? ''}',
      if ((booking?.type ?? '').isNotEmpty)
        'Service: ${booking!.type}${booking.destination.isEmpty ? '' : ' - ${booking.destination}'}',
      if ((booking?.reference ?? '').isNotEmpty) 'Booking ref: ${booking!.reference}',
      'Invoice amount: ${money(invoice.amount, widget.store.currency)}',
      'Paid: ${money(paid, widget.store.currency)}',
      'Balance: ${money(balance, widget.store.currency)}',
      if (invoice.dueDate.isNotEmpty) 'Due date: ${invoice.dueDate}',
      '',
      'Thank you.',
    ].join('\n');

    final uri = Uri.https('wa.me', phone, {'text': message});
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) _showMessage('Could not open WhatsApp.');
    } catch (e) {
      _showMessage('Could not open WhatsApp: $e');
    }
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _view(Invoice invoice) async {
    final booking = widget.store.bookingById(invoice.bookingId);
    final customer = booking == null ? null : widget.store.customerById(booking.customerId);
    final paid = widget.store.paidForBooking(invoice.bookingId);
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(invoice.number),
        content: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.store.agencyName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              Text(widget.store.address),
              Text(widget.store.phone),
              const Divider(height: 28),
              Text('Customer: ' + (customer?.name ?? 'Unknown')),
              Text('Service: ' + (booking?.type ?? '') + ' — ' + (booking?.destination ?? '')),
              Text('Booking reference: ' + (booking?.reference ?? '')),
              Text('Issue date: ' + invoice.issueDate),
              Text('Due date: ' + invoice.dueDate),
              const SizedBox(height: 16),
              Text('Invoice amount: ' + money(invoice.amount, widget.store.currency), style: const TextStyle(fontWeight: FontWeight.w700)),
              Text('Paid: ' + money(paid, widget.store.currency)),
              Text('Balance: ' + money(invoice.amount - paid, widget.store.currency)),
              if (invoice.notes.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Notes: ' + invoice.notes),
              ],
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _sendWhatsApp(invoice),
            icon: const Icon(Icons.chat_outlined),
            label: const Text('WhatsApp'),
          ),
          TextButton.icon(
            onPressed: () => _sharePdf(invoice),
            icon: const Icon(Icons.share_outlined),
            label: const Text('Share PDF'),
          ),
          FilledButton.icon(
            onPressed: () => _printInvoice(invoice),
            icon: const Icon(Icons.print_outlined),
            label: const Text('Print / PDF'),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _delete(Invoice invoice) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete invoice?'),
            content: Text('Delete invoice ' + invoice.number + '?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
            ],
          ),
        ) ??
        false;
    if (ok) await widget.store.deleteInvoice(invoice.id);
  }

  Future<void> _edit([Invoice? current]) async {
    String bookingId = current?.bookingId ?? widget.store.bookings.first.id;
    String status = current?.status ?? 'Issued';
    final number = TextEditingController(text: current?.number ?? '');
    final issueDate = TextEditingController(
      text: current?.issueDate ?? DateTime.now().toIso8601String().substring(0, 10),
    );
    final dueDate = TextEditingController(
      text: current?.dueDate ?? DateTime.now().add(const Duration(days: 7)).toIso8601String().substring(0, 10),
    );
    final selectedBooking = widget.store.bookingById(bookingId);
    final amount = TextEditingController(text: current?.amount.toString() ?? (selectedBooking?.salePrice ?? 0).toString());
    final notes = TextEditingController(text: current?.notes ?? '');

    final result = await showDialog<Invoice>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text(current == null ? 'New invoice' : 'Edit invoice'),
          content: SizedBox(
            width: 650,
            child: SingleChildScrollView(
              child: Column(children: [
                DropdownButtonFormField<String>(
                  initialValue: bookingId,
                  decoration: const InputDecoration(labelText: 'Booking'),
                  items: widget.store.bookings.map((b) {
                    final c = widget.store.customerById(b.customerId);
                    return DropdownMenuItem(value: b.id, child: Text((c?.name ?? 'Unknown') + ' — ' + b.type + ' / ' + b.destination));
                  }).toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setLocal(() {
                      bookingId = v;
                      if (current == null) {
                        final b = widget.store.bookingById(v);
                        amount.text = (b?.salePrice ?? 0).toString();
                      }
                    });
                  },
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: TextField(controller: number, decoration: const InputDecoration(labelText: 'Invoice number (auto if blank)'))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: ['Draft', 'Issued', 'Cancelled'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setLocal(() => status = v!),
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: issueDate,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Issue date', suffixIcon: Icon(Icons.calendar_today)),
                      onTap: () async {
                        final v = await pickDateText(context, issueDate.text);
                        if (v != null) issueDate.text = v;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: dueDate,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Due date', suffixIcon: Icon(Icons.calendar_today)),
                      onTap: () async {
                        final v = await pickDateText(context, dueDate.text);
                        if (v != null) dueDate.text = v;
                      },
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                TextField(
                  controller: amount,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Amount (' + widget.store.currency + ')'),
                ),
                const SizedBox(height: 10),
                TextField(controller: notes, minLines: 2, maxLines: 4, decoration: const InputDecoration(labelText: 'Notes')),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(amount.text) ?? 0;
                if (value <= 0) return;
                Navigator.pop(
                  context,
                  Invoice(
                    id: current?.id ?? widget.store.newId(),
                    bookingId: bookingId,
                    number: number.text.trim(),
                    issueDate: issueDate.text,
                    dueDate: dueDate.text,
                    amount: value,
                    status: status,
                    notes: notes.text.trim(),
                  ),
                );
              },
              child: const Text('Save invoice'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      current == null ? await widget.store.addInvoice(result) : await widget.store.updateInvoice(result);
    }
  }
}
