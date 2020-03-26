//
//  ViewController.swift
//  Nutrify
//
//  Created by Alex Benasutti on 2/24/20.
//  Copyright © 2020 Alex Benasutti. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print("This is an example of utilizing ViewController debug.")
    }
    
    @IBAction func exampleFunc(_ sender: Any) {
        // Example function
    }
    
    @IBAction func createAccount()
    {
        let vc = storyboard?.instantiateViewController(identifier: "createAccount") as! CreateAccountViewController
        
        vc.modalPresentationStyle = .fullScreen
        present(vc,animated: true)
    }

}

