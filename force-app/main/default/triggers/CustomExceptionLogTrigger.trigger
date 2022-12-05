trigger CustomExceptionLogTrigger on Custom_Exception_Log__e (after insert) {
    List<Error__c> errorsToInsert = new List<Error__c>();

    for (Custom_Exception_Log__e customExceptionLog : (List<Custom_Exception_Log__e>) Trigger.new) {
        errorsToInsert.add(new ErrorBuilder(customExceptionLog).build());
    }

    if (!errorsToInsert.isEmpty()) {
        insert errorsToInsert;
    }
}