# This test is use for the development cycle, to ensure that additional resources do not /
# break the setup.
#
# To run this test, you'll need to set the following environment variables:
#    - SINGLE_PROJECT
#    - PROD_PROJECT
#    - STAGE_PROJECT
#    - OPS_PROJECT

test_single_project () {
    # Set Variables
    cat > terraform.tfvars <<EOF
google_ops_project_id = "${SINGLE_PROJECT}"
environments = {staging = "${SINGLE_PROJECT}"}
EOF

    terraform init
    terraform apply --auto-approve
    #terraform plan

    # Collect Output
    ops_project_number=$(terraform output -raw ops_project_number)
    stage_project_number=$(terraform output -raw app.staging.project_number)

    # Should all be the same
    if [ "$ops_project_number" = "$stage_project_number" ]
    then
        echo "Project: $ops_project_number"
        echo "Success"
    else
        echo "Failure: Projects are not the same"
        exit
    fi

    terraform destroy --auto-approve
}

test_multi_project () {
    # Set Variables
    cat > terraform.tfvars <<EOF
google_ops_project_id = "${OPS_PROJECT}"
environments = {
    staging = "${STAGE_PROJECT}"
    prod = "${PROD_PROJECT}"
}
EOF

    terraform init
    terraform apply --auto-approve
    #terraform plan

    # Collect Output
    ops_project_number=$(terraform output -raw ops_project_number)
    stage_project_number=$(terraform output -raw app.staging.project_number)
    prod_project_number=$(terraform output -raw app.prod.project_number)

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

    terraform destroy --auto-approve
}

test_single_project
test_multi_project
