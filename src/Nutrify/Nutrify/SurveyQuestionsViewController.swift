//
//  SurveyQuestionsViewController.swift
//  Nutrify
//
//  Created by Alex Benasutti on 3/26/20.
//  Copyright © 2020 Alex Benasutti. All rights reserved.
//

import UIKit

// SurveyQuestionsViewController: View controller for all user identification survey questionnaire questions and functionality. Will redirect to homepage after completion.
class SurveyQuestionsViewController: UIViewController {
    
    @IBOutlet weak var genderField: UITextField!            // gender text field
    @IBOutlet weak var dateOfBirthField: UIDatePicker!      // DOB text field
    @IBOutlet weak var heightField: UITextField!            // height text field
    @IBOutlet weak var weightField: UITextField!            // weight text field
    @IBOutlet weak var goalWeightOverallField: UITextField! // goal weight text field
    @IBOutlet weak var goalWeightWeeklyField: UITextField!  // goal weekly weight text field
    @IBOutlet weak var textView: UITextView!                // results text view
        
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

    // enterAnswers: Activated by "Done" button on survey. Sends results to textView and navigates user to home page
    // input: Button sender
    @IBAction func enterAnswers(_ sender: Any)
    {
        textView.text = "Gender: \(genderField.text!)\nHeight: \(heightField.text!) in\nWeight: \(weightField.text!)\nGoal: \(goalWeightOverallField.text!)\nWeekly: \(goalWeightWeeklyField.text!)"
        
        navigateToHome()
    }
    
    // navigateToHome: navigate user to home page view controller
    private func navigateToHome()
    {
        let vc = storyboard?.instantiateViewController(identifier: "home") as! HomeViewController
        
        present(vc, animated: true)
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
