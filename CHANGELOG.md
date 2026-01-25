## 0.1.0 - 2026-01-26

### Performance Improvements
* **Log Batching**: Implemented intelligent batching system that reduces Firestore writes by 10x
  - Logs are buffered and sent in batches of 10
  - Auto-flush every 5 seconds if buffer has pending logs
  - Added `dispose()` method to manually flush remaining logs
* **Device Info Caching**: Device metadata (model, platform, app version) is now cached at initialization
  - Eliminates repeated async calls on every log
  - Significantly improves logging performance

### Bug Fixes
* **Empty String Validation**: Added validation to prevent null or empty messages from being logged
  - Reduces junk data in Firestore
  - Improves data quality and storage efficiency

### Breaking Changes
* Added `saveLogs(List<LoggerEntity>)` method to `LoggerRepository` interface
* `dispose()` method added for cleanup (optional, but recommended to call on app dispose)

### Internal Changes
* Improved code organization and removed commented-out code
* Enhanced error handling with better assertions

---

## 0.0.1 - Initial Release

* Firebase-powered logging with Clean Architecture
* Multiple log levels (commonLogs, apiError, apiResponse, etc.)
* Real-time settings sync from Firestore
* Color-coded console output
* Automatic device info capture
* Environment-aware logging (debug/release modes)

