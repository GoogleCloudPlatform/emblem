# Website Testing Philosophy

 - Status: approved
 - Last Updated: 2022-04
 - Objective: Determine how we should test Emblem's [Website component](/website)

## Context
The [Website component](/website) is a critical Emblem component. For this effort, we want to ensure that it remains in good working order **without** writing more tests than we need to.

Related issues:
- [Decision: choose a website testing approach](https://github.com/GoogleCloudPlatform/emblem/issues/307)

Related PRs:
- [Add canonical tests](https://github.com/GoogleCloudPlatform/emblem/issues/342) (based on [Playwright](https://playwright.dev))
- [Add CD Pipeline for Playwright image](https://github.com/GoogleCloudPlatform/emblem/issues/361)

## Priorities & Constraints

This effort has three major priorities:

1. **Accuracy:** detect as many errors in the Website as possible
2. **Development Speed:** minimize our time-to-useful-data
3. **Contributor Experience:** minimize friction in the contributor experience

Our chief constraint is that implementing tests can be time-consuming. Thus, we want to minimize the time we need to create a **useful** test suite.

The trade-off is that investing less time into our testing approach **inevitably** leads to two things:
1. **Less accurate results:** for the Emblem Website specifically, "cheaper" tests may not detect every bug in our code.
2. **More specialized tests:** we'll have to choose between _Accuracy_ and _Contributor Experience_.
    - **System Tests** are more accurate, as they can detect a wider range of bugs.
    - **Unit Tests** are easier for contributors to use, as they (generally) don't require a deployed Emblem Website instance to run.

## Considered Options

We have three types of tests to choose from:
- Unit tests
- Integration tests
- System tests (also known as "End-to-end" or "E2E" tests.)

_See the [Google SRE Guide](https://sre.google/sre-book/testing-reliability/#fig_testing_hierarchy) for an explanation of these test types._

The Emblem Website can have as many of each test type as we'd like it to. Our only constraint is the time we'd need to take to implement each test.

## Decisions

To minimize time-to-value, we should focus primarily on _a single test type_.

To maximize the comprehensiveness of our tests (and in turn, our initial return on investment), our team decided to focus on **End-to-End (E2E) tests**.

These tests are the quickest path to ensuring the website works _mostly_ as expected.

### Expected Consequences

First, we don't expect these tests to spot every possible bug.

Second, we don't expect our **initial** tests to simplify the contribution process.

Third, we expect our initial tests to help us _detect_ - but **not debug** - problems.

> The second and third issues can be solved by adding more **unit tests** and **integration tests** respectively. Those are things we may investigate later when we have more time.
