# Use Cloud Identity Platform for user authorization

* **Status:** Superceded by [2021-11 User Authentication](2021-11-user-authentication.md)
* **Last Updated:** 2021-07
* **Objective:** How should we implement SSO/Authentication?

## Rationale

[Cloud Identity Platform](https://cloud.google.com/identity-platform) is a Google Cloud-specific
layer on top of [Firebase Auth](https://firebase.google.com/docs/auth) that provides
several useful capabilities within GCP itself:

* _Built-in user account management tools_ available in the [Cloud Console](https://console.cloud.google.com/customer-identity/users).
* _Identity federation_, which combines sign-ons from a [wide variety](https://cloud.google.com/identity-platform/docs/concepts-authentication#key_capabilities) of identity providers (such as Google, Apple, and GitHub) into a single user identity.

The other option we reviewed, [Google Sign-in](https://developers.google.com/identity/sign-in/web/build-button), did not have either of these capabilities that we might want
to use later on. Thus, we decided to go with Cloud Identity Platform to "future-proof" our design.

Finally, we did not want to deal with the hassle of managing user credentials (such as passwords) ourselves.
Though this option gives the most _customizability_, we thought that the greater simplicity of Cloud Identity Platform was worth trading some flexibility for.

## Revision Criteria

In the unlikely event that we need to do something _not_ supported by Cloud Identity Platform,
then we may want to consider implementing a **username/password-based** authentication
system for additional flexibility.
