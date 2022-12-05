/**
 * @description Apex unit tests for ErrorBuilder.cls
 */
@IsTest
private class ErrorBuilderTest {
    /**
     * @description This tests creating an Error__c record using the builder with common fields.
     */
    @IsTest
    static void testBuildError() {
        Test.startTest();
        insert new ErrorBuilder('This is a custom error message from the unit test.')
            .contextType('ErrorBuilderTest')
            .errorType('Generic')
            .objectName('Asset')
            .recordId('02i03000004YVeLAAW') // NOPMD
            .severityLevel('High')
            .stackTrace('Line 1 Col 3')
            .build();
        Test.stopTest();

        Error__c assertError = [
            SELECT Id,
                Datetime__c,
                Context_Type__c,
                Error_Type__c,
                Full_Message__c,
                Object_Type__c,
                Record_URL__c,
                Severity_Level__c,
                Stack_Trace__c
            FROM Error__c
            LIMIT 1
        ];

        System.assertEquals('ErrorBuilderTest', assertError.Context_Type__c);
        System.assertEquals('Generic', assertError.Error_Type__c);
        System.assertEquals('Generic', assertError.Error_Type__c);
        System.assertEquals('Asset', assertError.Object_Type__c);
        System.assertEquals('High', assertError.Severity_Level__c);
        System.assertEquals(Url.getSalesforceBaseUrl().toExternalForm() + '/02i03000004YVeLAAW', assertError.Record_URL__c);
    }

    /**
     * @description This tests overwriting the constructor's message with the builder method.
     */
    @IsTest
    static void testCustomMessage() {
        Test.startTest();
        insert new ErrorBuilder('Original Message')
            .errorMessage('Different Message')
            .build();
        Test.stopTest();

        Error__c assertError = [
            SELECT Id,
                Full_Message__c
            FROM Error__c
            LIMIT 1
        ];

        System.assertEquals('Different Message', assertError.Full_Message__c,
            'Setting the errorMessage after constructor runs should overwrite the message.');
    }

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