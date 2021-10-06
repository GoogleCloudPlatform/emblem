# Use a one-folder-level split for Flask view functions

* **Status:** approved
* **Last Updated:** 2021-06-09
* **Objective:** Organize Flask Views

## Context & Problem Statement

Flask views are driven from annotated functions that are flexibly grouped.

## Decision

In order to organize our Flask view functions, we decided to **use a single folder level split combined with Flask blueprints**.

Concretely, our _views_ file architecture might look like this:
```
website/
  views/
    campaigns.py
    users.py
    ...
```

Flask views themselves are (usually) no more than 5-10 lines of code. A one-folder-level split is not too high-level (which makes finding _individual views_ difficult) and not too low-level (which would make finding _the file associated with a view_ more difficult).

### Expected Consequences <!-- optional -->

If views start becoming longer, or each file starts to accrue more views than we can reason about at a time, we may opt for a greater degree of splitting between views.

We do not expect the total number of views to become smaller and/or less complex, however - and thus, we do not expect to opt for a lesser degree of splitting.

## Links

* https://github.com/GoogleCloudPlatform/emblem/issues/37