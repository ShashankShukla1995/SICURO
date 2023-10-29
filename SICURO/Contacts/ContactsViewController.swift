//
//  ContactsViewController.swift
//  SICURO
//
//  Created by Shashank Shukla on 27/10/23.
//

import UIKit
import FirebaseDatabase
import CoreMedia

class ContactsViewController: UIViewController {

    @IBOutlet weak var contact1Details: UILabel!
    @IBOutlet weak var contactDetailsLabelheight: NSLayoutConstraint!
    @IBOutlet weak var contact1Email: UITextField!
    @IBOutlet weak var cintact1Name: UITextField!
    @IBOutlet weak var addContact1Button: UIButton!
    @IBOutlet weak var editContact1Button: UIButton!
    
    @IBOutlet weak var contact2Details: UILabel!
    @IBOutlet weak var contact2detailsLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var contact2Name: UITextField!
    @IBOutlet weak var contact2Email: UITextField!
    @IBOutlet weak var addContact2Button: UIButton!
    @IBOutlet weak var editContact2Button: UIButton!
    
    private let database = Database.database().reference()
    override func viewDidLoad() {
        super.viewDidLoad()
        contact1Details.numberOfLines = 0
        contact2Details.numberOfLines = 0
        checkIfContactIsPresent(contact: "contact1")
        checkIfContactIsPresent(contact: "contact2")
        // Do any additional setup after loading the view.
    }

    @IBAction func didTapBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func contact1AddContact(_ sender: Any) {
        if isValidEmailAddress(emailAddress: contact1Email.text!) {
            let object:[String: String] = [
                "name":cintact1Name.text!,
                "email": contact1Email.text!]
            database.child("contact1").setValue(object)
            let labelText = "name - " + cintact1Name.text! + "\n" + "email - " + contact1Email.text!
            setupDetailsView(contact: "contact1", labelText: labelText)
        } else {
            let alert = UIAlertController(title: "Alert", message: "incorrect email address", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func contact2AddContact(_ sender: Any) {
        if isValidEmailAddress(emailAddress: contact2Email.text!) {
            let object:[String: String] = [
                "name":contact2Name.text!,
                "email": contact2Email.text!]
            database.child("contact2").setValue(object)
            let labelText = "name - " + contact2Email.text! + "\n" + "email - " + contact2Email.text!
            setupDetailsView(contact: "contact2", labelText: labelText)
        } else {
            let alert = UIAlertController(title: "Alert", message: "incorrect email address", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func editContact1(_ sender: Any) {
        setupAddContactView(contact: "contact1")
    }
    
    
    @IBAction func editContact2(_ sender: Any) {
        setupAddContactView(contact: "contact2")
    }
    
    func checkIfContactIsPresent(contact: String) {
        database.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any], let contactDetails = value[contact] as? [String: Any] else {
                self.setupAddContactView(contact: contact)
                return
            }
            let name: String = contactDetails["name"] as! String
            let email: String = contactDetails["email"] as! String
            let labelText = "name - " + name + "\n" + "email - " + email
            self.setupDetailsView(contact: contact, labelText: labelText)
        }
    }
    
    func setupAddContactView(contact: String) {
        if contact == "contact1" {
            contactDetailsLabelheight.constant = 0
            contact1Email.isHidden = false
            cintact1Name.isHidden = false
            addContact1Button.isHidden = false
            editContact1Button.isHidden = true
            contact1Details.isHidden = true
            
        } else if contact == "contact2" {
            contact2detailsLabelHeight.constant = 0
            contact2Email.isHidden = false
            contact2Name.isHidden = false
            addContact2Button.isHidden = false
            editContact2Button.isHidden = true
            contact2Details.isHidden = true

        }
    }
    
    func setupDetailsView(contact: String, labelText: String) {
        if contact == "contact1" {
            contactDetailsLabelheight.constant = 100
            contact1Email.isHidden = true
            cintact1Name.isHidden = true
            addContact1Button.isHidden = true
            editContact1Button.isHidden = false
            contact1Details.isHidden = false
            contact1Details.text = labelText
            
        } else if contact == "contact2" {
            contact2detailsLabelHeight.constant = 100
            contact2Email.isHidden = true
            contact2Name.isHidden = true
            addContact2Button.isHidden = true
            editContact2Button.isHidden = false
            contact2Details.isHidden = false
            contact2Details.text = labelText

        }
    }
    
    func isValidEmailAddress(emailAddress: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: emailAddress)
    }
}
