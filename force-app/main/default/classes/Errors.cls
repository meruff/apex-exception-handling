/**
 * @description A helper class to work with Error__c records.
 *
 * @author Mat Ruff | mat.ruff@builtin.com
 *
 * @date 11/19/22
 */
public without sharing class Errors {
    /**
     * @description Used the ErrorBuilder to create and insert a new Error__c record using the given parameters.
     *
     * @param errorMsg a custom message String to write to the Error__c log generated.
     */
    public static void log(String errorMsg) {
        log(new ErrorBuilder(errorMsg).build());
    }

    /**
     * @description Used the ErrorBuilder to create and insert a new Error__c record using the given parameters.
     *
     * @param e the Exception that occurred. Used to pull detail from when creating the Error__c record.
     */
    public static void log(Exception e) {
        log(new ErrorBuilder(e).build());
    }

    /**
     * @description Used the ErrorBuilder to create and insert a new Error__c record using the given parameters.
     *
     * @param errorMsg a custom message String to write to the Error__c log generated.
     * @param e the Exception that occurred. Used to pull detail from when creating the Error__c record.

     */
    public static void log(String errorMsg, Exception e) {
        log(new ErrorBuilder(errorMsg, e).build());
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
                .build()
        );
        sObj.addError(errorMsg);
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