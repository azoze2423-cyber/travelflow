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
