# Use a two-folder-level split for Jinja templates

* **Status:** approved
* **Last Updated:** 2021-06-09
* **Objective:** Organize jinja templates in website

## Context & Problem Statement

Template organization is an important element for contributor discoverability.

## Decision

In order to organize our Jinja HTML templates, we decided to **use a two-level folder level split**. This will be combined with Jinja inheritance (i.e. the `extends` clause) for common components where possible.

Concretely, our _templates_ file architecture might look like this:

```
website/
  templates/
    campaigns/
      view_campaign.html
      create_or_edit_campaign.html
    users/
      view_user.html
    ...
```

Templates often mirror API actions (`create`, `read`, `update`, `delete`, etc). Since the API itself is organized by data types (e.g. `users`, `donations`, `causes`, etc), we saw it fit to mirror that information hierarchy here.

### Expected Consequences <!-- optional -->

This organization will not scale well to a significant number of templates. In that case, a more complex hierarchy will need to be created.

## Links

* https://github.com/GoogleCloudPlatform/emblem/issues/37