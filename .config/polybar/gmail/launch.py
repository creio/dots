#!/usr/bin/env python
# deps: google-auth google-auth-oauthlib google-api-python-client

import os
import pathlib
import subprocess
import time
import argparse
import pickle
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from google.auth.transport.requests import Request

parser = argparse.ArgumentParser()
parser.add_argument('-l', '--label', default='INBOX')
parser.add_argument('-p', '--prefix', default='\uf0e0')
parser.add_argument('-c', '--color', default='#bb9af7')
parser.add_argument('-ns', '--nosound', action='store_true')
args = parser.parse_args()

DIR = os.path.dirname(os.path.realpath(__file__))
CREDENTIALS_PATH = os.path.join(DIR, 'credentials.json')

unread_prefix = f'%{{F{args.color}}}{args.prefix} %{{F-}}'
error_prefix = f'%{{F{args.color}}}\uf06a %{{F-}}'

def get_gmail_service():
    if not os.path.exists(CREDENTIALS_PATH):
        return None

    with open(CREDENTIALS_PATH, 'rb') as token:
        creds = pickle.load(token)

    # Автоматическое обновление токена, если он протух
    if creds and creds.expired and creds.refresh_token:
        creds.refresh(Request())
        with open(CREDENTIALS_PATH, 'wb') as token:
            pickle.dump(creds, token)

    return build('gmail', 'v1', credentials=creds, cache_discovery=False)

def print_count(count, is_odd=False):
    tilde = '~' if is_odd else ''
    if count > 0:
        output = f"{unread_prefix}{tilde}{count}"
    else:
        output = f"{args.prefix} {tilde}".strip()
    print(output, flush=True)

count_was = 0
service = None

print_count(0, True)

while True:
    try:
        if service is None:
            service = get_gmail_service()

        if service:
            results = service.users().labels().get(userId='me', id=args.label).execute()
            count = results.get('messagesUnread', 0)
            print_count(count)

            if not args.nosound and count_was < count and count > 0:
                subprocess.run(['canberra-gtk-play', '-i', 'message'])
            count_was = count
        else:
            print(f"{error_prefix}auth error", flush=True)

        time.sleep(10)

    except HttpError as error:
        if error.resp.status == 404:
            print(f"{error_prefix}label not found", flush=True)
        elif error.resp.status in [401, 403]:
            service = None # Сброс сервиса для переавторизации
        time.sleep(5)
    except Exception as e:
        # Для отладки можно раскомментировать:
        # print(f"Error: {e}", flush=True)
        print_count(count_was, True)
        time.sleep(5)