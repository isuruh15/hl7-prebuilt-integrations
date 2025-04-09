import ballerina/http;
import ballerina/log;
import ballerinax/health.hl7v2;

configurable int port = 9090;
configurable string backendType = "FHIR_REPO";
configurable string backendAuthTokenURL = ?;
configurable string backendClientId = ?;
configurable string backendClientSecret = ?;
configurable string targetBackendUrl = ?;
configurable string[] scopes = ?;

service / on new http:Listener(9090) {

    isolated resource function post process(@http:Payload byte[] payload) returns json|http:Response|error {

        hl7v2:Message|error parsedMsg = hl7v2:parse(payload);

        if parsedMsg is error {
            string errorMessage = string `[${FAILURE}] Error occurred while parsing the received message: ${parsedMsg.message()}`;
            log:printError(errorMessage);
            http:Response response = new;
            response.statusCode = 400;
            response.setJsonPayload({message: errorMessage});
            return response;
        } else {
            error? processADTMessageResult = processADTMessage(parsedMsg);
            if processADTMessageResult is error {
                string errorMessage = string `[${FAILURE}] Error occurred while processing the received HL7 message: ${processADTMessageResult.message()}`;
                http:Response response = new;
                response.statusCode = 500;
                response.setJsonPayload({message: errorMessage});
                return response;
            }
            log:printDebug(string `Successfully processed the received HL7 message. Response: ${processADTMessageResult.toString()}`);
            return {status: "success"};
        }

    }

    isolated resource function get healthcheck() returns json {

        return {status: "healthy"};
    }

}
