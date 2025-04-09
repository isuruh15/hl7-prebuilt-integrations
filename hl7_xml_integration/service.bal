import ballerina/data.xmldata;
import ballerina/http;
import ballerina/log;
import ballerinax/health.hl7v2;

configurable string targetBackendUrl = ?;
configurable int targetBackendPort = ?;
configurable string hl7Version = ?;
configurable int listenerPort = ?;

service / on new http:Listener(9095) {

    resource function post transform/'xml(@http:Payload xml xmlData) returns http:InternalServerError & readonly|string|http:Created & readonly|error {

        log:printDebug(string `Received XML data:  ${xmlData.toBalString()}`);
        do {
            AdmissionMessage admissionMessage = check xmldata:parseAsType(xmlData, {}, AdmissionMessage);
            log:printDebug(string `Parsed XML data: ${admissionMessage.toString()}`);

            hl7v2:Message? convertedHl7Message = routeAdmissionMessage(admissionMessage, hl7Version);

            json|error? sendToHl7ExchangeResult = ();

            if convertedHl7Message is hl7v2:Message {
                sendToHl7ExchangeResult = sendToHl7Exchange(convertedHl7Message);
            } else {
                log:printError("Error converting the message to HL7 format");
                return http:INTERNAL_SERVER_ERROR;
            }

            if sendToHl7ExchangeResult is error {
                log:printError(string `Error sending HL7 message to exchange: ${sendToHl7ExchangeResult.message()}`);
                log:printError("error", sendToHl7ExchangeResult);
                return http:INTERNAL_SERVER_ERROR;

            } else {
                log:printDebug(string `HL7 message sent to exchange: ${sendToHl7ExchangeResult.toString()}`);
                return sendToHl7ExchangeResult.toString();
            }
        } on fail var e {
            log:printError(string `Error occurred while parsing the XML data: ${e.message()}`);
            return http:INTERNAL_SERVER_ERROR;
        }

    }
}
