from sqlalchemy import Column, Integer, String

from {{cookiecutter.project_name}}.database.models.base import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, index=True)
    password = Column(String)
    email = Column(String)
    first_name = Column(String)
    last_name = Column(String)
    age = Column(Integer)
