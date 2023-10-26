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
        googleLogin.style = .standard
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkUserInfoAndPresentHome()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func didTapLogin(_ sender: Any) {
        validateFields()
    }
    @IBAction func didTapSignUp(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "signUp")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
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
        if emailTextField.text?.isEmpty == true {
            return
        }
        if passwordTextField.text?.isEmpty == true {
            return
        }
        login()
    }
    
    func login() {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { [weak self] autheResult, error in
            guard let self = self else {
                return
            }
            if error != nil {
                let alert = UIAlertController(title: "Alert", message: "username or password is incorrect", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.checkUserInfoAndPresentHome()
        }
    }
    
    func checkUserInfoAndPresentHome() {
        if Auth.auth().currentUser != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Home")
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
        }
    }
    
}
