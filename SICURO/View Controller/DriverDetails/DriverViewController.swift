//
//  DriverViewController.swift
//  SICURO
//
//  Created by Shashank Shukla on 07/11/23.
//

import UIKit

class DriverViewController: UIViewController {

    @IBOutlet weak var driversPhoto: UIImageView!
    @IBOutlet weak var numberPlate: UIImageView!
    @IBOutlet weak var driversPhotoButton: UIButton!
    @IBOutlet weak var numberPlateButton: UIButton!
    var isNumberPlateTapped = false
    override func viewDidLoad() {
        super.viewDidLoad()
        checkImages()
        // Do any additional setup after loading the view.
    }
    
    func checkImages() {
        if UserManager.shared.image["number plate"] != nil {
            self.numberPlate.image = UserManager.shared.image["number plate"]
            self.numberPlateButton.titleLabel?.text = "Retake"
        } else {
            self.numberPlateButton.titleLabel?.text = "Capture"
        }
        if UserManager.shared.image["driver's photo"] != nil {
            self.driversPhoto.image = UserManager.shared.image["driver's photo"]
            self.driversPhotoButton.titleLabel?.text = "Retake"
        } else {
            self.driversPhotoButton.titleLabel?.text = "Capture"
        }
        
        
    }

    @IBAction func didTapDriversPhotoButton(_ sender: Any) {
        isNumberPlateTapped = false
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }
    @IBAction func didTapBumberPlateButton(_ sender: Any) {
        isNumberPlateTapped = true
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }

}

extension DriverViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        if isNumberPlateTapped {
            UserManager.shared.image["number plate"] =  image
            self.numberPlateButton.titleLabel?.text = "Retake"
        } else {
            UserManager.shared.image["driver's photo"] =  image
            self.driversPhotoButton.titleLabel?.text = "Retake"
        }
        
    }
}
