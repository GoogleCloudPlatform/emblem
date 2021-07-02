# Emblem API Reference

The Emblem API is a REST-style API which operates on the following
resources:

- Approvers
- Campaigns
- Causes
- Donations
- Donors

## Purpose and overview

The purpose of this API is to address the data needs relating to
fundraising *campaigns* for worthy *causes*.

A *cause* is an organization of some kind (often a charity) that
accepts *donations* from *donors*. Donations reach *causes*
through *campaigns*. Campaigns are promoted by sponsors, and can
only be for an approved *cause*.*Donors* are individuals who
are authenticated and approved by a campaign.

A *cause* may only accept donations if it has been approved by
one or more *approvers*, who are individuals designated by the
fundraising site to vet causes according to the site's criteria.

## Resources in general

Each resource, regardless of type, consists of _name/value_ pairs.
Every resource has a _kind_ (the name of the resource type), and
several *core* system assigned properties that are common to every
kind of resource:

 - _id_, which, along with the _kind_, uniquely specifies
that resource
- _timeCreated_
- _updated_
- _selfLink_, a unique URI of this resource

Every resource contains additional values specific to their
_kind_.

## Representations

The canonical representation of any resource is a JSON object listing
all the _name/value_ pairs in it. For example, an abstract resource
might be represented by:

    {
        "kind": "somekind",
        "id": "A8fj3js876",
        "timeCreated": "20211205T201500.00000Z",
        "updated": "20211215T114500.00000Z",
        "selfLink": "https://domain.name/somekind/A8fs3js876"
        "name": "Some resource",
        "score": 95
    }

Every resource sent to or returned from the API must have a
Content-Type of application/json.

## General Operations

Operations on resources are performed via HTTP(s) requests to
the resource's (or resource kind's) URI. They are consistent
with standard HTTP verbs and status codes.

Each resource may have special behaviors specific to its kind
but in general they follow the typical HTTP method behavior.

### Request Headers:

| Header | Value | Notes |
| --- | --- | --- |
| Content-Type | application/json | if request has a body |
| If-Match | string | only return value if resource's ETag matches |

### Response Headers:

| Header | Value | Notes |
| --- | --- | --- |
| Content-Type | application/json | if response has a body |
| ETag | string | if response contains a single resource |

### Status Codes:

| Code | Meaning |
| --- | --- |
| 200 | Request was honored |
| 403 | Request not authorized |
| 404 | No such kind |
| 409 | Resource's current ETag does not match If-Match value |

### Methods

#### list

Returns a list of all resources of a specific kind.

    GET base_uri://kinds

Note that there should not be a trailing slash */*.

#### get

Returns a single resource, if available.

    GET base_uri://kinds/id

#### insert

Creates a new resource. Body is the JSON representation
of user-provided fields (that is, not including the kind,
id, selfLink, timeCreated, or updated values)

    POST base_uri://kinds

Note again that there should not be a trailing slash.

Response body is the newly created resource. Status code is 201.

#### patch

Changes an existing resource, if allowed. Body is the
JSON representation of fields to change.

    PATCH base_uri://kinds/id

Response body is the newly updated resource.

#### delete

Removes a resource, if possible.

    DELETE base_uri://kinds/id

Response body is empty. Status code is 204.

## Examples

[Examples](./example_requests.md) of how to interact with the API
using the [curl](https://curl.se/) command line tool are available.

## Resource details

### Approvers

Each *approver* has three non-core properties:

| name | value |
| --- | --- |
| name | the person's actual name |
| email | how to reach this person |
| active | boolean; whether this person can currently approve |

Any *approvers* resource that has ever been used to approve a
*cause* should never be deleted. Instead, the _active_ property
should be set to `false`.

*insert* and *patch* operations that include an _email_ already
used in another *approvers* resource will fail with a `409` status
code.

### Campaigns

Each *campaign* has seven non-core properties:

| name | value |
| --- | --- |
| name | the display name of the campaign |
| description | string describing the purpose of the campaign |
| cause | the id of the cause this campaign is for |
| managers | array of strings containing email addresses of contact persons |
| goal | number; the amount in USD this campaign is trying to raise |
| imageUrl | string containing URL of an image to display |
| active | boolean; whether this person can currently approve |

Each *campaign's* name must be unique. Attempts to *insert* or *patch*
a *campaign* to have a _name_ already used by another *campaign* will
fail with a `409` status.

The _cause_ property of a campaign must contain the _id_ of an existing
_cause_.

### Causes

Each *cause* has four non-core properties:

| name | value |
| --- | --- |
| name | the display name of the campaign |
| description | string describing the purpose of the campaign |
| imageUrl | string containing URL of an image to display |
| active | boolean; whether this person can currently approve |

The _name_ must be unique among *causes*. A *campaign* resource with
an _id_ that is referenced by a *campaign* cannot be deleted. Instead
the _active_ property should be set to `false`.

Each *cause* has a sub-resource of *donations* to this cause, referenced
with the URI `base_uri://causes/cause_id/donations` (there should not
be a trailing */*). The only operation available on this sub-resource
is *list*.

### Donations

Each *donation* has three non-core properties:

| name | value |
| --- | --- |
| campaign | ID of the campaign this donation is for |
| donor | ID of the donor making this donation |
| amount | number; the amount in USD of the donation |

The value of the _campaign_ property must be the _id_ of an
existing *campaign*. The value of the _donor_ property must
be the _id_ of a *donor*.

### Donors

Each *donor* has three non-core properties:

| name | value |
| --- | --- |
| name | the display name of the donor |
| email | the donor's email address |
| mailing_address | the physical address of the donor |

The _email_ property must be unique among all *donors*.

Each *donor* has a sub-resource of *donations* to this cause, referenced
with the URI `base_uri://donors/donor_id/donations` (there should not
be a trailing */*). The only operation available on this sub-resource
is *list*.
