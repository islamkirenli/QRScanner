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
                    Alerts.showAlert(title: "Error",message: error?.localizedDescription ?? "kayıt sırasında hata alındı.", viewController: self)
                }else{
                    self.performSegue(withIdentifier: "toTabBarVC", sender: nil)
                }
            }
        }else if passwordTextField.text != secondPasswordTextField.text{
            Alerts.showAlert(title: "Error",message: "Şifre ve doğrulama şifresi aynı olmalıdır.", viewController: self)
        }else{
            Alerts.showAlert(title: "Error",message: "Email ve şifre alanlarını kontrol ediniz.", viewController: self)
        }
        
    }

}
