//
//  LoginViewController.swift
//  Nutrify
//  Description: Handle logins for Nutrify. Move to home screen if user has correct email and password credentials
//
//  Created by Alex Benasutti on 3/26/20.
//  Last modified: 4/27/20
//  Copyright © 2020 Alex Benasutti. All rights reserved.
//

import UIKit
import FirebaseAuth

// LoginViewController: View controller for all login screen functionality
class LoginViewController: UIViewController {

    @IBOutlet weak var textFieldEmail: UITextField!     // email text field
    
    @IBOutlet weak var textFieldPassword: UITextField!  // password text field
    
    // viewDidLoad: Active when Login screen loads for the first time
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    // loginUser: Button that responds to touch events. Attempt authenticating credentials from Firebase database
    @IBAction func loginUser(_ sender: Any) {
        // Set variables for email and password
        let email = textFieldEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = textFieldPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if error != nil {
                // Couldn't sign in
                self.showError(error!.localizedDescription)
            } else {
                // Sign in successful, navigate to home page
                self.navigateToHome()
            }
        }
    }
    
    // navigateToHome: navigate user to home page view controller
    private func navigateToHome()
    {
        let vc = storyboard?.instantiateViewController(identifier: "home") as! HomeViewController
        
        // present(vc, animated: true)
        view.window?.rootViewController = vc
        view.window?.makeKeyAndVisible()
    }
    
    // showError: Helper function to display errors within the debug screen
    private func showError(_ message: String)
    {
        debugPrint(message)
    }
}
