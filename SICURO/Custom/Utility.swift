//
//  Utility.swift
//  SICURO
//
//  Created by Satyanarayana on 30/10/23.
//

import UIKit

func showAlert(title: String = "Warning!", message: String, closeBtnText: String = "OK", viewController: UIViewController) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: closeBtnText, style: .default, handler: nil)
    alertController.addAction(okAction)
    
    viewController.present(alertController, animated: true, completion: nil)
}
