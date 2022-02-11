# Separate Staging and Production Projects

* **Status:**  approved 
* **Last Updated:** 2022-02-11
* **Objective:** Isolating Staging from Prod

## Context & Problem Statement

We want to reduce risk in our production environment. A common approach is to test changes in "staging" first, but what constitutes staging and how separate should it be from production?

## Priorities & Constraints

* Bugs introduced to staging should not affect production
* Transactions in staging should not affect production

## Considered Options

### Staging a separate service in the same project

In this approach, our staging app can simply be a separate Cloud Run service in the same project. We'd have two services, one called `website-prod` and `website-staging`.  This ensures that code is tested in the environment before being pushed to prod.

However, a Cloud Run service does not exist in isolation.  It reads and writes from a database, it communicates with an API, and it authenticates.  The risk here is that actions in staging might affect these other resources that production relies on.  E.g., if we write something to Firestore in staging that doesn't fit the data model expected by our website, this will not only cause a bug in staging, but one in production as well.  

### Maintaining separate projects for production and staging

We can maintain two separate projects that are nearly identical to each other to ensure that production and staging are completely isolated from each other.  

The challenge is ensuring that staging has all of the same elements as production.  If the projects diverge, the tests in staging lose their value. 

## Decision

We decided to maintain the separate projects.  This creates the least amount of risk for our production environment.  The overhead of managing the two projects is mitigated by using Terraform to create and manage both of them.  Furthermore, using the *same* terraform configuration for both staging and prod mitigates the risk of the projects diverging. 
