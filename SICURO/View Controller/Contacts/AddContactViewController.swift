//
//  AddContactViewController.swift
//  SICURO
//
//  Created by Shashank Shukla on 01/11/23.
//

import UIKit

class AddContactViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func didTapAddContact(_ sender: Any) {
        if let name = nameTextField.text, let email = emailTextField.text, email.isValidEmail {
            UserManager.shared.addContact(contact: Contact(email: email, name: name), email: UserManager.shared.getCharactersBeforeAt())
        }
    }
}
