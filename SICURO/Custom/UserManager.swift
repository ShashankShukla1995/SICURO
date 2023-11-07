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
    var allUsers: [String: [[String : String]]]? =  [String: [[String : String]]]()
    var image: [String : UIImage] = [String : UIImage]()

    
    
    var user: User!
    func addContact(contact:Contact, email: String) {
            
        if let keys = allUsers?.keys {
                if (keys.contains(email)) {
                    var val = allUsers![email] ?? []
                    let new = ["email":contact.email,
                               "name":contact.name]
                    if val.count < 2 {
                        val.append(new)
                        database.child(email).setValue(val)
                    }
                    return
                }
        }
        let object = ["email": contact.email,
                      "name": contact.name]
        database.child(email).setValue([object])
        }
    
    func getContact() {
        database.observeSingleEvent(of: .value) { snapshot in
            
            guard let value = snapshot.value else {
                return
            }
        
            self.allUsers = value as? [String: [[String : String]]]
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
