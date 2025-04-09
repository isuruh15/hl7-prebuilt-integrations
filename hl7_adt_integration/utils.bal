
enum LogType {
    NORMAL, // the integration accelerator functions normally
    FAILURE, // Malfunction of the integration accelerator. Typically caused device-internal or is process related 
    CHECK_FUNCTION, // Functional checks are currently performed.
    OFF_SPEC, // integration accelerator is operating outside its specified range
    MAINTENANCE_REQUIRED, // Although the incoming and outgoing message are valid, the environment reserve is nearly exhausted or a function will soon be restricted
    UNKNOWN // Shall be used if the device or component is not able to communicate its health state
}
