//
//  ChangePasswordViewController.swift
//  QRScanner
//
//  Created by islam kirenli on 18.05.2024.
//

import UIKit
import FirebaseAuth

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var reNewPasswordTextField: UITextField!
    
    let currentUser = Auth.auth().currentUser


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Çerçeve ayarları
        currentPasswordTextField.layer.borderColor = UIColor.lightGray.cgColor
        currentPasswordTextField.layer.borderWidth = 1.0
        currentPasswordTextField.layer.cornerRadius = 10.0
        currentPasswordTextField.layer.masksToBounds = true
        let placeholderText = "Current Password"
        let placeholderColor = UIColor.gray
        currentPasswordTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
        // Çerçeve ayarları
        newPasswordTextField.layer.borderColor = UIColor.lightGray.cgColor
        newPasswordTextField.layer.borderWidth = 1.0
        newPasswordTextField.layer.cornerRadius = 10.0
        newPasswordTextField.layer.masksToBounds = true
        let placeholderText2 = "New Password"
        newPasswordTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText2,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
        // Çerçeve ayarları
        reNewPasswordTextField.layer.borderColor = UIColor.lightGray.cgColor
        reNewPasswordTextField.layer.borderWidth = 1.0
        reNewPasswordTextField.layer.cornerRadius = 10.0
        reNewPasswordTextField.layer.masksToBounds = true
        let placeholderText3 = "Confirm New Password"
        reNewPasswordTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText3,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeKapat))
        view.addGestureRecognizer(gestureRecognizer)

    }
    
    @objc func klavyeKapat(){
        view.endEditing(true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        guard let currentPassword = currentPasswordTextField.text,
              let newPassword = newPasswordTextField.text,
              let reNewPassword = reNewPasswordTextField.text,
              !currentPassword.isEmpty,
              !newPassword.isEmpty,
              !reNewPassword.isEmpty else {
            // Kullanıcıya hata mesajı göster (örneğin, UIAlertController kullanarak)
            Alerts.showAlert(title: "ERROR", message: "Please fill in all fields.", viewController: self)
            return
        }
        
        if newPasswordTextField.text != reNewPasswordTextField.text{
            Alerts.showAlert(title: "ERROR", message: "The new passwords must match.", viewController: self)
        }
        
        guard let userEmail = currentUser?.email else {
            Alerts.showAlert(title: "ERROR", message: "User not logged in.", viewController: self)
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: userEmail, password: currentPassword)
        
        // Kullanıcı yeniden kimlik doğrulaması
        currentUser?.reauthenticate(with: credential) { authResult, error in
            if let error = error {
                // Hata durumunu işle
                Alerts.showAlert(title: "ERROR", message: "Reauthentication failed: \(error.localizedDescription)", viewController: self)
            } else {
                // Şifre güncellenebilir
                self.currentUser?.updatePassword(to: newPassword) { error in
                    if let error = error {
                        // Hata durumunu işle
                        Alerts.showAlert(title: "ERROR", message: "Password update failed: \(error.localizedDescription)", viewController: self)
                    } else {
                        // Başarılı güncelleme
                        Alerts.showAlert(title: "SUCCESS", message: "Password updated successfully.", viewController: self)
                    }
                }
            }
        }
    }
    
}
