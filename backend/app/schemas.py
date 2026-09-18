from pydantic import BaseModel

class LoginIn(BaseModel):
    email: str
    password: str

class CustomerIn(BaseModel):
    id: str | None = None
    name: str
    phone: str = ""
    email: str = ""
    nationality: str = ""
    passportNumber: str = ""
    passportExpiry: str = ""
    notes: str = ""

class BookingIn(BaseModel):
    id: str | None = None
    customerId: str
    type: str = "Flight"
    destination: str = ""
    travelDate: str = ""
    status: str = "New"
    cost: float = 0
    salePrice: float = 0
    reference: str = ""
    notes: str = ""

class PaymentIn(BaseModel):
    id: str | None = None
    bookingId: str
    amount: float
    method: str = "Cash"
    date: str = ""
    notes: str = ""

class InvoiceIn(BaseModel):
    id: str | None = None
    bookingId: str
    number: str = ""
    issueDate: str = ""
    dueDate: str = ""
    amount: float = 0
    status: str = "Issued"
    notes: str = ""

class VisaIn(BaseModel):
    id: str | None = None
    customerId: str
    country: str = ""
    visaType: str = "Tourist"
    status: str = "New"
    applicationDate: str = ""
    expiryDate: str = ""
    fee: float = 0
    notes: str = ""

class SupplierIn(BaseModel):
    id: str | None = None
    name: str
    type: str = "Airline"
    phone: str = ""
    email: str = ""
    contactPerson: str = ""
    notes: str = ""

class FlightSearchIn(BaseModel):
    origin: str
    destination: str
    travelDate: str
    adults: int = 1

class FlightPassengerIn(BaseModel):
    title: str
    gender: str
    givenName: str
    familyName: str
    bornOn: str
    email: str
    phoneNumber: str

class FlightOrderIn(BaseModel):
    offerId: str
    passengers: list[FlightPassengerIn]

class PortalRequestIn(BaseModel):
    offerId: str
    airline: str
    flightNumber: str = ""
    origin: str
    destination: str
    travelDate: str
    passengerName: str
    phone: str
    email: str = ""
    adults: int = 1
    amount: float = 0
    currency: str = "AED"

class PortalRequestStatusIn(BaseModel):
    status: str

class SettingsIn(BaseModel):
    name: str
    currency: str = "AED"
    phone: str = ""
    address: str = ""

class AccountIn(BaseModel):
    name: str | None = None
    email: str | None = None
    password: str | None = None

class UserIn(BaseModel):
    name: str
    email: str
    password: str
    role: str = "staff"
