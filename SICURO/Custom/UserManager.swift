//
//  UserManager.swift
//  SICURO
//
//  Created by Shashank Shukla on 01/11/23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class UserManager: NSObject {
    static let shared = UserManager()
    private let database = Database.database().reference()
    
    var user: User!
    func addContact(contact:Contact, email: String) {
        let object:Contact = Contact(email: contact.email, name: contact.name)
        database.child(email).setValue(object)
    }
    
    func getContact(email: String, completion: ([Contact]) -> Void) {
        database.observeSingleEvent(of: .value) { snapshot in
//            guard let value = snapshot.value(forKey: email) else {
//                return
//            }
//            let contacts = snapshot.value(forKey: email)
        }
    }
    
    func getCharactersBeforeAt() -> String {
        // Find the index of the @ symbol.
        guard let email = Auth.auth().currentUser?.email else {
            return ""
        }
        let atIndex = email.firstIndex(of: "@")

        // Return the characters before the @ symbol, or the entire email address if the @ symbol is not found.
        return atIndex != nil ? String(email[..<atIndex!]) : email
    }
}
