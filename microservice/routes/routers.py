from fastapi import APIRouter

ping = APIRouter(
    prefix="/ping",
)

auth = APIRouter(
    prefix="/auth",
)
