---
layout: default
title: Privacy Policy
permalink: /privacy-policy
---

# Privacy Policy

**Last updated:** May 1, 2026

"IkeTasks - Eisenhower to-do app" is developed and maintained by Thomas Borgogno as a free, open-source project.

This policy describes what data the app collects, how it is used, and your rights.

---

## 1. Data We Collect

### Google Account Information
When you sign in with Google, the app receives:
- Your **name** and **email address** (used to identify your account)
- Your **profile photo URL** (displayed in the app)

This information is provided by Google and is not stored independently — it is read at sign-in time.

### Guest (Anonymous) Users
If you choose to use the app without signing in, Firebase assigns an **anonymous UID** to your device. No personal information is collected. Your task data is stored in Firebase Firestore under this anonymous UID. The anonymous UID is tied to the app installation on the device and is lost if the app is uninstalled or its data is cleared.

### Task Data
All tasks and categories you create are stored in **Firebase Firestore** under your account UID (Google or anonymous). This includes:
- Task title, description, due date, category, quadrant, and completion status
- Category names and emoji icons
- Timestamps (created/updated)

### Google Tasks (optional, Google accounts only)
If you choose to import tasks from Google Tasks, the app reads the task lists and tasks from your Google Tasks account. Imported tasks are then stored in Firebase Firestore as described above.

---

## 2. How We Use Your Data

Your data is used **only** to provide the app's functionality:
- To sync your tasks across devices (Google accounts)
- To store your tasks locally on the device (guest mode)
- To display your tasks in the app and home screen widget
- To import tasks from Google Tasks on your request (Google accounts only)

We do **not**:
- Sell your data
- Share your data with third parties (other than Firebase, owned by Google)
- Use your data for advertising
- Access your data outside of what you explicitly do in the app

---

## 3. Data Storage & Security

Your task data is stored in [Firebase Firestore](https://firebase.google.com/products/firestore) (Google Cloud), regardless of whether you use a Google account or guest mode. Access is restricted by Firebase Security Rules so that only your authenticated session (Google or anonymous) can read or write your data.

For guest users: data is tied to the anonymous UID assigned to the device. If you later sign in with Google, your data can be linked to your Google account. If the Google account already exists, a new session is started and guest data is not migrated.

---

## 4. Third-Party Services

The app uses the following third-party services:

| Service | Purpose | Privacy Policy |
|---------|---------|---------------|
| Firebase Auth | Authentication (Google and anonymous) | [Google Privacy Policy](https://policies.google.com/privacy) |
| Firebase Firestore | Data storage | [Google Privacy Policy](https://policies.google.com/privacy) |
| Google Sign-In | Login (optional) | [Google Privacy Policy](https://policies.google.com/privacy) |
| Google Tasks API | Optional import (Google accounts only) | [Google Privacy Policy](https://policies.google.com/privacy) |

---

## 5. Data Retention & Deletion

**Google accounts:** Your data is retained in Firestore as long as your account exists. To delete your account and all associated data, tap your profile picture in the app, then tap the account button and select **Delete Account**. You can also contact thomas.borgogno99@gmail.com to request account and data deletion.

**Guest accounts:** Data is retained in Firestore under the anonymous UID. Because there is no account to recover, data is effectively lost if the app is uninstalled. To delete guest data, uninstall the app or contact thomas.borgogno99@gmail.com.

---

## 6. Children's Privacy

This app is not directed at children under 13. We do not knowingly collect personal data from children.

---

## 7. Changes to This Policy

If this policy changes materially, the "last updated" date at the top will be updated. Continued use of the app after changes constitutes acceptance.

---

## 8. Contact

Questions about this policy? Contact: thomas.borgogno99@gmail.com
