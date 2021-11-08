from azure.cognitiveservices.language.luis.authoring import LUISAuthoringClient
from msrest.authentication import CognitiveServicesCredentials

from microservice.constants import AUTHORING_KEY, AUTHORING_ENDPOINT

client_authoring = LUISAuthoringClient(
    AUTHORING_ENDPOINT, CognitiveServicesCredentials(AUTHORING_KEY),
)

print("\nList all apps")

for app in client_authoring.apps.list():
    print(f"\t->App: {app.name}\tId(PREDICTION_KEY): {app.id}")

print("\ndone")
