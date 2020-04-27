//
//  HomeViewController.swift
//  Nutrify
//
//  Created by Alex Benasutti on 3/26/20.
//  Copyright © 2020 Alex Benasutti. All rights reserved.
//

import UIKit
import Alamofire
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

// HomeViewController: View Controller for Nutrify home screen. Central hub for all main functionality of the application
class HomeViewController: UIViewController {
    
    
    @IBOutlet weak var textViewCalories: UITextView!
    
    @IBOutlet weak var textViewProtein: UITextView!
    
    @IBOutlet weak var textViewFat: UITextView!
    
    @IBOutlet weak var textViewCarbs: UITextView!
    
    @IBOutlet weak var textViewFood: UITextView!
    
    @IBOutlet weak var textFieldFood: UITextField!
    
    private let networkingClient = NetworkingClient()
    
    var db: Firestore!
    
    var ref: DocumentReference? = nil
    
    // viewDidLoad: Active when Home loads for the first time
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        
        db = Firestore.firestore()
        
        ref = self.db.collection("users").document()
                
        ref!.setData([
//        "gender": gender,
//        "height": height,
//        "weight": weight,
//        "goalWeightOverall": goalWeightOverall,
//        "goalWeightWeekly": goalWeightWeekly,
        "totalCalories": 2000,
        "currentCalories": 0,
        "totalCarbs": 100,
        "currentCarbs": 0,
        "totalFat": 100,
        "currentFat": 0,
        "totalProtein": 100,
        "currentProtein": 0
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(self.ref!.documentID)")
            }
        }
    }
    
    @IBAction func buttonAddFood(_ sender: Any) {
        
        let food = textFieldFood.text!
        
        networkingClient.fetchFoodData(foodName: food) { (json, error) in
            if let error = error {
                self.textViewFood.text = error.localizedDescription
            } else if let json = json {
                // self.textView.text = json.description
                let meals = json
                for meal in meals {
                    let name = (meal.name).capitalized
                    let calories = meal.calories
                    let carbs = meal.carbs
                    let fat = meal.fat
                    let protein = meal.protein
                    let viewMessage = "\(name)\n\(calories) calories\nCarbs: \(carbs)g\nFat: \(fat)g\nProtein: \(protein)g\n"
                    self.textViewFood.text = viewMessage
                    
                    //
//                    let ref = self.addAdaLovelace()
//                    debugPrint(ref!)
//                    self.addAlanMathison()
                    
                    
                    /*
                    newPersonRef.setData(["first": "Alex", "last": "Benasutti", "totalCalories": 2000, "currentCalories": 0], merge: true)
                    */
                    
                    /*
                    newPersonRef.collection("meals").addDocument(data: [
                        "name": name,
                        "calories": calories
                    ])
                    */
                    
                    self.addMealData(user: self.ref, meal: meal)
                }
            }
        }
    }
    
    private func addMealData(user: DocumentReference?, meal: Meal)
    {
        let mealCalories = meal.calories
        let mealCarbs = meal.carbs
        let mealFat = meal.fat
        let mealProtein = meal.protein
        
        // db.collection("users").document("Ada")
        user!.collection("meals").addDocument(data: [
            "name": meal.name,
            "calories": mealCalories,
            "carbs": mealCarbs,
            "fat": mealFat,
            "protein": mealProtein
        ])
        
        user!.getDocument { (document, error) in
            if let document = document, document.exists {
                let userCalories = document.get("currentCalories") as? Int
                let totalCalories = document.get("totalCalories").map(String.init(describing:)) ?? "nil"
                let userCarbs = document.get("currentCarbs") as? Int
                let totalCarbs = document.get("totalCarbs").map(String.init(describing:)) ?? "nil"
                let userFat = document.get("currentFat") as? Int
                let totalFat = document.get("totalFat").map(String.init(describing:)) ?? "nil"
                let userProtein = document.get("currentProtein")as? Int
                let totalProtein = document.get("totalProtein").map(String.init(describing:)) ?? "nil"
                
                let dailyCalories = userCalories! + mealCalories.intValue
                let dailyCarbs = userCarbs! + mealCarbs.intValue
                let dailyFat = userFat! + mealFat.intValue
                let dailyProtein = userProtein! + mealProtein.intValue

                let calorieString = "\(dailyCalories)/\(totalCalories)"
                let carbsString = "\(dailyCarbs)g/\(totalCarbs)g"
                let fatString = "\(dailyFat)g/\(totalFat)g"
                let proteinString = "\(dailyProtein)g/\(totalProtein)g"

                self.textViewCalories.text = calorieString
                self.textViewCarbs.text = carbsString
                self.textViewFat.text = fatString
                self.textViewProtein.text = proteinString
                
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
        
        
        // user.setData("")
    }
    
//    @IBAction func refreshButton(_ sender: Any) {
//
//        let user = db.collection("users").document()
//
//        user.getDocument { (document, error) in
//            if let document = document, document.exists {
//                let userCalories = document.get("currentCalories").map(String.init(describing:)) ?? "nil"
//                let totalCalories = document.get("totalCalories").map(String.init(describing:)) ?? "nil"
//                let userCarbs = document.get("currentCarbs").map(String.init(describing:)) ?? "nil"
//                let totalCarbs = document.get("totalCarbs").map(String.init(describing:)) ?? "nil"
//                let userFat = document.get("currentFat").map(String.init(describing:)) ?? "nil"
//                let totalFat = document.get("totalFat").map(String.init(describing:)) ?? "nil"
//                let userProtein = document.get("currentProtein").map(String.init(describing:)) ?? "nil"
//                let totalProtein = document.get("totalProtein").map(String.init(describing:)) ?? "nil"
//
//                let calorieString = "\(userCalories)/\(totalCalories)"
//                let carbsString = "\(userCarbs)g/\(totalCarbs)g"
//                let fatString = "\(userFat)g/\(totalFat)g"
//                let proteinString = "\(userProtein)g/\(totalProtein)g"
//
//                self.textViewCalories.text = calorieString
//                self.textViewCarbs.text = carbsString
//                self.textViewFat.text = fatString
//                self.textViewProtein.text = proteinString
//
//                debugPrint("Document data: \(userCalories)")
//            } else {
//                debugPrint("Document does not exist")
//            }
//        }
//    }
    
}
