Write-Host "Starting AI Wellness System..." -ForegroundColor Green

Write-Host "`n[1/2] Starting Backend Server on port 8082..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Set-Location '$(Get-Location)'; python -m uvicorn backend.main:app --host 0.0.0.0 --port 8082 --reload" -WindowStyle Normal

Start-Sleep -Seconds 5

Write-Host "`n[2/2] Starting Flutter Web App on port 3002..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Set-Location '$(Get-Location)'; flutter run -d chrome --web-port 3002" -WindowStyle Normal

Write-Host "`nSetup complete! The application will be available at:" -ForegroundColor Green
Write-Host "Backend API: http://localhost:8082" -ForegroundColor Cyan
Write-Host "Frontend App: http://localhost:3002" -ForegroundColor Cyan
Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")