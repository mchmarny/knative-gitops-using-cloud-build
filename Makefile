GCP_PROJECT_NAME=s9-demo

all: test

run:
	go run main.go

deps:
	go mod tidy

image:
	gcloud builds submit \
		--project=$(GCP_PROJECT_NAME) \
		--tag gcr.io/$(GCP_PROJECT_NAME)/$(BINARY_NAME) .

deploy:
	kubectl apply -f deployments/service.yaml

tag:
	export RELEASE_VERSION=0.1.3
	git tag "release-v${RELEASE_VERSION}"
	git push origin "release-v${RELEASE_VERSION}"