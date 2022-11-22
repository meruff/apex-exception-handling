/**
 * @description A base class for creating generic Exceptions and logging Error__c records.
 *
 * @author Mat Ruff | mat.ruff@builtin.com
 *
 * @date 11/18/22
 */
public without sharing class CustomException extends Exception {
    /**
     * @description Builds an instance of CustomException from the provides information and logs
     * the exception to an Error__c record.
     *
     * @param e the Exception that occurred. Used to pull data from for the log.
     *
     * @return the Exception that occurred.
     */
    public static Exception catchException(Exception e) {
        return buildCustomException(e.getMessage(), e, true);
    }

    /**
     * @description Builds an instance of CustomException from the provides information and logs
     * the exception to an Error__c record.
     *
     * @param errorMsg a custom message String. Used to write to the Full_Message__c field on the log.
     * @param e the Exception that occurred. Used to pull data from for the log.
     *
     * @return the Exception that occurred.
     */
    public static Exception catchException(String errorMsg, Exception e) {
        return buildCustomException(errorMsg, e, true);
    }

    /**
     * @description Builds an instance of CustomException from the provides information and logs
     * the exception to an Error__c record. This method does not add the standard Exception .getMessage()
     * value to the returned message after being caught. This is used specifically to set a custom message
     * on an exception that happens in the UI so the User only sees what the developer returns to them.
     *
     * @param errorMsg a custom message String. Used to write to the Full_Message__c field on the log.
     * @param e the Exception that occurred. Used to pull data from for the log.
     *
     * @return the Exception that occurred.
     */
    public static Exception catchUiException(String errorMsg, Exception e) {
        return buildCustomException(errorMsg, e, false);
    }

    /**
     * @description Builds a custom CustomException using the provided information and then writes to an
     * Error__c record.
     *
     * @param errorMsg a custom message String. Used to write to the Full_Message__c field on the log.
     * @param e the Exception that occurred. Used to pull data for the log.
     * @param allDetail a Boolean representing whether or not to provided all detail to the generated Error__c record.
     * If true, it will attempt to pull more data from the Exception. If false, it will only use the message provided
     * to the method.
     *
     * @return the Exception that occurred.
     */
    private static Exception buildCustomException(String errorMsg, Exception e, Boolean allDetail) {
        CustomException customException = new CustomException();

        if (allDetail && e != null) {
            String detailedMessage = getDetailedExceptionMsg(errorMsg, e);
            Errors.log(detailedMessage, e);
            customException.setMessage(detailedMessage);
        } else {
            Errors.log(errorMsg);
            customException.setMessage(errorMsg);
        }

        return customException;
    }

    /**
     * @description This method adds detail from the provided Exception to a given String. This is handy for building
     * out detail in a caught Exception and when logging Error__c records to the database.
     *
     * @param exceptionMsg the custom message String to write to.
     * @param e the Exception that occurred. Used to pull data from (i.e. e.getTypeName()).
     *
     * @return the newly constructed String.
     */
    private static String getDetailedExceptionMsg(String exceptionMsg, Exception e) {
        exceptionMsg += '\n';
        exceptionMsg += 'Exception Detail:\n';
        exceptionMsg += 'Message: ' + e?.getMessage() + '\n';
        exceptionMsg += 'Type: ' + e?.getTypeName() + '\n';
        exceptionMsg += 'Cause: ' + e?.getCause() + '\n';
        exceptionMsg += 'Stack Trace: ' + e?.getStackTraceString() + '\n';

        return exceptionMsg;
    }

    /**
     * @description This method simply inserts a Contact record without a LastName value to manually trigger a DML
     * exception. This is ONLY used to test catching a standard exception inside this custom class. This will emulate
     * a try/catch in a handler/service class attempting to do something that fails.
     *
     * @param isCustom a Boolean that determines whether or not to use a custom message
     * in the thrown Exception.
     */
    @TestVisible
    private static void throwContactException(Boolean isCustom) {
        if (!Test.isRunningTest()) {
            return;
        }

        try {
            insert new Contact();
        } catch (Exception e) {
            if (isCustom) {
                throw CustomException.catchException('Custom exception message', e);
            } else {
                throw CustomException.catchException(e);
            }
        }
    }
}
