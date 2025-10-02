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

There are two ways to set up the project: the easy automated script or the detailed manual process.

#### Option 1: Automated Setup (Recommended)

The `setup.sh` script automates all the necessary steps, including creating the Firebase project, configuring apps, and installing dependencies.

1.  **Clone the Repository**:
    ```bash
    git clone <repository-url>
    cd fit_ai
    ```

2.  **Make the script executable**:
    ```bash
    chmod +x setup.sh
    ```

3.  **Run the script**:
    ```bash
    ./setup.sh
    ```
    The script will prompt you for your desired **Firebase Project ID** and your **OpenAI API Key**. It will then pause for interactive input during the `firebase init` step—the script itself will print clear instructions on what to select.

4.  **Run the App**:
    - Once the script is finished, complete the final manual steps it provides (enabling auth methods in the Firebase Console).
    - Then, run the app:
    ```bash
    flutter run
    ```
    - On the first launch, you will be prompted to enter your OpenAI API key.

#### Option 2: Manual Setup

<details>
<summary>Click to view detailed manual setup instructions</summary>

1.  **Clone the Repository**:
    ```bash
    git clone <repository-url>
    cd fit_ai
    ```

2.  **Generate Native Project Files (Crucial First Step)**:
    This project contains only the cross-platform Dart code. You must generate the native `android` and `ios` project files yourself. Run the following command from the root of the project directory:
    ```bash
    flutter create .
    ```
    This will safely create the necessary native project folders without overwriting any of the existing Dart code.

3.  **Firebase Setup (CLI-First Method)**:
    This guide uses the Firebase CLI for a faster and more reproducible setup.

    a. **Install Firebase CLI**: If you don't have it, install it globally:
       ```bash
       npm install -g firebase-tools
       ```

    b. **Login to Firebase**:
       ```bash
       firebase login
       ```

    c. **Create Firebase Project**: Run the following command to create a new Firebase project. Replace `fitai-app-xxxx` with a unique, valid project ID (6-30 lowercase letters, numbers, and hyphens).
       ```bash
       firebase projects:create fitai-app-xxxx --display-name "FitAI App"
       ```

    d. **Initialize Firebase in your project**: From the root of your project directory, run:
        ```bash
        firebase init
        ```
        - When prompted, select **"Use an existing project"** and choose the project you just created (`fitai-app-xxxx`).
        - Select the services you want to set up: **Firestore** and **Functions**.
        - For Firestore, accept the default rules file (`firestore.rules`).
        - For Functions, choose JavaScript, accept the defaults for ESLint, and agree to install dependencies with npm. This will link your local `functions` directory to the Firebase project.

    e. **Create Android App & Get Config**:
       ```bash
       firebase apps:create android com.fitai.app
       firebase apps:sdkconfig android -o android/app/google-services.json
       ```
       > **Note**: After running `flutter create .`, the `applicationId` in `android/app/build.gradle` might be different. Ensure it is set to `com.fitai.app` to match this setup.

    f. **Create iOS App & Get Config (Requires a Mac)**:
       ```bash
       firebase apps:create ios com.fitai.app
       firebase apps:sdkconfig ios -o ios/Runner/GoogleService-Info.plist
       ```
       > **Note**: After running `flutter create .`, open `ios/Runner.xcworkspace` in Xcode and ensure the "Bundle Identifier" is set to `com.fitai.app`.

    g. **Enable Firebase Services (Manual Step)**:
       This part is still easiest via the web console. Go to your new project in the [Firebase Console](https://console.firebase.google.com/):
       - In the left-hand menu, go to **Authentication** > **Sign-in method** and enable **Email/Password** and **Google**.
       - Go to **Firestore Database** and create a database. Start in **test mode** for easy setup.

    h. **Secure Your Database**: The `firestore.rules` file in the root directory contains rules to protect user data. To deploy them, run the following command from the project root:
      ```bash
      firebase deploy --only firestore:rules
      ```

4.  **Backend Cloud Function Setup**:
    This project includes a Firebase Cloud Function to automatically adjust user plans based on their feedback. To deploy it, you need the Firebase CLI.

    a. **Set OpenAI API Key**: For security, the function retrieves your API key from the environment configuration. Set it by running this command from the `functions` directory:
       ```bash
       firebase functions:config:set openai.key="YOUR_OPENAI_API_KEY"
       ```

    b. **Deploy the function**:
       ```bash
       firebase deploy --only functions
       ```

5.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

6.  **Run the App**:
    - Connect a device or start an emulator and run the app:
    ```bash
    flutter run
    ```
    - On the first launch, you will be prompted to enter your OpenAI API key.
</details>

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

6.  **Test AI Plan Adjustment**:
    - After using the app for a while, navigate to the `FollowUpScreen` (Note: a button for this screen would need to be added to the UI, e.g., in the Profile or Settings screen).
    - Submit feedback.
    - Check the Firebase Cloud Functions logs to see the `adjustPlanOnFeedback` function trigger and execute.
    - Check your `workoutPlans` and `mealPlans` collections in Firestore to verify that the data has been updated by the function.

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

---

## 🎨 Asset Generation

After changing the placeholder images in `assets/images/` (`icon.png` and `splash.png`), you must run the following commands from the project root to apply your new app icon and splash screen.

### Generate App Icon

This command will generate all the necessary app icons for Android and iOS.

```bash
flutter pub run flutter_launcher_icons:main
```

### Generate Splash Screen

This command will create the native splash screens.

```bash
flutter pub run flutter_native_splash:create
```