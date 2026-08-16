# LIFEGUARD AI Emergency SMS Function
This directory contains the Phase 3B Firebase Cloud Function `sendEmergencyAlert`.

## Security
Twilio credentials must never be placed in Flutter, Firestore, Android files, Git, or logs. The function uses Firebase Functions Secret Manager parameters:

- `TWILIO_ACCOUNT_SID`
- `TWILIO_AUTH_TOKEN`
- `TWILIO_FROM_NUMBER`

The function authenticates the caller, verifies ownership of `users/{uid}/sos_alerts/{eventId}`, claims delivery atomically, loads contacts under the same user, validates phone numbers, sends independently, and writes delivery results back to the event document.

## Local setup
From `functions/`:

```powershell
npm install
npm run build
```

For emulator-only work, provide non-production test configuration through your local Firebase Functions configuration mechanism. Do not commit secrets.

## Configure production secrets
From the Flutter project root, after selecting the correct Firebase project:

```powershell
firebase use lifeguard-ai-24714
firebase functions:secrets:set TWILIO_ACCOUNT_SID
firebase functions:secrets:set TWILIO_AUTH_TOKEN
firebase functions:secrets:set TWILIO_FROM_NUMBER
```

The CLI prompts for each value; values are not stored in source code. Use a Twilio Messaging Service instead of `TWILIO_FROM_NUMBER` only after changing the function payload to use a server-side Messaging Service SID secret.

## Deploy
```powershell
cd functions
npm install
npm run build
cd ..
firebase deploy --only functions:sendEmergencyAlert
```

Do not deploy until the Firebase project is on a plan that supports Cloud Functions and the Twilio sender is approved/configured. Trial Twilio accounts can only send to verified recipient numbers.

## Test safety
The Flutter and TypeScript tests use fakes/build validation only. No real SMS is sent by tests.
