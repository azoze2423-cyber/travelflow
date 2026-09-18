import json
from datetime import datetime
from urllib import error, request

from .config import settings


DUFFEL_BASE_URL = "https://api.duffel.com"


class FlightProviderError(Exception):
    pass


def provider_status():
    token = settings.duffel_access_token
    if not token:
        return {"provider": "duffel", "configured": False, "mode": "unconfigured"}
    return {
        "provider": "duffel",
        "configured": True,
        "mode": "test" if token.startswith("duffel_test_") else "live",
    }


def _duffel_request(method: str, path: str, payload: dict | None = None, timeout: int = 25, extra_headers: dict | None = None) -> dict:
    token = settings.duffel_access_token
    if not token:
        raise FlightProviderError("Duffel is not configured yet")

    headers = {
        "Authorization": f"Bearer {token}",
        "Duffel-Version": "v2",
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Accept-Encoding": "gzip",
    }
    if extra_headers:
        headers.update({k: v for k, v in extra_headers.items() if v})

    body = json.dumps(payload).encode("utf-8") if payload is not None else None
    req = request.Request(
        DUFFEL_BASE_URL + path,
        data=body,
        method=method,
        headers=headers,
    )
    try:
        with request.urlopen(req, timeout=timeout) as response:
            raw = response.read()
            encoding = (response.headers.get("Content-Encoding") or "").lower()
            if encoding == "gzip":
                import gzip
                raw = gzip.decompress(raw)
            return json.loads(raw.decode("utf-8"))
    except error.HTTPError as exc:
        message = "Duffel rejected the request"
        try:
            raw = exc.read()
            if (exc.headers.get("Content-Encoding") or "").lower() == "gzip":
                import gzip
                raw = gzip.decompress(raw)
            data = json.loads(raw.decode("utf-8"))
            errors = data.get("errors") or []
            if errors:
                first = errors[0]
                message = first.get("message") or first.get("title") or message
                code = first.get("code")
                if code:
                    message = f"{message} ({code})"
        except Exception:
            pass
        raise FlightProviderError(message) from exc
    except error.URLError as exc:
        raise FlightProviderError("The airline provider is temporarily unreachable") from exc
    except TimeoutError as exc:
        raise FlightProviderError("The airline provider timed out. Please try again.") from exc


def _duffel_post(path: str, payload: dict, timeout: int = 25, extra_headers: dict | None = None) -> dict:
    return _duffel_request("POST", path, payload, timeout=timeout, extra_headers=extra_headers)


def _duffel_get(path: str, timeout: int = 20) -> dict:
    return _duffel_request("GET", path, None, timeout=timeout)


def _time_text(value):
    if not value:
        return ""
    try:
        return datetime.fromisoformat(value.replace("Z", "+00:00")).strftime("%H:%M")
    except Exception:
        return str(value)[11:16] if len(str(value)) >= 16 else str(value)


def _duration_text(value):
    if not value:
        return ""
    text = str(value)
    if not text.startswith("PT"):
        return text
    text = text[2:]
    hours = ""
    minutes = ""
    if "H" in text:
        hours, text = text.split("H", 1)
    if "M" in text:
        minutes = text.split("M", 1)[0]
    parts = []
    if hours:
        parts.append(f"{hours}h")
    if minutes:
        parts.append(f"{minutes}m")
    return " ".join(parts)


def _baggage_text(offer):
    try:
        segment = offer["slices"][0]["segments"][0]
        passengers = segment.get("passengers") or []
        baggages = passengers[0].get("baggages") if passengers else []
        if not baggages:
            return "See fare rules"
        pieces = []
        for baggage in baggages:
            quantity = baggage.get("quantity")
            bag_type = (baggage.get("type") or "bag").replace("_", " ")
            if quantity is not None:
                pieces.append(f"{quantity} {bag_type}")
        return ", ".join(pieces) if pieces else "Included baggage"
    except Exception:
        return "See fare rules"


def _refundable(offer):
    try:
        refund = (offer.get("conditions") or {}).get("refund_before_departure") or {}
        return refund.get("allowed") is True
    except Exception:
        return False


def _offer_to_json(offer):
    slices = offer.get("slices") or []
    first_slice = slices[0] if slices else {}
    segments = first_slice.get("segments") or []
    first_segment = segments[0] if segments else {}
    last_segment = segments[-1] if segments else {}

    carrier_names = []
    flight_numbers = []
    airline_codes = []
    for segment in segments:
        carrier = segment.get("operating_carrier") or segment.get("marketing_carrier") or {}
        name = carrier.get("name")
        if name and name not in carrier_names:
            carrier_names.append(name)
        marketing = segment.get("marketing_carrier") or {}
        code = marketing.get("iata_code") or carrier.get("iata_code")
        number = segment.get("marketing_carrier_flight_number") or segment.get("operating_carrier_flight_number")
        if code and code not in airline_codes:
            airline_codes.append(code)
        if number:
            flight_numbers.append(f"{code or ''}{number}".strip())

    owner = offer.get("owner") or {}
    airline = " / ".join(carrier_names) or owner.get("name") or "Airline"
    airline_code = "/".join(airline_codes) or owner.get("iata_code") or ""

    cabin = "Economy"
    try:
        passenger = (first_segment.get("passengers") or [])[0]
        cabin = passenger.get("cabin_class_marketing_name") or passenger.get("cabin_class") or cabin
        cabin = str(cabin).replace("_", " ").title()
    except Exception:
        pass

    requirements = offer.get("payment_requirements") or {}
    return {
        "id": offer.get("id", ""),
        "airline": airline,
        "airlineCode": airline_code,
        "flightNumber": " / ".join(flight_numbers),
        "origin": ((first_slice.get("origin") or {}).get("iata_code") or ""),
        "destination": ((first_slice.get("destination") or {}).get("iata_code") or ""),
        "travelDate": str(first_segment.get("departing_at") or "")[:10],
        "departureTime": _time_text(first_segment.get("departing_at")),
        "arrivalTime": _time_text(last_segment.get("arriving_at")),
        "duration": _duration_text(first_slice.get("duration")),
        "cabin": cabin,
        "baggage": _baggage_text(offer),
        "fareName": offer.get("fare_brand_name") or "Standard",
        "amount": float(offer.get("total_amount") or 0),
        "currency": offer.get("total_currency") or "",
        "refundable": _refundable(offer),
        "expiresAt": offer.get("expires_at") or "",
        "requiresInstantPayment": requirements.get("requires_instant_payment") is True,
        "paymentRequiredBy": requirements.get("payment_required_by") or "",
        "operatingCarriers": carrier_names,
        "source": "Duffel",
    }


def search_flights(origin: str, destination: str, travel_date: str, adults: int):
    payload = {
        "data": {
            "cabin_class": "economy",
            "passengers": [{"type": "adult"} for _ in range(adults)],
            "slices": [{
                "origin": origin,
                "destination": destination,
                "departure_date": travel_date,
            }],
        }
    }
    response = _duffel_post(
        "/air/offer_requests?return_offers=true&supplier_timeout=10000",
        payload,
    )
    data = response.get("data") or {}
    offers = data.get("offers") or []
    normalized = [_offer_to_json(offer) for offer in offers]
    normalized.sort(key=lambda item: item["amount"])
    status = provider_status()
    return {
        "inventoryMode": f"duffel_{status['mode']}",
        "provider": "Duffel",
        "liveMode": bool(data.get("live_mode")),
        "offerRequestId": data.get("id") or "",
        "notice": "Duffel Test Mode: no live orders or money movement." if status["mode"] == "test" else "",
        "offers": normalized[:30],
    }


def get_offer(offer_id: str):
    response = _duffel_get(f"/air/offers/{offer_id}")
    offer = response.get("data") or {}
    if not offer.get("id"):
        raise FlightProviderError("The selected fare could not be refreshed")
    return offer


def create_test_order(offer_id: str, passengers: list[dict], device_ip: str = "", user_agent: str = ""):
    status = provider_status()
    if status["mode"] != "test":
        raise FlightProviderError("Test order creation is disabled unless Duffel Test Mode is active")

    offer = get_offer(offer_id)
    offer_passengers = offer.get("passengers") or []
    if len(offer_passengers) != len(passengers):
        raise FlightProviderError("Passenger count no longer matches the selected fare. Please search again.")

    order_passengers = []
    for index, passenger in enumerate(passengers):
        offer_passenger_id = offer_passengers[index].get("id")
        if not offer_passenger_id:
            raise FlightProviderError("Duffel passenger reference is missing. Please search again.")
        order_passengers.append({
            "id": offer_passenger_id,
            "title": passenger["title"],
            "gender": passenger["gender"],
            "given_name": passenger["given_name"],
            "family_name": passenger["family_name"],
            "born_on": passenger["born_on"],
            "email": passenger["email"],
            "phone_number": passenger["phone_number"],
        })

    amount = str(offer.get("total_amount") or "")
    currency = str(offer.get("total_currency") or "")
    if not amount or not currency:
        raise FlightProviderError("The selected fare is missing its latest total price")

    payload = {
        "data": {
            "type": "instant",
            "selected_offers": [offer_id],
            "payments": [{
                "type": "balance",
                "currency": currency,
                "amount": amount,
            }],
            "passengers": order_passengers,
            "metadata": {
                "source": "travelflow_portal",
            },
        }
    }

    extra_headers = {}
    if device_ip:
        extra_headers["x-duffel-device-ip"] = device_ip
    if user_agent:
        extra_headers["x-duffel-device-user-agent"] = user_agent[:500]

    response = _duffel_post("/air/orders", payload, timeout=35, extra_headers=extra_headers)
    order = response.get("data") or {}
    if not order.get("id"):
        raise FlightProviderError("Duffel did not return a confirmed test order")

    payment_status = order.get("payment_status") or {}
    return {
        "offer": _offer_to_json(offer),
        "order": {
            "id": order.get("id") or "",
            "bookingReference": order.get("booking_reference") or "",
            "status": "Confirmed",
            "awaitingPayment": payment_status.get("awaiting_payment") is True,
            "totalAmount": float(order.get("total_amount") or amount),
            "totalCurrency": order.get("total_currency") or currency,
            "liveMode": bool(order.get("live_mode")),
            "documents": order.get("documents") or [],
            "availableActions": order.get("available_actions") or [],
        },
    }
