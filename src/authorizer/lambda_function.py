import os
import jwt
import requests
from jwt import decode
import json
from jwt.algorithms import RSAAlgorithm
from cryptography.hazmat.primitives import serialization
import re
# Section 1: base setup and token validation helper function
is_cold_start = True
keys = {}
user_pool_id = os.environ.get('USER_POOL_ID') or 'us-east-1_biacoZpbM'
app_client_id = os.environ.get(
    'APPLICATION_CLIENT_ID') or '431d1c2042d2hpvca1ls28un5m'
admin_group_name = os.environ.get('ADMIN_GROUP_NAME') or 'dev_AdminGroupName'


def validate_token(token, region):
    # KEYS URL -- REPLACE WHEN CHANGING IDENTITY PROVIDER
    keys_url = f'https://cognito-idp.{region}.amazonaws.com/{user_pool_id}/.well-known/jwks.json'

    global is_cold_start, keys
    if is_cold_start:
        response = requests.get(keys_url)
        keys = response.json().get('keys')

    header = jwt.get_unverified_header(token)
    kid_from_token = header["kid"]
    public_key = None

    for key in keys:
        if key['kid'] == kid_from_token:
            public_key = key

    pem = jwt.algorithms.RSAAlgorithm.from_jwk(json.dumps(public_key))

    # Convertendo a chave PEM em uma string
    pem_str = pem.public_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PublicFormat.SubjectPublicKeyInfo
    ).decode()
    try:
        decoded_jwt = jwt.decode(token,
                                 pem_str,
                                 algorithms=["RS256"],
                                 options={'verify_signature': True,
                                          'verify_exp': True},
                                 audience=app_client_id)
    except:
        print("Token Invalido")
        return False

    print(decoded_jwt)

    print("Signature successfully verified")
    return decoded_jwt


def lambda_handler(event, context):
    print("#start lambda handler")
    print('#event received')
    print(event)
    tmp = event["methodArn"].split(':')
    api_gateway_arn_tmp = tmp[5].split('/')
    region = tmp[3]
    aws_account_id = tmp[4]

    # validate the incoming token
    validated_decoded_token = validate_token(
        event["authorizationToken"], region)

    # initialize the policy
    if validated_decoded_token:
        principal_id = validated_decoded_token['sub']
        policy = AuthPolicy(principal_id, aws_account_id)
        policy.rest_api_id = api_gateway_arn_tmp[0]
        policy.region = region
        policy.stage = api_gateway_arn_tmp[1]

    if not validated_decoded_token:
        policy = AuthPolicy('', aws_account_id)
        policy.deny_all_methods()
        auth_response = policy.build()
        return auth_response

    # Section 2: authorization rules
    # Allow all public resources/methods explicitly
    policy.allow_method(HttpVerb.GET, f"/users/{principal_id}")
    policy.allow_method(HttpVerb.PUT, f"/users/{principal_id}")
    policy.allow_method(HttpVerb.DELETE, f"/users/{principal_id}")
    policy.allow_method(HttpVerb.GET, f"/users/{principal_id}/*")
    policy.allow_method(HttpVerb.PUT, f"/users/{principal_id}/*")
    policy.allow_method(HttpVerb.DELETE, f"/users/{principal_id}/*")

    # Look for admin group in Cognito groups
    # Assumption: admin group always has higher precedence
    print('validateddecoded: ', validated_decoded_token)
    if "cognito:groups" in validated_decoded_token and validated_decoded_token['cognito:groups'][0] == admin_group_name:
        # add administrative privileges
        policy.allow_method(HttpVerb.GET, "users")
        policy.allow_method(HttpVerb.GET, "users/*")
        policy.allow_method(HttpVerb.DELETE, "users")
        policy.allow_method(HttpVerb.DELETE, "users/*")
        policy.allow_method(HttpVerb.PUT, "users")
        policy.allow_method(HttpVerb.PUT, "users/*")

    # Finally, build the policy
    auth_response = policy.build()
    return auth_response


class HttpVerb:
    GET = 'GET'
    POST = 'POST'
    PUT = 'PUT'
    PATCH = 'PATCH'
    HEAD = 'HEAD'
    DELETE = 'DELETE'
    OPTIONS = 'OPTIONS'
    ALL = '*'


class AuthPolicy:
    def __init__(self, principal, aws_account_id):
        self.aws_account_id = aws_account_id
        self.principal_id = principal
        self.allow_methods = []
        self.deny_methods = []
        self.path_regex = '^[/.a-zA-Z0-9-\*]+$'
        self.rest_api_id = '<<restApiId>>'
        self.region = '<<region>>'
        self.stage = '<<stage>>'

    def add_method(self, effect, verb, resource: str, conditions):
        if verb != '*' and verb not in HttpVerb.__dict__.values():
            raise ValueError(
                f"Invalid HTTP verb '{verb}'. Allowed verbs in HttpVerb class")
        if not re.match(self.path_regex, resource):
            raise ValueError(
                f'Invalid resource path: {resource}. Path should match {self.path_regex}')
        if resource.startswith('/'):
            resource = resource[1:]
        resource_arn = f'arn:aws:execute-api:{self.region}:{self.aws_account_id}:{self.rest_api_id}/{self.stage}/{verb}/{resource}'
        if effect.lower() == 'allow':
            self.allow_methods.append(
                {'resource_arn': resource_arn, 'conditions': conditions})
        elif effect.lower() == 'deny':
            self.deny_methods.append(
                {'resource_arn': resource_arn, 'conditions': conditions})

    def get_empty_statement(self, effect):
        statement = {'Action': 'execute-api:Invoke',
                     'Effect': effect[0].upper() + effect[1:].lower(), 'Resource': []}
        return statement

    def get_statement_for_effect(self, effect, methods):
        statements = []
        for method in methods:
            statement = self.get_empty_statement(effect)
            statement['Resource'].append(method['resource_arn'])
            if method['conditions'] is not None and len(method['conditions']) > 0:
                statement['Condition'] = method['conditions']
            statements.append(statement)
        return statements

    def allow_all_methods(self):
        self.add_method('Allow', HttpVerb.ALL, '*', [])

    def deny_all_methods(self):
        self.add_method('Deny', HttpVerb.ALL, '*', [])

    def allow_method(self, verb, resource):
        self.add_method('Allow', verb, resource, [])

    def deny_method(self, verb, resource):
        self.add_method('Deny', verb, resource, [])

    def allow_method_with_conditions(self, verb, resource, conditions):
        pass

    def deny_method_with_conditions(self, verb, resource, conditions):
        pass

    def build(self):
        if not self.allow_methods and not self.deny_methods:
            raise ValueError('No statements defined for the policy')
        policy = {'principalId': self.principal_id, 'policyDocument': {
            'Version': '2012-10-17', 'Statement': []}}
        allow_methods_statement = self.get_statement_for_effect(
            'Allow', self.allow_methods)
        deny_methods_statement = self.get_statement_for_effect(
            'Deny', self.deny_methods)
        all_methods_statement = allow_methods_statement + deny_methods_statement
        if all_methods_statement:
            policy['policyDocument']['Statement'] = all_methods_statement

        print(policy)  # opcional: apenas para depuração
        return policy


if (__name__ == "__main__"):
    lambda_handler({'type': 'TOKEN',
                    'methodArn': 'arn:aws:execute-api:us-east-1:767398079178:wiz9wyxlfg/ESTestInvoke-stage/GET/',
                    'authorizationToken': 'eyJraWQiOiJIZ1hBOEpPZ05ObVUwcXh1Rm9Ec0ZxUDlHUlRtNzNEYXRiQ3p4blZ0dEJFPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI1NGM4MzQwOC1iMDUxLTcwMTAtMTE1MS1iNTlkZWZkOGEwYjUiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLnVzLWVhc3QtMS5hbWF6b25hd3MuY29tXC91cy1lYXN0LTFfYmlhY29acGJNIiwiY29nbml0bzp1c2VybmFtZSI6IjU0YzgzNDA4LWIwNTEtNzAxMC0xMTUxLWI1OWRlZmQ4YTBiNSIsIm9yaWdpbl9qdGkiOiIwYzA4MGEyOC1hN2YyLTRmZjMtOTUwMS03NDM4ZmZmMGI1NzkiLCJhdWQiOiI0MzFkMWMyMDQyZDJocHZjYTFsczI4dW41bSIsImV2ZW50X2lkIjoiNTQ1M2YxMmYtODMyZC00MmViLWIwMjAtMDQ3YzMwYjExZjIyIiwidG9rZW5fdXNlIjoiaWQiLCJhdXRoX3RpbWUiOjE3MTQwNzgwMzcsIm5hbWUiOiJWaWN0b3IgQ2FydmFsaG8iLCJleHAiOjE3MTQwODE2MzYsImlhdCI6MTcxNDA3ODAzNywianRpIjoiMDE5ZDI3ZWItOWNhOS00ZjNkLWFiZTgtYjkzNzExNzNmMmZjIiwiZW1haWwiOiJ2aWN0b3Iub2N2QGhvdG1haWwuY29tIn0.VLBc5CeeXH6-YFD-yPNaTYNUoUV4bEhk0Y43E1tgEoG4v8Z_jH2S6fmuMBRvp2_Xf6Ex3ulUW5ZXj9hFVxgce7rucEkSPN7T0AaUHAHXt4zylNF0ZALq5gS4kPnYo7XVKRbe2VRzhBb1Ydi4ZyqnVB1YZx5n3PhItbsZCprb-zmIH07ePottEGERBkG9PneDTbaIok_JbKtLgewt4rvsOHnDlRTlc3v8k3-1lkW_QKg5mVotz8uTHIKKzACIzqYEoN5jGdcB2GTen4iomOjeBmdfhcRWjTy7vQPkFYAE2m2ddurx582ovFXuzzFpRibjq4Xxb_63Ls7ex-ldGOIG9w'}, None)
