$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
$python = Get-ChildItem "$env:LOCALAPPDATA\Programs\Python" -Recurse -Filter python.exe -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notlike "*Scripts*" } | Select-Object -First 1 -ExpandProperty FullName
if (-not $python) { $python = (Get-Command python -ErrorAction SilentlyContinue).Source }
if (-not $python) { throw "Python was not found." }
if (-not (Test-Path ".venv\Scripts\python.exe")) { & $python -m venv .venv }
& ".venv\Scripts\python.exe" -m pip install -r requirements.txt
if (-not (Test-Path ".env")) { Copy-Item ".env.example" ".env" }
Write-Host "TravelFlow API: http://127.0.0.1:8000" -ForegroundColor Green
Write-Host "API docs:       http://127.0.0.1:8000/docs" -ForegroundColor Cyan
& ".venv\Scripts\python.exe" -m uvicorn app.main:app --host 0.0.0.0 --port 8000
