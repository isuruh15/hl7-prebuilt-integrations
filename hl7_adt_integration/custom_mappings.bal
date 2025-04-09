import ballerina/log;
import ballerinax/health.fhir.r4 as r4;
import ballerinax/health.fhir.r4.international401;
import ballerinax/health.fhir.r4.parser as r4parser;
import ballerinax/health.hl7v2;
import ballerinax/health.hl7v23;

public isolated function processBundle(json fhirBundle, hl7v2:Message message) returns r4:Bundle|error? {

    // refer to message parameter if any data need to be taken from Original message
    r4:Bundle bundle = <r4:Bundle>check r4parser:parse(fhirBundle);
    r4:BundleEntry[] updatedEntries = [];
    if bundle is r4:Bundle {
        r4:BundleEntry[] entries = <r4:BundleEntry[]>bundle.entry;
        foreach var entry in entries {
            map<anydata> fhirResource = <map<anydata>>entry?.'resource;
            if fhirResource["resourceType"].toString() == "Patient" {
                international401:Patient patientResource = <international401:Patient>check r4parser:parse(fhirResource.toJson());

                log:printDebug(string `[${NORMAL}] Patient resource: ${patientResource.toJsonString()}`);

                patientResource = processPatientResource(patientResource, message);
                log:printInfo(string `Updated Patient resource: ${patientResource.toJsonString()}`);
                updatedEntries.push({'resource: patientResource});
            } else if fhirResource["resourceType"].toString() == "Encounter" {
                international401:Encounter encounterResource = <international401:Encounter>check r4parser:parse(fhirResource.toJson());

                log:printDebug(string `[${NORMAL}] Encounter resource: ${encounterResource.toJsonString()}`);

                international401:Encounter|error processedEncounterResource = processEncounterResource(encounterResource, message);
                if processedEncounterResource is international401:Encounter {
                    encounterResource = processedEncounterResource;
                } else {
                    log:printError(string `[${FAILURE}] Error processing Encounter resource: ${processedEncounterResource.message()}`);
                    return processedEncounterResource;
                }
                updatedEntries.push({'resource: encounterResource});
            } else {
                updatedEntries.push(entry);
            }
        }
    } else {

    }
    bundle.entry = updatedEntries;

    return bundle;

}

# Customization logic for Patient resource.
#
# + patient - input Patient resource
# + message - original HL7v2 message
# + return - updated Patient resource
public isolated function processPatientResource(international401:Patient patient, hl7v2:Message message) returns international401:Patient {

    log:printDebug(string `FHIR resource: ${patient.toJsonString()}`);

    if message is hl7v23:ADT_A01 {

        international401:Patient mapADTA01ToPatient = mapADT_A01ToPatient(patient, <hl7v23:ADT_A01>message);
        return mapADTA01ToPatient;
    } else if message is hl7v23:ADT_A39 {

        // merge patient message
        international401:Patient mapADTA39ToPatient = mapADT_A39ToPatient(patient, <hl7v23:ADT_A39>message);
        return mapADTA39ToPatient;
    }
    // No customizations
    return patient;
}

public isolated function mapADT_A01ToPatient(international401:Patient patient, hl7v23:ADT_A01 message) returns international401:Patient => {
    maritalStatus: patient.maritalStatus,

    meta: patient.meta,

    text: patient.text,
    resourceType: patient.resourceType,
    identifier: [
        {
            id: message.pid.pid1,
            value: message.pid.pid1,
            system: ""
        }
    ],
    extension: patient.extension,
    gender: patient.gender,
    modifierExtension: patient.modifierExtension,
    link: patient.link,
    language: patient.language,
    contact: patient.contact,
    deceasedDateTime: patient.deceasedDateTime,
    generalPractitioner: patient.generalPractitioner,
    telecom: patient.telecom,
    id: patient.id,
    communication: patient.communication,
    address: patient.address,
    multipleBirthBoolean: patient.multipleBirthBoolean,
    active: patient.active,
    photo: patient.photo,
    birthDate: patient.birthDate,
    contained: patient.contained,
    deceasedBoolean: patient.deceasedBoolean,
    managingOrganization: patient.managingOrganization,
    multipleBirthInteger: patient.multipleBirthInteger,
    name: patient.name,
    implicitRules: patient.implicitRules

};

public isolated function mapADT_A39ToPatient(international401:Patient patient, hl7v23:ADT_A39 message) returns international401:Patient => let var survivingPatientId = message.patient[0].pid.pid1 in {
        maritalStatus: patient.maritalStatus,

        meta: patient.meta,

        text: patient.text,
        resourceType: patient.resourceType,
        identifier: [
            {
                system: "http://example.org/mrn",
                value: survivingPatientId,
                id: survivingPatientId
            }
        ],
        extension: patient.extension,
        gender: patient.gender,
        modifierExtension: patient.modifierExtension,
        link: patient.link,
        language: patient.language,
        contact: patient.contact,
        deceasedDateTime: patient.deceasedDateTime,
        generalPractitioner: patient.generalPractitioner,
        telecom: patient.telecom,
        id: patient.id,
        communication: patient.communication,
        address: patient.address,
        multipleBirthBoolean: patient.multipleBirthBoolean,
        active: patient.active,
        photo: patient.photo,
        birthDate: patient.birthDate,
        contained: patient.contained,
        deceasedBoolean: patient.deceasedBoolean,
        managingOrganization: patient.managingOrganization,
        multipleBirthInteger: patient.multipleBirthInteger,
        name: patient.name,
        implicitRules: patient.implicitRules

    };

# Custom logic to update Encounter resource.
#
# + encounter - input Encounter resource
# + message - original HL7v2 message
# + return - updated Encounter resource
public isolated function processEncounterResource(international401:Encounter encounter, hl7v2:Message message) returns international401:Encounter|error {

    log:printDebug(string `FHIR resource: ${encounter.toJsonString()}`);

    // Custom logic to update fields of Encounter resource comes here.

    encounter.status = "finished";

    log:printInfo(string `Encounter message Type: ${message is hl7v23:ADT_A39}`);

    if message is hl7v23:ADT_A01 {

        // No customizations
        return encounter;

    } else if message is hl7v23:ADT_A39 {
        // merge patient message
        hl7v23:ADT_A39 parsedMessage = <hl7v23:ADT_A39>message;

        string patientGivenName = parsedMessage.patient[0].pid.pid5[0].xpn2;

        log:printInfo(string `Patient given name: ${patientGivenName}`);

        // Search for Patient from given name and get the patient id
        json|xml patientResource = searchInFhirRepo("Patient", "given", patientGivenName);

        log:printInfo(string `Patient resource: ${patientResource.toString()}`);
        international401:Patient patient = <international401:Patient>check r4parser:parse(patientResource);

        international401:Encounter mapADTA01ToEncounter = mapADT_A39ToEncounter(encounter, patient);
        json|error mergeJson = patient.toJson().mergeJson(mapADTA01ToEncounter.toJson());
        if mergeJson is json {
            // return <international401:Patient>mergeJson;
            international401:Encounter|error encounterUpdated;
            encounterUpdated = r4parser:parse(mergeJson).ensureType(international401:Encounter);
            if encounterUpdated is international401:Encounter {
                return encounterUpdated;
            }
        }
    }
    return encounter;

}

isolated function mapADT_A39ToEncounter(international401:Encounter encounter, international401:Patient patient) returns international401:Encounter => let var existingPatientId = patient.id, var patientReference = existingPatientId is string ? existingPatientId : "0000" in {
        subject: {
            id: encounter.subject?.id,
            reference: patientReference
        },
        'class: encounter.'class,
        status: encounter.status
    };

public isolated function mapADT_A40ToPatient(international401:Patient patient, hl7v23:ADT_A40 message) returns international401:Patient => let var survivingPatientId = message.patient[0].pid.pid1 in {
        maritalStatus: patient.maritalStatus,

        meta: patient.meta,

        text: patient.text,
        resourceType: patient.resourceType,
        identifier: [
            {
                system: "http://example.org/mrn",
                value: survivingPatientId,
                id: survivingPatientId
            }
        ],
        extension: patient.extension,
        gender: patient.gender,
        modifierExtension: patient.modifierExtension,
        link: patient.link,
        language: patient.language,
        contact: patient.contact,
        deceasedDateTime: patient.deceasedDateTime,
        generalPractitioner: patient.generalPractitioner,
        telecom: patient.telecom,
        id: patient.id,
        communication: patient.communication,
        address: patient.address,
        multipleBirthBoolean: patient.multipleBirthBoolean,
        active: patient.active,
        photo: patient.photo,
        birthDate: patient.birthDate,
        contained: patient.contained,
        deceasedBoolean: patient.deceasedBoolean,
        managingOrganization: patient.managingOrganization,
        multipleBirthInteger: patient.multipleBirthInteger,
        name: patient.name,
        implicitRules: patient.implicitRules

    };

