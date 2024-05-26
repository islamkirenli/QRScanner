//
//  LogInViewController.swift
//  QRScanner
//
//  Created by islam kirenli on 28.04.2024.
//

import UIKit
import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift

class LogInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeKapat))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func klavyeKapat(){
        view.endEditing(true)
    }
    
    @IBAction func logInButton(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != ""{
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (authdataresult, error) in
                if error != nil{
                    Alerts.showAlert(title: "Error",message: error?.localizedDescription ?? "giriş yağılırken hata alındı.", viewController: self)
                }else{
                    self.performSegue(withIdentifier: "toTabBarVC", sender: nil)
                }
            }
        }
        else{
            Alerts.showAlert(title: "Error",message: "email ve şifre girin.", viewController: self)
        }
    }
    
    @IBAction func logInWithGoogleButton(_ sender: Any) {
        signInWithGoogle()
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        performSegue(withIdentifier: "toSignUpVC", sender: nil)
    }
    
    
    @IBAction func forgetPasswordButton(_ sender: Any) {
        performSegue(withIdentifier: "toForgetPasswordVC", sender: nil)
    }
    
    @IBAction func continueWithNoSignUp(_ sender: Any) {
        performSegue(withIdentifier: "toTabBarVC", sender: nil)
    }
    
    func signInWithGoogle(){
        Task { @MainActor in
            let success = await performSignInWithGoogle()
            if success {
                dismiss(animated: true)
                self.performSegue(withIdentifier: "toTabBarVC", sender: nil)
            } else {
                print("burda hata var.....")
            }
        }
    }
    
    func performSignInWithGoogle() async -> Bool {
      guard let clientID = FirebaseApp.app()?.options.clientID else {
        fatalError("No client ID found in Firebase configuration")
      }
      let config = GIDConfiguration(clientID: clientID)
      GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
        print("There is no root view controller!")
        return false
        }
        do {
          let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
          let user = userAuthentication.user
          guard let idToken = user.idToken else { throw AuthenticationError.showAlert(message: "ID token missing") }
          let accessToken = user.accessToken
          let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
                                                         accessToken: accessToken.tokenString)
          let result = try await Auth.auth().signIn(with: credential)
          let firebaseUser = result.user
          print("User \(firebaseUser.uid) signed in with email \(firebaseUser.email ?? "unknown")")
          return true
        }
        catch {
          print(error.localizedDescription)
          return false
        }
    }

    enum AuthenticationError: Error {
      case showAlert(message: String)
    }
    
}
