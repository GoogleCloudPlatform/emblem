# swagger_client.DefaultApi

All URIs are relative to *https://api-pwrmtjf4hq-uc.a.run.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**campaigns_get**](DefaultApi.md#campaigns_get) | **GET** /campaigns | Returns a list of campaigns
[**campaigns_id_get**](DefaultApi.md#campaigns_id_get) | **GET** /campaigns/{id} | returns a single campaign

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

