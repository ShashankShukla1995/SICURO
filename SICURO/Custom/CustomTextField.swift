//
//  CustomTextField.swift
//  SICURO
//
//  Created by Satyanarayana on 30/10/23.
//

import UIKit

class CustomTextField: UITextField {

    // Custom properties and methods
    var leftPadding: CGFloat = 10

    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialize your custom text field
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Initialize your custom text field
        setup()
    }

    func setup() {
        frame.size.height = 34.0
        borderStyle = .none
        backgroundColor = .white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        // Layout your custom text field

        // Set the left padding
        self.leftViewMode = .always
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: leftPadding, height: self.frame.size.height))
        self.leftView = paddingView
    }
}
