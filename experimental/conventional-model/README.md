This experimental directory is associated Github issue: [https://github.com/GoogleCloudPlatform/emblem/issues/334](https://github.com/GoogleCloudPlatform/emblem/issues/334)

## Before you begin

You will need: 
1. Three projects: ops, prod, and dev
1. A repository to connect to the Cloud Build pipeline


## Set up ops project

1. Deploy ops module using environments/ops dir
    * Update terraform.tfvars.example with values and rename to terraform.tfvars
    * Upon the first deployment, the module variable `deploy_triggers` will be set to false.
1. Connect a repository to your ops project: [https://console.cloud.google.com/cloud-build/triggers/connect](https://console.cloud.google.com/cloud-build/triggers/connect)
1. Redeploy ops module with the variable `deploy_triggers` set to `true` and values for `repo_owner` and `repo_name` from the previous step.  
