# Open API Tooling

* **Status:** approved
* **Last Updated:** 2021-08-17
* **Objective:** Determine an approach to design-driven API development

Use OpenAPI to describe the API resources, operations, and authentication requirements. Then generate
client libraries with OpenAPI code generation tools.

Swagger-codegen was tried out, then openapi-generator-cli. Both are open source using the Apache License 2.0.
openapi-generator-cli was forked from swagger-codegen in 2018.

They are functionally nearly identical, but openapi-generator-cli has more options and is
more actively developed. The Swagger tool is owned by Smart Bear, while the OpenAPI tool
is community owned.

After using both, we will use openapi-generator-cli going forward.
