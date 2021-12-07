#!/usr/bin/env bash
set -ex

# This test is use for the development cycle, to ensure that additional resources do not /
# break the setup.
#
# To run this test, you'll need to set the following environment variables:
#    - SINGLE_PROJECT
#    - PROD_PROJECT
#    - STAGE_PROJECT
#    - OPS_PROJECT

test_single_project() {
    pushd ops
    terraform init
    terraform apply --auto-approve \
        -var google_ops_project_id="${SINGLE_PROJECT}" > /dev/null
    popd

    pushd app
    terraform init
    cat > terraform.tfvars <<EOF
google_ops_project_id = "${SINGLE_PROJECT}"
google_project_id = "${SINGLE_PROJECT}"
EOF
    terraform import module.application.google_app_engine_application.main "${SINGLE_PROJECT}" || true
    terraform apply --auto-approve > /dev/null
    ops_project_number=$(terraform output -raw ops_project_number)
    stage_project_number=$(terraform output -raw project_number)
    popd

    # Should all be the same
    if [ "$ops_project_number" = "$stage_project_number" ]
    then
        echo "Project: $ops_project_number"
        echo "Success"
    else
        echo "Failure: Projects are not the same"
        exit
    fi

    terraform -chdir=app state rm module.application.google_app_engine_application.main || true
    terraform -chdir=app destroy --auto-approve > /dev/null
    terraform -chdir=ops destroy --auto-approve \
        -var google_ops_project_id="${SINGLE_PROJECT}" > /dev/null
    
}

test_multi_project () {
    pushd ops
    terraform init
    terraform apply --auto-approve \
        -var google_ops_project_id="${OPS_PROJECT}" > /dev/null
    ops_project_number=$(terraform output -raw ops_project_number)
    popd

    pushd app
    # Set Staging Variables
    cat > terraform.tfvars <<EOF
google_ops_project_id = "${OPS_PROJECT}"
google_project_id = "${STAGE_PROJECT}"
EOF

    terraform init --backend-config "path=./stage.tfstate" -reconfigure 
    terraform import module.application.google_app_engine_application.main "${STAGE_PROJECT}" || true
    terraform apply --auto-approve > /dev/null
    stage_project_number=$(terraform output -raw project_number)

    # Set Prod Variables
    cat > terraform.tfvars <<EOF
google_ops_project_id = "${OPS_PROJECT}"
google_project_id = "${PROD_PROJECT}"
EOF
    terraform init --backend-config "path=./prod.tfstate" -reconfigure
    terraform import module.application.google_app_engine_application.main "${PROD_PROJECT}" || true
    terraform apply --auto-approve > /dev/null
    prod_project_number=$(terraform output -raw project_number)
    popd    

    # Should all be different
    if [ "$ops_project_number" != "$stage_project_number" ] \
        && [ "$ops_project_number" != "$prod_project_number" ]
    then
        echo "Ops Project: $ops_project_number"
        echo "Stage Project: $stage_project_number"
        echo "Prod Project: $prod_project_number"
        echo "Success"
    else
        echo "Failure: Projects are the same"
        exit
    fi

    # TODO: Terraform standards suggest env dirs as root module.
    # This would allow avoiding init thrash, and open up concurrent operations.
    pushd app
    # Set Prod Variables
    cat > terraform.tfvars <<EOF
google_ops_project_id = "${OPS_PROJECT}"
google_project_id = "${PROD_PROJECT}"
EOF
    terraform init --backend-config "path=./prod.tfstate" -reconfigure > /dev/null
    terraform state rm module.application.google_app_engine_application.main || true
    terraform destroy --auto-approve > /dev/null

    # Set Staging Variables
    cat > terraform.tfvars <<EOF
google_ops_project_id = "${OPS_PROJECT}"
google_project_id = "${STAGE_PROJECT}"
EOF
    terraform init --backend-config "path=./stage.tfstate" -reconfigure > /dev/null
    terraform state rm module.application.google_app_engine_application.main || true
    terraform destroy --auto-approve  > /dev/null
    popd

    terraform -chdir=ops destroy --auto-approve \
        -var google_ops_project_id="${OPS_PROJECT}" > /dev/null

}

test_single_project
test_multi_project
