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
    
    @IBOutlet weak var genderField: UITextField!
    @IBOutlet weak var dateOfBirthField: UIDatePicker!
    @IBOutlet weak var heightField: UITextField!
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var goalWeightOverallField: UITextField!
    @IBOutlet weak var goalWeightWeeklyField: UITextField!
    @IBOutlet weak var textView: UITextView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        genderField.delegate = self
        heightField.delegate = self
        weightField.delegate = self
        goalWeightOverallField.delegate = self
        goalWeightWeeklyField.delegate = self
    }

    @IBAction func enterAnswers(_ sender: Any)
    {
        textView.text = "Gender: \(genderField.text!)\nHeight: \(heightField.text!) in\nWeight: \(weightField.text!)\nGoal: \(goalWeightOverallField.text!)\nWeekly: \(goalWeightWeeklyField.text!)"
        
        navigateToHome()
    }
    
    private func navigateToHome()
    {
        let vc = storyboard?.instantiateViewController(identifier: "home") as! HomeViewController
        
        present(vc, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        heightField.resignFirstResponder()
        weightField.resignFirstResponder()
        goalWeightWeeklyField.resignFirstResponder()
        goalWeightOverallField.resignFirstResponder()
    }
}

extension SurveyQuestionsViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
