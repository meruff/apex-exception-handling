/**
 * @description Apex unit tests for Errors.cls
 */
@IsTest
private class ErrorsTest {
    private static final String CUSTOM_MESSAGE = 'Custom message';
    private static final String CUSTOM_MESSAGE_SHOULD_HAVE_BEEN_WRITTEN = CUSTOM_MESSAGE + ' should have been written to the Error__c record.';
    private static final String ERROR_SHOULD_HAVE_BEEN_CREATED = '1 Error__c should have been created.';
    private static final String SEVERITY_HIGH = 'High';
    private static final String SEVERITY_LOW = 'Low';
    private static final String SEVERITY_SHOULD_HAVE_BEEN_WRITTEN = ' severity should have been written to the Error__c record.';

    /**
     * @description Tests logging an Error__c record using a custom message.
     */
    @IsTest
    static void testLogCustomMsg() {
        Test.startTest();
        Errors.log(CUSTOM_MESSAGE);
        Test.stopTest();

        List<Error__c> assertErrors = [
            SELECT Id,
                Full_Message__c
            FROM Error__c
            LIMIT 1
        ];

        Assert.areEqual(1, assertErrors.size(), ERROR_SHOULD_HAVE_BEEN_CREATED);
        Assert.areEqual(CUSTOM_MESSAGE, assertErrors[0].Full_Message__c, CUSTOM_MESSAGE_SHOULD_HAVE_BEEN_WRITTEN);
    }

    /**
     * @description Tests logging an Error__c record using an Exception.
     */
    @IsTest
    static void testLogException() {
        Test.startTest();
        try {
            insert new Contact();
        } catch (Exception e) {
            Errors.log(e);
        }
        Test.stopTest();

        List<Error__c> assertErrors = [
            SELECT Id,
                Full_Message__c
            FROM Error__c
        ];

        Assert.areEqual(1, assertErrors.size(), ERROR_SHOULD_HAVE_BEEN_CREATED);
        Assert.isTrue(
            assertErrors[0].Full_Message__c.contains('REQUIRED_FIELD_MISSING'),
            'Exception should have been written to the Error__c record.'
        );
    }

    /**
     * @description Tests logging an Error__c record using a custom message an Exception.
     */
    @IsTest
    static void testLogCustomMsgException() {
        Test.startTest();
        try {
            insert new Contact();
        } catch (Exception e) {
            Errors.log(CUSTOM_MESSAGE, e);
        }
        Test.stopTest();

        List<Error__c> assertErrors = [
            SELECT Id,
                Full_Message__c
            FROM Error__c
        ];

        Assert.areEqual(1, assertErrors.size(), ERROR_SHOULD_HAVE_BEEN_CREATED);
        Assert.areEqual(CUSTOM_MESSAGE, assertErrors[0].Full_Message__c, CUSTOM_MESSAGE_SHOULD_HAVE_BEEN_WRITTEN);
    }

    /**
     * @description Tests logging an Error__c record using a custom message an Exception with Low Severity.
     */
    @IsTest
    static void testLogCustomMsgExceptionLowSeverity() {
        Test.startTest();
        try {
            insert new Contact();
        } catch (Exception e) {
            Errors.log(CUSTOM_MESSAGE, e, Errors.Severity.Low);
        }
        Test.stopTest();

        List<Error__c> assertErrors = [
            SELECT Id,
                Full_Message__c,
                Severity_Level__c
            FROM Error__c
        ];

        Assert.areEqual(1, assertErrors.size(), ERROR_SHOULD_HAVE_BEEN_CREATED);
        Assert.areEqual(
            CUSTOM_MESSAGE,
            assertErrors[0].Full_Message__c,
            CUSTOM_MESSAGE_SHOULD_HAVE_BEEN_WRITTEN
        );
        Assert.areEqual(
            SEVERITY_LOW,
            assertErrors[0].Severity_Level__c,
            SEVERITY_LOW + SEVERITY_SHOULD_HAVE_BEEN_WRITTEN
        );
    }

    /**
     * @description Tests logging an Error__c record using a custom message an Exception with High Severity.
     */
    @IsTest
    static void testLogCustomMsgExceptionHighSeverity() {
        Test.startTest();
        try {
            insert new Contact();
        } catch (Exception e) {
            Errors.log(CUSTOM_MESSAGE, e, Errors.Severity.High);
        }
        Test.stopTest();

        List<Error__c> assertErrors = [
            SELECT Id,
                Full_Message__c,
                Severity_Level__c
            FROM Error__c
        ];

        Assert.areEqual(1, assertErrors.size(), ERROR_SHOULD_HAVE_BEEN_CREATED);
        Assert.areEqual(
            CUSTOM_MESSAGE,
            assertErrors[0].Full_Message__c,
            CUSTOM_MESSAGE_SHOULD_HAVE_BEEN_WRITTEN
        );
        Assert.areEqual(
            SEVERITY_HIGH,
            assertErrors[0].Severity_Level__c,
            SEVERITY_HIGH + SEVERITY_SHOULD_HAVE_BEEN_WRITTEN
        );
    }

    /**
     * @description Tests logging a list of Error__c records.
     */
    @IsTest
    static void testLogList() {
        Test.startTest();
        Errors.log(new List<Error__c>{
            new Error__c(Full_Message__c = 'Test 1'),
            new Error__c(Full_Message__c = 'Test 2')
        });
        Test.stopTest();

        List<Error__c> assertErrors = [
            SELECT Id
            FROM Error__c
        ];

        Assert.areEqual(2, assertErrors.size(), '2 Error__c records should have been created.');
    }

    /**
     * @description Tests logging an Error__c record.
     */
    @IsTest
    static void testLogError() {
        Test.startTest();
        Errors.log(new Error__c(Full_Message__c = 'Test Error'));
        Test.stopTest();

        List<Error__c> assertErrors = [
            SELECT Id,
                Full_Message__c
            FROM Error__c
        ];

        Assert.areEqual(1, assertErrors.size(), ERROR_SHOULD_HAVE_BEEN_CREATED);
    }

    /**
     * @description Tests logging an Error__c record with a severity and context type.
     */
    @IsTest
    static void testLogWithSeverity() {
        Test.startTest();
        try {
            insert new Contact();
        } catch (Exception e) {
            Errors.log(CUSTOM_MESSAGE, e, Errors.Severity.High, 'Custom Context');
        }
        Test.stopTest();

        List<Error__c> assertErrors = [
            SELECT Id,
                Full_Message__c,
                Severity_Level__c,
                Context_Type__c
            FROM Error__c
        ];

        Assert.areEqual(1, assertErrors.size(), ERROR_SHOULD_HAVE_BEEN_CREATED);
        Assert.areEqual(
            CUSTOM_MESSAGE,
            assertErrors[0].Full_Message__c,
            CUSTOM_MESSAGE_SHOULD_HAVE_BEEN_WRITTEN
        );
        Assert.areEqual(
            SEVERITY_HIGH,
            assertErrors[0].Severity_Level__c,
            SEVERITY_HIGH + SEVERITY_SHOULD_HAVE_BEEN_WRITTEN
        );
        Assert.areEqual(
            'Custom Context',
            assertErrors[0].Context_Type__c,
            'Custom Context should have been written to the Error__c record.'
        );
    }

    /**
     * @description Tests formatting a message with a StatusCode.
     */
    @IsTest
    static void testMessageWithStatusCode() {
        Test.startTest();
        Assert.areEqual(
            'ContentStudioLogin;;' + CUSTOM_MESSAGE,
            Errors.messageWithStatusCode(Errors.StatusCode.ContentStudioLogin, CUSTOM_MESSAGE),
            'Message should have been formatted with the StatusCode.'
        );
        Test.stopTest();
    }

    /**
     * @description Tests adding an error to a SObject and logs it.
     */
    @IsTest
    static void testAddSObjectError() {
        Contact testContact = TestDataFactory.createContact('Testing', null);
        insert testContact;

        String customContactError = 'Custom contact error';

        Test.startTest();
        try {
            Errors.addSobjectError(customContactError, testContact);
        } catch (Exception e) {
            Assert.areEqual(e.getMessage(), customContactError);
        }
        Test.stopTest();

        List<Error__c> assertErrors = [
            SELECT Id,
                Object_Type__c,
                Record_URL__c,
                Full_Message__c
            FROM Error__c
        ];

        Assert.areEqual(1, assertErrors.size(), ERROR_SHOULD_HAVE_BEEN_CREATED);
        Assert.areEqual('Contact', assertErrors[0].Object_Type__c);
        Assert.areEqual(
            customContactError,
            assertErrors[0].Full_Message__c,
            'Custom message should have been written to Error__c record.');
        Assert.isTrue(
            assertErrors[0].Record_URL__c.contains(testContact.Id),
            'Record Id should have been set inside the Record_Url__c field.'
        );
    }
}