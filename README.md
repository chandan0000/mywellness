# MyWellness

Simple instructions to run the project locally and with Docker.

## Prerequisites

- Python 3.9+
- Docker & Docker Compose (optional)
- PostgreSQL (optional; Docker Compose provides one)

## Quick start (local)

1. Create and activate a virtual environment

```bash
python3 -m venv .venv
source .venv/bin/activate
```

1. Install dependencies

```bash
pip install -r requirements.txt
```

1. Create a `.env` file at the project root with the database URLs required by the app. The application expects these variables (see `app/core/config.py`):

```
DATABASE_ASYNC_URL=postgresql+asyncpg://<user>:<pass>@<host>:<port>/<db>
DATABASE_SYNC_URL=postgresql://<user>:<pass>@<host>:<port>/<db>
```

For a local Postgres instance called `mywellness` with user `postgres` and password `postgres` on the default port, example values are:

```
DATABASE_ASYNC_URL=postgresql+asyncpg://postgres:postgres@localhost:5432/mywellness
DATABASE_SYNC_URL=postgresql://postgres:postgres@localhost:5432/mywellness
```

> Note: `app/core/security.py` sets `SECRET_KEY = "your-secret-key"` in the code. For production replace that value or modify the file to load a secret from env if required.

1. Run the app with Uvicorn

```bash
uvicorn app.main:app --host 0.0.0.0 --port 9000 --reload
```

Or run the module (the file itself calls `uvicorn.run` when executed):

```bash
python -m app.main
```

Open <http://127.0.0.1:9000/> or the docs at <http://127.0.0.1:9000/docs>

## Docker (recommended for production-like environment)

The repository includes a `docker-compose.yml` that runs a Postgres DB and the app. By default `docker-compose.yml` sets an environment variable named `DATABASE_URL`. The app expects `DATABASE_ASYNC_URL` and `DATABASE_SYNC_URL` in `app/core/config.py`.

You can either update `docker-compose.yml` to pass both variables, or set `DATABASE_URL` in the compose file and modify `app/core/config.py` to read it. To run with the existing compose file (edit compose to match your needs):

```bash
docker-compose up --build
```

If you update the compose environment to use both variables, use these values for the `web` service:

```
DATABASE_ASYNC_URL=postgresql+asyncpg://postgres:postgres@db:5432/mywellness
DATABASE_SYNC_URL=postgresql://postgres:postgres@db:5432/mywellness
```

## Database

The application will create tables automatically on startup by calling `create_db_and_tables()`.

## Running tests

```bash
pytest -q
```

## Troubleshooting

- Database connection errors: verify `.env` variables match your DB and that the DB is reachable.
- Dependency issues: ensure the virtualenv is active (activate `.venv`) and `pip install -r requirements.txt` completed without errors.
- JWT / auth problems: `app/core/security.py` currently uses a hardcoded `SECRET_KEY`. Set a secure key for production.

## Useful commands

- Start local server: `uvicorn app.main:app --reload --port 9000`
- Run tests: `pytest`
- Build and run with Docker Compose: `docker-compose up --build`

---
If you want, I can:

- Update `docker-compose.yml` to set `DATABASE_ASYNC_URL` and `DATABASE_SYNC_URL` automatically.
- Load `SECRET_KEY` from `.env` and update `app/core/security.py`.
Which would you like next?
