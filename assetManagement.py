from dotenv import load_dotenv
import requests
import os
import json


# Load environment variables from .env
load_dotenv()

panda_email = os.getenv("EMAIL")
panda_password = os.getenv("PASSWORD")
TOKEN_URL = os.getenv("ASSET_PANDA_TOKEN_URL")
base_url = os.getenv("BASE_URL")


def get_session_token():
    token = None
    try:    
        payload = {
            "email": panda_email,
            "password": panda_password
        }

        if TOKEN_URL:
            response = requests.post(TOKEN_URL, data=payload)
            if response.status_code == 200:
                data = response.json()
                token = data["access_token"]
                return token
        else:
            return token
    except:
        return token     




def api_call():
   token = get_session_token()     
   group_id = ""
   if token:
        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",   
            }   
        url = f"{base_url}groups/{group_id}/fields"
        response = requests.get(url, headers=headers)

        if response.status_code == 200:
            print(json.dumps(response.json(), indent=4))
        else:
            raise Exception(f"API request failed: {response.status_code}, {response.text}")
        

if __name__ == "__main__":
    api_call()










