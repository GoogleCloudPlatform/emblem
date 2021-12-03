# Ask user to fetch OAuth 2.0 secret config values manually

- Status: approved
- Last updated: 2021-12
- Objective: Decide how to fetch OAuth secret values

## Context & Problem Statement

OAuth credentials can be shared between GCP projects, but the secret configuration values must somehow be fetched from GCP.

## Priorities & Constraints

- **Auth not required:** in [https://github.com/GoogleCloudPlatform/emblem/issues/117#issuecomment-887900131], we decided that auth configuration should not be required to run the website.
- **Security is paramount:** we want to avoid storing the secret values on the developer's machine (in both _terminal history_ and/or _somewhere in the filesystem_) if we can help it.

## Considered Options

- Option 1: fetch config values programmatically via `gcloud`
- Option 2: download a credential file manually and extract values from that
- Option 3: prompt users to copy-paste the values into _Cloud Console's Secret Manager page_
- Option 4: use Terraform to either **a)** prompt users to specify values in _their terminal_ or **b)** pre-configure them as `TFVAR_` environment variables.

## Decision

As a group, we [decided on](https://github.com/GoogleCloudPlatform/emblem/issues/262#issuecomment-982927394) _Option 3_. Thus, we'll prompt users to copy-paste OAuth 2.0 secret config values into the Secret Manager page on Cloud Console.

We opted to create the secrets themselves (i.e. [`google_secret_manager_secret` objects](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret)) via Terraform, as creating those objects does not require any highly-sensitive data.

### Expected Consequences

In choosing this option, our intent is to maximize the security of the OAuth 2.0 configuration values. This increase in security comes at the expense of additional friction during the setup process.

### Revision Criteria

"Security vs. convenience" is a _very_ common tradeoff within the software industry. If we find that the additional friction added by manually interacting with the Cloud Console is too difficult to bear, we may revise this decision in favor of increased convenience.
