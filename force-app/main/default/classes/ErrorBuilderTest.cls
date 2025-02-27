/**
 * @description Apex unit tests for ErrorBuilder.cls
 */
@IsTest
private class ErrorBuilderTest {
    private static final String ASSERT_ONE_ERROR = '1 Error__c should have been created.';
    private static final String ASSERT_VALUE_SHOULD_MATCH = 'Assert value should match the given value.';
    private static final String TEST_DATABASE_ERROR_STRING = '{"message":"An unexpected error occurred.","fields":["Name"],"statusCode":""}';
    private static final String TEST_ERROR = 'Test Error';

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
                Context_Type__c,
                Error_Type__c,
                Object_Type__c,
                Record_URL__c,
                Severity_Level__c
            FROM Error__c
            LIMIT 1
        ];

        Assert.areEqual('ErrorBuilderTest', assertError.Context_Type__c, ASSERT_VALUE_SHOULD_MATCH);
        Assert.areEqual('Generic', assertError.Error_Type__c, ASSERT_VALUE_SHOULD_MATCH);
        Assert.areEqual('Asset', assertError.Object_Type__c, ASSERT_VALUE_SHOULD_MATCH);
        Assert.areEqual('High', assertError.Severity_Level__c, ASSERT_VALUE_SHOULD_MATCH);
        Assert.areEqual(
            Url.getOrgDomainUrl().toExternalForm() + '/02i03000004YVeLAAW',
            assertError.Record_URL__c,
            ASSERT_VALUE_SHOULD_MATCH
        );
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

        Assert.areEqual(
            'Different Message',
            assertError.Full_Message__c,
            'Setting the errorMessage after constructor runs should overwrite the message.'
        );
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
                Full_Message__c
            FROM Error__c
        ];

        Assert.areEqual(1, assertErrors.size(), ASSERT_ONE_ERROR);
        Assert.isTrue(
            assertErrors[0].Full_Message__c.contains('Custom exception message'),
            'The custom message should have been written to the Error__c record.'
        );
        Assert.isTrue(
            assertErrors[0].Full_Message__c.contains('Exception Detail'),
            'Error message on the Error__c record should contain detailed lines.'
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

        List<Error__c> assertErrors = [
            SELECT Id,
                Datetime__c,
                Error_Type__c,
                Full_Message__c,
                Stack_Trace__c
            FROM Error__c
        ];

        Assert.areEqual(1, assertErrors.size(), ASSERT_ONE_ERROR);
        Assert.isTrue(
            assertErrors[0].Full_Message__c.contains('REQUIRED_FIELD_MISSING'),
            'The custom message should have been written to the Error__c record.'
        );
        Assert.isTrue(
            assertErrors[0].Full_Message__c.contains('Exception Detail'),
            'Error message on the Error__c record should contain detailed lines.'
        );
    }

    /**
     * @description This tests that a Database.Error is correctly converted to an Error__c record to be logged.
     */
    @IsTest
    static void testDatabaseError() {
        Test.startTest();
        List<Database.SaveResult> saveResults = Database.update(
            new List<Account>{new Account()},
            false
        );

        Error__c assertError = new ErrorBuilder(saveResults[0].getErrors()[0])
            .objectName('Account')
            .errorType(TEST_ERROR)
            .build();
        Test.stopTest();

        Assert.isTrue(
            assertError.Full_Message__c.containsIgnoreCase(String.valueOf(StatusCode.MISSING_ARGUMENT)),
            'Full Message should include status code from Database.Error.'
        );
        Assert.isTrue(
            assertError.Full_Message__c.containsIgnoreCase('Id not specified in an update call'),
            'Full Message should include no Id in update.'
        );
    }

    @IsTest
    static void testBuildErrorsFromSaveResult() {
        Test.startTest();
        List<Error__c> assertErrors = ErrorBuilder.buildErrorsFromSaveResult(
            (Database.SaveResult) JSON.deserialize(
                '{"success":false,"id":"' + TriggersTest.getFakeId(Account.SObjectType, 1) + '","errors":[' + TEST_DATABASE_ERROR_STRING + ']}',
                Database.SaveResult.class
            ),
            TEST_ERROR
        );
        Test.stopTest();

        Assert.areEqual(1, assertErrors.size(), ASSERT_ONE_ERROR);
        Assert.areEqual(TEST_ERROR, assertErrors[0].Error_Type__c, ASSERT_VALUE_SHOULD_MATCH);
    }

    @IsTest
    static void testBuildErrorsFromUpsertResult() {
        Test.startTest();
        List<Error__c> assertErrors = ErrorBuilder.buildErrorsFromUpsertResult(
            (Database.UpsertResult) JSON.deserialize(
                '{"success":false,"id":"' + TriggersTest.getFakeId(Account.SObjectType, 1) + '","errors":[' + TEST_DATABASE_ERROR_STRING + ']}',
                Database.UpsertResult.class
            ),
            TEST_ERROR
        );
        Test.stopTest();

        Assert.areEqual(1, assertErrors.size(), ASSERT_ONE_ERROR);
        Assert.areEqual(TEST_ERROR, assertErrors[0].Error_Type__c, ASSERT_VALUE_SHOULD_MATCH);
    }

    @IsTest
    static void testBuildErrorsFromDeleteResult() {
        Test.startTest();
        List<Error__c> assertErrors = ErrorBuilder.buildErrorsFromDeleteResult(
            (Database.DeleteResult) JSON.deserialize(
                '{"success":false,"id":"' + TriggersTest.getFakeId(Account.SObjectType, 1) + '","errors":[' + TEST_DATABASE_ERROR_STRING + ']}',
                Database.DeleteResult.class
            ),
            TEST_ERROR
        );
        Test.stopTest();

        Assert.areEqual(1, assertErrors.size(), ASSERT_ONE_ERROR);
        Assert.areEqual(TEST_ERROR, assertErrors[0].Error_Type__c, ASSERT_VALUE_SHOULD_MATCH);
    }

    @IsTest
    static void testBuildErrorsFromDatabaseErrors() {
        Test.startTest();
        List<Error__c> assertErrors = ErrorBuilder.buildCustomErrorsFromDatabaseErrors(
            new List<Database.Error>{(Database.Error) JSON.deserialize(TEST_DATABASE_ERROR_STRING, Database.Error.class)},
            TriggersTest.getFakeId(Account.SObjectType, 1),
            TEST_ERROR
        );
        Test.stopTest();

        Assert.areEqual(1, assertErrors.size(), ASSERT_ONE_ERROR);
        Assert.areEqual(TEST_ERROR, assertErrors[0].Error_Type__c, ASSERT_VALUE_SHOULD_MATCH);
    }
}