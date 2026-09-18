class Customer {
  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.nationality,
    required this.passportNumber,
    required this.passportExpiry,
    required this.notes,
  });

  String id;
  String name;
  String phone;
  String email;
  String nationality;
  String passportNumber;
  String passportExpiry;
  String notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'nationality': nationality,
        'passportNumber': passportNumber,
        'passportExpiry': passportExpiry,
        'notes': notes,
      };

  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
        id: j['id'] ?? '',
        name: j['name'] ?? '',
        phone: j['phone'] ?? '',
        email: j['email'] ?? '',
        nationality: j['nationality'] ?? '',
        passportNumber: j['passportNumber'] ?? '',
        passportExpiry: j['passportExpiry'] ?? '',
        notes: j['notes'] ?? '',
      );
}

class Booking {
  Booking({
    required this.id,
    required this.customerId,
    required this.type,
    required this.destination,
    required this.travelDate,
    required this.status,
    required this.cost,
    required this.salePrice,
    required this.reference,
    required this.notes,
  });

  String id;
  String customerId;
  String type;
  String destination;
  String travelDate;
  String status;
  double cost;
  double salePrice;
  String reference;
  String notes;

  double get profit => salePrice - cost;

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'type': type,
        'destination': destination,
        'travelDate': travelDate,
        'status': status,
        'cost': cost,
        'salePrice': salePrice,
        'reference': reference,
        'notes': notes,
      };

  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
        id: j['id'] ?? '',
        customerId: j['customerId'] ?? '',
        type: j['type'] ?? 'Flight',
        destination: j['destination'] ?? '',
        travelDate: j['travelDate'] ?? '',
        status: j['status'] ?? 'New',
        cost: (j['cost'] ?? 0).toDouble(),
        salePrice: (j['salePrice'] ?? 0).toDouble(),
        reference: j['reference'] ?? '',
        notes: j['notes'] ?? '',
      );
}

class Payment {
  Payment({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.method,
    required this.date,
    required this.notes,
  });

  String id;
  String bookingId;
  double amount;
  String method;
  String date;
  String notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookingId': bookingId,
        'amount': amount,
        'method': method,
        'date': date,
        'notes': notes,
      };

  factory Payment.fromJson(Map<String, dynamic> j) => Payment(
        id: j['id'] ?? '',
        bookingId: j['bookingId'] ?? '',
        amount: (j['amount'] ?? 0).toDouble(),
        method: j['method'] ?? 'Cash',
        date: j['date'] ?? '',
        notes: j['notes'] ?? '',
      );
}


class Invoice {
  Invoice({
    required this.id,
    required this.bookingId,
    required this.number,
    required this.issueDate,
    required this.dueDate,
    required this.amount,
    required this.status,
    required this.notes,
  });

  String id;
  String bookingId;
  String number;
  String issueDate;
  String dueDate;
  double amount;
  String status;
  String notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookingId': bookingId,
        'number': number,
        'issueDate': issueDate,
        'dueDate': dueDate,
        'amount': amount,
        'status': status,
        'notes': notes,
      };

  factory Invoice.fromJson(Map<String, dynamic> j) => Invoice(
        id: j['id'] ?? '',
        bookingId: j['bookingId'] ?? '',
        number: j['number'] ?? '',
        issueDate: j['issueDate'] ?? '',
        dueDate: j['dueDate'] ?? '',
        amount: (j['amount'] ?? 0).toDouble(),
        status: j['status'] ?? 'Issued',
        notes: j['notes'] ?? '',
      );
}


class PortalRequest {
  PortalRequest({
    required this.id,
    required this.offerId,
    required this.airline,
    required this.flightNumber,
    required this.origin,
    required this.destination,
    required this.travelDate,
    required this.passengerName,
    required this.phone,
    required this.email,
    required this.adults,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
  });

  String id;
  String offerId;
  String airline;
  String flightNumber;
  String origin;
  String destination;
  String travelDate;
  String passengerName;
  String phone;
  String email;
  int adults;
  double amount;
  String currency;
  String status;
  String createdAt;

  factory PortalRequest.fromJson(Map<String, dynamic> j) => PortalRequest(
        id: j['id'] ?? '',
        offerId: j['offerId'] ?? '',
        airline: j['airline'] ?? '',
        flightNumber: j['flightNumber'] ?? '',
        origin: j['origin'] ?? '',
        destination: j['destination'] ?? '',
        travelDate: j['travelDate'] ?? '',
        passengerName: j['passengerName'] ?? '',
        phone: j['phone'] ?? '',
        email: j['email'] ?? '',
        adults: (j['adults'] ?? 1) as int,
        amount: (j['amount'] ?? 0).toDouble(),
        currency: j['currency'] ?? 'AED',
        status: j['status'] ?? 'New',
        createdAt: j['createdAt'] ?? '',
      );
}

class VisaCase {
  VisaCase({
    required this.id,
    required this.customerId,
    required this.country,
    required this.visaType,
    required this.status,
    required this.applicationDate,
    required this.expiryDate,
    required this.fee,
    required this.notes,
  });

  String id;
  String customerId;
  String country;
  String visaType;
  String status;
  String applicationDate;
  String expiryDate;
  double fee;
  String notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'country': country,
        'visaType': visaType,
        'status': status,
        'applicationDate': applicationDate,
        'expiryDate': expiryDate,
        'fee': fee,
        'notes': notes,
      };

  factory VisaCase.fromJson(Map<String, dynamic> j) => VisaCase(
        id: j['id'] ?? '',
        customerId: j['customerId'] ?? '',
        country: j['country'] ?? '',
        visaType: j['visaType'] ?? 'Tourist',
        status: j['status'] ?? 'New',
        applicationDate: j['applicationDate'] ?? '',
        expiryDate: j['expiryDate'] ?? '',
        fee: (j['fee'] ?? 0).toDouble(),
        notes: j['notes'] ?? '',
      );
}

class Supplier {
  Supplier({
    required this.id,
    required this.name,
    required this.type,
    required this.phone,
    required this.email,
    required this.contactPerson,
    required this.notes,
  });

  String id;
  String name;
  String type;
  String phone;
  String email;
  String contactPerson;
  String notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'phone': phone,
        'email': email,
        'contactPerson': contactPerson,
        'notes': notes,
      };

  factory Supplier.fromJson(Map<String, dynamic> j) => Supplier(
        id: j['id'] ?? '',
        name: j['name'] ?? '',
        type: j['type'] ?? 'Airline',
        phone: j['phone'] ?? '',
        email: j['email'] ?? '',
        contactPerson: j['contactPerson'] ?? '',
        notes: j['notes'] ?? '',
      );
}

class UserAccount {
  UserAccount({required this.id, required this.name, required this.email, required this.role, required this.active});
  String id;
  String name;
  String email;
  String role;
  bool active;

  factory UserAccount.fromJson(Map<String, dynamic> j) => UserAccount(
    id: j['id'] ?? '',
    name: j['name'] ?? '',
    email: j['email'] ?? '',
    role: j['role'] ?? 'staff',
    active: j['active'] ?? true,
  );
}
