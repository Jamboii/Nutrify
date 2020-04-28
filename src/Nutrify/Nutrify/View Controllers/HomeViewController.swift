//
//  HomeViewController.swift
//  Nutrify
//  Description: Central hub for Nutrify. User can search for foods to add to their daily intake, or update their daily weight
//
//  Created by Alex Benasutti on 3/26/20.
//  Last Modified: 4/27/20
//  Copyright © 2020 Alex Benasutti. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

// HomeViewController: View Controller for Nutrify home screen. Central hub for all main functionality of the application
class HomeViewController: UIViewController {
    
    @IBOutlet weak var textViewCalories: UITextView!    // Calories text view
    @IBOutlet weak var textViewProtein: UITextView!     // Protein text view
    @IBOutlet weak var textViewFat: UITextView!         // Fats text view
    @IBOutlet weak var textViewCarbs: UITextView!       // Carbohydrates text view
    @IBOutlet weak var textViewFood: UITextView!        // Most recent food specifications text view
    @IBOutlet weak var textFieldFood: UITextField!      // Food search text field
    
    private let networkingClient = NetworkingClient()   // NutritionixAPI client, talks to Nutritionix database
    
    var db: Firestore!                                  // Firestore database
    
    var ref: DocumentReference? = nil                   // Reference within Firestore
    
    // viewDidLoad: Active when Home loads for the first time
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Load Firestore settings
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        
        // Initialize database
        db = Firestore.firestore()
        
        // Get user id and find the user currently logged in
        let user = Auth.auth().currentUser
        let uid = user?.uid
        
        // Search for matching uid
        db.collection("users").whereField("uid", isEqualTo: uid!)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    // Matching uid NOT found
                    debugPrint("Error getting documents: \(err)")
                } else {
                    // matching uid found
                    for document in querySnapshot!.documents {
                        debugPrint("\(document.documentID) => \(document.data())")
                        // Set ref to document belonging to uid
                        self.ref = self.db.collection("users").document(document.documentID)
                        // Update homepage calorie and macro data with user document
                        self.updateData()
                    }
                }
        }
    }
    
    // buttonAddFood: Button that responds to touch events. Talks to Nutritionix database in attempt to add the food in the
    // text field to the user's daily food intake
    @IBAction func buttonAddFood(_ sender: Any) {
        
        // Set food from text field
        let food = textFieldFood.text!
        
        // Networking client talks to Nutritionix database, checks for common food
        networkingClient.fetchFoodData(foodName: food) { (json, error) in
            if let error = error {
                // Food was not found, throw error
                // TODO: make a proper error message
                self.textViewFood.text = error.localizedDescription
            } else if let json = json {
                // Food was found, add to user meal data
                let meals = json
                // Grab nutrient information
                for meal in meals {
                    let name = (meal.name).capitalized
                    let calories = meal.calories
                    let carbs = meal.carbs
                    let fat = meal.fat
                    let protein = meal.protein
                    let viewMessage = "\(name)\n\(calories) calories\nCarbs: \(carbs)g\nFat: \(fat)g\nProtein: \(protein)g\n"
                    // Display nutrient info in text field
                    self.textViewFood.text = viewMessage
                    // Add meal to user's intake
                    self.addMealData(user: self.ref, meal: meal)
                }
            }
        }
    }
    
    // logoutUser: Button that repsonds to touch events. Will logout user, putting them back at the startup screen
    @IBAction func logoutUser(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            // Attempt signout
            try firebaseAuth.signOut()
            // Navigate to login screen
            self.navigateToLogin()
        } catch let signOutError as NSError {
            // Error in signing out
            debugPrint("Error signing out: %@", signOutError)
        }
    }
    
    // addMealData: add meal/food from Nutritionix to user diary
    // user - reference to user document in Firebase database
    // meal - meal fetched from Nutritionix to be stored
    private func addMealData(user: DocumentReference?, meal: Meal)
    {
        // Set nutrient variables
        let mealCalories = meal.calories
        let mealCarbs = meal.carbs
        let mealFat = meal.fat
        let mealProtein = meal.protein
        
        // Add new document to user's meals collection
        user!.collection("meals").addDocument(data: [
            "name": meal.name,
            "calories": mealCalories,
            "carbs": mealCarbs,
            "fat": mealFat,
            "protein": mealProtein
        ])
        
        // Update daily nutrition info for the user
        user!.getDocument { (document, error) in
            if let document = document, document.exists {
                // Get current and total macros/calories
                let userCalories = document.get("currentCalories") as? Int
                let totalCalories = document.get("totalCalories").map(String.init(describing:)) ?? "nil"
                let userCarbs = document.get("currentCarbs") as? Int
                let totalCarbs = document.get("totalCarbs").map(String.init(describing:)) ?? "nil"
                let userFat = document.get("currentFat") as? Int
                let totalFat = document.get("totalFat").map(String.init(describing:)) ?? "nil"
                let userProtein = document.get("currentProtein")as? Int
                let totalProtein = document.get("totalProtein").map(String.init(describing:)) ?? "nil"
                
                // Update daily calories/macros
                let dailyCalories = userCalories! + mealCalories.intValue
                let dailyCarbs = userCarbs! + mealCarbs.intValue
                let dailyFat = userFat! + mealFat.intValue
                let dailyProtein = userProtein! + mealProtein.intValue

                // Set new strings to display on home page
                let calorieString = "\(dailyCalories)/\(totalCalories)"
                let carbsString = "\(dailyCarbs)g/\(totalCarbs)g"
                let fatString = "\(dailyFat)g/\(totalFat)g"
                let proteinString = "\(dailyProtein)g/\(totalProtein)g"

                // Update calories/macros on homepage for user
                self.textViewCalories.text = calorieString
                self.textViewCarbs.text = carbsString
                self.textViewFat.text = fatString
                self.textViewProtein.text = proteinString
                
                // Update user's document data
                self.ref!.setData([
                    "currentCalories": dailyCalories,
                    "currentCarbs": dailyCarbs,
                    "currentFat": dailyFat,
                    "currentProtein": dailyProtein
                ], merge: true)

                debugPrint("Document data: \(String(describing: userCalories))")
            } else {
                debugPrint("Document does not exist")
            }
        }
    }
    
    // updateData: procedure that is called every time the home page is loaded: updates with most recent nutrient data for user
    private func updateData()
    {
        // Update daily nutrition info for the user
        ref!.getDocument { (document, error) in
            if let document = document, document.exists {
                // Get current and total macros/calories
                let userCalories = document.get("currentCalories").map(String.init(describing:)) ?? "nil"
                let totalCalories = document.get("totalCalories").map(String.init(describing:)) ?? "nil"
                let userCarbs = document.get("currentCarbs").map(String.init(describing:)) ?? "nil"
                let totalCarbs = document.get("totalCarbs").map(String.init(describing:)) ?? "nil"
                let userFat = document.get("currentFat").map(String.init(describing:)) ?? "nil"
                let totalFat = document.get("totalFat").map(String.init(describing:)) ?? "nil"
                let userProtein = document.get("currentProtein").map(String.init(describing:)) ?? "nil"
                let totalProtein = document.get("totalProtein").map(String.init(describing:)) ?? "nil"
                
                // Update daily calories/macros
                let calorieString = "\(userCalories)/\(totalCalories)"
                let carbsString = "\(userCarbs)g/\(totalCarbs)g"
                let fatString = "\(userFat)g/\(totalFat)g"
                let proteinString = "\(userProtein)g/\(totalProtein)g"

                // Update calories/macros on homepage for user
                self.textViewCalories.text = calorieString
                self.textViewCarbs.text = carbsString
                self.textViewFat.text = fatString
                self.textViewProtein.text = proteinString
                
                debugPrint("Document data: \(String(describing: userCalories))")
            } else {
                debugPrint("Document does not exist")
            }
        }
    }
    
    // navigateToLogin: procedure to take user back to startup screen of Nutrify
    private func navigateToLogin() {
        let vc = storyboard?.instantiateViewController(identifier: "startup") as! ViewController
        
        view.window?.rootViewController = vc
        view.window?.makeKeyAndVisible()
    }
    
}
