import ballerina/http;
import ballerina/log;
import ballerina/os;
import ballerina/tcp;
import ballerinax/health.hl7v2;

configurable int port = 64294;
configurable map<string> hl7MessageProcessors = {"ADT": "http://localhost:9090", "MDM": "http://localhost:9091"};

// Read environment variables
configurable string serviceURL = os:getEnv("CHOREO_LISTENERTOADT_SERVICEURL");
configurable string choreoApiKey = os:getEnv("CHOREO_LISTENERTOADT_APIKEY");

# Port of the target backend

service on new tcp:Listener(port) {
    remote function onConnect(tcp:Caller caller) returns tcp:ConnectionService {
        log:printInfo(string `Client connected to HL7 server:   ${caller.remotePort.toString()}`);
        return new HL7ServiceConnectionService();
    }
}

service class HL7ServiceConnectionService {
    *tcp:ConnectionService;

    remote function onBytes(tcp:Caller caller, readonly & byte[] data) returns tcp:Error? {
        string|error fromBytes = string:fromBytes(data);
        if fromBytes is string {
            log:printDebug(string `Received HL7 Message: ${fromBytes}`);
        }

        hl7v2:Message|error parsedMsg = hl7v2:parse(data);
        if parsedMsg is error {
            log:printError(string `Error occurred while parsing the received message: ${parsedMsg.message()}`);
            return error(string `Error occurred while parsing the received message: ${parsedMsg.message()}`,
            parsedMsg);
        }

        // Get the message type prefix
        string messageTypePrefix = parsedMsg.name.substring(0, 3);

        // Send the message to the relevant processor
        if hl7MessageProcessors.hasKey(messageTypePrefix) {
            string processorUrl = hl7MessageProcessors.get(messageTypePrefix);
            do {
                http:Client httpClient = check new (processorUrl);
                http:Response response = check httpClient->post("/process", data);
                log:printInfo(string `Sent HL7 message to processor: ${processorUrl}, Response: ${response.statusCode}`);
            } on fail var e {
                log:printError(string `Error occurred while sending HL7 message to processor: ${processorUrl}, Error: ${e.message()}`);

            }
        }

        // Encode message to wire format.
        byte[]|error encodedMsg = generateAckMessage(parsedMsg);

        if encodedMsg is error {
            log:printError(string `Error occurred while encoding the ACK message: ${encodedMsg.message()}`);
            return error(string `Error occurred while encoding the ACK message: ${encodedMsg.message()}`, encodedMsg);
        }

        string|error resp = string:fromBytes(encodedMsg);
        if resp is string {
            log:printDebug(string `Encoded HL7 ACK Response Message: ${resp}`);
        }

        // Echoes back the data to the client from which the data is received.
        check caller->writeBytes(encodedMsg);

    }

    remote function onError(tcp:Error err) {
        log:printError(string `An error occurred while receiving HL7 message: ${err.message()}. Stack trace: `,
                err);
    }

    remote function onClose() {
        log:printInfo(string `Client left`);
    }
}
