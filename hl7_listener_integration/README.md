# HL7 Message Listener

This is a Ballerina-based HL7 message processor that receives HL7 messages over TCP, processes them, and routes them to specific message processors based on the message type.

## Features

- TCP-based HL7 message listener
- Support for multiple HL7 versions (v2.3, v2.4, v2.5, v2.6)
- Message routing based on message type (ADT, MDM)
- Automatic acknowledgment generation
- Configurable message processor endpoints
- Error handling and logging

## Prerequisites

- Ballerina Swan Lake
- HTTP endpoints for message processors

## Configuration

The application can be configured using the following parameters:

### Required Configurations

```toml
# Config.toml
port = 64294  # TCP port to listen for HL7 messages

# Message processor endpoints
[hl7MessageProcessors]
"ADT" = "http://localhost:9090"
"MDM" = "http://localhost:9091"
```

### Environment Variables

- `CHOREO_LISTENERTOADT_SERVICEURL` - Service URL for the ADT processor
- `CHOREO_LISTENERTOADT_APIKEY` - API key for authentication

## Running the Application

1. Set up the configuration in `Config.toml`
2. Set the required environment variables
3. Run the application:
   ```bash
   bal run
   ```

## Message Flow

1. Client connects to the TCP listener
2. HL7 message is received and parsed
3. Message type is identified (ADT, MDM)
4. Message is routed to the appropriate processor
5. Acknowledgment is generated and sent back to the client

## Supported Message Types

- ADT (Admission, Discharge, Transfer)
- MDM (Medical Document Management)

## Error Handling

The application includes comprehensive error handling for:
- Message parsing errors
- Message routing errors
- Processor communication errors
- Message encoding errors

## Logging

The application provides detailed logging for:
- Client connections/disconnections
- Message reception and parsing
- Message routing
- Error conditions
