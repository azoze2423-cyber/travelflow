import os
from pathlib import Path
from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent.parent
load_dotenv(BASE_DIR / ".env")

class Settings:
    secret_key = os.getenv("SECRET_KEY", "dev-change-this-secret-before-production")
    database_url = os.getenv("DATABASE_URL", f"sqlite:///{(BASE_DIR / 'data' / 'travelflow.db').as_posix()}")
    access_token_minutes = int(os.getenv("ACCESS_TOKEN_MINUTES", "720"))
    allowed_origins = [x.strip() for x in os.getenv("ALLOWED_ORIGINS", "*").split(",") if x.strip()]
    admin_email = os.getenv("ADMIN_EMAIL", "admin@travelflow.ae")
    admin_password = os.getenv("ADMIN_PASSWORD", "admin123")
    agency_name = os.getenv("AGENCY_NAME", "TravelFlow Agency")
    currency = os.getenv("CURRENCY", "AED")
    seed_demo = os.getenv("SEED_DEMO", "true").lower() in {"1", "true", "yes", "on"}
    duffel_access_token = os.getenv("DUFFEL_ACCESS_TOKEN", "").strip()

settings = Settings()
