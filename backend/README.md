# ClawHand Backend

FastAPI-based backend service for ClawHand iOS app.

## Tech Stack

- **Framework**: FastAPI
- **Database**: PostgreSQL (async SQLAlchemy + asyncpg)
- **Message Queue**: RabbitMQ (aio-pika)
- **ORM**: SQLAlchemy 2.0 (async)
- **Validation**: Pydantic v2
- **Deployment**: Docker + Docker Compose

## Project Structure

```
backend/
├── app/
│   ├── api/           # API routes
│   │   ├── health.py
│   │   ├── users.py
│   │   └── messages.py
│   ├── db/
│   │   ├── models/    # SQLAlchemy models
│   │   │   ├── user.py
│   │   │   └── message.py
│   │   └── session.py # Database session & engine
│   ├── services/      # Business logic (RabbitMQ, etc.)
│   ├── config.py      # Settings (Pydantic Settings)
│   └── main.py        # Application entry point
├── docker/            # Docker configuration
├── docker-compose.yml
├── Dockerfile
├── requirements.txt
├── .env.example
└── README.md
```

## Quick Start

### Local Development

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Copy environment file
cp .env.example .env

# Run development server
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Docker Compose (Recommended)

```bash
# Build and run all services
docker-compose up -d

# View logs
docker-compose logs -f app

# Stop all services
docker-compose down
```

## Services

| Service | Port | Description |
|---------|------|-------------|
| App | 8000 | FastAPI application |
| PostgreSQL | 5432 | Database |
| RabbitMQ | 5672 | Message queue |
| RabbitMQ Management | 15672 | RabbitMQ admin UI |
| Redis | 6379 | Cache (optional) |

## API Documentation

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## Endpoints

### Health
- `GET /api/v1/health/` - Health check

### Users
- `POST /api/v1/users/` - Create user
- `GET /api/v1/users/{user_id}` - Get user by ID

### Messages
- `POST /api/v1/messages/` - Send message
- `GET /api/v1/messages/user/{user_id}` - Get user's messages

## Environment Variables

See `.env.example` for all configuration options.
