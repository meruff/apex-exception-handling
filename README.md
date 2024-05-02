# Apex Exception Handling

A simple framework for handling custom Apex exceptions.

# Usage

This framework comes with a custom object named `Error__c`. Whenever an exception is thrown a new error record is created. This way you can track errors that occur during processing.

## Custom Metadata Type

| Field API Name    | Field Type     | Description                                                                   |
|-------------------|----------------|-------------------------------------------------------------------------------|
| Context_Type__c   | Text Area      | Context that generated the error, if known.                                   |
| Datetime__c       | Date/Time      | Date & time the error occurred.                                               |
| Error_Type__c     | Text Area      | Type of error that occurred.                                                  |
| Full_Message__c   | Long Text Area | Full text of the error message.                                               |
| Object_Type__c    | Text Area      | The object on which the error occurred, if known.                             |
| Record_URL__c     | URL            | A link to the record which caused the error, if available.                    |
| Severity_Level__c | Picklist       | Determines the level of impact this Error has on the system (Low, Med, High). |
| Stack_Trace__c    | Long Text Area | Stack trace for the thrown error, if available at runtime.                    |

## Throwing a Custom Exception
When throwing a custom exception, the framework automatically pull data from a given Apex exception and creates a new `Error__c` record to insert.

```java
try {
    // something that throws an exception
} catch (Exception e) {
    throw CustomException('My custom message', e);
}
```

Adding a custom message to the exception will write it to the `Error__c` record created. In order to create errors in an asynchronous manner, this framework also includes a custom platform event named `Custom_Exception_Log__e`. When an exception occurs, it fires a platform event that triggers the error record creation through [CustomExceptionLogTrigger](/force-app/main/default/triggers/CustomExceptionLogTrigger.trigger).

## Manually Building an Error

You can also utilize the [ErrorBuilder](/force-app/main/default/classes/ErrorBuilder.cls) class to manually build an error record with whatever values you want:

```java
insert new ErrorBuilder('This is a custom error message.')
    .contextType('ErrorBuilderTest')
    .errorType('Generic')
    .objectName('Asset')
    .recordId('02i03000004Yxxxxxx')
    .severityLevel('High')
    .stackTrace('Line 1 Col 3')
    .build();
```