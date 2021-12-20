# knative-gitops-using-cloud-build

> GitOps demo using Cloud Build and Knative

Live demo: https://gocr.demo.knative.tech/

Simple setup to automate Knative deployments using Git and Cloud Build

As a developer, you write code and commit it to a repo. You also hopefully run tests on that code for each commit. Assuming your application passes all the tests, you may want to deploy it to Knative cluster. You can do it form your workstation by using any one of the Knative CLIs (e.g. gcloud, knctl, tm etc.).

In this demo however we are going to demonstrate deploying directly from git repository. This means that you as a developer do not need install anything on your machine other than the standard git tooling. Here is the outline:

* Create a release tag on the commit you want to deploy in git
* Cloud Build then:
  * Tests (again)
  * Builds and tags image
  * Pushes that image to repository
  * Creates Knative service manifest
  * Applies that manifest to designated Knative cluster

> As an add-on, we are also going to send mobile notification with build status using [knative-build-status-notifs](https://github.com/mchmarny/knative-build-status-notifs)

## Setup

You will have to [configure git trigger](https://console.cloud.google.com/cloud-build/triggers/add) in Cloud Build first. There doesn't seem to be a way to do this using `gcloud`.

![kpush flow](static/img/src.png)

Then setup IAM policy binding to allow Cloud Builder deploy build image to your cluster

```shell
PROJECT_NUMBER="$(gcloud projects describe ${PROJECT_ID} --format='get(projectNumber)')"
gcloud projects add-iam-policy-binding ${PROJECT_NUMBER} \
    --member=serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com \
    --role=roles/container.developer
```

Finally submit the Cloud Build configuration

```shell
gcloud builds submit --config deployments/cloudbuild.yaml
```

![kpush flow](static/img/trigger.png)

## Deployment

To build and deploy specific commit from git, tag it and publish the tags. We also are going to print the last few tags so we can see the exact commit hash.

```shell
git tag "release-v${RELEASE_VERSION}"
git push origin "release-v${RELEASE_VERSION}"
git log --oneline
```

## Logs

You can monitor progress of your build but first finding its id

```shell
gcloud builds list
```

And then describing it

```shell
gcloud builds describe BUILD_ID
```

You can always also navigate to the [Build History](https://console.cloud.google.com/cloud-build/builds) screen in UI and see it there.

