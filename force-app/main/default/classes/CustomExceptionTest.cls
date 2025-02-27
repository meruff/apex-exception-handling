/**
 * @description Apex unit tests for CustomException.cls
 */
@IsTest
private class CustomExceptionTest {
    private static final String EXCEPTION_DETAIL = 'Exception Detail';
    private static final String CUSTOM_MESSAGE_SHOULD_HAVE_BEEN_WRITTEN = 'The custom message should have been written to the Error__c record.';
    private static final String ERROR_SHOULD_HAVE_BEEN_CREATED = '1 Error__c should have been created.';
    private static final String TEST_CUSTOM_EXCEPTION_MESSAGE = 'Test custom exception message';

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

        Assert.isTrue(assertMessage.contains('Custom exception message'), 'Custom error message should be returned.');
        Assert.isTrue(assertMessage.contains(EXCEPTION_DETAIL), 'Error message should contain detailed lines.');

        List<Error__c> assertErrors = [
            SELECT Id,
                Context_Type__c,
                Datetime__c,
                Error_Type__c,
                Full_Message__c,
                Stack_Trace__c
            FROM Error__c
        ];

        Assert.areEqual(1, assertErrors.size(), ERROR_SHOULD_HAVE_BEEN_CREATED);
        Assert.isTrue(
            assertErrors[0].Full_Message__c.contains('Custom exception message'),
            CUSTOM_MESSAGE_SHOULD_HAVE_BEEN_WRITTEN
        );
        Assert.isTrue(
            assertErrors[0].Full_Message__c.contains(EXCEPTION_DETAIL),
            'Error message on the Error__c record should contain detailed lines.'
        );
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
            throw CustomException.catchUiException(TEST_CUSTOM_EXCEPTION_MESSAGE, null);
        } catch (Exception e) {
            assertMessage = e.getMessage();
        }
        Test.stopTest();

        Assert.areEqual(TEST_CUSTOM_EXCEPTION_MESSAGE, assertMessage, 'Custom error message should be returned.');
        Assert.isTrue(
            !assertMessage.contains(EXCEPTION_DETAIL),
            'Error message should NOT contain detailed lines for UI exception.'
        );

        List<Error__c> assertErrors = [
            SELECT Id,
                Datetime__c,
                Error_Type__c,
                Full_Message__c,
                Stack_Trace__c
            FROM Error__c
        ];

        Assert.areEqual(1, assertErrors.size(), ERROR_SHOULD_HAVE_BEEN_CREATED);
        Assert.isTrue(
            assertErrors[0].Full_Message__c.containsIgnoreCase(TEST_CUSTOM_EXCEPTION_MESSAGE),
            CUSTOM_MESSAGE_SHOULD_HAVE_BEEN_WRITTEN
        );
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

        Assert.isTrue(assertMessage.contains('REQUIRED_FIELD_MISSING'), 'Standard error message should be returned.');
        Assert.isTrue(assertMessage.contains(EXCEPTION_DETAIL), 'Error message should contain detailed lines.');

        List<Error__c> assertErrors = [
            SELECT Id,
                Datetime__c,
                Error_Type__c,
                Full_Message__c,
                Stack_Trace__c
            FROM Error__c
        ];

        Assert.areEqual(1, assertErrors.size(), ERROR_SHOULD_HAVE_BEEN_CREATED);
        Assert.isTrue(
            assertErrors[0].Full_Message__c.contains('REQUIRED_FIELD_MISSING'),
            CUSTOM_MESSAGE_SHOULD_HAVE_BEEN_WRITTEN
        );
        Assert.isTrue(
            assertErrors[0].Full_Message__c.contains(EXCEPTION_DETAIL),
            'Error message on the Error__c record should contain detailed lines.'
        );
    }
}