# Managing the application via a central "Ops" project

* **Status:** approved 
* **Last Updated:** YYYY-MM-DD
* **Builds on:** [Short Title](2021-05-15-short-title.md)
* **Objective:** [description or link to contextual issue]

## Context & Problem Statement

We need a project to run tests, build images, store images, and orchestrate pipelines. 

## Priorities & Constraints

* We should avoid having separate copies of an image for prod and staging environments

## Considered Options

### Manage staging and prod separately

In this approach, staging and prod are completely separate.  They have their own copies of the container images and their own orchestration pipelines.  

The benefit here is that prod is completely isolated from all development and staging efforts.  There is no chance of cross-project leakage.  

However, this makes it necessary to build the image twice.  Promoting from staging to prod would therefore carry significant risk.  

Additionally, there is the added complexity of having to use two projects to check the pipeline progress.  This reduces discoverability and generally makes debugging and traiging issues more difficult.  

Lastly, you have to connect both projects to your GitHub account to read from the repo.

### Maintain an independent "Ops" project to manage all the resources

In this approach, the "Ops" project serves as a central resource for managing both prod and staging.  The images are built and stored in this project and shared with the other environments. Additionally, the pipelines are managed in the same spot and you can watch the progress of the application rollout from staging to prod altogether.   

This also means that only one project has to connect to the GitHub repo, reducing the number of steps for setting up the project. 

## Decision

We have chosen the Ops managed approach, primarily to reduce the risk of having separate copies of the container image in prod and staging. We want to be absolutely sure that the image tested in staging is the one deployed to production.  

The additional benefits of easier pipeline management and connecting fewer projects to GitHub are icing on the cake.  


## Links

* Related PRs
* Related User Journeys
