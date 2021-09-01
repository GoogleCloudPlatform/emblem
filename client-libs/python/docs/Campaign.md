# Campaign


## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **str** | unique, system-assigned identifier | [optional] [readonly] 
**name** | **str** | the campaign&#39;s display name | [optional] 
**description** | **str** | the purpose of the campaign | [optional] 
**cause** | **str** | the id of the Cause this campaign is for | [optional] 
**managers** | **[str]** |  | [optional] 
**goal** | **float** | the fundraising goal, in USD | [optional] 
**image_url** | **str** | location of image to display for the campaign | [optional] 
**active** | **bool** | is this campaign accepting donations at this time? | [optional] 
**time_created** | **datetime** | system-assigned creation timestamp | [optional] [readonly] 
**updated** | **datetime** | system-assigned update timestamp | [optional] [readonly] 
**self_link** | **str** | full URI of the resource | [optional] [readonly] 
**any string name** | **bool, date, datetime, dict, float, int, list, str, none_type** | any string name can be used but the value must be the correct type | [optional]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


