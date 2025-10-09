#!/usr/bin/env python

import os
import pathlib
import httplib2
import webbrowser
from oauth2client import client, file

SCOPE = 'https://www.googleapis.com/auth/gmail.labels'
REDIRECT_URI = 'urn:ietf:wg:oauth:2.0:oob'
DIR = os.path.dirname(os.path.realpath(__file__))
CLIENT_SECRETS_PATH = os.path.join(DIR, 'client_secret.json')
CREDENTIALS_PATH = os.path.join(DIR, 'credentials.json')
storage = file.Storage(CREDENTIALS_PATH)

if pathlib.Path(CREDENTIALS_PATH).is_file():
    credentials = storage.get()
    if isinstance(credentials, client.OAuth2Credentials):
        try:
            credentials.refresh(httplib2.Http())
            print('Credentials successfully refreshed')
        except client.HttpAccessTokenRefreshError:
            print('Expired or revoked credentials. Try to remove credentials.json')
    else:
        print('credentials.json has wrong format, try to remove it')
else:
    flow = client.flow_from_clientsecrets(CLIENT_SECRETS_PATH, scope=SCOPE, redirect_uri=REDIRECT_URI)
    auth_uri = flow.step1_get_authorize_url()
    webbrowser.open(auth_uri)
    auth_code = input('Enter the auth code: ')
    credentials = flow.step2_exchange(auth_code)
    storage.put(credentials)
    print('Credentials successfully created')
