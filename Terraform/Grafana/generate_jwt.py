import jwt
import sys
from jwt.algorithms import RSAAlgorithm
import time

with open(sys.argv[1], 'r') as f:
    private_key = f.read()

with open(sys.argv[2], 'r') as f:
    kid = f.read()


headers = {
    "alg": "RS256",
    "typ": "JWT",
    "kid": kid
}

payload = {
        "iss": "2006849458",
        "sub": "2006849458",
        "aud": "https://api.line.me/",
        "exp": int(time.time())+(60 * 30),
        "token_exp": 60 * 60 * 24 * 30
}

key = RSAAlgorithm.from_jwk(private_key)

JWT = jwt.encode(
        payload, key, algorithm="RS256", headers=headers, json_encoder=None
)

print(JWT)
