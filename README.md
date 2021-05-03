
# GitOps for Delivery of Multiple Apps

This is a reference for how GitOps can be used for the delivery of multiple apps into multiple Kubernetes environments.

The main benefit of this approach is to refocus the pipeline around the data structures of what is to be deployed, making the delivery more observable, and allowing different actors to see and collaborate on the delivery process.

Container images for these apps are built with [Cloud Native Buildpacks](https://buildpacks.io/) in [Tanzu Build Service](https://tanzu.vmware.com/build-service) to enable automatic patching via [image rebasing](https://buildpacks.io/docs/concepts/operations/rebase/). You can see how this is done in the [example Angular repo](https://github.com/benjvi/angular-realworld-example-app/tree/buildpacks)/

# Overview

![overview](https://github.com/benjvi/apps-gitops/raw/main/docs/apps-gitops-overview.png)

The system is made up of three repos. The two app repos are primarily concerned with the purpose of developing the apps, while this repo is concerned with managing their deployment, via Kubernetes manifests. Items responsible for the delivery of the software (the "pipeline") are highlighted in green, whilst the content of what is to be deployed is left uncoloured. At the bottom, its roughly shown how the structure of this repo maps to the structure where the apps are running, in Kubernetes.

## App Repos

There are two separate apps that feed into this repo:
- [An example Angular app](https://github.com/benjvi/angular-realworld-example-app/tree/buildpacks)
- [An example Spring Boot app](https://github.com/benjvi/minimal-spring-web-demo)

Each repo contains its own "CI" pipeline, running once code has been integrated into the main branch. These are defined to run on Jenkins, with Jenkinsfiles:
- [Angular pipeline](https://github.com/benjvi/angular-realworld-example-app/blob/buildpacks/Jenkinsfile)
- [Spring pipeline (incomplete)](https://github.com/benjvi/minimal-spring-web-demo/blob/main/Jenkinsfile)

As the Angular example shows, a Kubernetes package is customized before the Kubernetes manifests are directly pushed to the main branch of this repo, in the corresponding nonprod folder (this is according to the strategy set in the directory by the [config file](https://github.com/benjvi/apps-gitops/blob/main/nonprod-cluster/prify.yml) for [PRify](https://github.com/benjvi/PRify)).

In this way, the app repos control everything in the development flow until the app is ready for a 'real' deployment, then it hands over control to this GitOps repo.

## Deployment

This repo contains Kubernetes manifests used in two Kubernetes environments ("nonprod" and "prod") for each app. The manifests are duplicated so that we can clearly capture the desired state for each environment. An ArgoCD "Application" is created for each app/environment combination, which continuously updates the running app with any changes made to the manifests here. 

So, for example, whenever code changes are made to either app:

1. the docker image will be rebuilt
2. the manifests in this repo will be updated with the new image version
3. ArgoCD will then cause the running apps in the nonprod envionment to be updated with the new image.

## Promotion

In the real world, based on that deployment, some automated E2E tests or other validation would be run on the non-prod environment. After that, the application may be deployed to production. Here, we skip the tests and simple define [a workflow](https://github.com/benjvi/apps-gitops/blob/main/.github/workflows/promote-to-prod.yml) that runs after changes to non-prod, and creates PRs to this repo for the deployment of any changed apps (again, this behaviour is governed by [the PRify config](https://github.com/benjvi/apps-gitops/blob/main/prod-cluster/prify.yml). Once the changes are merged, ArgoCD will once again deploy the changes, this time to Production.
