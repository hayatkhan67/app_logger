📦 App Logger
A Clean Architecture based, Firebase-powered logger for your Flutter apps.
Save logs to Firebase, control visibility per environment, and view color-coded logs in your console.

✨ Features
✅ Log messages with different levels (info, warning, error, critical)
✅ Save logs to your own Firebase project (Firestore)
✅ Console logs with color-coded output (fully customizable)
✅ Device info, app version, and platform auto-captured
✅ Enable/disable Firebase logging based on build mode (debug / release)
✅ Follows Clean Architecture structure internally

🚀 Getting Started
Installation
Add to your pubspec.yaml:

yaml
Copy
Edit
dependencies:
  app_logger:
    path: ../app_logger  # Adjust path as per your setup
Run:

bash
Copy
Edit
flutter pub get
⚡ Basic Usage
1. Import the Package
dart
Copy
Edit
import 'package:app_logger/app_logger.dart';
import 'package:firebase_core/firebase_core.dart';
2. Initialize App Logger
Firebase setup example:

dart
Copy
Edit
const firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSy...xyz",
  authDomain: "your-app.firebaseapp.com",
  projectId: "your-app",
  storageBucket: "your-app.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:1234567890:web:abcdefg12345",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppLogger.initialize(
    firebaseOptions: firebaseOptions,
    config: LoggerConfigEntity(
      enableInDebug: true,   // Allow saving logs in debug mode
      enableInRelease: true, // Allow saving logs in release mode
      logColors: {
        LogLevel.info: '\x1B[36m',     // Cyan
        LogLevel.warning: '\x1B[33m',  // Yellow
        LogLevel.error: '\x1B[31m',    // Red
        LogLevel.critical: '\x1B[41m', // Red Background
      },
    ),
  );

  runApp(const MyApp());
}
3. Log Messages
dart
Copy
Edit
AppLogger.log("App Started");

AppLogger.log(
  "API request failed",
  level: LogLevel.error,
  extra: {
    "endpoint": "/login",
    "status": 500,
  },
);

AppLogger.log(
  "Critical system failure",
  level: LogLevel.critical,
);
🎨 Console Log Output Example
csharp
Copy
Edit
[INFO] App Started
[ERROR] API request failed
[CRITICAL] Critical system failure
Colors depend on your logColors config

📂 Where Logs Are Saved
Logs are stored in your Firebase Firestore, in a logs collection with fields like:

json
Copy
Edit
{
  "log": "API request failed",
  "level": "error",
  "timestamp": "2025-07-03T11:00:00Z",
  "device": "Pixel 6",
  "platform": "Android",
  "appVersion": "1.0.0",
  "extra": {
    "endpoint": "/login",
    "status": 500
  }
}
⚙ Advanced Configuration
Option	Description	Default
enableInDebug	Save logs to Firebase in debug mode	true
enableInRelease	Save logs to Firebase in release mode	true
logColors	Define console log colors per log level	Pre-defined

🔥 Dependencies
firebase_core

cloud_firestore

device_info_plus

package_info_plus

Version ranges are set for long-term support

📁 Internal Clean Architecture
Domain Layer → Entities, enums, repository contract

Data Layer → Firebase datasource implementation

Core Layer → Device helpers, color print logic, config management

Facade → Easy-to-use AppLogger public interface

🛠 Contributing
PRs and suggestions are welcome!
Let's build better logging for Flutter.

📢 Note
This package requires users to connect their own Firebase project.
We don't store or process your data externally.

🏁 Start logging smarter, start with App Logger!
