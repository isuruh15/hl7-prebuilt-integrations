# HL7v2 ADT Message Processing Service

This service processes HL7v2 ADT (Admission, Discharge, and Transfer) messages by converting them to FHIR resources and storing them in a FHIR repository. It provides a RESTful interface for message processing and health monitoring.

## Features

- Processes HL7v2 ADT messages (A01, A39, A40)
- Converts HL7v2 messages to FHIR R4 resources
- Supports custom mapping for Patient and Encounter resources
- Stores converted FHIR resources in a FHIR repository
- Health check endpoint for monitoring
- OAuth2 authentication support for backend FHIR repository

## Prerequisites

- Ballerina Swan Lake 2201.8.0 or later
- Access to a FHIR R4 repository
- OAuth2 credentials for FHIR repository authentication

## Configuration

The service can be configured using a `Config.toml` file with the following parameters:

```toml
# HTTP service port
port = 9090

# Backend configuration
backendType = "FHIR_REPO"                                    # Type of backend (currently only FHIR_REPO is supported)
targetBackendUrl = "http://hapi.fhir.org/baseR4"            # FHIR repository URL
backendAuthTokenURL = "<oauth-token-url>"                    # OAuth2 token endpoint
backendClientId = "<client-id>"                             # OAuth2 client ID
backendClientSecret = "<client-secret>"                     # OAuth2 client secret
scopes = ["scope1", "scope2"]                               # OAuth2 scopes
```

## API Endpoints

### 1. Process HL7v2 Message
- **Endpoint**: POST /process
- **Description**: Processes an HL7v2 ADT message
- **Request Body**: Raw HL7v2 message as bytes
- **Response**: 
  - Success: `{"status": "success"}`
  - Error: Error message with appropriate HTTP status code

### 2. Health Check
- **Endpoint**: GET /healthcheck
- **Description**: Checks the service health
- **Response**: `{"status": "healthy"}`

## Error Handling

The service implements comprehensive error handling with different log levels:
- NORMAL: Normal operation
- FAILURE: Operation failures
- CHECK_FUNCTION: Functional checks
- OFF_SPEC: Out of specification operation
- MAINTENANCE_REQUIRED: System requires maintenance
- UNKNOWN: Unknown state

## Supported Message Types

Currently supports the following HL7v2 ADT message types:
- ADT_A01: Admit/Visit Notification
- ADT_A40: Patient Merge

## FHIR Resource Processing

The service processes and customizes the following FHIR resources:
- Patient
- Encounter

Each resource type has specific mapping logic that can be customized in the `custom_mappings.bal` file.

## Running the Service

1. Configure the `Config.toml` file with appropriate values
2. Run the service using Ballerina CLI:
   ```bash
   bal run
   ```
