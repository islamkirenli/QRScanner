//
//  SignUpViewController.swift
//  QRScanner
//
//  Created by islam kirenli on 28.04.2024.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var secondPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Çerçeve ayarları
        emailTextField.layer.borderColor = UIColor.lightGray.cgColor
        emailTextField.layer.borderWidth = 1.0
        emailTextField.layer.cornerRadius = 10.0
        emailTextField.layer.masksToBounds = true
        let placeholderTextemail = "example@email.com"
        let placeholderColor = UIColor.gray
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderTextemail,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
        // Çerçeve ayarları
        passwordTextField.layer.borderColor = UIColor.lightGray.cgColor
        passwordTextField.layer.borderWidth = 1.0
        passwordTextField.layer.cornerRadius = 10.0
        passwordTextField.layer.masksToBounds = true
        let placeholderTextpassword = "Password"
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderTextpassword,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
        // Çerçeve ayarları
        secondPasswordTextField.layer.borderColor = UIColor.lightGray.cgColor
        secondPasswordTextField.layer.borderWidth = 1.0
        secondPasswordTextField.layer.cornerRadius = 10.0
        secondPasswordTextField.layer.masksToBounds = true
        let placeholderText = "Confirm Password"
        secondPasswordTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )

        // Do any additional setup after loading the view.
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeKapat))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func klavyeKapat(){
        view.endEditing(true)
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        
        if emailTextField.text != "" && passwordTextField.text != "" && passwordTextField.text == secondPasswordTextField.text{
            // kayıt olma işlemi
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (authdataresult, error) in
                if error != nil{
                    Alerts.showAlert(title: "Error",message: error?.localizedDescription ?? "There is an error.", viewController: self)
                }else{
                    self.performSegue(withIdentifier: "toTabBarVC", sender: nil)
                }
            }
        }else if passwordTextField.text != secondPasswordTextField.text{
            Alerts.showAlert(title: "Error",message: "The password and the confirmation password must be the same.", viewController: self)
        }else{
            Alerts.showAlert(title: "Error",message: "Please check the email and password fields.", viewController: self)
        }
        
    }

}
