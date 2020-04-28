//
//  ViewController.swift
//  Nutrify
//  Description: Initial startup screen for Nutrify. User can choose to either sign up for an account or log into the app.
//
//  Created by Alex Benasutti on 2/24/20.
//  Last Modified: 4/27/20
//  Copyright © 2020 Alex Benasutti. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // GENERATED: Executes on view controller load
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // login: Button that responds to touch events, sends user to login screen
    @IBAction func login(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "login") as! LoginViewController
        
        present(vc, animated: true)
    }
    
    // createAccount: Button that responds to touch events, sends user to create account screen
    @IBAction func createAccount()
    {
        navigateToSurvey()
    }
    
    // navigateToSurvey: Procedure taht changes the view controller to the account creation survey
    private func navigateToSurvey()
    {
        let vc = storyboard?.instantiateViewController(identifier: "survey") as! SurveyNavigationController
        
        present(vc, animated: true)
    }

}

