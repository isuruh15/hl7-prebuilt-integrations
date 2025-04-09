import ballerina/log;
import ballerina/uuid;
import ballerinax/health.hl7v2;
import ballerinax/health.hl7v23;
import ballerinax/health.hl7v24;

function routeAdmissionMessage(AdmissionMessage admissionMessage, string hl7Version) returns hl7v2:Message? {
    if (hl7Version == "2.3") {
        return mapAdmissionToAdt23(admissionMessage);
    } else if (hl7Version == "2.4") {
        return mapAdmissionToAdt24(admissionMessage);
    } else {
        log:printError("Unsupported HL7 version");
    }
    return;
}

function mapAdmissionToAdt24(AdmissionMessage admissionMessage) returns hl7v24:ADT_A01 => {
    msh: {
        msh1: "|",
        msh2: "^~\\&",
        msh3: {
            hd1: "HOSPITAL_EMR"
        },
        msh4: {
            hd1: "MAIN_HOSPITAL"
        },
        msh5: {
            hd1: "RAPP"
        },
        msh6: {
            hd1: "198808181126"
        },
        msh7: {
            ts1: "2020-05-08T13:06:43"
        },
        msh9: {
            msg1: "ADT",
            msg2: "A01"
        },
        msh10: uuid:createType1AsString().substring(0, 8),
        msh11: {
            pt1: "P"
        },
        msh12: {
            vid1: hl7v24:VERSION
        },
        msh15: "AL",
        msh17: "44",
        msh18: ["ASCII"]
    },
    evn: {
        evn1: "NEW_ADMISSION"
    },
    pid: {
        pid5: [
            {
                xpn1: {
                    fn1: admissionMessage.PatientInformation.PersonalDetails.LastName
                },
                xpn2: admissionMessage.PatientInformation.PersonalDetails.FirstName,
                xpn3: admissionMessage.PatientInformation.PersonalDetails.MiddleName
            }
        ]
    },
    pv1: {}
};

function mapAdmissionToAdt23(AdmissionMessage admissionMessage) returns hl7v23:ADT_A01 => {
    msh: {
        msh1: "|",
        msh2: "^~\\&",
        msh3: {
            hd1: "HOSPITAL_EMR"
        },
        msh4: {
            hd1: "MAIN_HOSPITAL"
        },
        msh5: {
            hd1: "RAPP"
        },
        msh6: {
            hd1: "198808181126"
        },
        msh7: {
            ts1: "2020-05-08T13:06:43"
        },
        msh9: {
            cm_msg1: "ADT",
            cm_msg2: "A01"
        },
        msh10: uuid:createType1AsString().substring(0, 8),
        msh11: {
            pt1: "P"
        },
        msh12: hl7v23:VERSION,
        msh15: "AL",
        msh17: "44",
        msh18: ["ASCII"]
    },
    evn: {
        evn1: "NEW_ADMISSION"
    },
    pid: {
        pid5: [
            {
                xpn1: admissionMessage.PatientInformation.PersonalDetails.LastName,
                xpn2: admissionMessage.PatientInformation.PersonalDetails.FirstName,
                xpn3: admissionMessage.PatientInformation.PersonalDetails.MiddleName
            }
        ],
        pid8: admissionMessage.PatientInformation.PersonalDetails.Gender,
        pid11: [
            {
                xad1: admissionMessage.PatientInformation.ContactInformation.Address.Street,

                xad3: admissionMessage.PatientInformation.ContactInformation.Address.City,
                xad4: admissionMessage.PatientInformation.ContactInformation.Address.State,
                xad6: admissionMessage.PatientInformation.ContactInformation.Address.Country
            }
        ],
        pid13: [
            {
                xtn1: admissionMessage.PatientInformation.ContactInformation.HomePhone
            }
        ],
        pid3: [
            {
                cx1: admissionMessage.PatientInformation.Identifiers.MedicalRecordNumber.toString()
            }
        ],
        pid7: {
            ts1: admissionMessage.PatientInformation.PersonalDetails.BirthDate.toString()
        }
    },
    pv1: {
        pv12: admissionMessage.VisitDetails.PatientType,
        pv13: {
            pl1: admissionMessage.VisitDetails.Location.Unit,
            pl2: admissionMessage.VisitDetails.Location.RoomNumber.toString(),
            pl3: admissionMessage.VisitDetails.Location.BedId
        },
        pv14: admissionMessage.VisitDetails.AdmissionCategory,
        pv17: [
            {
                xcn1: admissionMessage.VisitDetails.AttendingClinician.ProviderId,
                xcn2: admissionMessage.VisitDetails.AttendingClinician.LastName,
                xcn3: admissionMessage.VisitDetails.AttendingClinician.FirstName
            }
        ],
        pv119: {
            cx1: admissionMessage.VisitDetails.EncounterNumber
        },
        pv144: {
            ts1: admissionMessage.VisitDetails.AdmissionDateTime.toString()
        },
        pv11: admissionMessage.VisitDetails.SequenceNumber.toString()
    },
    dg1: [
        {
            dg11: admissionMessage.ClinicalInformation.SequenceNumber.toString(),
            dg12: admissionMessage.ClinicalInformation.CodingStandard,
            dg13: {
                ce1: admissionMessage.ClinicalInformation.DiagnosisCode
            },
            dg14: admissionMessage.ClinicalInformation.DiagnosisDescription,
            dg15: {
                ts1: admissionMessage.ClinicalInformation.DiagnosisDateTime.toString()
            },
            dg16: admissionMessage.ClinicalInformation.DiagnosisCategory
        }
    ]
};
