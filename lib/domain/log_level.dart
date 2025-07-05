enum LogLevel {
  apiError, // API failed, error message
  apiResponse, // API response body
  apiHeaders, // API response/request headers
  apiBody, // API request payload
  apiUrl, // API endpoint or URL

  stackTrace, // Full stack trace log
  unkown, // Undefined or fallback
}
