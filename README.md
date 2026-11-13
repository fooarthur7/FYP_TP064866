# Car Accident Assistance for iOS

An academic final-year prototype combining sound and accelerometer alerts, nearby repair-shop discovery, and user-confirmed emergency messaging. The iOS client uses SwiftUI; the API uses Vapor and PostgreSQL.

**Educational prototype:** this is not a certified crash detector or emergency-response service. Do not rely on it for safety-critical use or expose the backend publicly without addressing the security limitations below.

## Features

- Register, sign in, update a profile and emergency contact, and change a password.
- Browse nearby repair shops sorted by distance, view MapKit annotations and contact details, and open driving directions.
- Monitor microphone amplitude and accelerometer magnitude with fixed thresholds.
- Display an alert after both detection flags are set. Selecting **Open** requests an emergency message containing location and timestamp.
- Integrate with Twilio through the backend. Delivery and WhatsApp channel behavior have not been verified.

This is heuristic detection, not a trained model. No measured accuracy or real-world safety validation is included.

## Repository layout

- `ProjectTest2/`: SwiftUI iOS client, Xcode project, Podfile and test scaffolding.
- `ProjectTest2/ProjectTest2/`: views, audio/motion/location managers, networking and sample shop data.
- `MyMobileAppServer/Sources/App/`: Vapor routes, database models/migrations and Twilio integration.
- `MyMobileAppServer/Sources/Run/main.swift`: server entry point.
- `MyMobileAppServer/Tests/AppTests/`: existing backend test scaffolding.
- `MyMobileAppServer/.env.example`: safe local configuration template.

## Technology and requirements

SwiftUI, MapKit, CoreLocation, AVFoundation, CoreMotion, UserNotifications, Vapor, Fluent and PostgreSQL.

The iOS project targets iOS 17.5, uses Swift 5 language mode, and has an Xcode 15.4-era scheme. The server Dockerfile uses Swift 5.10. Package.resolved pins Vapor 4.102.1, Fluent 4.11.0 and FluentPostgresDriver 2.9.2. These are project settings, not a tested compatibility matrix.

## Configure the backend

From `MyMobileAppServer/`, copy `.env.example` to `.env` and fill it locally. Vapor can load the file from the package working directory; exported environment variables can also be used. Never commit populated credentials.

| Variable | Behavior |
| --- | --- |
| DATABASE_HOST | Defaults to localhost |
| DATABASE_PORT | Defaults to 5432 |
| DATABASE_USERNAME | Required; startup fails clearly when missing |
| DATABASE_PASSWORD | Required; no embedded password fallback |
| DATABASE_NAME | Required |
| SERVER_HOST | Defaults to 127.0.0.1; choose a reachable LAN interface for a physical device |
| SERVER_PORT | Defaults to 8081 |
| TWILIO_ACCOUNT_SID | Optional unless messaging is needed |
| TWILIO_AUTH_TOKEN | Optional unless messaging is needed |
| TWILIO_FROM_NUMBER | Optional unless messaging is needed |

All three Twilio settings must be nonempty for emergency messaging. Otherwise that endpoint returns a configuration error with HTTP 503. Port values must be integers between 1 and 65535.

Prepare a dedicated local PostgreSQL database matching the configuration. After reviewing configuration and migrations, the intended development commands are:

```sh
cd MyMobileAppServer
cp .env.example .env
# Edit .env locally before continuing.
swift build
swift run Run
```

**Startup automatically applies database migrations.** Do not point development or tests at a real production database. Repair-shop records must be populated separately; no working database seed command is provided.

The included Compose file passes environment-backed database and messaging settings, binds the container server to 8080, and requires local database credentials. It is not a verified deployment path: the Dockerfile still assumes an executable named App, while the active entry point belongs to Run.

## Configure the iOS app

1. Open `ProjectTest2/ProjectTest2.xcodeproj` in Xcode.
2. Select your signing team for physical-device builds. Machine-specific signing and plist paths have been removed from shared configuration.
3. Review CocoaPods setup. The Podfile declares Alamofire, but application networking currently uses URLSession. Lock/workspace outputs are absent and test targets retain CocoaPods build phases; `pod install` may be needed to regenerate the workspace.
4. Replace the hardcoded LAN API address in LoginView, RegisterView, MyProfileView, ChangePasswordView, NetworkManager and HomeView with your backend address. Centralizing this configuration is future work.
5. Build and run. A clean end-to-end build and device test have not been verified.

Use a physical device to evaluate microphone and accelerometer behavior. Test with consented contacts and avoid enabling live outgoing messaging until its behavior is reviewed.

## Detection and messaging

AudioManager samples every 0.1 seconds and triggers above a linear amplitude of 0.7. VibrationManager uses the same interval and triggers above an acceleration magnitude of 2.5. HomeView combines flags and presents the confirmation alert.

There is no time-window check establishing that the two detections occurred together. Reset/restart behavior needs improvement. Declared background modes do not establish reliable background sensing.

An emergency request sends an email identifier, coordinates and timestamp to the backend. The backend retrieves contact details and constructs a message with a Google Maps link. The Twilio helper is named for WhatsApp, but active formatting and form encoding need review; successful delivery is not established.

## API

| Method | Route | Purpose |
| --- | --- | --- |
| POST | /register | Register with a Bcrypt-hashed password |
| POST | /login | Verify email/password |
| GET | /car_repair_shops_details | List repair shops |
| GET | /user | Read profile by email |
| PUT | /user | Update profile/contact details |
| POST | /change_password | Verify and change password |
| POST | /send_emergency_message | Request emergency-contact messaging |

## Security and privacy limitations

- Previously committed credentials must be rotated with their issuers. Removing values from current source does not revoke them or remove them from Git history.
- Login does not issue a session/token. Profile and emergency-message routes lack authenticated authorization.
- The user response includes a password hash and contact fields that should not be exposed.
- The client retains a plaintext password and logs profile requests/responses. These behaviors require a separate security fix.
- Client requests use HTTP, the plist allows arbitrary loads, and NetworkManager bypasses normal certificate validation. HTTPS and proper validation are required before deployment.
- The app requests location, microphone and notification access and uses motion sensors. Emergency messages may share names, phone numbers and location.
- Personal Xcode user-state files are ignored and no longer tracked. Source attribution remains intact.

## Sample dataset

`ProjectTest2/ProjectTest2/sample-data-Car_repair_and_maintenances.csv` contains Malaysian repair-shop business information. It has a title line before the CSV header and quoted fields. Its original source and redistribution license are not documented. Confirm those rights before reuse.

The legacy client importer is commented out. Runtime shop data comes from PostgreSQL.

## Tests and remaining work

- iOS tests are unit/launch/performance templates rather than feature coverage.
- Backend tests target hello/todo routes not registered by the current app.
- Backend teardown reverts database migrations. Use only a dedicated disposable test database.
- Legacy Core Data and commented scaffolding remain.
- Docker executable alignment, authentication, transport security, sensor reliability and seed tooling remain open work.
- No full application test, live message delivery or production deployment is claimed.

## License

No project license is included. Dependencies retain their own licenses; dataset redistribution rights are undocumented.

### Cleanup verification

Swift syntax parsing for the changed server files, Xcode project plist validation, ignore-rule checks and Git whitespace checks passed. A full Swift build was attempted but blocked by the local command-line-tools/sandbox environment before application compilation. No app, database tests or live messaging request was run.
