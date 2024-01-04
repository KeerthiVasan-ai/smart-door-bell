import requests
import Utils

def request(message):
    requests.post(Utils.SENDER_API,data=message.encode(encoding='utf-8'))