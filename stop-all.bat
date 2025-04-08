@echo off
echo Stop all services (n8n, ngrok, Redis, PostgreSQL)...
docker compose down

echo All services have been stopped.
pause