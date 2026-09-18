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
