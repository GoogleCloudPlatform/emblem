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
google_prod_project_id = "${SINGLE_PROJECT}"
google_stage_project_id = "${SINGLE_PROJECT}"
google_ops_project_id = "${SINGLE_PROJECT}"
EOF

terraform init
terraform apply --auto-approve

# Collect Output
ops_project_number=$(terraform output -raw ops_project_number)
stage_project_number=$(terraform output -raw stage_project_number)
prod_project_number=$(terraform output -raw prod_project_number)

# Should all be the same
if [ "$ops_project_number" = "$stage_project_number" ] \
        && [ "$ops_project_number" = "$prod_project_number" ]
    then
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
google_prod_project_id = "${PROD_PROJECT}"
google_stage_project_id = "${STAGE_PROJECT}"
google_ops_project_id = "${OPS_PROJECT}"
EOF

terraform init
terraform apply --auto-approve

# Collect Output
ops_project_number=$(terraform output -raw ops_project_number)
stage_project_number=$(terraform output -raw stage_project_number)
prod_project_number=$(terraform output -raw prod_project_number)

# Should all be different
if [ "$ops_project_number" != "$stage_project_number" ] \
        && [ "$ops_project_number" != "$prod_project_number" ]
    then
        echo "Success"
    else
        echo "Failure: Projects are the same"
        exit
    fi 

terraform destroy --auto-approve
}


test_single_project
test_multi_project

