@echo off
echo === Xoa file cau hinh n8n cu ===
docker compose -f D:\Docker\n8n\n8n-ngrok\docker-compose.yml down
docker volume rm n8n-ngrok_n8n_data

echo === Khoi dong lai n8n ===
cd /d D:\Docker\n8n
call start-all.bat