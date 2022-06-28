# Reorganize Terraform directory

-   **Status:** approved
-   **Last Updated:** 2022-06
-   **Builds on:** [Use Terraform in a Single Directory](2021-05-terraform-centralized.md)
-   **Objective:** Organize Terraform code in a conventional file structure, including Terraform modules and environment folders.

## Context & Problem Statement

Originally, as the `setup.sh` script deployed resources via Terraform, it manipulated `*.tfvar` files in-place and left Terraform state files in various directories.  The stucture of the `terraform/` directory did not follow any conventional model for organizing Terraform modules or root module directories, which could lead to confusion.

## Priorities & Constraints <!-- optional -->

N/A

## Considered Options

1.  **Split Terraform into two primary modules**: The Terraform modules would be created to correspond with the type of environment that needs to be deployed.  

## Decision

Chosen option: "[option 1] Split Terraform into two primary modules".

`setup.sh` provisioned two types of environments, each associated with its own Google Cloud Project.  At the time of this decision, these types were ops and application. With the exception of some values that could be managed via variables, deployed resources were identical for each application environment (stage and prod), and ops was a unique environment on its own. Therefore `terraform/modules/ops` and `terraform/modules/emblem-app` were created. Additionally, to better isolate state files among environments, `terraform/environments/` was created, where Terraform root modules corresponding with each environment would be created.  

### Expected Consequences <!-- optional -->

-   The `setup.sh` script would need to be updated to use the update Terraform code.
-   Terraform resources from the orginal Terraform code would need to be reorganized into each corresponding module.

### Research

-   [Terraform: Up and Running (chapter 4)](https://www.google.com/books/edition/Terraform_Up_Running/7bytDwAAQBAJ?hl=en&gbpv=0)
-   [Best Practices for Using Terraform](https://cloud.google.com/docs/terraform/best-practices-for-terraform)

## Links

-   **PR:** [feat(terraform): integrate modular terraform #476](https://github.com/GoogleCloudPlatform/emblem/pull/476)
-   **Issue:** [delivery: Explicit environment in terraform configuration #334](https://github.com/GoogleCloudPlatform/emblem/issues/334)
