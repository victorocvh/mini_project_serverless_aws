
AuthorizerPath = ./src/authorizer

generate-authorizer-package:
	rm -r $(AuthorizerPath)/package.zip
	pip install -r $(AuthorizerPath)/requirements.txt --target=$(AuthorizerPath)/package \
	--platform manylinux2014_x86_64 --only-binary=:all: --upgrade
	cd $(AuthorizerPath)/package && zip -r ../package.zip .
	cd $(AuthorizerPath) && zip package.zip ./lambda_function.py
	rm -r $(AuthorizerPath)/package
