# Campaign


## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | **str** | the campaign&#39;s display name | 
**cause** | **str** | the id of the Cause this campaign is for | 
**id** | **str** | unique, system-assigned identifier | [optional] [readonly] 
**description** | **str** | the purpose of the campaign | [optional]  if omitted the server will use the default value of "no description"
**managers** | **[str]** |  | [optional]  if omitted the server will use the default value of []
**goal** | **float** | the fundraising goal, in USD | [optional]  if omitted the server will use the default value of 0
**image_url** | **str, none_type** | location of image to display for the campaign | [optional] 
**active** | **bool** | is this campaign accepting donations at this time? | [optional]  if omitted the server will use the default value of False
**time_created** | **datetime** | system-assigned creation timestamp | [optional] [readonly] 
**updated** | **datetime** | system-assigned update timestamp | [optional] [readonly] 
**self_link** | **str** | full URI of the resource | [optional] [readonly] 
**any string name** | **bool, date, datetime, dict, float, int, list, str, none_type** | any string name can be used but the value must be the correct type | [optional]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


