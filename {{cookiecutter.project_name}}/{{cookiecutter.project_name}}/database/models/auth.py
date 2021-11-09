from sqlalchemy import Column, Integer, String

from {{cookiecutter.project_name}}.database.models.base import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String, default="")
    username = Column(String, index=True, nullable=False)
    password = Column(String, nullable=False)
    email = Column(String, nullable=True)
    age = Column(Integer, nullable=True)
    disabled = Column(Boolean, default=False)
