Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  Starting BugTrack Pro (Vite, Express and Python AI)" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Freeing ports 5173, 3000, 5000 if previously occupied..." -ForegroundColor Yellow
Get-NetTCPConnection -LocalPort 5173, 3000, 5000 -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue }
Write-Host "Ports are clean." -ForegroundColor Green
Write-Host ""
Write-Host "  1. Frontend: http://localhost:5173" -ForegroundColor Green
Write-Host "  2. Backend:  http://localhost:3000" -ForegroundColor Green
Write-Host "  3. Analyzer: http://127.0.0.1:5000" -ForegroundColor Green
Write-Host ""
Write-Host "  NOTE: Keep this window OPEN while using the app!" -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""
npm run dev
