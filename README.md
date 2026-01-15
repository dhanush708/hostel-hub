# Hostel Hub

A mobile-based hostel management prototype that allows students to record meal intentions and submit simple reports, with admin-side viewing through Firebase.

---

## 1. One-line project description

A Flutter application that connects to Firebase to record meal orders, track basic complaints, and list lost-and-found items within a hostel context.

---

## 2. Problem statement

In many hostels, daily meal counts, complaints, and lost items are handled informally.  
Counts are often estimated, complaints are passed verbally, and lost items are hard to track.  
This creates unnecessary food waste, delayed issue handling, and duplicated communication.

Hostel Hub explores whether a small digital system can make these interactions more structured without changing existing hostel roles.

---

## 3. What the system does

Based strictly on the existing codebase, the system:

- Displays a login screen
- Treats one fixed account as an admin
- Treats all other accounts as students
- Allows students to:
  - Mark whether they want a meal
  - Submit a short complaint entry
  - Submit a short lost-and-found entry
- Allows the admin to:
  - Enable or disable meal submission
  - View live meal counts
  - View student complaints
  - View lost-and-found items
  - Clear recorded complaints and lost-and-found entries
- Persists all data in Firebase Firestore
- Stores simple local session state with SharedPreferences

There are no additional behaviors beyond what is listed above.

---

## 4. What the system does NOT do

The system does not:

- Validate hostel identity
- Verify student information
- Infer reasons for complaints
- Categorize or prioritize reports
- Perform scheduling or messaging
- Predict meal demand
- Provide analytics or dashboards
- Connect to payment systems
- Synchronize across hostels
- Accept images or binary uploads
- Modify data formats automatically
- Handle offline mode
- Perform authentication against real user directories

No intelligence, learning, or adaptation are claimed or implied.

---

## 5. How the system works (high-level)

At a high level:

1. The user opens the Flutter application.
2. A local check retrieves a stored username from SharedPreferences.
3. If no username is stored, a simple username/password form is shown.
4. One hard-coded credential maps to an admin role.
5. All other credentials map to a student role.
6. Once logged in:
   - Students write data into Firestore collections.
   - Admin reads from the same collections.
7. Admin actions directly modify Firestore documents.
8. UI components listen for Firestore updates and refresh automatically.

There is no separate backend server, and no processing outside Firestore updates.

---

## 6. How to run the project

Local execution only:

1. Install Flutter and Dart on your development machine.
2. Clone this repository.
3. Create a Firebase project configured for Android builds.
4. Download and place the `google-services.json` file into the Android app module.
5. Connect an Android device or start an emulator.
6. Run the following commands:

```bash
flutter pub get
flutter run
```

No deployment, hosting, or remote pipeline is required beyond Firebase configuration.

---

## 7. Input rules

Accepted inputs:

- Usernames as free-form text
- Passwords as free-form text
- Complaint text as free-form text
- Lost-and-found fields (item name, place, date, time)
- Meal toggle controlled by the admin

Rejected or unsupported inputs:

- Images
- Videos
- Binary files
- Structured data formats
- Empty Firebase configuration
- Non-UTF8 strings

Refusals occur when:

- Firebase is not initialized
- Firestore collections are missing
- SharedPreferences fails to load
- Admin disables meal submission

Refusals exist to avoid invalid writes and inconsistent state.

---

## 8. Output states

The system presents one of the following states:

### `login_required`
SharedPreferences has no stored user; login screen is displayed.

### `student_dashboard`
Student logged in; forms for meals, complaints, and lost items are available.

### `admin_dashboard`
Admin logged in; Firestore snapshots are visible with controls for data management.

### `write_refused`
Student attempts a meal submission when the admin has disabled the toggle.

### `firebase_unavailable`
Firebase configuration or initialization failed.

These states map directly to UI behaviors present in the codebase.

---

## 9. Why refusal is a feature

The system avoids guessing user intent.  
If Firebase is not configured or meal submissions are disabled, writing data would produce unclear or misleading records.  
Refusing to proceed in these cases preserves correctness and prevents silent corruption.

Refusal is therefore intentional and part of the design.

---

## 10. Limitations

Intentional limitations include:

- Hard-coded admin credential
- No encryption of local session state
- No role management beyond admin/student split
- No cross-hostel support
- No analytics or insights
- No offline caching
- No retry logic
- No media upload
- Android-focused testing only

These limitations keep the prototype simple and controlled.

---

## 11. Who this project is for

This repository is intended for:

- Engineers reviewing Flutter + Firebase fundamentals
- Recruiters evaluating candidate code samples
- Reviewers assessing correctness-focused prototypes
- Students learning mobile development basics

It is not intended as a production hostel management platform.

---

## 12. Internal technical details

### Data storage
Records are stored in Firestore collections for meals, complaints, and lost-and-found entries.  
Documents are written or cleared directly by UI actions.

### Authentication
A simple login screen checks a hard-coded credential for admin mode.  
Other credentials are treated as student accounts without verification.

### State management
No advanced state management library is used.  
UI updates rely on Firestore snapshot streams and simple widget rebuilds.

### Local persistence
SharedPreferences stores the last used user identifier to skip login screens when possible.

### Platform assumptions
The project expects an Android execution environment, a valid Firebase configuration, and network connectivity during operation.

---

## 13. Attribution

Built end-to-end by **Dhanush** as a correctness-focused Flutter + Firebase prototype.
