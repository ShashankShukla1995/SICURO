//
//  LoginViewController.swift
//  SICURO
//
//  Created by Shashank Shukla on 21/10/23.
//

import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var googleLogin: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        let imageView = UIImageView(image: UIImage(named: "background"))
//        emailTextField.background?.cgImage = CGImage(imageView)
        googleLogin.style = .standard
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkUserInfoAndPresentHome()
    }
    
    
    @IBAction func didTapLogin(_ sender: Any) {
        validateFields()
    }
        
    @IBAction func didTapGoogleSignIn(_ sender: Any) {
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                self.checkUserInfoAndPresentHome()
            }
        }
    }
    
    
    func validateFields() {
        guard let emailText = emailTextField.text, emailText.isValidEmail else {
            showAlert(message: "Email can't be empty or invalid", viewController: self)
            return
        }
        
        guard let pwdText = passwordTextField.text, !pwdText.isEmpty, pwdText.count > 8 else {
            showAlert(message: "Password must be greater than 8 characters", viewController: self)
            return
        }
        
        
        Auth.auth().signIn(withEmail: emailText, password: pwdText) { [weak self] autheResult, error in
            guard let self = self else {
                return
            }
            
            if error != nil {
                showAlert(message: "Username or Password is incorrect", viewController: self)
                return
            }
            
            self.checkUserInfoAndPresentHome()
        }
    }
    
    func checkUserInfoAndPresentHome() {
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: "HomePage", sender: nil)
        }
    }
}
