//
//  SignUpViewController.swift
//  SICURO
//
//  Created by Shashank Shukla on 21/10/23.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTexztField: UITextField!

    @IBAction func didTapSignUp(_ sender: Any) {
        guard let emailText = emailTextField.text, emailText.isValidEmail else {
            showAlert(message: "Email can't be empty or invalid", viewController: self)
            return
        }
        
        guard let pwdText = passwordTexztField.text, !pwdText.isEmpty, pwdText.count > 8 else {
            showAlert(message: "Password must be greater than 8 characters", viewController: self)
            return
        }
                
        Auth.auth().createUser(withEmail: emailText, password: pwdText) { authResult, error in
            guard let _ = authResult?.user, error == nil else {
                showAlert(message: "Failed to create User, try again.", viewController: self)
                return
            }
            
            self.performSegue(withIdentifier: "HomePage", sender: nil)
        }
    }
    
    @IBAction func didTapAlreadyHaveLogin(_ sender: Any) {
        guard let navController = navigationController else {
            return
        }
        
        navController.popViewController(animated: true)
    }
}
