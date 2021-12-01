# Flexible Environment Terraform Experiment

In the experiment single-multi-env-tf, we've been working to remove hard-coding environments from Terraform to provide more flexibility to how it's used.

Unfortunately, the current path there has gone too far. While we have the functionality coming together to provision one or multiple environments, we don't have the ability to put in place a change management process for later updates.

## Example

### Case 1: New App Infra, ship Stage & Prod

terraform apply => Changes are shipped to prod without any QA

### Case 2: New App Infra, ship Stage then Prod, single state backend

1. terraform apply stage => ops+stage provisioned & state updated
2. terraform apply stage+prod => ops+stage unchanged. prod provisioned & state updated. Be alert for drift risk to stage.
3. terraform apply stage => prod destroyed

### Case 3: New App Infra, ship Stage then Prod, separate state backends

1. terraform init --backend-config path="./stage"; terraform apply stage => ops+stage provisioned & state updated
2. terraform init --backend-config path="./prod"; terraform apply stage+prod => stage state is inaccessible

## Path Forward

My proposed fix is something previously discussed that we discarded as potentially too complicated. Here's how it would go:

terraform apply ops (with dedicated state)
terraform apply <env> (with dedicated <env> state, touching both ops + <env> projects)

In setup.sh, we would run terraform apply once, +1 per environment we want to provision.

State would ultimately be persisted in a bucket called `<ops project>-terraform-state`, with a prefix inside that bucket of `<emblem-ops-project>` for ops and `emblem-<env>` for each app environment.

As a result, we'll be able to do something like the following:

terraform init \
  -backend-config='bucket=emblem-ops-terraform-state' \
  -backend-config='prefix=emblem-stage'
terraform destroy \
  -var project=emblem-stage-pancakes \
  -var ops_project=emblem-ops-pancakes

This will initialize the current terraform workspace to use the Cloud Storage Bucket & object for the stage environment, then use that to remove all resources managed for stage from the pancakes projects.

## Friction Encountered

### Trying to import an App Engine app

```sh
terraform import module.application.google_app_engine_application.main  apps/emblem-stage-adamross6
```

will timeout with the error

```txt
│ Error: Error when reading or editing App Engine Application "apps/emblem-stage-adamross6": googleapi: Error 500: Internal error encountered., backendError
```

Checking the docs, I'm not supposed to use the full resource name of `apps/<project>`, only `<project>`