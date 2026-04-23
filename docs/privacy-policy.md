# Privacy Policy

**Last updated:** April 23, 2026

Eisenhower Matrix ("the app") is developed and maintained by Thomas Borgogno as a free, open-source project.

This policy describes what data the app collects, how it is used, and your rights.

---

## 1. Data We Collect

### Google Account Information
When you sign in with Google, the app receives:
- Your **name** and **email address** (used to identify your account)
- Your **profile photo URL** (displayed in the app)

This information is provided by Google and is not stored independently — it is read at sign-in time.

### Task Data
All tasks and categories you create in the app are stored in **Firebase Firestore** under your Google account UID. This includes:
- Task title, description, due date, category, quadrant, and completion status
- Category names and emoji icons
- Timestamps (created/updated)

### Google Tasks (optional)
If you choose to import tasks from Google Tasks, the app reads the task lists and tasks from your Google Tasks account. Imported tasks are then stored in Firebase Firestore as described above.

---

## 2. How We Use Your Data

Your data is used **only** to provide the app's functionality:
- To sync your tasks across devices
- To display your tasks in the app and home screen widget
- To import tasks from Google Tasks on your request

We do **not**:
- Sell your data
- Share your data with third parties (other than Firebase, owned by Google)
- Use your data for advertising
- Access your data outside of what you explicitly do in the app

---

## 3. Data Storage & Security

Your task data is stored in [Firebase Firestore](https://firebase.google.com/products/firestore) (Google Cloud). Access is restricted by Firebase Security Rules so that only your authenticated account can read or write your data.

---

## 4. Third-Party Services

The app uses the following third-party services:

| Service | Purpose | Privacy Policy |
|---------|---------|---------------|
| Firebase Auth | Authentication | [Google Privacy Policy](https://policies.google.com/privacy) |
| Firebase Firestore | Data storage | [Google Privacy Policy](https://policies.google.com/privacy) |
| Google Sign-In | Login | [Google Privacy Policy](https://policies.google.com/privacy) |
| Google Tasks API | Optional import | [Google Privacy Policy](https://policies.google.com/privacy) |

---

## 5. Data Retention & Deletion

Your data is retained in Firestore as long as your account exists. To delete all your data, sign out and contact thomas.borgogno99@gmail.com to request account and data deletion, or delete your data directly from [Firebase Console](https://console.firebase.google.com) if you have access.

---

## 6. Children's Privacy

This app is not directed at children under 13. We do not knowingly collect personal data from children.

---

## 7. Changes to This Policy

If this policy changes materially, the "last updated" date at the top will be updated. Continued use of the app after changes constitutes acceptance.

---

## 8. Contact

Questions about this policy? Contact: thomas.borgogno99@gmail.com
