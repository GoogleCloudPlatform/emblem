# Example API Requests

Each path starts with `https://hostname/resourcename`. These examples
use the *campaigns* resource. The hostname is a temporary staging service
on Cloud Run, for now.

The [curl](https://curl.se/) tool is used here. The `-i` flag shows
response headers as well as response bodies. Parameter quoting is
correct for bash or similar shells.

## List resources

Curl request:

    curl -i -X GET https://api-pwrmtjf4hq-uc.a.run.app/campaigns

Response examples:

Empty list:

    HTTP/2 200
    content-type: application/json
    date: Thu, 17 Jun 2021 22:34:24 GMT
    content-length: 2

    []

One resource:

    HTTP/2 200
    content-type: application/json
    date: Thu, 17 Jun 2021 23:52:51 GMT
    content-length: 591
    [{"kind": "campaigns", "id": "Ciyjbet8YNBegmuRbSX5", "timeCreated": "2021-06-17T23:51:27.006267Z", "updated": "2021-06-17T23:51:27.006267Z", "selfLink": "https://api-pwrmtjf4hq-uc.a.run.app/campaigns/Ciyjbet8YNBegmuRbSX5", "name": "Demo Campaign", "description": "A campaign created to demonstrate the API", "cause": "Something useful", "managers": ["nobody@example.com", "nobodyelse@example.com"], "goal": 1000.0, "imageUrl": "https://github.githubassets.com/images/icons/emoji/unicode/1f4a0.png", "active": true, "etag": "c05b6cb53808bd7a9625116b7470414730e78dff4b7cd322f9f82fd33b48bc67"}]


## Get a resource

Curl request:

    curl -i -X GET https://api-pwrmtjf4hq-uc.a.run.app/campaigns/Ciyjbet8YNBegmuRbSX5

Response:

    HTTP/2 200
    content-type: application/json
    date: Thu, 17 Jun 2021 23:55:53 GMT
    content-length: 589

    {"kind": "campaigns", "id": "Ciyjbet8YNBegmuRbSX5", "timeCreated": "2021-06-17T23:51:27.006267Z", "updated": "2021-06-17T23:51:27.006267Z", "selfLink": "https://api-pwrmtjf4hq-uc.a.run.app/campaigns/Ciyjbet8YNBegmuRbSX5", "name": "Demo Campaign", "description": "A campaign created to demonstrate the API", "cause": "Something useful", "managers": ["nobody@example.com", "nobodyelse@example.com"], "goal": 1000.0, "imageUrl": "https://github.githubassets.com/images/icons/emoji/unicode/1f4a0.png", "active": true, "etag": "c05b6cb53808bd7a9625116b7470414730e78dff4b7cd322f9f82fd33b48bc67"}


## Create resources

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
    location: https://api-pwrmtjf4hq-uc.a.run.app/campaigns/Ciyjbet8YNBegmuRbSX5
    date: Thu, 17 Jun 2021 23:51:27 GMT
    content-length: 589
    {"kind": "campaigns", "id": "Ciyjbet8YNBegmuRbSX5", "timeCreated": "2021-06-17T23:51:27.006267Z", "updated": "2021-06-17T23:51:27.006267Z", "selfLink": "https://api-pwrmtjf4hq-uc.a.run.app/campaigns/Ciyjbet8YNBegmuRbSX5", "name": "Demo Campaign", "description": "A campaign created to demonstrate the API", "cause": "Something useful", "managers": ["nobody@example.com", "nobodyelse@example.com"], "goal": 1000.0, "imageUrl": "https://github.githubassets.com/images/icons/emoji/unicode/1f4a0.png", "active": true, "etag": "c05b6cb53808bd7a9625116b7470414730e78dff4b7cd322f9f82fd33b48bc67"}
