import ballerina/log;
import ballerinax/health.clients.hl7;
import ballerinax/health.hl7v2;

final hl7:HL7Client hl7Client = check new (targetBackendUrl, targetBackendPort);

public function sendToHl7Exchange(hl7v2:Message message) returns json|error {

    byte[] encode = check hl7v2:encode(hl7Version, message);
    string encodedMessage = check string:fromBytes(encode);
    log:printInfo(string `Encoded HL7 message: ${encodedMessage}`);

    hl7v2:Message msg = check hl7Client->sendMessage(message);
    log:printInfo(string `Message recieved from HL7 exchange: ${msg.toString()}`);
    return msg.toJson();

}

