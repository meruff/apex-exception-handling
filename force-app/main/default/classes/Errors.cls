/**
 * @description A helper class to work with Error__c records.
 *
 * @author Mat Ruff
 *
 * @date 11/19/22
 */
public without sharing class Errors {
    public static final String STATUS_CODE_DELIMITER = ';;';
    public enum Severity { Low, Med, High }
    public enum StatusCode { ContentStudioLogin }

    /**
     * @description Uses the ErrorBuilder to create and insert a new Custom_Exception_Log__e record using the
     * given parameters.
     *
     * @param errorMsg a custom message String to write to the Error__c log generated.
     */
    public static void log(String errorMsg) {
        log(new ErrorBuilder(errorMsg).buildEvent());
    }

    /**
     * @description Uses the ErrorBuilder to create and insert a new Custom_Exception_Log__e record using the
     * given parameters.
     *
     * @param e the Exception that occurred. Used to pull detail from when creating the Error__c record.
     */
    public static void log(Exception e) {
        log(new ErrorBuilder(e).buildEvent());
    }

    /**
     * @description Uses the ErrorBuilder to create and insert a new Custom_Exception_Log__e record using the
     * given parameters.
     *
     * @param errorMsg a custom message String to write to the Error__c log generated.
     * @param e the Exception that occurred. Used to pull detail from when creating the Error__c record.
     */
    public static void log(String errorMsg, Exception e) {
        log(new ErrorBuilder(errorMsg, e).buildEvent());
    }

    /**
     * @description Uses the ErrorBuilder to create and insert a new Custom_Exception_Log__e record using the
     * given parameters.
     *
     * @param errorMsg a custom message String to write to the Error__c log generated.
     * @param e the Exception that occurred. Used to pull detail from when creating the Error__c record.
     * @param severity the severity to give the Error__c record created.
     */
    public static void log(String errorMsg, Exception e, Errors.Severity severity) {
        log(new ErrorBuilder(errorMsg, e).severityLevel(severity.name()).buildEvent());
    }

    /**
     * @description Uses the ErrorBuilder to create and insert a new Custom_Exception_Log__e record using the
     * given parameters.
     *
     * @param errorMsg a custom message String to write to the Error__c log generated.
     * @param e the Exception that occurred. Used to pull detail from when creating the Error__c record.
     * @param severity the severity to give the Error__c record created.
     * @param contextType the context type to give the Error__c record created.
     */
    public static void log(String errorMsg, Exception e, Errors.Severity severity, String contextType) {
        log(new ErrorBuilder(errorMsg, e).severityLevel(severity.name()).contextType(contextType).buildEvent());
    }

    /**
     * @description Inserts the given Custom_Exception_Log__e record into the database. Events are inserted immediately.
     *
     * @param customExceptionLog the Custom_Exception_Log__e record to insert.
     */
    @AuraEnabled
    public static void log(Custom_Exception_Log__e customExceptionLog) {
        try {
            EventBus.publish(customExceptionLog);
        } catch (Exception e) {
            throw CustomException.catchException(e);
        }
    }

    /**
     * @description Serializes the given List of Error__c records into JSON in order to call the log() method
     * in its Future context.
     *
     * @param errors a List of Error__c records to insert.
     */
    public static void log(List<Error__c> errors) {
        logAsync(JSON.serialize(errors), true);
    }

    /**
     * @description Serializes the given Error__c record into JSON in order to call the log() method
     * in its Future context.
     *
     * @param error an Error__c record to insert.
     */
    public static void log(Error__c error) {
        logAsync(JSON.serialize(error), false);
    }

    /**
     * @description Calls .addError() for the given SObject with the supplied custom message String. Inserts a
     * new Error__c record pertaining to the SObject prior to that.
     *
     * @param errorMsg a custom message String to pass to both the Error__c record log and .addError().
     * @param sObj the SObject to use when generating/calling the Error__c record log and .addError() method.
     */
    public static void addSobjectError(String errorMsg, SObject sObj) {
        log(
            new ErrorBuilder(errorMsg)
                .objectName(sObj.getSObjectType().getDescribe().getName())
                .recordId(sObj?.Id)
                .buildEvent()
        );
        sObj.addError(errorMsg);
    }

    /**
     * @description Adds the given StatusCode to the beginning of the given error message.
     *
     * @param statusCode the StatusCode to add to the error message.
     * @param errorMsg the error message to add the StatusCode to.
     *
     * @return the new error message with the StatusCode added.
     */
    public static String messageWithStatusCode(StatusCode statusCode, String errorMsg) {
        return statusCode.name() + STATUS_CODE_DELIMITER + errorMsg;
    }

    /**
     * @description Deserializes the given Error__c record String and inserts them into the database asynchronously.
     *
     * @param errorJsonString a String representing a List of Error__c records or a single Error__c record. Determined
     * by the supplied flag.
     * @param isList a Boolean that determines whether or not this method deserializes a List of Error__c records or
     * a single Error__c record.
     */
    @Future
    private static void logAsync(String errorJsonString, Boolean isList) {
        try {
            if (isList) {
                insert (List<Error__c>) JSON.deserialize(errorJsonString, List<Error__c>.class);
                return;
            }

            insert (Error__c) JSON.deserialize(errorJsonString, Error__c.class);
        } catch (Exception e) {
            throw CustomException.catchException(e);
        }
    }
}