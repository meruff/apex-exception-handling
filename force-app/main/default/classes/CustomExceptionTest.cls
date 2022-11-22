/**
 * @description Apex unit tests for CustomException.cls
 */
@IsTest
private class CustomExceptionTest {
    /**
     * @description This tests catching an exception with a custom message then
     * logs the Error__c record. The exception message should contain detailed lines.
     */
    @IsTest
    static void testCustomExceptionMessage() {
        Test.startTest();
        String assertMessage;

        try {
            CustomException.throwContactException(true);
        } catch (Exception e) {
            assertMessage = e.getMessage();
        }
        Test.stopTest();

        System.assert(assertMessage.contains('Custom exception message'),
            'Custom error message should be returned.');
        System.assert(assertMessage.contains('Exception Detail'),
            'Error message should contain detailed lines.');

        List<Error__c> assertErrors = [
            SELECT Id,
                Datetime__c,
                Error_Type__c,
                Full_Message__c,
                Stack_Trace__c
            FROM Error__c
        ];

        System.assertEquals(1, assertErrors.size(),
            '1 Error__c should have been created.');
        System.assert(assertErrors[0].Full_Message__c.contains('Custom exception message'),
            'The custom message should have been written to the Error__c record.');
        System.assert(assertErrors[0].Full_Message__c.contains('Exception Detail'),
            'Error message on the Error__c record should contain detailed lines.');
    }

    /**
     * @description This tests catching an exception with a custom UI message then
     * logs the Error__c record. The exception message that is caught should NOT contain
     * detailed lines.
     */
    @IsTest
    static void testCustomUiExceptionMessage() {
        Test.startTest();
        String assertMessage;

        try {
            throw CustomException.catchUiException('Test custom exception message', null);
        } catch (CustomException e) {
            assertMessage = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals('Test custom exception message', assertMessage,
            'Custom error message should be returned.');
        System.assert(!assertMessage.contains('Exception Detail'),
            'Error message should NOT contain detailed lines for UI exception.');

        List<Error__c> assertErrors = [
            SELECT Id,
                Datetime__c,
                Error_Type__c,
                Full_Message__c,
                Stack_Trace__c
            FROM Error__c
        ];

        System.assertEquals(1, assertErrors.size(),
            '1 Error__c should have been created.');
        System.assertEquals('Test custom exception message', assertErrors[0].Full_Message__c,
            'The custom message should have been written to the Error__c record.');
    }

    /**
     * @description This tests that catching the exception without a custom message return
     * the standard Exception message and logs the details to an Error__c record.
     */
    @IsTest
    static void testExceptionMessage() {
        Test.startTest();
        String assertMessage;

        try {
            CustomException.throwContactException(false);
        } catch (Exception e) {
            assertMessage = e.getMessage();
        }
        Test.stopTest();

        System.assert(assertMessage.contains('REQUIRED_FIELD_MISSING'),
            'Standard error message should be returned.');
        System.assert(assertMessage.contains('Exception Detail'),
            'Error message should contain detailed lines.');

        List<Error__c> assertErrors = [
            SELECT Id,
                Datetime__c,
                Error_Type__c,
                Full_Message__c,
                Stack_Trace__c
            FROM Error__c
        ];

        System.assertEquals(1, assertErrors.size(),
            '1 Error__c should have been created.');
        System.assert(assertErrors[0].Full_Message__c.contains('REQUIRED_FIELD_MISSING'),
            'The custom message should have been written to the Error__c record.');
        System.assert(assertErrors[0].Full_Message__c.contains('Exception Detail'),
            'Error message on the Error__c record should contain detailed lines.');
    }
}