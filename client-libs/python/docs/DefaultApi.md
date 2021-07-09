# swagger_client.DefaultApi

All URIs are relative to *https://api-pwrmtjf4hq-uc.a.run.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**campaigns_get**](DefaultApi.md#campaigns_get) | **GET** /campaigns | Returns a list of campaigns
[**campaigns_id_delete**](DefaultApi.md#campaigns_id_delete) | **DELETE** /campaigns/{id} | deletes a single campaign
[**campaigns_id_get**](DefaultApi.md#campaigns_id_get) | **GET** /campaigns/{id} | returns a single campaign
[**campaigns_id_patch**](DefaultApi.md#campaigns_id_patch) | **PATCH** /campaigns/{id} | updates a single campaign
[**campaigns_post**](DefaultApi.md#campaigns_post) | **POST** /campaigns | Create a new campaign

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

