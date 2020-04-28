//
//  Utilities.swift
//  Nutrify
//  Description: Various utilities for Nutrify
//
//  Created by Alex Benasutti on 4/27/20.
//  Last Modified: 4/27/20
//  Copyright © 2020 Alex Benasutti. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    // isPasswordValid: Determine if password is at least 8 characters, contains 1 number, 1 special character
    // password: Password to be validated
    // returns - true/false: validation of password based on regex
    static func isPasswordValid(_ password: String) -> Bool {
        // passTest is a regex that evaluates a string for 8 characters, 1 number and 1 special character
        let passTest = NSPredicate(format: "SELF MATCHES %@",
                                   "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        // Return whether the password was validated
        return passTest.evaluate(with: password)
    }
}
