# Flexible Environment Terraform Experiment

Split into two root modules: one for ops and one for app. The Ops root module knows nothing about specific environments. The app module touches some spanning ops resources. Terraform backend configuration is used when interacting with the app module to swap the environment.

In setup.sh, we would run terraform apply once, +1 per environment we want to provision.

## Usage Example

```sh
pushd ops
terraform init
terraform apply
popd

push app
terraform init --backend-config=stage.tfstate
terraform apply
terraform init --backend-config=prod.tfstate
terraform apply
popd
```

## Idea: Aggregator Root Module

The [aggregator](./aggregator) root module is a notion I prototyped into this experiment, the idea that it could assemble state from across environments into a single, easily accessed output structure.

I think this should be avoided, but if we find we need to assemble data from everywhere it will likely simplify scripting.

## Cloud Storage Backend

In order to wrap terraform into a CD process, state will be persisted in a bucket called `<ops project>-terraform-state`, with a prefix inside that bucket of `<emblem-ops-project>` for ops and `emblem-<env>` for each app environment.

```sh
terraform init \
  -backend-config='bucket=emblem-ops-terraform-state' \
  -backend-config='prefix=emblem-stage'
terraform destroy \
  -var project=emblem-stage-pancakes \
  -var ops_project=emblem-ops-pancakes
```

This will initialize the current terraform root module to use the Cloud Storage Bucket & object for the stage environment, then use that to remove all resources managed for stage from the pancakes projects.

## Limitations of this Approach

This approach requires terraform init churn to toggle the environment state, and does not allow for environment specific infrastructure config. One challenge is that we cannot use terraform.tfvars in the app root module easily as it thrashes between environments.

A more standard approach would leave `app/application` as the module, move the root module in app to it's own module, and use environment directories as root modules. Each of those directories would be init to their own terraform backend and could carry overriding behavior, such as only prod introducing a Serverless VPC Connector to support internal ingress.

```txt
.
├── modules
│   ├── app
│   └── delivery
└── environments
    ├── ops
    ├── stage
    └── prod
```

In this case, a setup.sh implementation might look like this:

```sh
gsutil mb gs://${OPS_PROJECT}-tf-state
for d in {'ops','stage','prod'}
do
  pushd $d
  terraform init \
    --backend-config "bucket=${OPS_PROJECT}-tf-state"
    --backend-config "prefix=${d}"
  terraform apply
  popd
done
```

Later operations inherit that state configuration, and can perform operations by setting context to the state

```sh
for d in {'ops','stage','prod'}
do
  terraform -chdir=$d output -raw project_number
done
```

## Analysis of Single-Multi-Env experiment

In the experiment [single-multi-env-tf](../single-multi-env-tf)<!-- TODO: Permalink -->, we've been removing hard-coded environments from Terraform to provide more flexibility to how it's used.

Unfortunately, the current path there has gone too far. While we have the functionality to provision one or multiple environments, we don't have a change management process to stage infra updates before shipping to production.

### Example

#### Case 1: New App Infra, ship Stage & Prod

terraform apply stage+prod => Changes are shipped to prod without any QA

#### Case 2: New App Infra, ship Stage then Prod, single state backend

1. terraform apply stage => ops+stage provisioned & state updated
2. terraform apply stage+prod => ops+stage unchanged. prod provisioned & state updated. Be alert for drift risk to stage.
3. terraform apply stage => prod destroyed

#### Case 3: New App Infra, ship Stage then Prod, separate state backends

1. terraform init --backend-config path="./stage"; terraform apply stage => ops+stage provisioned & state updated
2. terraform init --backend-config path="./prod"; terraform apply stage+prod => stage state is inaccessible
