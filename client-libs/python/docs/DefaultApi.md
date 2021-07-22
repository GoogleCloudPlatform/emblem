# swagger_client.DefaultApi

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
> list[Approver] approvers_get()

Returns a list of approvers

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()

try:
    # Returns a list of approvers
    api_response = api_instance.approvers_get()
    pprint(api_response)
except ApiException as e:
    print("Exception when calling DefaultApi->approvers_get: %s\n" % e)
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**list[Approver]**](Approver.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **approvers_id_delete**
> approvers_id_delete(id)

deletes a single approver

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()
id = 'id_example' # str | Approver Id

try:
    # deletes a single approver
    api_instance.approvers_id_delete(id)
except ApiException as e:
    print("Exception when calling DefaultApi->approvers_id_delete: %s\n" % e)
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **str**| Approver Id | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **approvers_id_get**
> Approver approvers_id_get(id)

returns a single approver

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()
id = 'id_example' # str | Approver Id

try:
    # returns a single approver
    api_response = api_instance.approvers_id_get(id)
    pprint(api_response)
except ApiException as e:
    print("Exception when calling DefaultApi->approvers_id_get: %s\n" % e)
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **str**| Approver Id | 

### Return type

[**Approver**](Approver.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **approvers_id_patch**
> Approver approvers_id_patch(body, id)

updates a single approver

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()
body = swagger_client.Approver() # Approver | JSON representation of a single approver
id = 'id_example' # str | Approver Id

try:
    # updates a single approver
    api_response = api_instance.approvers_id_patch(body, id)
    pprint(api_response)
except ApiException as e:
    print("Exception when calling DefaultApi->approvers_id_patch: %s\n" % e)
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **body** | [**Approver**](Approver.md)| JSON representation of a single approver | 
 **id** | **str**| Approver Id | 

### Return type

[**Approver**](Approver.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **approvers_post**
> approvers_post(body)

Create a new approver

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()
body = swagger_client.Approver() # Approver | JSON representation of a single approver

try:
    # Create a new approver
    api_instance.approvers_post(body)
except ApiException as e:
    print("Exception when calling DefaultApi->approvers_post: %s\n" % e)
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **body** | [**Approver**](Approver.md)| JSON representation of a single approver | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campaigns_get**
> list[Campaign] campaigns_get()

Returns a list of campaigns

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()

try:
    # Returns a list of campaigns
    api_response = api_instance.campaigns_get()
    pprint(api_response)
except ApiException as e:
    print("Exception when calling DefaultApi->campaigns_get: %s\n" % e)
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**list[Campaign]**](Campaign.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campaigns_id_delete**
> campaigns_id_delete(id)

deletes a single campaign

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()
id = 'id_example' # str | Campaign Id

try:
    # deletes a single campaign
    api_instance.campaigns_id_delete(id)
except ApiException as e:
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

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campaigns_id_donations_get**
> list[Donation] campaigns_id_donations_get(id)

lists all donations for the specified campaign

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()
id = 'id_example' # str | Campaign Id

try:
    # lists all donations for the specified campaign
    api_response = api_instance.campaigns_id_donations_get(id)
    pprint(api_response)
except ApiException as e:
    print("Exception when calling DefaultApi->campaigns_id_donations_get: %s\n" % e)
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **str**| Campaign Id | 

### Return type

[**list[Donation]**](Donation.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campaigns_id_get**
> Campaign campaigns_id_get(id)

returns a single campaign

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()
id = 'id_example' # str | Campaign Id

try:
    # returns a single campaign
    api_response = api_instance.campaigns_id_get(id)
    pprint(api_response)
except ApiException as e:
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

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campaigns_id_patch**
> Campaign campaigns_id_patch(body, id)

updates a single campaign

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()
body = swagger_client.Campaign() # Campaign | JSON representation of a single campaign
id = 'id_example' # str | Campaign Id

try:
    # updates a single campaign
    api_response = api_instance.campaigns_id_patch(body, id)
    pprint(api_response)
except ApiException as e:
    print("Exception when calling DefaultApi->campaigns_id_patch: %s\n" % e)
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **body** | [**Campaign**](Campaign.md)| JSON representation of a single campaign | 
 **id** | **str**| Campaign Id | 

### Return type

[**Campaign**](Campaign.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campaigns_post**
> campaigns_post(body)

Create a new campaign

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()
body = swagger_client.Campaign() # Campaign | JSON representation of a single campaign

try:
    # Create a new campaign
    api_instance.campaigns_post(body)
except ApiException as e:
    print("Exception when calling DefaultApi->campaigns_post: %s\n" % e)
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **body** | [**Campaign**](Campaign.md)| JSON representation of a single campaign | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **causes_get**
> list[Cause] causes_get()

Returns a list of causes

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()

try:
    # Returns a list of causes
    api_response = api_instance.causes_get()
    pprint(api_response)
except ApiException as e:
    print("Exception when calling DefaultApi->causes_get: %s\n" % e)
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**list[Cause]**](Cause.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **causes_id_delete**
> causes_id_delete(id)

deletes a single cause

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()
id = 'id_example' # str | Cause Id

try:
    # deletes a single cause
    api_instance.causes_id_delete(id)
except ApiException as e:
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

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **causes_id_get**
> Cause causes_id_get(id)

returns a single cause

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()
id = 'id_example' # str | Cause Id

try:
    # returns a single cause
    api_response = api_instance.causes_id_get(id)
    pprint(api_response)
except ApiException as e:
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

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **causes_id_patch**
> Cause causes_id_patch(body, id)

updates a single cause

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()
body = swagger_client.Cause() # Cause | JSON representation of a single cause
id = 'id_example' # str | Cause Id

try:
    # updates a single cause
    api_response = api_instance.causes_id_patch(body, id)
    pprint(api_response)
except ApiException as e:
    print("Exception when calling DefaultApi->causes_id_patch: %s\n" % e)
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **body** | [**Cause**](Cause.md)| JSON representation of a single cause | 
 **id** | **str**| Cause Id | 

### Return type

[**Cause**](Cause.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **causes_post**
> causes_post(body)

Create a new cause

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()
body = swagger_client.Cause() # Cause | JSON representation of a single cause

try:
    # Create a new cause
    api_instance.causes_post(body)
except ApiException as e:
    print("Exception when calling DefaultApi->causes_post: %s\n" % e)
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **body** | [**Cause**](Cause.md)| JSON representation of a single cause | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **donations_get**
> list[Donation] donations_get()

Returns a list of donations

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()

try:
    # Returns a list of donations
    api_response = api_instance.donations_get()
    pprint(api_response)
except ApiException as e:
    print("Exception when calling DefaultApi->donations_get: %s\n" % e)
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**list[Donation]**](Donation.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **donations_id_delete**
> donations_id_delete(id)

deletes a single donation

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()
id = 'id_example' # str | Donation Id

try:
    # deletes a single donation
    api_instance.donations_id_delete(id)
except ApiException as e:
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

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **donations_id_get**
> Donation donations_id_get(id)

returns a single donation

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()
id = 'id_example' # str | Donation Id

try:
    # returns a single donation
    api_response = api_instance.donations_id_get(id)
    pprint(api_response)
except ApiException as e:
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

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **donations_id_patch**
> Donation donations_id_patch(body, id)

updates a single donation

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()
body = swagger_client.Donation() # Donation | JSON representation of a single donation
id = 'id_example' # str | Donation Id

try:
    # updates a single donation
    api_response = api_instance.donations_id_patch(body, id)
    pprint(api_response)
except ApiException as e:
    print("Exception when calling DefaultApi->donations_id_patch: %s\n" % e)
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **body** | [**Donation**](Donation.md)| JSON representation of a single donation | 
 **id** | **str**| Donation Id | 

### Return type

[**Donation**](Donation.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **donations_post**
> Donation donations_post(body)

Create a new donation

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()
body = swagger_client.Donation() # Donation | JSON representation of a single donation

try:
    # Create a new donation
    api_response = api_instance.donations_post(body)
    pprint(api_response)
except ApiException as e:
    print("Exception when calling DefaultApi->donations_post: %s\n" % e)
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **body** | [**Donation**](Donation.md)| JSON representation of a single donation | 

### Return type

[**Donation**](Donation.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **donors_get**
> list[Donor] donors_get()

Returns a list of donors

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()

try:
    # Returns a list of donors
    api_response = api_instance.donors_get()
    pprint(api_response)
except ApiException as e:
    print("Exception when calling DefaultApi->donors_get: %s\n" % e)
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**list[Donor]**](Donor.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **donors_id_delete**
> donors_id_delete(id)

deletes a single donor

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()
id = 'id_example' # str | Donor Id

try:
    # deletes a single donor
    api_instance.donors_id_delete(id)
except ApiException as e:
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

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **donors_id_donations_get**
> list[Donation] donors_id_donations_get(id)

lists all donations for the specified donor

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()
id = 'id_example' # str | Donor Id

try:
    # lists all donations for the specified donor
    api_response = api_instance.donors_id_donations_get(id)
    pprint(api_response)
except ApiException as e:
    print("Exception when calling DefaultApi->donors_id_donations_get: %s\n" % e)
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **str**| Donor Id | 

### Return type

[**list[Donation]**](Donation.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **donors_id_get**
> Donor donors_id_get(id)

returns a single donor

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()
id = 'id_example' # str | Donor Id

try:
    # returns a single donor
    api_response = api_instance.donors_id_get(id)
    pprint(api_response)
except ApiException as e:
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

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **donors_id_patch**
> Donor donors_id_patch(body, id)

updates a single donor

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()
body = swagger_client.Donor() # Donor | JSON representation of a single donor
id = 'id_example' # str | Donor Id

try:
    # updates a single donor
    api_response = api_instance.donors_id_patch(body, id)
    pprint(api_response)
except ApiException as e:
    print("Exception when calling DefaultApi->donors_id_patch: %s\n" % e)
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **body** | [**Donor**](Donor.md)| JSON representation of a single donor | 
 **id** | **str**| Donor Id | 

### Return type

[**Donor**](Donor.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **donors_post**
> donors_post(body)

Create a new donor

### Example
```python
from __future__ import print_function
import time
import swagger_client
from swagger_client.rest import ApiException
from pprint import pprint

# create an instance of the API class
api_instance = swagger_client.DefaultApi()
body = swagger_client.Donor() # Donor | JSON representation of a single donor

try:
    # Create a new donor
    api_instance.donors_post(body)
except ApiException as e:
    print("Exception when calling DefaultApi->donors_post: %s\n" % e)
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **body** | [**Donor**](Donor.md)| JSON representation of a single donor | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

