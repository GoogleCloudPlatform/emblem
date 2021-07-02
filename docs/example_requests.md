# Example API Requests

Each path starts with `https://hostname/resourcename`. These examples
use the *campaigns* resource. The hostname is a temporary staging service
on Cloud Run, for now.

The [curl](https://curl.se/) tool is used here. The `-i` flag shows
response headers as well as response bodies. Parameter quoting is
correct for bash or similar shells.

In the future, some insert and patch operations can fail if they include
a foreign ID that does not exist. Some delete or patch operations can
fail if a different resource references them by ID.

## List resources

Curl request:

    curl -i -X GET https://api-pwrmtjf4hq-uc.a.run.app/campaigns

Response examples:

Empty list:

    HTTP/2 200
    content-type: application/json
    date: Fri, 18 Jun 2021 19:34:03 GMT
    content-length: 2

    []

One resource:

    HTTP/2 200
    content-type: application/json
    date: Fri, 18 Jun 2021 19:38:29 GMT
    content-length: 515

    [{"kind": "campaigns", "id": "JvJIMRstni8LF102rOyO", "timeCreated": "2021-06-18T19:35:10.932923Z", "updated": "2021-06-18T19:35:10.932923Z", "selfLink": "https://api-pwrmtjf4hq-uc.a.run.app/campaigns/JvJIMRstni8LF102rOyO", "name": "Demo Campaign", "description": "A campaign created to demonstrate the API", "cause": "Something useful", "managers": ["nobody@example.com", "nobodyelse@example.com"], "goal": 1000.0, "imageUrl": "https://github.githubassets.com/images/icons/emoji/unicode/1f4a0.png", "active": true}]


## Get a resource

Curl request:

    curl -i -X GET https://api-pwrmtjf4hq-uc.a.run.app/campaigns/JvJIMRstni8LF102rOyO

Response:

    HTTP/2 200
    content-type: application/json
    etag: 0ac3008345d822283253e2cbbd5aaa5afba01f38b05231ee8396f0453adb6ed8
    date: Fri, 18 Jun 2021 19:40:12 GMT
    content-length: 513{"kind": "campaigns", "id": "JvJIMRstni8LF102rOyO", "timeCreated": "2021-06-18T19:35:10.932923Z", "updated": "2021-06-18T19:35:10.932923Z", "selfLink": "https://api-pwrmtjf4hq-uc.a.run.app/campaigns/JvJIMRstni8LF102rOyO", "name": "Demo Campaign", "description": "A campaign created to demonstrate the API", "cause": "Something useful", "managers": ["nobody@example.com", "nobodyelse@example.com"], "goal": 1000.0, "imageUrl": "https://github.githubassets.com/images/icons/emoji/unicode/1f4a0.png", "active": true}

Note that a response containing a single resource has an etag header.

## Create a resource

First, create a file named `resource.json` with the following (or
similar) content:

    {
        "name": "Demo Campaign",
        "description": "A campaign created to demonstrate the API",
        "cause": "Something useful",
        "managers": ["nobody@example.com", "nobodyelse@example.com"],
        "goal": 1000.00,
        "imageUrl": "https://github.githubassets.com/images/icons/emoji/unicode/1f4a0.png",
        "active": true
    }

Curl request:

    curl -i -d @resource.json -H "Content-Type: application/json" -X POST https://api-pwrmtjf4hq-uc.a.run.app/campaigns

Response:

    HTTP/2 201
    content-type: application/json
    etag: 0ac3008345d822283253e2cbbd5aaa5afba01f38b05231ee8396f0453adb6ed8
    location: https://api-pwrmtjf4hq-uc.a.run.app/campaigns/JvJIMRstni8LF102rOyO
    date: Fri, 18 Jun 2021 19:35:10 GMT
    content-length: 589

    {"kind": "campaigns", "id": "JvJIMRstni8LF102rOyO", "timeCreated": "2021-06-18T19:35:10.932923Z", "updated": "2021-06-18T19:35:10.932923Z", "selfLink": "https://api-pwrmtjf4hq-uc.a.run.app/campaigns/JvJIMRstni8LF102rOyO", "name": "Demo Campaign", "description": "A campaign created to demonstrate the API", "cause": "Something useful", "managers": ["nobody@example.com", "nobodyelse@example.com"], "goal": 1000.0, "imageUrl": "https://github.githubassets.com/images/icons/emoji/unicode/1f4a0.png", "active": true, "etag": "0ac3008345d822283253e2cbbd5aaa5afba01f38b05231ee8396f0453adb6ed8"}


## Update (PATCH) a resource

First, create a file named `update_resource.json` with the following (or
similar) content:

    {
        "goal": 2000.00,
    }

This is a partial representation of the resource containing only the `goal`
field. It's purpose is to update the amount of the goal.

Curl request - update only if resource has not changed:

    curl -i -d @resource.json -H "Content-Type: application/json" -H "If-Match: 0ac3008345d822283253e2cbbd5aaa5afba01f38b05231ee8396f0453adb6ed8" -X PATCH https://api-pwrmtjf4hq-uc.a.run.app/campaigns/JvJIMRstni8LF102rOyO

Successful response:

    HTTP/2 204
    content-type: text/html; charset=utf-8
    date: Fri, 18 Jun 2021 19:48:30 GMT

Failed response (ETags do not match):

    HTTP/2 409
    content-type: text/html; charset=utf-8
    date: Fri, 18 Jun 2021 19:50:54 GMT
    content-length: 8

    Conflict

Curl request - unconditional update:

    curl -i -d @resource.json -H "Content-Type: application/json" -X PATCH https://api-pwrmtjf4hq-uc.a.run.app/campaigns/JvJIMRstni8LF102rOyO

Response:

    HTTP/2 204
    content-type: text/html; charset=utf-8
    date: Fri, 18 Jun 2021 19:52:09 GMT

## Delete a resource

Curl request - delete only if resource has not changed:

    curl -i -H "If-Match: c05b6cb53808bd7a9625116b7470414730e78dff4b7cd322f9f82fd33b48bc67" -X DELETE https://api-pwrmtjf4hq-uc.a.run.app/campaigns/JvJIMRstni8LF102rOyO

Successful Response:

    HTTP/2 204
    content-type: text/html; charset=utf-8
    date: Fri, 18 Jun 2021 19:56:24 GMT

Failed response (ETags do not match):

    HTTP/2 409
    content-type: text/html; charset=utf-8
    date: Fri, 18 Jun 2021 19:54:25 GMT

Curl request - unconditional delete:

    curl -i -X DELETE https://api-pwrmtjf4hq-uc.a.run.app/campaigns/JvJIMRstni8LF102rOyO

Response:

    HTTP/2 204
    content-type: text/html; charset=utf-8
    date: Fri, 18 Jun 2021 19:56:24 GMT
