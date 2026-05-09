#!/usr/bin/env python

# deps: google-auth-oauthlib google-auth-httplib2 google-api-python-client

import os
from google_auth_oauthlib.flow import InstalledAppFlow
import pickle

# Важно: Scope должен совпадать с тем, что в твоем основном скрипте
SCOPES = ['https://www.googleapis.com/auth/gmail.labels']
DIR = os.path.dirname(os.path.realpath(__file__))
CLIENT_SECRET_FILE = os.path.join(DIR, 'client_secret.json') # Новый файл (Desktop App)
TOKEN_FILE = os.path.join(DIR, 'credentials.json')

flow = InstalledAppFlow.from_client_secrets_file(CLIENT_SECRET_FILE, SCOPES)
# Это само откроет браузер на localhost
creds = flow.run_local_server(port=0)

# Сохраняем токен
with open(TOKEN_FILE, 'wb') as token:
    pickle.dump(creds, token)

print("Готово! Токен сохранен в credentials.json")