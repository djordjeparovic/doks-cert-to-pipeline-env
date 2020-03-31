default: build

build:
	docker build \
		-t doks-cert-to-bitbucket-env:latest \
		-f ./Dockerfile \
		./
