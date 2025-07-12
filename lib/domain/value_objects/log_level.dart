enum LogLevel {
  apiError, // API failed, error message
  apiResponse, // API response body
  apiHeaders, // API response/request headers
  apiBody, // API request payload
  endPoint, // API endpoint or URL

  stackTrace, // Full stack trace log
  commonLogs, // Undefined or fallback
}
