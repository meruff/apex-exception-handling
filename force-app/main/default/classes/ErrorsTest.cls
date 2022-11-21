/**
 * @description Apex unit tests for Errors.cls
 */
@IsTest
private class ErrorsTest {
    /**
     * @description Tests logging an Error__c record using a custom message.
     */
    @IsTest
    static void testLogCustomMsg() {
        Test.startTest();
        Errors.log('Custom message');
        Test.stopTest();

        List<Error__c> assertErrors = [
            SELECT Id,
                Full_Message__c
            FROM Error__c
            LIMIT 1
        ];

        System.assertEquals(1, assertErrors.size(),
            '1 Error__c should have been created.');
        System.assertEquals('Custom message', assertErrors[0].Full_Message__c,
            'Custom message should have been written to the Error__c record.');
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

        System.assertEquals(1, assertErrors.size(),
            '1 Error__c should have been created.');
        System.assert(assertErrors[0].Full_Message__c.contains('REQUIRED_FIELD_MISSING'),
            'Exception should have been written to the Error__c record.');
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
            Errors.log('Custom message', e);
        }
        Test.stopTest();

        List<Error__c> assertErrors = [
            SELECT Id,
                Full_Message__c
            FROM Error__c
        ];

        System.assertEquals(1, assertErrors.size(),
            '1 Error__c should have been created.');
        System.assertEquals('Custom message', assertErrors[0].Full_Message__c,
            'Custom message should have been written to the Error__c record.');
    }

    /**
     * @description Tests logging a list of Error__c records.
     */
    @IsTest
    static void testLogList() {
        Test.startTest();
        Errors.log(new List<Error__c>{
            new Error__c(
                Full_Message__c = 'Test 1'
            ),
            new Error__c(
                Full_Message__c = 'Test 2'
            )
        });
        Test.stopTest();

        List<Error__c> assertErrors = [
            SELECT Id
            FROM Error__c
        ];

        System.assertEquals(2, assertErrors.size(),
            '2 Error__c records should have been created.');
    }

    /**
     * @description Tests adding an error to a SObject and logs it.
     */
    @IsTest
    static void testAddSObjectError() {
        Contact testContact = TestDataFactory.createContact('Testing', null);
        insert testContact;

        Test.startTest();
        try {
            Errors.addSobjectError('Custom contact error', testContact);
        } catch (Exception e) {
            System.assertEquals(e.getMessage(), 'Custom contact error');
        }
        Test.stopTest();

        List<Error__c> assertErrors = [
            SELECT Id,
                Object_Type__c,
                Record_URL__c,
                Full_Message__c
            FROM Error__c
        ];

        System.assertEquals(1, assertErrors.size(),
            '1 Error__c record should have been created.');
        System.assertEquals('Custom contact error', assertErrors[0].Full_Message__c,
            'Custom message should have been written to Error__c record.');
        System.assertEquals('Contact', assertErrors[0].Object_Type__c);
        System.assert(assertErrors[0].Record_URL__c.contains(testContact.Id),
            'Record Id should have been set inside the Record_Url__c field.');
    }
}