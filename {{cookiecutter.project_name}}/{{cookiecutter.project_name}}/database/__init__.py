import os
from contextlib import contextmanager
from typing import Optional, Generator

from sqlalchemy import create_engine, engine
from sqlalchemy.orm import sessionmaker, Session as OrmSession

from {{cookiecutter.project_name}}.config import config

SQLALCHEMY_DATABASE_URL = os.getenv("DB_CONN")


class DatabaseConfig:

    def __init__(self, url=None, db_config=None):
        self.Session = None

        self.db_config = {
            "db_name": config.DB_NAME or "service-test",
            "user": config.DB_USER or "service-test",
            "password": config.DB_PASS or "service-test",
            "host": config.DB_HOST or "localhost",
            "port": config.DB_PORT or "5432",
        }

    @property
    def pg_url(self) -> str:
        """Return the PostgreSQL url to use with this service."""
        return engine.URL.create(
            drivername=f"postgresql+psycopg2",
            username=self.db_config["user"],
            password=self.db_config["password"],
            host=self.db_config["host"],
            port=self.db_config["port"],
            database=self.db_config["db_name"],
            query={
                "sslmode": "prefer",
                "target_session_attrs": "read-write",
            },
        )

    def get_engine(self, url: Optional[str] = None):
        url = url or self.pg_url
        return create_engine(url, pool_size=2, max_overflow=1)

    @property
    def db_engine(self):
        """Return the default engine."""
        return self.get_engine()

    def session(self) -> Generator[OrmSession, None, None]:
        """Provides a session."""
        if not self.Session:
            self.Session = sessionmaker(autocommit=False, autoflush=False, bind=self.db_engine)
        try:
            session = self.Session()
            yield session
        finally:
            session.close()

    @contextmanager
    def session_scope(self) -> Generator[OrmSession, None, None]:
        """Provides a session."""
        if not self.Session:
            self.Session = sessionmaker(autocommit=False, autoflush=False, bind=self.db_engine)
        try:
            session = self.Session()
            yield session
        finally:
            session.close()


db_config = DatabaseConfig()