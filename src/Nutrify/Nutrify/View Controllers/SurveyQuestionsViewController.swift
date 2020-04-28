//
//  SurveyQuestionsViewController.swift
//  Nutrify
//  Description: Display survey and account creation inputs for user, once done, create user account
//
//  Created by Alex Benasutti on 3/26/20.
//  Last Modified: 4/27/20
//  Copyright © 2020 Alex Benasutti. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

// SurveyQuestionsViewController: View controller for all user identification survey questionnaire questions and functionality. Will redirect to homepage after completion.
class SurveyQuestionsViewController: UIViewController {
    
    @IBOutlet weak var genderField: UITextField!            // gender text field
    @IBOutlet weak var dateOfBirthField: UIDatePicker!      // DOB text field
    @IBOutlet weak var heightField: UITextField!            // height text field
    @IBOutlet weak var weightField: UITextField!            // weight text field
    @IBOutlet weak var goalWeightOverallField: UITextField! // goal weight text field
    @IBOutlet weak var goalWeightWeeklyField: UITextField!  // goal weekly weight text field
    @IBOutlet weak var textView: UITextView!                // results text view
    @IBOutlet weak var textFieldEmail: UITextField!         // email/username
    @IBOutlet weak var textFieldPassword: UITextField!      // password
    
    var db: Firestore!                                      // Firestore database
        
    // viewDidLoad: Active when survey questions page loads for the first time
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign all text fields as delegates
        genderField.delegate = self
        heightField.delegate = self
        weightField.delegate = self
        goalWeightOverallField.delegate = self
        goalWeightWeeklyField.delegate = self
        
    }
    
    // validateFields: Check the fields and vlaidate that the data is correct. If everything is correct, this method returns nil. Otherwise, it returns the error message
    func validateFields() -> String? {
        
        // Check all fields are filled in
        if genderField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            heightField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            weightField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            goalWeightOverallField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            goalWeightWeeklyField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            textFieldEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            textFieldPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all fields."
        }
        
        // Check if the password is secure
        let cleanPass = textFieldPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isPasswordValid(cleanPass) == false {
            // Password isn't secure enough
            return "Please make sure password is at least 8 characters, contains a special character, and a number"
        }
        
        return nil
    }

    // enterAnswers: Button that is called from a touch event. Activated by "Done" button on survey. Sends results to textView and navigates user to home page
    @IBAction func enterAnswers(_ sender: Any)
    {
        let error = validateFields()
        
        if error != nil {
            // Error occurrance in fields, show error message
            showError(error!)
        } else {
            // Sign up new user
            // User created successflly, store first and last name
            let email = self.textFieldEmail.text!
            let password = self.textFieldPassword.text!
            // Set up variables from each text field
            let gender = self.genderField.text!
            let height = self.heightField.text!
            let weight = self.weightField.text!
            let goalWeightOverall = self.goalWeightOverallField.text!
            let goalWeightWeekly = self.goalWeightWeeklyField.text!
            
            db = Firestore.firestore() // Initialize Firebase database
            
            // Create Firebase authentication call to create user account
            Auth.auth().createUser(withEmail: email, password : password) { authResult, error in
                if error != nil {
                    // error creating account
                    self.showError("Error creating user")
                } else {
                    // begin creating user account
                    
                    // Calculate goal calories and macronutrients
                    // Calories
                    let bodyFatPercentage = 15.0
                    var tdee = 9.8
                    tdee *= Double(weight)! * ((100.0 - bodyFatPercentage) / 100.0)
                    tdee += 370.0
                    tdee *= 1.5
                    let dailySurplus = ((Double(goalWeightWeekly)! * 3500) / 7)
                    let goalDailyCalories = (tdee + dailySurplus)
                    let goalDailyProtein: Double
                    let goalDailyFat: Double
                    let goalDailyCarbs: Double
                    
                    // Proteins
                    let proteinMult: Double
                    if bodyFatPercentage < 20 {
                        proteinMult = 1
                    } else if bodyFatPercentage <= 25 {
                        proteinMult = 0.8
                    } else {
                        proteinMult = 0.73
                    }
                    goalDailyProtein = (Double(weight)! * proteinMult);
                    
                    // Fats
                    goalDailyFat = (0.25 * goalDailyCalories) / 9.0
                    
                    // Carbs
                    goalDailyCarbs = (goalDailyCalories - (goalDailyProtein * 4.0) - (goalDailyFat * 9.0)) / 4.0
                    
                    // Create new user with survey data
                    var newUserRef: DocumentReference? = nil
                    newUserRef = self.db.collection("users").document()
                    newUserRef?.setData([
                    "uid": authResult!.user.uid,
                    "gender": gender,
                    "height": height,
                    "weight": weight,
                    "goalWeightOverall": goalWeightOverall,
                    "goalWeightWeekly": goalWeightWeekly,
                    "totalCalories": Int(goalDailyCalories),
                    "currentCalories": 0,
                    "totalCarbs": Int(goalDailyCarbs),
                    "currentCarbs": 0,
                    "totalFat": Int(goalDailyFat),
                    "currentFat": 0,
                    "totalProtein": Int(goalDailyProtein),
                    "currentProtein": 0
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID: \(newUserRef!.documentID)")
                            // Account created, navigate user to home page
                            self.navigateToHome()
                        }
                    }
                }
            }
        }
    }
    
    // showError: helper procedure to display an error message
    private func showError(_ message: String)
    {
        debugPrint(message)
    }
    
    // navigateToHome: navigate user to home page view controller
    private func navigateToHome()
    {
        let vc = storyboard?.instantiateViewController(identifier: "home") as! HomeViewController
        
        // present(vc, animated: true)
        view.window?.rootViewController = vc
        view.window?.makeKeyAndVisible()
    }
    
    // touchesBegan: Check for touches when certain input text fields (i.e. number pads) are open. Close when user touches outside of text field
    // inputs
    //   touches: Set of UITouch instances to represent the touches for the starting phase of an event
    //   event: The event to which the touches belong
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        heightField.resignFirstResponder()
        weightField.resignFirstResponder()
        goalWeightWeeklyField.resignFirstResponder()
        goalWeightOverallField.resignFirstResponder()
    }
}

extension SurveyQuestionsViewController : UITextFieldDelegate
{
    // textFieldShouldReturn: asks a delegate if the text field should process the pressing of the return button. Relinquish the status of first responder to the text field
    // input
    //   textField: the text field whose return button was pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
