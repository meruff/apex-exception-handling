trigger CustomExceptionLogTrigger on Custom_Exception_Log__e (after insert) {
    Triggers.prepare().afterInsert().bind(new CustomExceptionLogCreationHandler()).execute();
}