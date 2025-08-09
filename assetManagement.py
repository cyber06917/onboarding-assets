from dotenv import load_dotenv
import requests
import os


# Load environment variables from .env
load_dotenv()

panda_email = os.getenv("EMAIL")
panda_password = os.getenv("PASSWORD")
TOKEN_URL = os.getenv("ASSET_PANDA_TOKEN_URL")


payload = {
    "email": panda_email,
    "password": panda_password
}

if TOKEN_URL:
    response = requests.post(TOKEN_URL, data=payload)
    print(response.json())





