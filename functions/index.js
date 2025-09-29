const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();
const db = admin.firestore();

// It's highly recommended to set your OpenAI API key as an environment variable
// in your Cloud Functions configuration for security.
// You can do this by running the following command in your terminal:
// firebase functions:config:set openai.key="YOUR_API_KEY"
const OPENAI_API_KEY = functions.config().openai.key;

exports.adjustPlanOnFeedback = functions.firestore
  .document("feedback/{feedbackId}")
  .onCreate(async (snap, context) => {
    const feedbackData = snap.data();
    const userId = feedbackData.userId;

    if (!userId) {
      functions.logger.error("No userId found in feedback document.");
      return null;
    }

    try {
      // 1. Fetch the user's profile from Firestore.
      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) {
        functions.logger.error("User document not found for userId:", userId);
        return null;
      }
      const userData = userDoc.data();

      // 2. Construct a new prompt for the OpenAI API.
      const prompt = buildAdjustmentPrompt(userData, feedbackData);
      functions.logger.log("Generated prompt for OpenAI:", prompt);

      // 3. Call the OpenAI API to get the adjusted plan.
      const response = await axios.post(
        "https://api.openai.com/v1/chat/completions",
        {
          model: "gpt-4-turbo",
          messages: [
            {
              role: "system",
              content:
                "You are a world-class personal trainer and dietician AI. Your task is to adjust a user's 7-day workout and diet plan based on their latest feedback. Respond ONLY with a valid JSON object with 'workoutPlan' and 'mealPlan' keys.",
            },
            { role: "user", content: prompt },
          ],
          temperature: 0.7,
          response_format: { type: "json_object" },
        },
        {
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${OPENAI_API_KEY}`,
          },
        }
      );

      const newPlan = response.data.choices[0].message.content;
      const parsedPlan = JSON.parse(newPlan);
      functions.logger.log("Received adjusted plan from OpenAI.");

      // 4. Update the user's plans in Firestore.
      // We need to find the existing plan documents to update them.
      const workoutPlanQuery = await db
        .collection("workoutPlans")
        .where("userId", "==", userId)
        .limit(1)
        .get();

      const mealPlanQuery = await db
        .collection("mealPlans")
        .where("userId", "==", userId)
        .limit(1)
        .get();

      if (!workoutPlanQuery.empty) {
        const workoutPlanDocId = workoutPlanQuery.docs[0].id;
        await db.collection("workoutPlans").doc(workoutPlanDocId).update({
            'dailyWorkouts': parsedPlan.workoutPlan.dailyWorkouts
        });
        functions.logger.log(`Updated workout plan for user ${userId}`);
      } else {
         functions.logger.warn(`No existing workout plan found for user ${userId} to update.`);
      }

      if (!mealPlanQuery.empty) {
        const mealPlanDocId = mealPlanQuery.docs[0].id;
        await db.collection("mealPlans").doc(mealPlanDocId).update({
            'dailyMeals': parsedPlan.mealPlan.dailyMeals
        });
         functions.logger.log(`Updated meal plan for user ${userId}`);
      } else {
         functions.logger.warn(`No existing meal plan found for user ${userId} to update.`);
      }

      return { status: "success", message: "Plans updated successfully." };
    } catch (error) {
      functions.logger.error("Error adjusting plan:", error);
      if (error.response) {
        functions.logger.error("Error response data:", error.response.data);
      }
      return { status: "error", message: "Failed to adjust plans." };
    }
  });

function buildAdjustmentPrompt(userData, feedbackData) {
  return `
    Please adjust the 7-day workout and diet plan for the following user based on their recent feedback.

    **User Profile:**
    - Age: ${userData.age}
    - Gender: ${userData.gender}
    - Height: ${userData.height} cm
    - Weight: ${userData.weight} kg
    - Goal: ${userData.fitnessGoal}
    - Activity Level: ${userData.activityLevel}

    **User's Feedback from the Past Week:**
    - Energy Level (1-5): ${feedbackData.energyLevel}
    - Hunger Level (1-5): ${feedbackData.hungerLevel}
    - Sleep Quality (1-5): ${feedbackData.sleepQuality}
    - Adherence to Plan: ${feedbackData.adherenceRate}%
    - Comments: "${feedbackData.comments}"

    **Adjustment Instructions:**
    - If energy was low and hunger was high, consider slightly increasing calories or reducing workout intensity.
    - If energy was high and the user adhered well, consider a slight progression in workout difficulty.
    - If the user had specific comments (e.g., "I hated squats"), replace that exercise with a suitable alternative.
    - Generate a new, complete 7-day plan based on these adjustments.

    **JSON Structure Requirements:**
    The JSON response must contain two top-level keys: "workoutPlan" and "mealPlan".
    1.  **workoutPlan**:
        - Should contain a list of "dailyWorkouts".
        - Each "dailyWorkouts" object must have: "day" (String) and "exercises" (List of exercise objects).
        - Each exercise object must have: "name", "sets", "reps", and "rest" (all Strings).
    2.  **mealPlan**:
        - Should contain a list of "dailyMeals".
        - Each "dailyMeals" object must have: "day" (String), "totalCalories" (Integer), and "meals" (List of meal objects).
        - Each meal object must have: "name", "time", "ingredients" (all Strings), and "calories" (Integer).
    `;
}