@echo off
echo === Khoi dong network n8n-network ===
docker network create n8n-network 2>nul

cd /d D:\Docker\n8n\redis
echo === Khoi dong Redis ===
docker-compose up -d

cd /d D:\Docker\n8n\supabase
echo === Khoi dong Supabase ===
docker-compose up -d

cd /d D:\Docker\n8n\n8n-ngrok
echo === Khoi dong n8n va ngrok ===
docker-compose up -d

echo === Tat ca dich vu da duoc khoi dong ===
echo === Truy cap n8n: http://localhost:5678 ===
echo === Truy cap Supabase Studio: http://localhost:3000 ===
echo === Truy cap Supabase API: http://localhost:8000 ===
echo === Truy cap n8n qua ngrok: https://select-regularly-emu.ngrok-free.app ===
echo.
echo === Nhan phim bat ky de ket thuc ===
pause > nul