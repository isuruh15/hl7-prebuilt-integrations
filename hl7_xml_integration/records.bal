
type Identifiers record {
    int MedicalRecordNumber;
};

type PersonalDetails record {
    string LastName;
    string FirstName;
    string MiddleName;
    int BirthDate;
    string Gender;
};

type Address record {
    string Street;
    string City;
    string State;
    int PostalCode;
    string Country;
};

type ContactInformation record {
    Address Address;
    string HomePhone;
};

type PatientInformation record {
    Identifiers Identifiers;
    PersonalDetails PersonalDetails;
    ContactInformation ContactInformation;
};

type Location record {
    string Unit;
    int RoomNumber;
    string BedId;
    string Campus;
};

type AttendingClinician record {
    string ProviderId;
    string LastName;
    string FirstName;
};

type VisitDetails record {
    int SequenceNumber;
    string PatientType;
    Location Location;
    string AdmissionCategory;
    AttendingClinician AttendingClinician;
    string EncounterNumber;
    int AdmissionDateTime;
};

type ClinicalInformation record {
    int SequenceNumber;
    string CodingStandard;
    string DiagnosisCode;
    string DiagnosisDescription;
    int DiagnosisDateTime;
    string DiagnosisCategory;
};

type AdmissionMessage record {
    PatientInformation PatientInformation;
    VisitDetails VisitDetails;
    ClinicalInformation ClinicalInformation;
};
