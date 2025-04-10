# HL7 To XML Service

This service provides XML to HL7 message transformation capabilities, specifically handling admission messages and converting them to HL7 v2.3 or v2.4 ADT_A01 messages.

## Features

- Accepts XML admission data via HTTP POST endpoint
- Transforms XML data to HL7 v2.3 or v2.4 ADT_A01 messages
- Forwards transformed messages to an HL7 exchange
- Supports configurable HL7 version and backend connectivity

## Prerequisites

- Ballerina Swan Lake 2201.12.0 or later

## Configuration

The service requires the following configurations:

```toml
# Config.toml
targetBackendUrl = "<HL7 exchange backend URL>"
targetBackendPort = <HL7 exchange port number>
hl7Version = "<HL7 version (2.3 or 2.4)>"
listenerPort = <HTTP listener port>
```

## API Reference

### Transform XML to HL7

**Endpoint:** POST /transform/xml

**Request Body:** XML data containing admission message with the following structure:
```xml
<AdmissionMessage>
    <PatientInformation>
        <Identifiers>
            <MedicalRecordNumber>...</MedicalRecordNumber>
        </Identifiers>
        <PersonalDetails>
            <LastName>...</LastName>
            <FirstName>...</FirstName>
            <MiddleName>...</MiddleName>
            <BirthDate>...</BirthDate>
            <Gender>...</Gender>
        </PersonalDetails>
        <ContactInformation>
            <Address>
                <Street>...</Street>
                <City>...</City>
                <State>...</State>
                <PostalCode>...</PostalCode>
                <Country>...</Country>
            </Address>
            <HomePhone>...</HomePhone>
        </ContactInformation>
    </PatientInformation>
    <VisitDetails>
        <SequenceNumber>...</SequenceNumber>
        <PatientType>...</PatientType>
        <Location>
            <Unit>...</Unit>
            <RoomNumber>...</RoomNumber>
            <BedId>...</BedId>
            <Campus>...</Campus>
        </Location>
        <AdmissionCategory>...</AdmissionCategory>
        <AttendingClinician>
            <ProviderId>...</ProviderId>
            <LastName>...</LastName>
            <FirstName>...</FirstName>
        </AttendingClinician>
        <EncounterNumber>...</EncounterNumber>
        <AdmissionDateTime>...</AdmissionDateTime>
    </VisitDetails>
    <ClinicalInformation>
        <SequenceNumber>...</SequenceNumber>
        <CodingStandard>...</CodingStandard>
        <DiagnosisCode>...</DiagnosisCode>
        <DiagnosisDescription>...</DiagnosisDescription>
        <DiagnosisDateTime>...</DiagnosisDateTime>
        <DiagnosisCategory>...</DiagnosisCategory>
    </ClinicalInformation>
</AdmissionMessage>
```

**Response:**
- 201 Created: Successfully transformed and sent to HL7 exchange
- 500 Internal Server Error: Error in transformation or sending to HL7 exchange

## Running the Service

1. Create a `Config.toml` file with the required configurations
2. Run the service using:
```bash
bal run
```

The service will start on the configured port and begin accepting XML messages for transformation.