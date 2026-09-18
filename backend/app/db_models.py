from datetime import datetime
from sqlalchemy import Boolean, DateTime, Float, ForeignKey, String, Text
from sqlalchemy.orm import Mapped, mapped_column
from .database import Base

class Agency(Base):
    __tablename__ = "agencies"
    id: Mapped[str] = mapped_column(String, primary_key=True)
    name: Mapped[str] = mapped_column(String, default="TravelFlow Agency")
    currency: Mapped[str] = mapped_column(String, default="AED")
    phone: Mapped[str] = mapped_column(String, default="")
    address: Mapped[str] = mapped_column(String, default="")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

class User(Base):
    __tablename__ = "users"
    id: Mapped[str] = mapped_column(String, primary_key=True)
    agency_id: Mapped[str] = mapped_column(ForeignKey("agencies.id"), index=True)
    name: Mapped[str] = mapped_column(String, default="Administrator")
    email: Mapped[str] = mapped_column(String, unique=True, index=True)
    password_hash: Mapped[str] = mapped_column(String)
    role: Mapped[str] = mapped_column(String, default="staff")
    active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

class Customer(Base):
    __tablename__ = "customers"
    id: Mapped[str] = mapped_column(String, primary_key=True)
    agency_id: Mapped[str] = mapped_column(ForeignKey("agencies.id"), index=True)
    name: Mapped[str] = mapped_column(String)
    phone: Mapped[str] = mapped_column(String, default="")
    email: Mapped[str] = mapped_column(String, default="")
    nationality: Mapped[str] = mapped_column(String, default="")
    passport_number: Mapped[str] = mapped_column(String, default="")
    passport_expiry: Mapped[str] = mapped_column(String, default="")
    notes: Mapped[str] = mapped_column(Text, default="")

class Booking(Base):
    __tablename__ = "bookings"
    id: Mapped[str] = mapped_column(String, primary_key=True)
    agency_id: Mapped[str] = mapped_column(ForeignKey("agencies.id"), index=True)
    customer_id: Mapped[str] = mapped_column(ForeignKey("customers.id"), index=True)
    type: Mapped[str] = mapped_column(String, default="Flight")
    destination: Mapped[str] = mapped_column(String, default="")
    travel_date: Mapped[str] = mapped_column(String, default="")
    status: Mapped[str] = mapped_column(String, default="New")
    cost: Mapped[float] = mapped_column(Float, default=0)
    sale_price: Mapped[float] = mapped_column(Float, default=0)
    reference: Mapped[str] = mapped_column(String, default="")
    notes: Mapped[str] = mapped_column(Text, default="")

class Payment(Base):
    __tablename__ = "payments"
    id: Mapped[str] = mapped_column(String, primary_key=True)
    agency_id: Mapped[str] = mapped_column(ForeignKey("agencies.id"), index=True)
    booking_id: Mapped[str] = mapped_column(ForeignKey("bookings.id"), index=True)
    amount: Mapped[float] = mapped_column(Float, default=0)
    method: Mapped[str] = mapped_column(String, default="Cash")
    date: Mapped[str] = mapped_column(String, default="")
    notes: Mapped[str] = mapped_column(Text, default="")

class Invoice(Base):
    __tablename__ = "invoices"
    id: Mapped[str] = mapped_column(String, primary_key=True)
    agency_id: Mapped[str] = mapped_column(ForeignKey("agencies.id"), index=True)
    booking_id: Mapped[str] = mapped_column(ForeignKey("bookings.id"), index=True)
    number: Mapped[str] = mapped_column(String, index=True)
    issue_date: Mapped[str] = mapped_column(String, default="")
    due_date: Mapped[str] = mapped_column(String, default="")
    amount: Mapped[float] = mapped_column(Float, default=0)
    status: Mapped[str] = mapped_column(String, default="Issued")
    notes: Mapped[str] = mapped_column(Text, default="")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

class PortalRequest(Base):
    __tablename__ = "portal_requests"
    id: Mapped[str] = mapped_column(String, primary_key=True)
    agency_id: Mapped[str] = mapped_column(ForeignKey("agencies.id"), index=True)
    offer_id: Mapped[str] = mapped_column(String, default="")
    airline: Mapped[str] = mapped_column(String, default="")
    flight_number: Mapped[str] = mapped_column(String, default="")
    origin: Mapped[str] = mapped_column(String, default="")
    destination: Mapped[str] = mapped_column(String, default="")
    travel_date: Mapped[str] = mapped_column(String, default="")
    passenger_name: Mapped[str] = mapped_column(String)
    phone: Mapped[str] = mapped_column(String, default="")
    email: Mapped[str] = mapped_column(String, default="")
    adults: Mapped[int] = mapped_column(default=1)
    amount: Mapped[float] = mapped_column(Float, default=0)
    currency: Mapped[str] = mapped_column(String, default="AED")
    status: Mapped[str] = mapped_column(String, default="New")
    provider: Mapped[str] = mapped_column(String, default="")
    provider_order_id: Mapped[str] = mapped_column(String, default="", index=True)
    booking_reference: Mapped[str] = mapped_column(String, default="")
    booking_id: Mapped[str | None] = mapped_column(ForeignKey("bookings.id"), nullable=True, index=True)
    payment_status: Mapped[str] = mapped_column(String, default="")
    passenger_data: Mapped[str] = mapped_column(Text, default="")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

class VisaCase(Base):
    __tablename__ = "visas"
    id: Mapped[str] = mapped_column(String, primary_key=True)
    agency_id: Mapped[str] = mapped_column(ForeignKey("agencies.id"), index=True)
    customer_id: Mapped[str] = mapped_column(ForeignKey("customers.id"), index=True)
    country: Mapped[str] = mapped_column(String, default="")
    visa_type: Mapped[str] = mapped_column(String, default="Tourist")
    status: Mapped[str] = mapped_column(String, default="New")
    application_date: Mapped[str] = mapped_column(String, default="")
    expiry_date: Mapped[str] = mapped_column(String, default="")
    fee: Mapped[float] = mapped_column(Float, default=0)
    notes: Mapped[str] = mapped_column(Text, default="")

class Supplier(Base):
    __tablename__ = "suppliers"
    id: Mapped[str] = mapped_column(String, primary_key=True)
    agency_id: Mapped[str] = mapped_column(ForeignKey("agencies.id"), index=True)
    name: Mapped[str] = mapped_column(String)
    type: Mapped[str] = mapped_column(String, default="Airline")
    phone: Mapped[str] = mapped_column(String, default="")
    email: Mapped[str] = mapped_column(String, default="")
    contact_person: Mapped[str] = mapped_column(String, default="")
    notes: Mapped[str] = mapped_column(Text, default="")
