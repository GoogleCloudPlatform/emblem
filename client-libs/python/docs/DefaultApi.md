# generated.DefaultApi

All URIs are relative to *https://api-pwrmtjf4hq-uc.a.run.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**approvers_get**](DefaultApi.md#approvers_get) | **GET** /approvers | Returns a list of approvers
[**approvers_id_delete**](DefaultApi.md#approvers_id_delete) | **DELETE** /approvers/{id} | deletes a single approver
[**approvers_id_get**](DefaultApi.md#approvers_id_get) | **GET** /approvers/{id} | returns a single approver
[**approvers_id_patch**](DefaultApi.md#approvers_id_patch) | **PATCH** /approvers/{id} | updates a single approver
[**approvers_post**](DefaultApi.md#approvers_post) | **POST** /approvers | Create a new approver
[**campaigns_get**](DefaultApi.md#campaigns_get) | **GET** /campaigns | Returns a list of campaigns
[**campaigns_id_delete**](DefaultApi.md#campaigns_id_delete) | **DELETE** /campaigns/{id} | deletes a single campaign
[**campaigns_id_donations_get**](DefaultApi.md#campaigns_id_donations_get) | **GET** /campaigns/{id}/donations | lists all donations for the specified campaign
[**campaigns_id_get**](DefaultApi.md#campaigns_id_get) | **GET** /campaigns/{id} | returns a single campaign
[**campaigns_id_patch**](DefaultApi.md#campaigns_id_patch) | **PATCH** /campaigns/{id} | updates a single campaign
[**campaigns_post**](DefaultApi.md#campaigns_post) | **POST** /campaigns | Create a new campaign
[**causes_get**](DefaultApi.md#causes_get) | **GET** /causes | Returns a list of causes
[**causes_id_delete**](DefaultApi.md#causes_id_delete) | **DELETE** /causes/{id} | deletes a single cause
[**causes_id_get**](DefaultApi.md#causes_id_get) | **GET** /causes/{id} | returns a single cause
[**causes_id_patch**](DefaultApi.md#causes_id_patch) | **PATCH** /causes/{id} | updates a single cause
[**causes_post**](DefaultApi.md#causes_post) | **POST** /causes | Create a new cause
[**donations_get**](DefaultApi.md#donations_get) | **GET** /donations | Returns a list of donations
[**donations_id_delete**](DefaultApi.md#donations_id_delete) | **DELETE** /donations/{id} | deletes a single donation
[**donations_id_get**](DefaultApi.md#donations_id_get) | **GET** /donations/{id} | returns a single donation
[**donations_id_patch**](DefaultApi.md#donations_id_patch) | **PATCH** /donations/{id} | updates a single donation
[**donations_post**](DefaultApi.md#donations_post) | **POST** /donations | Create a new donation
[**donors_get**](DefaultApi.md#donors_get) | **GET** /donors | Returns a list of donors
[**donors_id_delete**](DefaultApi.md#donors_id_delete) | **DELETE** /donors/{id} | deletes a single donor
[**donors_id_donations_get**](DefaultApi.md#donors_id_donations_get) | **GET** /donors/{id}/donations | lists all donations for the specified donor
[**donors_id_get**](DefaultApi.md#donors_id_get) | **GET** /donors/{id} | returns a single donor
[**donors_id_patch**](DefaultApi.md#donors_id_patch) | **PATCH** /donors/{id} | updates a single donor
[**donors_post**](DefaultApi.md#donors_post) | **POST** /donors | Create a new donor


# **approvers_get**
> [Approver] approvers_get()

Returns a list of approvers

### Example

* Bearer (JWT) Authentication (bearerAuth):
```python
import time
import generated
from generated.api import default_api
from generated.model.approver import Approver
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)

# The client must configure the authentication and authorization parameters
# in accordance with the API server security policy.
# Examples for each auth method are provided below, use the example that
# satisfies your auth use case.

# Configure Bearer authorization (JWT): bearerAuth
configuration = generated.Configuration(
    access_token = 'YOUR_BEARER_TOKEN'
)

# Enter a context with an instance of the API client
with generated.ApiClient(configuration) as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)

    # example, this endpoint has no required or optional parameters
    try:
        # Returns a list of approvers
        api_response = api_instance.approvers_get()
        pprint(api_response)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->approvers_get: %s\n" % e)
```


### Parameters
This endpoint does not need any parameter.

### Return type

[**[Approver]**](Approver.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**200** | A JSON array of approvers |  -  |
**403** | Forbidden |  -  |
**404** | not found. The path must have a typo |  -  |
**0** | Unexpected error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **approvers_id_delete**
> approvers_id_delete(id)

deletes a single approver

### Example

* Bearer (JWT) Authentication (bearerAuth):
```python
import time
import generated
from generated.api import default_api
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)

# The client must configure the authentication and authorization parameters
# in accordance with the API server security policy.
# Examples for each auth method are provided below, use the example that
# satisfies your auth use case.

# Configure Bearer authorization (JWT): bearerAuth
configuration = generated.Configuration(
    access_token = 'YOUR_BEARER_TOKEN'
)

# Enter a context with an instance of the API client
with generated.ApiClient(configuration) as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)
    id = "id_example" # str | Approver Id

    # example passing only required values which don't have defaults set
    try:
        # deletes a single approver
        api_instance.approvers_id_delete(id)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->approvers_id_delete: %s\n" % e)
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **str**| Approver Id |

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**204** | No content |  -  |
**403** | Forbidden |  -  |
**404** | not found |  -  |
**409** | Conflict. If-Match header provided does not match current contents |  -  |
**0** | Unexpected error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **approvers_id_get**
> Approver approvers_id_get(id)

returns a single approver

### Example

* Bearer (JWT) Authentication (bearerAuth):
```python
import time
import generated
from generated.api import default_api
from generated.model.approver import Approver
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)

# The client must configure the authentication and authorization parameters
# in accordance with the API server security policy.
# Examples for each auth method are provided below, use the example that
# satisfies your auth use case.

# Configure Bearer authorization (JWT): bearerAuth
configuration = generated.Configuration(
    access_token = 'YOUR_BEARER_TOKEN'
)

# Enter a context with an instance of the API client
with generated.ApiClient(configuration) as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)
    id = "id_example" # str | Approver Id

    # example passing only required values which don't have defaults set
    try:
        # returns a single approver
        api_response = api_instance.approvers_id_get(id)
        pprint(api_response)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->approvers_id_get: %s\n" % e)
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **str**| Approver Id |

### Return type

[**Approver**](Approver.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**200** | JSON representation of a approver |  -  |
**403** | Forbidden |  -  |
**404** | not found |  -  |
**0** | Unexpected error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **approvers_id_patch**
> Approver approvers_id_patch(id, approver)

updates a single approver

### Example

* Bearer (JWT) Authentication (bearerAuth):
```python
import time
import generated
from generated.api import default_api
from generated.model.approver import Approver
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)

# The client must configure the authentication and authorization parameters
# in accordance with the API server security policy.
# Examples for each auth method are provided below, use the example that
# satisfies your auth use case.

# Configure Bearer authorization (JWT): bearerAuth
configuration = generated.Configuration(
    access_token = 'YOUR_BEARER_TOKEN'
)

# Enter a context with an instance of the API client
with generated.ApiClient(configuration) as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)
    id = "id_example" # str | Approver Id
    approver = Approver(
        name="name_example",
        email="email_example",
        active=True,
    ) # Approver | JSON representation of a single approver

    # example passing only required values which don't have defaults set
    try:
        # updates a single approver
        api_response = api_instance.approvers_id_patch(id, approver)
        pprint(api_response)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->approvers_id_patch: %s\n" % e)
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **str**| Approver Id |
 **approver** | [**Approver**](Approver.md)| JSON representation of a single approver |

### Return type

[**Approver**](Approver.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**201** | JSON representation of a approver |  -  |
**403** | Forbidden |  -  |
**404** | not found |  -  |
**409** | Conflict. If-Match header provided does not match current contents |  -  |
**0** | Unexpected error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **approvers_post**
> approvers_post(approver)

Create a new approver

### Example

* Bearer (JWT) Authentication (bearerAuth):
```python
import time
import generated
from generated.api import default_api
from generated.model.approver import Approver
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)

# The client must configure the authentication and authorization parameters
# in accordance with the API server security policy.
# Examples for each auth method are provided below, use the example that
# satisfies your auth use case.

# Configure Bearer authorization (JWT): bearerAuth
configuration = generated.Configuration(
    access_token = 'YOUR_BEARER_TOKEN'
)

# Enter a context with an instance of the API client
with generated.ApiClient(configuration) as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)
    approver = Approver(
        name="name_example",
        email="email_example",
        active=True,
    ) # Approver | JSON representation of a single approver

    # example passing only required values which don't have defaults set
    try:
        # Create a new approver
        api_instance.approvers_post(approver)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->approvers_post: %s\n" % e)
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **approver** | [**Approver**](Approver.md)| JSON representation of a single approver |

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**201** | Created |  -  |
**403** | Forbidden |  -  |
**404** | approvers must have been misspelled in path |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campaigns_get**
> [Campaign] campaigns_get()

Returns a list of campaigns

### Example

```python
import time
import generated
from generated.api import default_api
from generated.model.campaign import Campaign
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)


# Enter a context with an instance of the API client
with generated.ApiClient() as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)

    # example, this endpoint has no required or optional parameters
    try:
        # Returns a list of campaigns
        api_response = api_instance.campaigns_get()
        pprint(api_response)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->campaigns_get: %s\n" % e)
```


### Parameters
This endpoint does not need any parameter.

### Return type

[**[Campaign]**](Campaign.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**200** | A JSON array of campaigns |  -  |
**404** | not found. The path must have a typo |  -  |
**0** | Unexpected error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campaigns_id_delete**
> campaigns_id_delete(id)

deletes a single campaign

### Example

```python
import time
import generated
from generated.api import default_api
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)


# Enter a context with an instance of the API client
with generated.ApiClient() as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)
    id = "id_example" # str | Campaign Id

    # example passing only required values which don't have defaults set
    try:
        # deletes a single campaign
        api_instance.campaigns_id_delete(id)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->campaigns_id_delete: %s\n" % e)
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **str**| Campaign Id |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**204** | No content |  -  |
**404** | not found |  -  |
**409** | Conflict. If-Match header provided does not match current contents |  -  |
**0** | Unexpected error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campaigns_id_donations_get**
> [Donation] campaigns_id_donations_get(id)

lists all donations for the specified campaign

### Example

```python
import time
import generated
from generated.api import default_api
from generated.model.donation import Donation
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)


# Enter a context with an instance of the API client
with generated.ApiClient() as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)
    id = "id_example" # str | Campaign Id

    # example passing only required values which don't have defaults set
    try:
        # lists all donations for the specified campaign
        api_response = api_instance.campaigns_id_donations_get(id)
        pprint(api_response)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->campaigns_id_donations_get: %s\n" % e)
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **str**| Campaign Id |

### Return type

[**[Donation]**](Donation.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**201** | JSON representation of an array of donations |  -  |
**404** | not found |  -  |
**0** | Unexpected error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campaigns_id_get**
> Campaign campaigns_id_get(id)

returns a single campaign

### Example

```python
import time
import generated
from generated.api import default_api
from generated.model.campaign import Campaign
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)


# Enter a context with an instance of the API client
with generated.ApiClient() as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)
    id = "id_example" # str | Campaign Id

    # example passing only required values which don't have defaults set
    try:
        # returns a single campaign
        api_response = api_instance.campaigns_id_get(id)
        pprint(api_response)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->campaigns_id_get: %s\n" % e)
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **str**| Campaign Id |

### Return type

[**Campaign**](Campaign.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**200** | JSON representation of a campaign |  -  |
**404** | not found |  -  |
**0** | Unexpected error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campaigns_id_patch**
> Campaign campaigns_id_patch(id, campaign)

updates a single campaign

### Example

```python
import time
import generated
from generated.api import default_api
from generated.model.campaign import Campaign
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)


# Enter a context with an instance of the API client
with generated.ApiClient() as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)
    id = "id_example" # str | Campaign Id
    campaign = Campaign(
        name="name_example",
        description="description_example",
        cause="cause_example",
        managers=[
            "managers_example",
        ],
        goal=3.14,
        image_url="image_url_example",
        active=True,
    ) # Campaign | JSON representation of a single campaign

    # example passing only required values which don't have defaults set
    try:
        # updates a single campaign
        api_response = api_instance.campaigns_id_patch(id, campaign)
        pprint(api_response)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->campaigns_id_patch: %s\n" % e)
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **str**| Campaign Id |
 **campaign** | [**Campaign**](Campaign.md)| JSON representation of a single campaign |

### Return type

[**Campaign**](Campaign.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**201** | JSON representation of a campaign |  -  |
**404** | not found |  -  |
**409** | Conflict. If-Match header provided does not match current contents |  -  |
**0** | Unexpected error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campaigns_post**
> campaigns_post(campaign)

Create a new campaign

### Example

```python
import time
import generated
from generated.api import default_api
from generated.model.campaign import Campaign
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)


# Enter a context with an instance of the API client
with generated.ApiClient() as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)
    campaign = Campaign(
        name="name_example",
        description="description_example",
        cause="cause_example",
        managers=[
            "managers_example",
        ],
        goal=3.14,
        image_url="image_url_example",
        active=True,
    ) # Campaign | JSON representation of a single campaign

    # example passing only required values which don't have defaults set
    try:
        # Create a new campaign
        api_instance.campaigns_post(campaign)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->campaigns_post: %s\n" % e)
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **campaign** | [**Campaign**](Campaign.md)| JSON representation of a single campaign |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**201** | Created |  -  |
**404** | campaigns must have been misspelled in path |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **causes_get**
> [Cause] causes_get()

Returns a list of causes

### Example

```python
import time
import generated
from generated.api import default_api
from generated.model.cause import Cause
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)


# Enter a context with an instance of the API client
with generated.ApiClient() as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)

    # example, this endpoint has no required or optional parameters
    try:
        # Returns a list of causes
        api_response = api_instance.causes_get()
        pprint(api_response)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->causes_get: %s\n" % e)
```


### Parameters
This endpoint does not need any parameter.

### Return type

[**[Cause]**](Cause.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**200** | A JSON array of causes |  -  |
**404** | not found. The path must have a typo |  -  |
**0** | Unexpected error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **causes_id_delete**
> causes_id_delete(id)

deletes a single cause

### Example

```python
import time
import generated
from generated.api import default_api
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)


# Enter a context with an instance of the API client
with generated.ApiClient() as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)
    id = "id_example" # str | Cause Id

    # example passing only required values which don't have defaults set
    try:
        # deletes a single cause
        api_instance.causes_id_delete(id)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->causes_id_delete: %s\n" % e)
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **str**| Cause Id |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**204** | No content |  -  |
**404** | not found |  -  |
**409** | Conflict. If-Match header provided does not match current contents |  -  |
**0** | Unexpected error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **causes_id_get**
> Cause causes_id_get(id)

returns a single cause

### Example

```python
import time
import generated
from generated.api import default_api
from generated.model.cause import Cause
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)


# Enter a context with an instance of the API client
with generated.ApiClient() as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)
    id = "id_example" # str | Cause Id

    # example passing only required values which don't have defaults set
    try:
        # returns a single cause
        api_response = api_instance.causes_id_get(id)
        pprint(api_response)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->causes_id_get: %s\n" % e)
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **str**| Cause Id |

### Return type

[**Cause**](Cause.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**200** | JSON representation of a cause |  -  |
**404** | not found |  -  |
**0** | Unexpected error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **causes_id_patch**
> Cause causes_id_patch(id, cause)

updates a single cause

### Example

```python
import time
import generated
from generated.api import default_api
from generated.model.cause import Cause
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)


# Enter a context with an instance of the API client
with generated.ApiClient() as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)
    id = "id_example" # str | Cause Id
    cause = Cause(
        name="name_example",
        description="description_example",
        image_url="image_url_example",
        active=True,
    ) # Cause | JSON representation of a single cause

    # example passing only required values which don't have defaults set
    try:
        # updates a single cause
        api_response = api_instance.causes_id_patch(id, cause)
        pprint(api_response)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->causes_id_patch: %s\n" % e)
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **str**| Cause Id |
 **cause** | [**Cause**](Cause.md)| JSON representation of a single cause |

### Return type

[**Cause**](Cause.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**201** | JSON representation of a cause |  -  |
**404** | not found |  -  |
**409** | Conflict. If-Match header provided does not match current contents |  -  |
**0** | Unexpected error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **causes_post**
> causes_post(cause)

Create a new cause

### Example

```python
import time
import generated
from generated.api import default_api
from generated.model.cause import Cause
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)


# Enter a context with an instance of the API client
with generated.ApiClient() as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)
    cause = Cause(
        name="name_example",
        description="description_example",
        image_url="image_url_example",
        active=True,
    ) # Cause | JSON representation of a single cause

    # example passing only required values which don't have defaults set
    try:
        # Create a new cause
        api_instance.causes_post(cause)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->causes_post: %s\n" % e)
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cause** | [**Cause**](Cause.md)| JSON representation of a single cause |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**201** | Created |  -  |
**404** | causes must have been misspelled in path |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **donations_get**
> [Donation] donations_get()

Returns a list of donations

### Example

```python
import time
import generated
from generated.api import default_api
from generated.model.donation import Donation
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)


# Enter a context with an instance of the API client
with generated.ApiClient() as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)

    # example, this endpoint has no required or optional parameters
    try:
        # Returns a list of donations
        api_response = api_instance.donations_get()
        pprint(api_response)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->donations_get: %s\n" % e)
```


### Parameters
This endpoint does not need any parameter.

### Return type

[**[Donation]**](Donation.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**200** | A JSON array of donations |  -  |
**404** | not found. The path must have a typo |  -  |
**0** | Unexpected error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **donations_id_delete**
> donations_id_delete(id)

deletes a single donation

### Example

```python
import time
import generated
from generated.api import default_api
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)


# Enter a context with an instance of the API client
with generated.ApiClient() as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)
    id = "id_example" # str | Donation Id

    # example passing only required values which don't have defaults set
    try:
        # deletes a single donation
        api_instance.donations_id_delete(id)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->donations_id_delete: %s\n" % e)
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **str**| Donation Id |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**204** | No content |  -  |
**404** | not found |  -  |
**409** | Conflict. If-Match header provided does not match current contents |  -  |
**0** | Unexpected error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **donations_id_get**
> Donation donations_id_get(id)

returns a single donation

### Example

```python
import time
import generated
from generated.api import default_api
from generated.model.donation import Donation
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)


# Enter a context with an instance of the API client
with generated.ApiClient() as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)
    id = "id_example" # str | Donation Id

    # example passing only required values which don't have defaults set
    try:
        # returns a single donation
        api_response = api_instance.donations_id_get(id)
        pprint(api_response)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->donations_id_get: %s\n" % e)
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **str**| Donation Id |

### Return type

[**Donation**](Donation.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**200** | JSON representation of a donation |  -  |
**404** | not found |  -  |
**0** | Unexpected error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **donations_id_patch**
> Donation donations_id_patch(id, donation)

updates a single donation

### Example

```python
import time
import generated
from generated.api import default_api
from generated.model.donation import Donation
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)


# Enter a context with an instance of the API client
with generated.ApiClient() as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)
    id = "id_example" # str | Donation Id
    donation = Donation(
        campaign="campaign_example",
        donor="donor_example",
        amount=3.14,
    ) # Donation | JSON representation of a single donation

    # example passing only required values which don't have defaults set
    try:
        # updates a single donation
        api_response = api_instance.donations_id_patch(id, donation)
        pprint(api_response)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->donations_id_patch: %s\n" % e)
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **str**| Donation Id |
 **donation** | [**Donation**](Donation.md)| JSON representation of a single donation |

### Return type

[**Donation**](Donation.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**201** | JSON representation of a donation |  -  |
**404** | not found |  -  |
**409** | Conflict. If-Match header provided does not match current contents |  -  |
**0** | Unexpected error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **donations_post**
> Donation donations_post(donation)

Create a new donation

### Example

```python
import time
import generated
from generated.api import default_api
from generated.model.donation import Donation
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)


# Enter a context with an instance of the API client
with generated.ApiClient() as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)
    donation = Donation(
        campaign="campaign_example",
        donor="donor_example",
        amount=3.14,
    ) # Donation | JSON representation of a single donation

    # example passing only required values which don't have defaults set
    try:
        # Create a new donation
        api_response = api_instance.donations_post(donation)
        pprint(api_response)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->donations_post: %s\n" % e)
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **donation** | [**Donation**](Donation.md)| JSON representation of a single donation |

### Return type

[**Donation**](Donation.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**201** | Created |  -  |
**404** | donations must have been misspelled in path |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **donors_get**
> [Donor] donors_get()

Returns a list of donors

### Example

```python
import time
import generated
from generated.api import default_api
from generated.model.donor import Donor
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)


# Enter a context with an instance of the API client
with generated.ApiClient() as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)

    # example, this endpoint has no required or optional parameters
    try:
        # Returns a list of donors
        api_response = api_instance.donors_get()
        pprint(api_response)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->donors_get: %s\n" % e)
```


### Parameters
This endpoint does not need any parameter.

### Return type

[**[Donor]**](Donor.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**200** | A JSON array of donors |  -  |
**404** | not found. The path must have a typo |  -  |
**0** | Unexpected error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **donors_id_delete**
> donors_id_delete(id)

deletes a single donor

### Example

```python
import time
import generated
from generated.api import default_api
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)


# Enter a context with an instance of the API client
with generated.ApiClient() as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)
    id = "id_example" # str | Donor Id

    # example passing only required values which don't have defaults set
    try:
        # deletes a single donor
        api_instance.donors_id_delete(id)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->donors_id_delete: %s\n" % e)
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **str**| Donor Id |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**204** | No content |  -  |
**404** | not found |  -  |
**409** | Conflict. If-Match header provided does not match current contents |  -  |
**0** | Unexpected error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **donors_id_donations_get**
> [Donation] donors_id_donations_get(id)

lists all donations for the specified donor

### Example

```python
import time
import generated
from generated.api import default_api
from generated.model.donation import Donation
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)


# Enter a context with an instance of the API client
with generated.ApiClient() as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)
    id = "id_example" # str | Donor Id

    # example passing only required values which don't have defaults set
    try:
        # lists all donations for the specified donor
        api_response = api_instance.donors_id_donations_get(id)
        pprint(api_response)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->donors_id_donations_get: %s\n" % e)
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **str**| Donor Id |

### Return type

[**[Donation]**](Donation.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**201** | JSON representation of an array of donations |  -  |
**404** | not found |  -  |
**0** | Unexpected error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **donors_id_get**
> Donor donors_id_get(id)

returns a single donor

### Example

```python
import time
import generated
from generated.api import default_api
from generated.model.donor import Donor
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)


# Enter a context with an instance of the API client
with generated.ApiClient() as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)
    id = "id_example" # str | Donor Id

    # example passing only required values which don't have defaults set
    try:
        # returns a single donor
        api_response = api_instance.donors_id_get(id)
        pprint(api_response)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->donors_id_get: %s\n" % e)
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **str**| Donor Id |

### Return type

[**Donor**](Donor.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**200** | JSON representation of a donor |  -  |
**404** | not found |  -  |
**0** | Unexpected error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **donors_id_patch**
> Donor donors_id_patch(id, donor)

updates a single donor

### Example

```python
import time
import generated
from generated.api import default_api
from generated.model.donor import Donor
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)


# Enter a context with an instance of the API client
with generated.ApiClient() as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)
    id = "id_example" # str | Donor Id
    donor = Donor(
        name="name_example",
        email="email_example",
        mailing_address="mailing_address_example",
    ) # Donor | JSON representation of a single donor

    # example passing only required values which don't have defaults set
    try:
        # updates a single donor
        api_response = api_instance.donors_id_patch(id, donor)
        pprint(api_response)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->donors_id_patch: %s\n" % e)
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **str**| Donor Id |
 **donor** | [**Donor**](Donor.md)| JSON representation of a single donor |

### Return type

[**Donor**](Donor.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**201** | JSON representation of a donor |  -  |
**404** | not found |  -  |
**409** | Conflict. If-Match header provided does not match current contents |  -  |
**0** | Unexpected error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **donors_post**
> donors_post(donor)

Create a new donor

### Example

```python
import time
import generated
from generated.api import default_api
from generated.model.donor import Donor
from pprint import pprint
# Defining the host is optional and defaults to https://api-pwrmtjf4hq-uc.a.run.app
# See configuration.py for a list of all supported configuration parameters.
configuration = generated.Configuration(
    host = "https://api-pwrmtjf4hq-uc.a.run.app"
)


# Enter a context with an instance of the API client
with generated.ApiClient() as api_client:
    # Create an instance of the API class
    api_instance = default_api.DefaultApi(api_client)
    donor = Donor(
        name="name_example",
        email="email_example",
        mailing_address="mailing_address_example",
    ) # Donor | JSON representation of a single donor

    # example passing only required values which don't have defaults set
    try:
        # Create a new donor
        api_instance.donors_post(donor)
    except generated.ApiException as e:
        print("Exception when calling DefaultApi->donors_post: %s\n" % e)
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **donor** | [**Donor**](Donor.md)| JSON representation of a single donor |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**201** | Created |  -  |
**404** | donors must have been misspelled in path |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

