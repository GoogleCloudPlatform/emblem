data "terraform_remote_state" "ops" {
  backend = "local"
  config = {
    path = "../ops/terraform.tfstate"
  }
}

data "terraform_remote_state" "stage" {
  backend = "local"
  config = {
    path = "../app/stage.tfstate"
  }
}
