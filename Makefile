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