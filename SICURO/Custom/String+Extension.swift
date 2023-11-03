//
//  String+Extension.swift
//  SICURO
//
//  Created by Satyanarayana on 30/10/23.
//

import Foundation

extension String {
    var isValidEmail: Bool {
        if self.isEmpty {
            return false
        }
        
        let regex = "^[a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9-]+(?:\\.[a-zA-Z0-9-]+)*$"
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
}
