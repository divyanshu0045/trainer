# FitAI - AI-Powered Fitness & Diet Planner

FitAI is a Flutter-based Android application that acts as a personal gym trainer and dietician. It leverages an AI backend to provide personalized workout and diet plans, tracks user progress, and offers an AI chat assistant for support.

---

## ✨ Features

- **Personalized Onboarding**: Collects user data to tailor fitness and diet plans.
- **AI-Generated Plans**: Integrates with OpenAI's GPT-4 API to create personalized workout and meal schedules.
- **Firebase Integration**: Uses Firebase for authentication, Firestore database, and messaging.
- **In-App API Key Management**: Prompts the user to enter their API key on first launch and securely stores it on the device using `shared_preferences`.
- **Tabbed Navigation**: Clean UI with separate tabs for Dashboard, Workouts, Diet, and Progress.
- **Progress Tracking**: Visualizes user progress with charts for weight and workout adherence.
- **AI Chat Assistant**: An interactive chat screen for live fitness and nutrition advice from GPT-4.
- **Local Notifications**: Service implemented for scheduling reminders.
- **State Management**: Built with Riverpod for robust and scalable state management.

---

## 🚀 Getting Started

Follow these instructions to get the project up and running on your local machine.

### Prerequisites

- **Flutter SDK**: Ensure you have the Flutter SDK installed. ([Installation Guide](https://flutter.dev/docs/get-started/install))
- **IDE**: Android Studio or VS Code with the Flutter plugin.
- **Firebase Account**: A Google account to create and manage the Firebase project.
- **OpenAI API Key**: An API key from OpenAI to use the GPT-4 model. You will be prompted to enter this in the app.

### Setup and Running

1.  **Firebase Setup**:
    - Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.
    - Add an Android app with the package name `com.fitai.app`.
    - For Google Sign-In, get your SHA-1 key by running `cd android && ./gradlew signingReport` in your project terminal. Add the `SHA1` value from the `debug` variant to the Firebase console.
    - Download the `google-services.json` file and place it in the `android/app/` directory.
      > **IMPORTANT**: The `google-services.json` file is **mandatory** for the app to connect to Firebase. The application will fail to build or run without it.
    - **Update Package Name**: Open the `android/app/build.gradle` file. Find the `applicationId` inside the `defaultConfig` block and change its value to `"com.fitai.app"` to match your `google-services.json`.
    - In the Firebase console, enable **Authentication** (Email/Password & Google) and **Firestore Database** (start in test mode).

2.  **Clone the Repository**:
    ```bash
    git clone <repository-url>
    cd fit_ai
    ```

3.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

4.  **Run the App**:
    - Connect a device or start an emulator and run the app:
    ```bash
    flutter run
    ```
    - On the first launch, you will be prompted to enter your OpenAI API key.

---

## 🧪 Manual Testing Instructions

1.  **Enter API Key**:
    - On the first launch, the app will prompt you to enter your OpenAI API key.
    - Enter a valid key and press "Save and Continue". The key will be saved to your device's local storage.

2.  **Onboarding**:
    - After saving the key, you should see the "Create Your Profile" screen.
    - Fill out all the fields in the multi-step form.
    - Click "Finish". The app will save your profile to Firestore and navigate to the `HomeScreen`.

3.  **Home Screen & Live Plan Generation**:
    - Upon reaching the `HomeScreen`, the app will make a **live API call** to OpenAI to generate your personalized plan. A loading indicator will be shown.
    - **Dashboard**: Verify the dashboard shows a summary of the AI-generated workout and diet.
    - **Workout & Diet Tabs**: Check that the tabs are populated with the data from the AI.

4.  **Detail Screens**:
    - Navigate to the workout and diet detail screens to see the full plans.

5.  **AI Chat Assistant**:
    - Click the floating action button to open the `ChatAssistantScreen`.
    - Type a message and send it. You should receive a **live response** from the AI assistant.

---

## 📦 Building the App for Release

To build a release version of the app, you can create either an Android App Bundle (recommended for Google Play) or an APK file.

### Build an App Bundle (.aab)

The App Bundle is the standard format for publishing apps on Google Play.

```bash
flutter build appbundle
```

The output file will be located at `build/app/outputs/bundle/release/app-release.aab`.

### Build an APK (.apk)

An APK can be useful for direct installation and testing on devices.

```bash
flutter build apk
```

The output file will be located at `build/app/outputs/flutter-apk/app-release.apk`.