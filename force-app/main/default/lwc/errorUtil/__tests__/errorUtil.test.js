import { logError, logErrorHigh } from "../errorUtil";
import log from "@salesforce/apex/Errors.log";
const mockLogFail = require("./data/logFail.json");

jest.mock(
  "@salesforce/apex/Errors.log",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

afterEach(() => {
  jest.clearAllMocks();
});

describe("logError", () => {
  it("should log an error", async () => {
    const error = new Error("Test error");
    log.mockResolvedValue({});

    logError(error);

    expect(log).toHaveBeenCalledTimes(1);
    expect(log).toHaveBeenCalledWith({
      customExceptionLog: expect.objectContaining({
        apiName: "Custom_Exception_Log__e",
        fields: expect.objectContaining({
          Severity_Level__c: "Med",
          Error_Type__c: "JavaScript Error",
          Full_Message__c: error.message
        })
      })
    });
  });

  it("should fail to log an error", async () => {
    const error = new Error("Test error");
    log.mockRejectedValue(mockLogFail);

    try {
      logError(error);
    } catch (e) {
      // eslint-disable-next-line jest/no-conditional-expect
      expect(e).toEqual(mockLogFail);
    } finally {
      expect(log).toHaveBeenCalledTimes(1);
    }
  });
});

describe("logErrorHigh", () => {
  it("should log a high severity error", async () => {
    const error = new Error("Test error");
    log.mockResolvedValue({});

    logErrorHigh(error);

    expect(log).toHaveBeenCalledTimes(1);
    expect(log).toHaveBeenCalledWith({
      customExceptionLog: expect.objectContaining({
        apiName: "Custom_Exception_Log__e",
        fields: expect.objectContaining({
          Severity_Level__c: "High",
          Error_Type__c: "JavaScript Error",
          Full_Message__c: error.message
        })
      })
    });
  });

  it("should fail to log a high severity error", async () => {
    const error = new Error("Test error");
    log.mockRejectedValue(mockLogFail);

    try {
      logErrorHigh(error);
    } catch (e) {
      // eslint-disable-next-line jest/no-conditional-expect
      expect(e).toEqual(mockLogFail);
    } finally {
      expect(log).toHaveBeenCalledTimes(1);
    }
  });
});