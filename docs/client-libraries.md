# Emblem - Client Libraries

Emblem applications and tools are expected to interact with application data
through the [Content API](./content-api.md). They can operate that API via HTTP
requests directly or use a client library.

The Content API is specified using the OpenAPI specification, in this case, using
the file [openapi.yaml](../content-api/openapi.yaml).

One benefit of documenting an API this is the ability to automatically generate
code compatible with it. We used one such tool,
[OpenAPI Generator](https://github.com/OpenAPITools/openapi-generator),
to create a Python client library for Emblem. See the link for the various 
options for installing the tool.

Once the tool is generated, open a shell and navigate to the
[client-libs/python](../client-libs/python) directory, and run the command:

    rm -rf generated && openapi-generator-cli generate -g python -i ../../content-api/openapi.yaml

Python programs can directly import from the newly generated library, or use
an Emblem-specific shim that imports and wraps that library:

    import emblem_client
    client = emblem_client.EmblemClient(API_SERVER_URL, **kwargs)
