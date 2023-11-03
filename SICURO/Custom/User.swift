//
//  User.swift
//  SICURO
//
//  Created by Shashank Shukla on 01/11/23.
//

import Foundation
struct User: Codable {
    let uid: String
    let contact: [Contact]
}

// MARK: - Contact
struct Contact: Codable {
    let email, name: String
}
