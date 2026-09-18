from contextlib import asynccontextmanager
import json
from uuid import uuid4
from fastapi import Depends, FastAPI, HTTPException, Request, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import select
from sqlalchemy.orm import Session
from .auth import admin_user, create_token, current_user, hash_password, verify_password
from .config import settings
from .database import Base, SessionLocal, engine, get_db
from .flight_provider import FlightProviderError, create_test_order, provider_status, search_flights
from .db_models import Agency, Booking, Customer, Invoice, Payment, PortalRequest, Supplier, User, VisaCase
from .schemas import AccountIn, BookingIn, CustomerIn, FlightOrderIn, FlightSearchIn, InvoiceIn, LoginIn, PaymentIn, PortalRequestIn, PortalRequestStatusIn, SettingsIn, SupplierIn, UserIn, VisaIn


def uid(prefix: str) -> str:
    return f"{prefix}_{uuid4().hex[:16]}"

def customer_json(x): return {"id":x.id,"name":x.name,"phone":x.phone,"email":x.email,"nationality":x.nationality,"passportNumber":x.passport_number,"passportExpiry":x.passport_expiry,"notes":x.notes}
def booking_json(x): return {"id":x.id,"customerId":x.customer_id,"type":x.type,"destination":x.destination,"travelDate":x.travel_date,"status":x.status,"cost":x.cost,"salePrice":x.sale_price,"reference":x.reference,"notes":x.notes}
def payment_json(x): return {"id":x.id,"bookingId":x.booking_id,"amount":x.amount,"method":x.method,"date":x.date,"notes":x.notes}
def invoice_json(x): return {"id":x.id,"bookingId":x.booking_id,"number":x.number,"issueDate":x.issue_date,"dueDate":x.due_date,"amount":x.amount,"status":x.status,"notes":x.notes}
def visa_json(x): return {"id":x.id,"customerId":x.customer_id,"country":x.country,"visaType":x.visa_type,"status":x.status,"applicationDate":x.application_date,"expiryDate":x.expiry_date,"fee":x.fee,"notes":x.notes}
def supplier_json(x): return {"id":x.id,"name":x.name,"type":x.type,"phone":x.phone,"email":x.email,"contactPerson":x.contact_person,"notes":x.notes}
def user_json(x): return {"id":x.id,"name":x.name,"email":x.email,"role":x.role,"active":x.active}
def agency_json(x): return {"id":x.id,"name":x.name,"currency":x.currency,"phone":x.phone,"address":x.address}
def portal_request_json(x): return {
    "id":x.id,"offerId":x.offer_id,"airline":x.airline,"flightNumber":x.flight_number,
    "origin":x.origin,"destination":x.destination,"travelDate":x.travel_date,
    "passengerName":x.passenger_name,"phone":x.phone,"email":x.email,"adults":x.adults,
    "amount":x.amount,"currency":x.currency,"status":x.status,
    "provider":x.provider,"providerOrderId":x.provider_order_id,
    "bookingReference":x.booking_reference,"bookingId":x.booking_id or "",
    "paymentStatus":x.payment_status,
    "createdAt":x.created_at.isoformat() if x.created_at else ""
}

def seed_database():
    Base.metadata.create_all(engine)
    with SessionLocal() as db:
        existing = db.scalar(select(Agency).limit(1))
        if existing:
            return
        agency = Agency(id=uid("agency"), name=settings.agency_name, currency=settings.currency, phone="+971 50 000 0000", address="United Arab Emirates")
        admin = User(id=uid("user"), agency_id=agency.id, name="Administrator", email=settings.admin_email.lower(), password_hash=hash_password(settings.admin_password), role="admin")
        db.add_all([agency, admin]); db.flush()
        if settings.seed_demo:
            c1=Customer(id="c1",agency_id=agency.id,name="Ahmed Ali",phone="+971501112233",email="ahmed@example.com",nationality="Sudanese",passport_number="P1234567",passport_expiry="2028-05-20",notes="Prefers WhatsApp")
            c2=Customer(id="c2",agency_id=agency.id,name="Sara Omar",phone="+971502223344",email="sara@example.com",nationality="Egyptian",passport_number="A7654321",passport_expiry="2027-11-10",notes="Family booking")
            c3=Customer(id="c3",agency_id=agency.id,name="Mohammed Hassan",phone="+971503334455",email="mohammed@example.com",nationality="Emirati",passport_number="UAE778899",passport_expiry="2029-03-15",notes="Corporate client")
            db.add_all([c1,c2,c3]); db.flush()
            db.add_all([
                Booking(id="b1",agency_id=agency.id,customer_id="c1",type="Flight",destination="Istanbul",travel_date="2026-10-02",status="Confirmed",cost=1450,sale_price=1750,reference="TK-88321",notes=""),
                Booking(id="b2",agency_id=agency.id,customer_id="c2",type="Hotel",destination="Dubai",travel_date="2026-09-25",status="Processing",cost=900,sale_price=1250,reference="HT-1045",notes="3 nights"),
                Booking(id="b3",agency_id=agency.id,customer_id="c3",type="Package",destination="Baku",travel_date="2026-10-10",status="New",cost=3200,sale_price=4100,reference="PK-2201",notes="2 adults"),
                Payment(id="p1",agency_id=agency.id,booking_id="b1",amount=1750,method="Card",date="2026-09-15",notes="Paid in full"),
                Payment(id="p2",agency_id=agency.id,booking_id="b2",amount=500,method="Cash",date="2026-09-16",notes="Deposit"),
                VisaCase(id="v1",agency_id=agency.id,customer_id="c1",country="Turkey",visa_type="Tourist",status="Approved",application_date="2026-09-01",expiry_date="2026-12-01",fee=350,notes="E-visa"),
                Supplier(id="s1",agency_id=agency.id,name="Global Air Partner",type="Airline",phone="+97140000001",email="sales@airpartner.test",contact_person="Mona",notes=""),
                Supplier(id="s2",agency_id=agency.id,name="City Hotels Network",type="Hotel",phone="+97140000002",email="booking@cityhotels.test",contact_person="Karim",notes=""),
            ])
        db.commit()

@asynccontextmanager
async def lifespan(app: FastAPI):
    seed_database()
    yield

app = FastAPI(title="TravelFlow API", version="2.0.0", lifespan=lifespan)
app.add_middleware(CORSMiddleware, allow_origins=settings.allowed_origins, allow_credentials=False, allow_methods=["*"], allow_headers=["*"])

@app.get("/health")
def health(): return {"ok": True, "service": "travelflow-api"}


@app.get("/public/agency")
def public_agency(db: Session = Depends(get_db)):
    agency=db.scalar(select(Agency).limit(1))
    if not agency: raise HTTPException(503,"Agency is not configured")
    return agency_json(agency)

@app.get("/public/flights/provider")
def public_flight_provider():
    return provider_status()

@app.post("/public/flights/search")
def public_flight_search(data: FlightSearchIn):
    origin=data.origin.strip().upper()
    destination=data.destination.strip().upper()
    if len(origin)!=3 or len(destination)!=3 or origin==destination:
        raise HTTPException(400,"Enter valid 3-letter origin and destination airport codes")
    if not data.travelDate.strip():
        raise HTTPException(400,"Travel date is required")
    adults=max(1,min(data.adults,9))
    try:
        return search_flights(origin, destination, data.travelDate.strip(), adults)
    except FlightProviderError as exc:
        raise HTTPException(502, str(exc))

@app.post("/public/flights/test-orders")
def public_flight_test_order(data: FlightOrderIn, request: Request, db: Session = Depends(get_db)):
    if provider_status()["mode"] != "test":
        raise HTTPException(403, "Test booking is available only while Duffel Test Mode is active")
    if not data.offerId.strip():
        raise HTTPException(400, "Offer ID is required")
    if not data.passengers or len(data.passengers) > 9:
        raise HTTPException(400, "Provide between 1 and 9 passengers")

    allowed_titles={"mr","mrs","ms","miss","dr"}
    allowed_genders={"m","f"}
    passengers=[]
    for p in data.passengers:
        if p.title not in allowed_titles or p.gender not in allowed_genders:
            raise HTTPException(400, "Passenger title or gender is invalid")
        if len(p.givenName.strip())<1 or len(p.familyName.strip())<1:
            raise HTTPException(400, "Every passenger needs a given name and family name")
        if "@" not in p.email or "." not in p.email.split("@")[-1]:
            raise HTTPException(400, "Every passenger needs a valid email address")
        if len(p.phoneNumber.strip())<7:
            raise HTTPException(400, "Every passenger needs a valid phone number")
        if len(p.bornOn.strip())!=10:
            raise HTTPException(400, "Every passenger needs a date of birth in YYYY-MM-DD format")
        passengers.append({
            "title":p.title,"gender":p.gender,
            "given_name":p.givenName.strip(),"family_name":p.familyName.strip(),
            "born_on":p.bornOn.strip(),"email":p.email.strip().lower(),
            "phone_number":p.phoneNumber.strip()
        })

    forwarded=(request.headers.get("x-forwarded-for") or "").split(",")[0].strip()
    device_ip=forwarded or (request.client.host if request.client else "")
    user_agent=request.headers.get("user-agent") or ""
    try:
        result=create_test_order(data.offerId.strip(),passengers,device_ip=device_ip,user_agent=user_agent)
    except FlightProviderError as exc:
        raise HTTPException(502, str(exc))

    agency=db.scalar(select(Agency).limit(1))
    if not agency:
        raise HTTPException(503,"Agency is not configured")

    offer=result["offer"]; order=result["order"]; lead=data.passengers[0]
    lead_email=lead.email.strip().lower(); lead_phone=lead.phoneNumber.strip()
    lead_name=f"{lead.givenName.strip()} {lead.familyName.strip()}".strip()

    customer=None
    if lead_email:
        customer=db.scalar(select(Customer).where(Customer.agency_id==agency.id,Customer.email==lead_email).limit(1))
    if not customer and lead_phone:
        customer=db.scalar(select(Customer).where(Customer.agency_id==agency.id,Customer.phone==lead_phone).limit(1))
    if not customer:
        customer=Customer(
            id=uid("c"),agency_id=agency.id,name=lead_name,phone=lead_phone,email=lead_email,
            nationality="",passport_number="",passport_expiry="",notes="Created from Duffel test booking"
        )
        db.add(customer);db.flush()

    payment_status="Awaiting payment" if order["awaitingPayment"] else "Paid with Duffel test balance"
    portal=PortalRequest(
        id=uid("req"),agency_id=agency.id,offer_id=data.offerId.strip(),
        airline=offer["airline"],flight_number=offer["flightNumber"],
        origin=offer["origin"],destination=offer["destination"],travel_date=offer["travelDate"],
        passenger_name=lead_name,phone=lead_phone,email=lead_email,adults=len(data.passengers),
        amount=order["totalAmount"],currency=order["totalCurrency"],status="Confirmed",
        provider="Duffel",provider_order_id=order["id"],booking_reference=order["bookingReference"],
        booking_id=None,payment_status=payment_status,
        passenger_data=json.dumps([{
            "title":p.title,"gender":p.gender,"givenName":p.givenName.strip(),
            "familyName":p.familyName.strip(),"bornOn":p.bornOn.strip(),
            "email":p.email.strip().lower(),"phoneNumber":p.phoneNumber.strip()
        } for p in data.passengers])
    )
    db.add(portal);db.commit();db.refresh(portal)
    return {
        "ok":True,"testMode":True,"requestNumber":portal.id,
        "orderId":order["id"],"bookingReference":order["bookingReference"],
        "amount":order["totalAmount"],"currency":order["totalCurrency"],
        "airline":offer["airline"],"route":f"{offer['origin']} → {offer['destination']}",
        "status":"Confirmed","paymentStatus":payment_status,
        "message":"Duffel test order created successfully. No live money moved."
    }

@app.post("/public/booking-requests")
def public_booking_request(data: PortalRequestIn, db: Session = Depends(get_db)):
    agency=db.scalar(select(Agency).limit(1))
    if not agency: raise HTTPException(503,"Agency is not configured")
    if len(data.passengerName.strip())<2: raise HTTPException(400,"Passenger name is required")
    if len(data.phone.strip())<7: raise HTTPException(400,"A valid phone number is required")
    x=PortalRequest(
        id=uid("req"),agency_id=agency.id,offer_id=data.offerId,airline=data.airline,
        flight_number=data.flightNumber,origin=data.origin.upper(),destination=data.destination.upper(),
        travel_date=data.travelDate,passenger_name=data.passengerName.strip(),phone=data.phone.strip(),
        email=data.email.strip().lower(),adults=max(1,min(data.adults,9)),amount=max(0,data.amount),
        currency=data.currency or agency.currency,status="New"
    )
    db.add(x);db.commit();db.refresh(x)
    return {"ok":True,"requestNumber":x.id,"status":x.status,"message":"Your booking request has been sent to the agency."}

@app.post("/auth/login")
def login(data: LoginIn, db: Session = Depends(get_db)):
    user = db.scalar(select(User).where(User.email == data.email.lower()))
    if not user or not user.active or not verify_password(data.password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid email or password")
    return {"accessToken": create_token(user.id), "user": user_json(user)}

@app.get("/bootstrap")
def bootstrap(user: User = Depends(current_user), db: Session = Depends(get_db)):
    aid=user.agency_id; agency=db.get(Agency,aid)
    return {
        "agency": agency_json(agency), "user": user_json(user),
        "customers": [customer_json(x) for x in db.scalars(select(Customer).where(Customer.agency_id==aid)).all()],
        "bookings": [booking_json(x) for x in db.scalars(select(Booking).where(Booking.agency_id==aid)).all()],
        "payments": [payment_json(x) for x in db.scalars(select(Payment).where(Payment.agency_id==aid)).all()],
        "invoices": [invoice_json(x) for x in db.scalars(select(Invoice).where(Invoice.agency_id==aid)).all()],
        "portalRequests": [portal_request_json(x) for x in db.scalars(select(PortalRequest).where(PortalRequest.agency_id==aid).order_by(PortalRequest.created_at.desc())).all()],
        "visas": [visa_json(x) for x in db.scalars(select(VisaCase).where(VisaCase.agency_id==aid)).all()],
        "suppliers": [supplier_json(x) for x in db.scalars(select(Supplier).where(Supplier.agency_id==aid)).all()],
        "users": [user_json(x) for x in db.scalars(select(User).where(User.agency_id==aid)).all()] if user.role=="admin" else [],
    }


@app.put("/portal-requests/{item_id}/status")
def update_portal_request_status(item_id:str,data:PortalRequestStatusIn,user:User=Depends(current_user),db:Session=Depends(get_db)):
    x=db.get(PortalRequest,item_id)
    if not x or x.agency_id!=user.agency_id: raise HTTPException(404,"Online request not found")
    allowed={"New","Contacted","Quoted","Confirmed","Cancelled"}
    if data.status not in allowed: raise HTTPException(400,"Invalid request status")
    x.status=data.status;db.commit();db.refresh(x);return portal_request_json(x)

@app.post("/customers")
def add_customer(data: CustomerIn, user: User=Depends(current_user), db: Session=Depends(get_db)):
    x=Customer(id=data.id or uid("c"),agency_id=user.agency_id,name=data.name,phone=data.phone,email=data.email,nationality=data.nationality,passport_number=data.passportNumber,passport_expiry=data.passportExpiry,notes=data.notes); db.add(x); db.commit(); db.refresh(x); return customer_json(x)
@app.put("/customers/{item_id}")
def update_customer(item_id:str,data:CustomerIn,user:User=Depends(current_user),db:Session=Depends(get_db)):
    x=db.get(Customer,item_id)
    if not x or x.agency_id!=user.agency_id: raise HTTPException(404,"Customer not found")
    x.name=data.name;x.phone=data.phone;x.email=data.email;x.nationality=data.nationality;x.passport_number=data.passportNumber;x.passport_expiry=data.passportExpiry;x.notes=data.notes;db.commit();return customer_json(x)
@app.delete("/customers/{item_id}")
def delete_customer(item_id:str,user:User=Depends(current_user),db:Session=Depends(get_db)):
    x=db.get(Customer,item_id)
    if not x or x.agency_id!=user.agency_id: raise HTTPException(404,"Customer not found")
    if db.scalar(select(Booking.id).where(Booking.customer_id==item_id).limit(1)): raise HTTPException(409,"Customer has bookings and cannot be deleted")
    db.delete(x);db.commit();return {"ok":True}

@app.post("/bookings")
def add_booking(data:BookingIn,user:User=Depends(current_user),db:Session=Depends(get_db)):
    c=db.get(Customer,data.customerId)
    if not c or c.agency_id!=user.agency_id: raise HTTPException(400,"Invalid customer")
    x=Booking(id=data.id or uid("b"),agency_id=user.agency_id,customer_id=data.customerId,type=data.type,destination=data.destination,travel_date=data.travelDate,status=data.status,cost=data.cost,sale_price=data.salePrice,reference=data.reference,notes=data.notes);db.add(x);db.commit();db.refresh(x);return booking_json(x)
@app.put("/bookings/{item_id}")
def update_booking(item_id:str,data:BookingIn,user:User=Depends(current_user),db:Session=Depends(get_db)):
    x=db.get(Booking,item_id)
    if not x or x.agency_id!=user.agency_id: raise HTTPException(404,"Booking not found")
    c=db.get(Customer,data.customerId)
    if not c or c.agency_id!=user.agency_id: raise HTTPException(400,"Invalid customer")
    x.customer_id=data.customerId;x.type=data.type;x.destination=data.destination;x.travel_date=data.travelDate;x.status=data.status;x.cost=data.cost;x.sale_price=data.salePrice;x.reference=data.reference;x.notes=data.notes;db.commit();return booking_json(x)
@app.delete("/bookings/{item_id}")
def delete_booking(item_id:str,user:User=Depends(current_user),db:Session=Depends(get_db)):
    x=db.get(Booking,item_id)
    if not x or x.agency_id!=user.agency_id: raise HTTPException(404,"Booking not found")
    for p in db.scalars(select(Payment).where(Payment.booking_id==item_id)).all(): db.delete(p)
    for inv in db.scalars(select(Invoice).where(Invoice.booking_id==item_id)).all(): db.delete(inv)
    db.delete(x);db.commit();return {"ok":True}

@app.post("/payments")
def add_payment(data:PaymentIn,user:User=Depends(current_user),db:Session=Depends(get_db)):
    b=db.get(Booking,data.bookingId)
    if not b or b.agency_id!=user.agency_id: raise HTTPException(400,"Invalid booking")
    x=Payment(id=data.id or uid("p"),agency_id=user.agency_id,booking_id=data.bookingId,amount=data.amount,method=data.method,date=data.date,notes=data.notes);db.add(x);db.commit();db.refresh(x);return payment_json(x)
@app.delete("/payments/{item_id}")
def delete_payment(item_id:str,user:User=Depends(current_user),db:Session=Depends(get_db)):
    x=db.get(Payment,item_id)
    if not x or x.agency_id!=user.agency_id: raise HTTPException(404,"Payment not found")
    db.delete(x);db.commit();return {"ok":True}


@app.post("/invoices")
def add_invoice(data:InvoiceIn,user:User=Depends(current_user),db:Session=Depends(get_db)):
    b=db.get(Booking,data.bookingId)
    if not b or b.agency_id!=user.agency_id: raise HTTPException(400,"Invalid booking")
    number=(data.number or "").strip()
    if not number:
        count=len(db.scalars(select(Invoice).where(Invoice.agency_id==user.agency_id)).all())+1
        number=f"INV-{count:05d}"
    if db.scalar(select(Invoice.id).where(Invoice.agency_id==user.agency_id, Invoice.number==number).limit(1)):
        raise HTTPException(409,"Invoice number already exists")
    x=Invoice(id=data.id or uid("inv"),agency_id=user.agency_id,booking_id=data.bookingId,number=number,issue_date=data.issueDate,due_date=data.dueDate,amount=data.amount or b.sale_price,status=data.status,notes=data.notes)
    db.add(x);db.commit();db.refresh(x);return invoice_json(x)

@app.put("/invoices/{item_id}")
def update_invoice(item_id:str,data:InvoiceIn,user:User=Depends(current_user),db:Session=Depends(get_db)):
    x=db.get(Invoice,item_id)
    if not x or x.agency_id!=user.agency_id: raise HTTPException(404,"Invoice not found")
    b=db.get(Booking,data.bookingId)
    if not b or b.agency_id!=user.agency_id: raise HTTPException(400,"Invalid booking")
    number=(data.number or x.number).strip()
    duplicate=db.scalar(select(Invoice).where(Invoice.agency_id==user.agency_id,Invoice.number==number,Invoice.id!=item_id).limit(1))
    if duplicate: raise HTTPException(409,"Invoice number already exists")
    x.booking_id=data.bookingId;x.number=number;x.issue_date=data.issueDate;x.due_date=data.dueDate;x.amount=data.amount;x.status=data.status;x.notes=data.notes
    db.commit();return invoice_json(x)

@app.delete("/invoices/{item_id}")
def delete_invoice(item_id:str,user:User=Depends(current_user),db:Session=Depends(get_db)):
    x=db.get(Invoice,item_id)
    if not x or x.agency_id!=user.agency_id: raise HTTPException(404,"Invoice not found")
    db.delete(x);db.commit();return {"ok":True}

@app.post("/visas")
def add_visa(data:VisaIn,user:User=Depends(current_user),db:Session=Depends(get_db)):
    c=db.get(Customer,data.customerId)
    if not c or c.agency_id!=user.agency_id: raise HTTPException(400,"Invalid customer")
    x=VisaCase(id=data.id or uid("v"),agency_id=user.agency_id,customer_id=data.customerId,country=data.country,visa_type=data.visaType,status=data.status,application_date=data.applicationDate,expiry_date=data.expiryDate,fee=data.fee,notes=data.notes);db.add(x);db.commit();db.refresh(x);return visa_json(x)
@app.put("/visas/{item_id}")
def update_visa(item_id:str,data:VisaIn,user:User=Depends(current_user),db:Session=Depends(get_db)):
    x=db.get(VisaCase,item_id)
    if not x or x.agency_id!=user.agency_id: raise HTTPException(404,"Visa case not found")
    c=db.get(Customer,data.customerId)
    if not c or c.agency_id!=user.agency_id: raise HTTPException(400,"Invalid customer")
    x.customer_id=data.customerId;x.country=data.country;x.visa_type=data.visaType;x.status=data.status;x.application_date=data.applicationDate;x.expiry_date=data.expiryDate;x.fee=data.fee;x.notes=data.notes;db.commit();return visa_json(x)
@app.delete("/visas/{item_id}")
def delete_visa(item_id:str,user:User=Depends(current_user),db:Session=Depends(get_db)):
    x=db.get(VisaCase,item_id)
    if not x or x.agency_id!=user.agency_id: raise HTTPException(404,"Visa case not found")
    db.delete(x);db.commit();return {"ok":True}

@app.post("/suppliers")
def add_supplier(data:SupplierIn,user:User=Depends(current_user),db:Session=Depends(get_db)):
    x=Supplier(id=data.id or uid("s"),agency_id=user.agency_id,name=data.name,type=data.type,phone=data.phone,email=data.email,contact_person=data.contactPerson,notes=data.notes);db.add(x);db.commit();db.refresh(x);return supplier_json(x)
@app.put("/suppliers/{item_id}")
def update_supplier(item_id:str,data:SupplierIn,user:User=Depends(current_user),db:Session=Depends(get_db)):
    x=db.get(Supplier,item_id)
    if not x or x.agency_id!=user.agency_id: raise HTTPException(404,"Supplier not found")
    x.name=data.name;x.type=data.type;x.phone=data.phone;x.email=data.email;x.contact_person=data.contactPerson;x.notes=data.notes;db.commit();return supplier_json(x)
@app.delete("/suppliers/{item_id}")
def delete_supplier(item_id:str,user:User=Depends(current_user),db:Session=Depends(get_db)):
    x=db.get(Supplier,item_id)
    if not x or x.agency_id!=user.agency_id: raise HTTPException(404,"Supplier not found")
    db.delete(x);db.commit();return {"ok":True}

@app.put("/settings")
def update_settings(data:SettingsIn,user:User=Depends(admin_user),db:Session=Depends(get_db)):
    a=db.get(Agency,user.agency_id);a.name=data.name;a.currency=data.currency;a.phone=data.phone;a.address=data.address;db.commit();return agency_json(a)
@app.put("/account")
def update_account(data:AccountIn,user:User=Depends(current_user),db:Session=Depends(get_db)):
    if data.name is not None and data.name.strip(): user.name=data.name.strip()
    if data.email is not None and data.email.strip() and data.email.lower()!=user.email:
        if db.scalar(select(User).where(User.email==data.email.lower())): raise HTTPException(409,"Email already in use")
        user.email=data.email.lower()
    if data.password is not None and data.password:
        if len(data.password)<6: raise HTTPException(400,"Password must contain at least 6 characters")
        user.password_hash=hash_password(data.password)
    db.commit();return user_json(user)

@app.get("/users")
def list_users(user:User=Depends(admin_user),db:Session=Depends(get_db)):
    return [user_json(x) for x in db.scalars(select(User).where(User.agency_id==user.agency_id)).all()]
@app.post("/users")
def add_user(data:UserIn,user:User=Depends(admin_user),db:Session=Depends(get_db)):
    if data.role not in {"admin","staff"}: raise HTTPException(400,"Role must be admin or staff")
    if db.scalar(select(User).where(User.email==data.email.lower())): raise HTTPException(409,"Email already in use")
    if len(data.password)<6: raise HTTPException(400,"Password must contain at least 6 characters")
    x=User(id=uid("user"),agency_id=user.agency_id,name=data.name,email=data.email.lower(),password_hash=hash_password(data.password),role=data.role,active=True);db.add(x);db.commit();db.refresh(x);return user_json(x)
@app.delete("/users/{item_id}")
def delete_user(item_id:str,user:User=Depends(admin_user),db:Session=Depends(get_db)):
    if item_id==user.id: raise HTTPException(400,"You cannot delete your own account")
    x=db.get(User,item_id)
    if not x or x.agency_id!=user.agency_id: raise HTTPException(404,"User not found")
    db.delete(x);db.commit();return {"ok":True}
