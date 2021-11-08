from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi_versioning import VersionedFastAPI  # type: ignore

from {{cookiecutter.project_name}}.constants import ALLOW_ORIGINS
from {{cookiecutter.project_name}}.routes.routers import ping, auth

app = FastAPI(
    title="{{cookiecutter.project_name}}",
    description="This a common service",
)

app.include_router(ping)
app.include_router(auth)

app = VersionedFastAPI(
    app,
    version_format="{major}",
    prefix_format="/api_v{major}",
    description="This is a common service",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOW_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
