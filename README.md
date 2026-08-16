\# 🚨 LIFEGUARD AI



\## AI-Powered Emergency Response \& Personal Safety Platform



LIFEGUARD AI is an intelligent healthcare and emergency response mobile application designed to provide rapid assistance during critical situations using Artificial Intelligence, Machine Learning, and real-time location services.



The platform provides smart SOS activation, emergency contact management, GPS-based emergency events, fall detection, and AI health assistance to improve personal safety and emergency response.



\---



\# ✨ Features



\## 🚨 Smart SOS Emergency System

\- 5-second cancellable SOS countdown

\- Real-time GPS location capture

\- Emergency event creation and persistence

\- Secure Firebase Firestore storage

\- Google Maps location sharing



\## 👥 Emergency Contact Management

\- Add, edit, and delete emergency contacts

\- Set primary emergency contact

\- User-specific Firestore synchronization

\- Clean Architecture implementation



\## 🧠 AI Health Assistant

\- AI-powered healthcare assistance

\- Disease information support

\- Future medical intelligence integration



\## 🩺 Fall Detection

\- Smartphone sensor-based fall detection

\- Accelerometer and gyroscope analysis

\- Machine learning integration (planned)



\---



\# 🏗️ Architecture



LIFEGUARD AI follows Clean Architecture principles.



```

lib/

│

├── core/

│   ├── constants

│   ├── services

│   ├── theme

│   └── dependency injection

│

├── features/

│   ├── auth/

│   ├── contacts/

│   └── sos/

│

└── presentation/

&#x20;   ├── screens

&#x20;   └── router

```



\---



\# 🛠️ Tech Stack



\### Mobile Application

\- Flutter

\- Dart

\- Flutter Bloc / Cubit

\- Go Router



\### Backend

\- Firebase Authentication

\- Cloud Firestore



\### AI / ML

\- Machine Learning

\- TensorFlow Lite (Future Integration)

\- On-device AI Processing



\### Tools

\- VS Code

\- Android Studio

\- GitHub



\---



\# 🚑 SOS Workflow



```

User presses SOS

&#x20;       ↓

5-second countdown

&#x20;       ↓

Capture GPS location

&#x20;       ↓

Load emergency contacts

&#x20;       ↓

Create emergency event

&#x20;       ↓

Store securely in Firebase

&#x20;       ↓

Ready for alert delivery

```



\---



\# 📌 Development Status



\## Phase 1 ✅

Authentication Module



\## Phase 2 ✅

Emergency Contacts Module



\## Phase 3A ✅

Core Emergency SOS



Implemented:

\- SOS countdown

\- Location service

\- Emergency event model

\- Firestore persistence

\- SOS Cubit

\- Unit testing



\## Phase 3B 🚧

Upcoming:

\- SMS emergency alerts

\- Network notification system

\- Real-time alert delivery



\---



\# 🧪 Testing



Current test coverage:



```

✓ Emergency Contact Model Tests

✓ Emergency Event Model Tests

✓ SOS Cubit Tests

✓ Widget Tests



Total: 19 Tests Passed

```



\---



\# 🔐 Security



\- User-scoped Firestore data

\- Private emergency records

\- Secure authentication flow

\- Protected emergency information



\---



\# 👨‍💻 Developer



\*\*Madhan Kumar S\*\*  

B.Tech Artificial Intelligence \& Data Science  

Sri Sairam Engineering College



\---



\## ⭐ Project Vision



To build an intelligent AI-based emergency companion that can assist individuals during critical situations and reduce emergency response time.

