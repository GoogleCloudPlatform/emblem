# Require both user and application authorization

* **Status:** approved
* **Last Updated:** 2021-07

Some of the API methods deal with person-specific information, such as donations, which have a donor ID and a
contribution amount. Calls to those methods will require an Authorization header with value 'Bearer _jwt_' where
_jwt_ is an identity token from Google Identity Platform.

Many API methods don't deal with particularly sensitive content, so do not require user authentication. However,
we don't want random requests being made to the API, so we require the application use the API to be
"registered". That is, it must have an API key that the owner of the REST API issues. All API requests
will require an API key as a query parameter, as in `GET /campaigns?api_key=registered_key`. Our REST API
will get a list of valid values from an environment variable. The client application will get the
specific value from an environment variable.

Note that this means that some requests use two authentication methods, one for the application using the
API, and one for the user requesting a sensitive operation.