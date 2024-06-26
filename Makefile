
AuthorizerPath = ./src/authorizer

generate-authorizer-package:
	rm -r $(AuthorizerPath)/package.zip
	pip install -r $(AuthorizerPath)/requirements.txt --target=$(AuthorizerPath)/package \
	--platform manylinux2014_x86_64 --only-binary=:all: --upgrade
	cd $(AuthorizerPath)/package && zip -r ../package.zip .
	cd $(AuthorizerPath) && zip package.zip ./lambda_function.py
	rm -r $(AuthorizerPath)/package


generate-cognito-token:
	mkdir tmp
	aws cognito-idp initiate-auth --auth-flow USER_PASSWORD_AUTH \
	--client-id $(cli) --region us-east-1 --auth-parameters \
	USERNAME=admin-noreply@testadmin.com,PASSWORD=admin@123M > ./tmp/token.json

.PHONY: generate-cognito-token



# REQUESTS

http-post:
	curl --location "$(url)" \
	--request POST \
	--header 'Content-Type: application/json' \
	--header 'Authorization: $(token)' \
	--data '{"name": "User Test", "content": "navigator", "endereços": "tellme", "telefone": 123456}'



.PHONY: http-post
