#!/bin/bash

# A script to automate the setup of the FitAI Flutter project.

# --- Helper Functions ---
print_color() {
    COLOR=$1
    TEXT=$2
    echo -e "\e[${COLOR}m${TEXT}\e[0m"
}

# --- Main Script ---

print_color "36" "--- FitAI Flutter App Setup Script ---"
echo "This script will guide you through setting up the necessary Firebase project and local configuration."
echo

# 1. Check Dependencies
print_color "33" "Checking for required tools (Flutter & Firebase CLI)..."
if ! command -v flutter &> /dev/null; then
    print_color "31" "Error: Flutter SDK not found. Please install it and make sure it's in your PATH."
    exit 1
fi
if ! command -v firebase &> /dev/null; then
    print_color "31" "Error: Firebase CLI not found. Please run 'npm install -g firebase-tools' to install it."
    exit 1
fi
print_color "32" "✓ All required tools are installed."
echo

# 2. Prompt for User Input
while true; do
  read -p "Enter a new, unique Firebase Project ID (6-30 lowercase letters, numbers, hyphens): " FIREBASE_PROJECT_ID
  if [[ ${#FIREBASE_PROJECT_ID} -ge 6 && ${#FIREBASE_PROJECT_ID} -le 30 && "$FIREBASE_PROJECT_ID" =~ ^[a-z0-9-]+$ ]]; then
    break
  else
    print_color "31" "Invalid Project ID. Please ensure it is 6-30 characters long and contains only lowercase letters, numbers, and hyphens."
  fi
done

read -sp "Enter your OpenAI API Key (it will not be displayed): " OPENAI_API_KEY
echo
echo

# 3. Execute Setup Commands
print_color "33" "Step 1/9: Generating native Flutter project files..."
flutter create .
print_color "32" "✓ Flutter project files generated."
echo

print_color "33" "Step 2/9: Logging into Firebase..."
firebase login
print_color "32" "✓ Firebase login complete."
echo

print_color "33" "Step 3/9: Creating Firebase project '$FIREBASE_PROJECT_ID'..."
firebase projects:create $FIREBASE_PROJECT_ID --display-name "FitAI App"
if [ $? -ne 0 ]; then
    print_color "31" "Error: Failed to create Firebase project. It might already exist or there was a network issue."
    exit 1
fi
print_color "32" "✓ Firebase project created successfully."
echo

print_color "33" "Step 4/9: Initializing Firebase in this project..."
print_color "36" "The next step is interactive. Please make the following selections:"
print_color "36" "  - Are you ready to proceed? > Press Enter"
print_color "36" "  - Which Firebase features? > Use arrows and spacebar to select 'Firestore' and 'Functions'."
print_color "36" "  - Please select an option: > Use an existing project"
print_color "36" "  - Select a default Firebase project: > Select the project you just created ($FIREBASE_PROJECT_ID)."
print_color "36" "  - What file should be used for Firestore Rules? > Press Enter (firestore.rules)"
print_color "36" "  - What language for Cloud Functions? > JavaScript"
print_color "36" "  - Use ESLint? > Yes"
print_color "36" "  - Install dependencies with npm now? > Yes"
firebase init
print_color "32" "✓ Firebase project initialized."
echo

print_color "33" "Step 5/9: Creating Android app and configuration..."
firebase apps:create android com.fitai.app --project=$FIREBASE_PROJECT_ID
firebase apps:sdkconfig android -o android/app/google-services.json --project=$FIREBASE_PROJECT_ID
print_color "32" "✓ Android app created and configured."
echo

print_color "33" "Step 6/9: Creating iOS app and configuration..."
firebase apps:create ios com.fitai.app --project=$FIREBASE_PROJECT_ID
firebase apps:sdkconfig ios -o ios/Runner/GoogleService-Info.plist --project=$FIREBASE_PROJECT_ID
print_color "32" "✓ iOS app created and configured."
echo

print_color "33" "Step 7/9: Setting OpenAI API Key for backend function..."
firebase functions:config:set openai.key="$OPENAI_API_KEY" --project=$FIREBASE_PROJECT_ID
print_color "32" "✓ OpenAI API Key configured for the backend."
echo

print_color "33" "Step 8/9: Installing Flutter app dependencies..."
flutter pub get
print_color "32" "✓ Flutter dependencies installed."
echo

print_color "33" "Step 9/9: Deploying Firestore security rules..."
firebase deploy --only firestore:rules --project=$FIREBASE_PROJECT_ID
print_color "32" "✓ Firestore security rules deployed."
echo

# 4. Final Instructions
print_color "36" "--- ✅ Automatic Setup Complete! ---"
echo
print_color "33" "Two final manual steps are required:"
echo "1. Go to your new project in the Firebase Console: https://console.firebase.google.com/project/$FIREBASE_PROJECT_ID"
echo "2. In the left-hand menu, go to 'Authentication' > 'Sign-in method' and enable 'Email/Password' and 'Google'."
echo "3. Go to 'Firestore Database' and create a database if one wasn't created during 'init'."
echo
print_color "32" "After completing the manual steps, you can deploy the backend functions with 'firebase deploy --only functions' and run the app with 'flutter run'."
echo