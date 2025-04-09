# HL7v2 ADT Message Processing Template

## Configuration Values

``` toml
port = 64959                                                                        # port of the listening HL7 service

backendType = "FHIR_REPO"                                                           # Backend type, now only FHIR_REPO is supported
targetBackendUrl = "http://hapi.fhir.org/baseR4"                                    # Backend server URL
backendAuthTokenURL = "https://api.asgardeo.io/t/isurusamaranayake/oauth2/token"    # Backend's Auth token endpoint
backendClientId = "IHar0XyQhfAX4f56JiuKJAONl8Ya"                                    # Client ID for Backend Auth
backendClientSecret = "dWTZfbVN2kLJ6EGG2_CnU4AUFJ0Uf3kZAp9Gs3FoRLwa"                # Client Secret for Backend Auth
```