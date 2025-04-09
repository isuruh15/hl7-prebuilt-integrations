import ballerina/log;
import ballerinax/health.fhir.r4;
import ballerinax/health.hl7v2;
import ballerinax/health.hl7v2.utils.v2tofhirr4;

public isolated function processADTMessage(hl7v2:Message message) returns error? {

    if backendType == "FHIR_REPO" {
        // Convert HL7v2 message to FHIR resource
        json v2tofhirResult = check v2tofhirr4:v2ToFhir(message);
        log:printDebug(string `[${NORMAL}] FHIR resource generated from HL7v2 message: ${v2tofhirResult.toString()}`);
        r4:Bundle|error? processBundleResult = processBundle(v2tofhirResult, message);

        if processBundleResult is error {
            return log:printError(string `[${FAILURE}] Error processing FHIR bundle: ${processBundleResult.message()}`);

        } else if processBundleResult is r4:Bundle {

            log:printDebug(string `[${NORMAL}] FHIR bundle sent to the FHIR repository: ${processBundleResult.toString()}`);
            boolean sendToFhirRepoResult = extractBundleAndSendToFhirRepo(processBundleResult);
            if (!sendToFhirRepoResult) {
                return log:printError(string `[${FAILURE}] Failed to send FHIR bundle to the FHIR repository`);
            }

        }
    }
    // Handle other backend types: HL7v2, Custom Data Services etc.
}

