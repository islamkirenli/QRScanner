//
//  ForgetPasswordViewController.swift
//  QRScanner
//
//  Created by islam kirenli on 21.05.2024.
//

import UIKit
import FirebaseAuth

class ForgetPasswordViewController: UIViewController {

    @IBOutlet weak var userEmailTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeKapat))
        view.addGestureRecognizer(gestureRecognizer)

    }
    
    @objc func klavyeKapat(){
        view.endEditing(true)
    }
    
    @IBAction func sendMailButton(_ sender: Any) {
        guard let email = userEmailTextField.text, !email.isEmpty else {
            // Kullanıcıya hata mesajı göster (örneğin, UIAlertController kullanarak)
            Alerts.showAlert(title: "Error",message: "Please enter your email address.", viewController: self)
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                // Hata durumunu işle
                Alerts.showAlert(title: "Error",message: "Error sending password reset email: \(error.localizedDescription)", viewController: self)
            } else {
                // Başarılı gönderim
                Alerts.showAlert(title: "Success",message: "Password reset email sent successfully.", viewController: self)
            }
        }
    }
    
}
