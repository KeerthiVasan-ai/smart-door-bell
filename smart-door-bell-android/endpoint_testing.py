import json
import requests

resp = requests.get("https://ntfy.sh/dummy-dharma/json", stream=True)
for line in resp.iter_lines():
  if line:
    print(json.loads(line))