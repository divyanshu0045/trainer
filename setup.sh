#!/bin/bash

# A script to perform the initial, non-interactive setup of the FitAI Flutter project.

# --- Helper Functions ---
print_color() {
    COLOR=$1
    TEXT=$2
    echo -e "\e[${COLOR}m${TEXT}\e[0m"
}

# --- Main Script ---

print_color "36" "--- FitAI Flutter App Initial Setup Script ---"
echo "This script will perform the initial non-interactive setup steps."
echo "It will then provide you with the final commands to run manually."
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

# 3. Execute Non-Interactive Setup Commands
print_color "33" "Step 1/3: Generating native Flutter project files..."
flutter create .
print_color "32" "✓ Flutter project files generated."
echo

print_color "33" "Step 2/3: Logging into Firebase..."
firebase login
print_color "32" "✓ Firebase login complete."
echo

print_color "33" "Step 3/3: Creating Firebase project '$FIREBASE_PROJECT_ID'..."
firebase projects:create $FIREBASE_PROJECT_ID --display-name "FitAI App"
if [ $? -ne 0 ]; then
    print_color "31" "Error: Failed to create Firebase project. It might already exist or there was a network issue."
    exit 1
fi
print_color "32" "✓ Firebase project created successfully."
echo

# 4. Final Instructions
print_color "36" "--- ✅ Initial Setup Complete! ---"
echo
print_color "33" "Please run the following commands manually, one by one, to complete the setup."
echo
print_color "32" "# 1. Initialize Firebase in your project (this is interactive)"
echo "firebase init"
echo "#  -> When prompted, select 'Use an existing project' and choose '$FIREBASE_PROJECT_ID'."
echo "#  -> Select 'Firestore' and 'Functions'."
echo "#  -> Accept the defaults for the rules file, language (JavaScript), and ESLint."
echo
print_color "32" "# 2. Create the Android and iOS apps"
echo "firebase apps:create android com.fitai.app --project=$FIREBASE_PROJECT_ID"
echo "firebase apps:sdkconfig android -o android/app/google-services.json --project=$FIREBASE_PROJECT_ID"
echo "firebase apps:create ios com.fitai.app --project=$FIREBASE_PROJECT_ID"
echo "firebase apps:sdkconfig ios -o ios/Runner/GoogleService-Info.plist --project=$FIREBASE_PROJECT_ID"
echo
print_color "32" "# 3. Set your OpenAI API Key for the backend function"
echo "firebase functions:config:set openai.key=\"$OPENAI_API_KEY\" --project=$FIREBASE_PROJECT_ID"
echo
print_color "32" "# 4. Install all dependencies"
echo "(cd functions && npm install)"
echo "flutter pub get"
echo
print_color "32" "# 5. Deploy your backend rules and functions"
echo "firebase deploy --only firestore:rules --project=$FIREBASE_PROJECT_ID"
echo "firebase deploy --only functions --project=$FIREBASE_PROJECT_ID"
echo
print_color "33" "After running these commands, you have two final manual steps in the Firebase Console:"
echo "1. Go to your project: https://console.firebase.google.com/project/$FIREBASE_PROJECT_ID"
echo "2. Enable Authentication: Go to 'Authentication' > 'Sign-in method' and enable 'Email/Password' and 'Google'."
echo
print_color "32" "Once all steps are complete, you can run the app with 'flutter run'."
echo