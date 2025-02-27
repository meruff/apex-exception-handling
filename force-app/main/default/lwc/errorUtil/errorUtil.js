import CONTEXT_TYPE from "@salesforce/schema/Custom_Exception_Log__c.Context_Type__c";
import ERROR_TYPE from "@salesforce/schema/Custom_Exception_Log__c.Error_Type__c";
import FULL_MESSAGE from "@salesforce/schema/Custom_Exception_Log__c.Full_Message__c";
import OBJECT_TYPE from "@salesforce/schema/Custom_Exception_Log__c.Object_Type__c";
import RECORD_URL from "@salesforce/schema/Custom_Exception_Log__c.Record_URL__c";
import SEVERITY_LEVEL from "@salesforce/schema/Custom_Exception_Log__c.Severity_Level__c";
import STACK_TRACE from "@salesforce/schema/Custom_Exception_Log__c.Stack_Trace__c";
import log from "@salesforce/apex/Errors.log";

const CUSTOM_EXCEPTION_LOG = "Custom_Exception_Log__e";
const Severity = Object.freeze({
  Low: "Low",
  Med: "Med",
  High: "High"
});

/**
 * Represents the value of a LWC error object.
 * @typedef {object} ResponseError
 * @property {ResponseErrorBody} body
 * @property {string} errorType
 * @property {string} enhancedErrorType
 * @property {boolean} ok
 * @property {string} stack
 * @property {string} statusText
 */

/**
 * Represents the body value of a ResponseError object.
 * @typedef {object} ResponseErrorBody
 * @property {string} exceptionType
 * @property {boolean} isUserDefinedException
 * @property {string} message
 * @property {string} stackTrace
 * @property {object} output
 */

/**
 * Represents a Fetch API Response object.
 * @typedef {object} FetchResponse
 * @property {number} status
 * @property {string} statusText
 * @property {object} data
 * @property {object} error
 */

/**
 * Logs an error to the Custom_Exception_Log__e object.
 * @param payload {Error | ResponseError} The error to log.
 * @param severity {string} The severity of the error.
 * @param contextType {string} The context of the error, i.e. the component or service that threw the error.
 * @param objectType {string} The object type in relation to the error, if known i.e. Account, or Content__c.
 * @returns {Promise<void>} A promise that resolves when the error is logged.
 */
const logViaApex = async (payload, severity, contextType, objectType) => {
  const errorLogFields = {};
  errorLogFields[OBJECT_TYPE.fieldApiName] = objectType;
  errorLogFields[RECORD_URL.fieldApiName] = window.location.href;
  errorLogFields[SEVERITY_LEVEL.fieldApiName] = severity;

  if (payload instanceof Error) {
    const additionalFields = {};
    additionalFields[CONTEXT_TYPE.fieldApiName] = payload.name;
    additionalFields[ERROR_TYPE.fieldApiName] = "JavaScript Error";
    additionalFields[FULL_MESSAGE.fieldApiName] = payload.message;
    additionalFields[STACK_TRACE.fieldApiName] = payload.stack;

    await log({
      customExceptionLog: {
        apiName: CUSTOM_EXCEPTION_LOG,
        fields: {
          ...errorLogFields,
          ...additionalFields
        }
      }
    });
  } else if (Object.hasOwn(payload, "body")) {
    /** @type {ResponseErrorBody} */
    const body = {};
    Object.assign(body, payload.body);

    const additionalFields = {};
    additionalFields[
      CONTEXT_TYPE.fieldApiName
    ] = `Lightning Component: ${contextType}`;
    additionalFields[ERROR_TYPE.fieldApiName] =
      payload.errorType || payload.enhancedErrorType;
    additionalFields[FULL_MESSAGE.fieldApiName] = `${payload.status} | ${
      payload.statusText
    }: ${body.message}\n\nDetail:\n${JSON.stringify(body.output)}`;
    additionalFields[STACK_TRACE.fieldApiName] = body.stackTrace;

    await log({
      customExceptionLog: {
        sobjectType: CUSTOM_EXCEPTION_LOG,
        ...errorLogFields,
        ...additionalFields
      }
    });
  }
};

/**
 * Logs an error with medium severity.
 * @param payload {Error | ResponseError | FetchResponse}
 * @param contextType {string} The context of the error, i.e. the component or service that threw the error.
 * @param objectType {string} The object type in relation to the error, if known i.e. Account, or Content__c.
 */
const logError = (payload, contextType, objectType) => {
  logViaApex(payload, Severity.Med, contextType, objectType).catch((error) => {
    try {
      logError(error, "errorUtil.logError()", "Error__c");
    } catch (e) {
      console.error(e);
    }
  });
};

/**
 * Logs an error with high severity.
 * @param payload {Error | ResponseError | FetchResponse}
 * @param contextType {string} The context of the error, i.e. the component or service that threw the error.
 * @param objectType {string} The object type in relation to the error, if known i.e. Account, or Content__c.
 */
const logErrorHigh = (payload, contextType, objectType) => {
  logViaApex(payload, Severity.High, contextType, objectType).catch((error) => {
    try {
      logError(error, "errorUtil.logError()", "Error__c");
    } catch (e) {
      console.error(e);
    }
  });
};

export { logError, logErrorHigh };