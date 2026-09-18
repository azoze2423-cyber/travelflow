# TravelFlow Backend V2

## التشغيل المحلي
من PowerShell داخل مجلد backend:

```powershell
powershell -ExecutionPolicy Bypass -File .\run_backend.ps1
```

ثم افتح `http://127.0.0.1:8000/docs` للتأكد من أن الـ API يعمل.

الدخول الافتراضي لأول تشغيل:
- admin@travelflow.ae
- admin123

غيّر كلمة المرور وSECRET_KEY قبل الإنتاج.

## الإنتاج
- استخدم PostgreSQL عبر `DATABASE_URL`.
- غيّر `SECRET_KEY` إلى قيمة طويلة عشوائية.
- اضبط `ALLOWED_ORIGINS` على نطاق واجهة Flutter فقط بدل `*`.
- شغّل خلف HTTPS عبر منصة استضافة أو reverse proxy.
