/**
 * @description A helper class to create Error__c records. Uses a standard builder pattern.
 * 
 * @author Mat Ruff | mat.ruff@builtin.com
 * 
 * @date 11/18/22
 */
public without sharing class ErrorBuilder {
    private String contextType;
    private String errorType;
    private String errorMessage;
    private String objectType = 'User';
    private String recordUrl = UserInfo.getUserId();
    private String severityLevel = Errors.Severity.Med.name();
    private String stackTrace;

    private Exception e {
        get {
            return e;
        }

        set {
            this.e = value;

            // Only populate if we haven't added values to these fields already.
            this.errorType = String.isNotBlank(this.errorType)
                ? this.errorType
                : e?.getTypeName();
            this.errorMessage = String.isNotBlank(this.errorMessage)
                ? this.errorMessage
                : e?.getMessage();
            this.stackTrace = String.isNotBlank(this.stackTrace)
                ? this.stackTrace
                : e?.getStackTraceString();
        }
    }

    public ErrorBuilder(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    public ErrorBuilder(Exception e) {
        this.e = e;
    }

    public ErrorBuilder(String errorMessage, Exception e) {
        this.errorMessage = errorMessage;
        this.e = e;
    }

    public ErrorBuilder(Custom_Exception_Log__e customExceptionLog) {
        this.contextType = customExceptionLog.Context_Type__c;
        this.errorType = customExceptionLog.Error_Type__c;
        this.errorMessage = customExceptionLog.Full_Message__c;
        this.objectType = customExceptionLog.Object_Type__c;
        this.recordUrl = customExceptionLog.Record_URL__c;
        this.severityLevel = customExceptionLog.Severity_Level__c;
        this.stackTrace = customExceptionLog.Stack_Trace__c;
    }

    public ErrorBuilder(Database.Error error) {
        this.errorMessage = 'Message: ' + error.getMessage() +
            ', Fields: ' + error.getFields() +
            ', StatusCode: ' + error.getStatusCode();
    }

    public ErrorBuilder contextType(String contextType) {
        this.contextType = contextType;
        return this;
    }

    public ErrorBuilder errorType(String errorType) {
        this.errorType = errorType;
        return this;
    }

    public ErrorBuilder errorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
        return this;
    }

    public ErrorBuilder objectName(String objectName) {
        this.objectType = objectName;
        return this;
    }

    public ErrorBuilder recordId(String recordId) {
        if (String.isBlank(recordId)) {
            return this;
        }

        this.recordUrl = Url.getOrgDomainUrl().toExternalForm() + '/' + recordId;
        return this;
    }

    public ErrorBuilder severityLevel(String severityLevel) {
        this.severityLevel = severityLevel;
        return this;
    }

    public ErrorBuilder stackTrace(String stackTrace) {
        this.stackTrace = stackTrace;
        return this;
    }

    public Error__c build() {
        return new Error__c(
            Context_Type__c = this.contextType,
            Datetime__c = System.now(),
            Error_Type__c = this.errorType,
            Full_Message__c = this.errorMessage,
            Object_Type__c = this.objectType,
            Record_URL__c = this.recordUrl,
            Severity_Level__c = this.severityLevel,
            Stack_Trace__c = this.stackTrace
        );
    }

    public Custom_Exception_Log__e buildEvent() {
        return new Custom_Exception_Log__e(
            Context_Type__c = this.contextType,
            Datetime__c = System.now(),
            Error_Type__c = this.errorType,
            Full_Message__c = this.errorMessage,
            Object_Type__c = this.objectType,
            Record_URL__c = this.recordUrl,
            Severity_Level__c = this.severityLevel,
            Stack_Trace__c = this.stackTrace
        );
    }

    /**
     * @description Builds a List of Error__c records from a given Database.SaveResult.
     *
     * @param saveResult the Database.SaveResult to build Error__c records from.
     * @param errorType the context of the error that occurred.
     *
     * @return a new List of Error__c records for insertion.
     */
    public static List<Error__c> buildErrorsFromSaveResult(Database.SaveResult saveResult, String errorType) {
        return buildCustomErrorsFromDatabaseErrors(saveResult.getErrors(), saveResult.getId(), errorType);
    }

    /**
     * @description Builds a List of Error__c records from a given Database.UpsertResult.
     *
     * @param upsertResult the Database.UpsertResult to build Error__c records from.
     * @param errorType the context of the error that occurred.
     *
     * @return a new List of Error__c records for insertion.
     */
    public static List<Error__c> buildErrorsFromUpsertResult(Database.UpsertResult upsertResult, String errorType) {
        return buildCustomErrorsFromDatabaseErrors(upsertResult.getErrors(), upsertResult.getId(), errorType);
    }

    /**
     * @description Builds a List of Error__c records from a given Database.DeleteResult.
     *
     * @param deleteResult the Database.DeleteResult to build Error__c records from.
     * @param errorType the context of the error that occurred.
     *
     * @return a new List of Error__c records for insertion.
     */
    public static List<Error__c> buildErrorsFromDeleteResult(Database.DeleteResult deleteResult, String errorType) {
        return buildCustomErrorsFromDatabaseErrors(deleteResult.getErrors(), deleteResult.getId(), errorType);
    }

    /**
     * @description Builds a List of Error__c records from a given List of Database.Error records.
     *
     * @param databaseErrors a List of Database.Error records to build Error__c records from.
     * @param recordId the Id of the record the error occurred on. Used to log the Id and API name of the record.
     * @param errorType the context of the error that occurred. Typically this is the class / function that was being
     * performed.
     *
     * @return a new List of Error__c records for insertion.
     */
    public static List<Error__c> buildCustomErrorsFromDatabaseErrors(
        List<Database.Error> databaseErrors,
        Id recordId,
        String errorType
    ) {
        List<Error__c> customErrors = new List<Error__c>();
        String objectApiName = recordId?.getSobjectType().getDescribe().getName();

        for (Database.Error error : databaseErrors) {
            customErrors.add(new ErrorBuilder(error)
                .recordId(recordId)
                .objectName(objectApiName)
                .errorType(errorType)
                .build()
            );
        }

        return customErrors;
    }
}