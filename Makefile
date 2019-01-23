GCP_PROJECT_NAME=s9-demo
RELEASE_VERSION=0.1.18

all: test

run:
	go run main.go

deps:
	go mod tidy

policy:
	PROJECT_NUMBER="$(gcloud projects describe ${PROJECT_ID} --format='get(projectNumber)')"
	gcloud projects add-iam-policy-binding ${PROJECT_NUMBER} \
    	--member=serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com \
    	--role=roles/container.developer

image:
	gcloud builds submit \
		--project=$(GCP_PROJECT_NAME) \
		--tag gcr.io/$(GCP_PROJECT_NAME)/$(BINARY_NAME) .

deploy:
	kubectl apply -f deployments/service.yaml

tag:
	git tag "release-v${RELEASE_VERSION}"
	git push origin "release-v${RELEASE_VERSION}"
	git log --oneline