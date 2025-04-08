@echo off
echo Start all services (Redis, PostgreSQL, n8n, ngrok)...
docker compose up -d --build

echo All services have been started.
echo You can access n8n at https://platypus-assuring-usually.ngrok-free.app
echo You can access Redis at http://localhost:8081
echo You can access PostgreSQL at http://localhost:5050
pause