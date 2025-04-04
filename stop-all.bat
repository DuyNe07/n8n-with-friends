@echo off
echo === Dung tat ca dich vu ===

cd /d D:\Docker\n8n\n8n-ngrok
echo === Dung n8n va ngrok ===
docker-compose down

cd /d D:\Docker\n8n\supabase
echo === Dung Supabase ===
docker-compose down

cd /d D:\Docker\n8n\redis
echo === Dung Redis ===
docker-compose down

echo === Tat ca dich vu da duoc dung lai ===
echo.
echo === Nhan phim bat ky de ket thuc ===
pause > nul