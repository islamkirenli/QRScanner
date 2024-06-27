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
import AuthenticationServices

class LogInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Çerçeve ayarları
        emailTextField.layer.borderColor = UIColor.lightGray.cgColor
        emailTextField.layer.borderWidth = 1.0
        emailTextField.layer.cornerRadius = 10.0
        emailTextField.layer.masksToBounds = true
        let placeholderTextemail = "e-Mail"
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
        let placeholderText = "Password"
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )

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
                    Alerts.showAlert(title: "Error",message: error?.localizedDescription ?? "There is an error.", viewController: self)
                }else{
                    self.performSegue(withIdentifier: "toTabBarVC", sender: nil)
                }
            }
        }
        else{
            Alerts.showAlert(title: "Error",message: "Enter your email and password.", viewController: self)
        }
    }
    
    @IBAction func logInWithGoogleButton(_ sender: Any) {
        signInWithGoogle()
    }
    
    
    @IBAction func logInWithAppleButton(_ sender: Any) {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
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
    
    /*
    func signInWithApple() {
        Task { @MainActor in
            let success = await performSignInWithApple()
            if success {
                dismiss(animated: true)
                self.performSegue(withIdentifier: "toTabBarVC", sender: nil)
            } else {
                print("Apple girişi sırasında hata oluştu...")
            }
        }
    }

    func performSignInWithApple() async -> Bool {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        
        return await withCheckedContinuation { continuation in
            authorizationController.performRequests()
            continuation.resume(returning: true)
        }
    }
     */
}

extension LogInViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let idTokenData = appleIDCredential.identityToken,
                  let idTokenString = String(data: idTokenData, encoding: .utf8) else {
                print("Apple ID token missing")
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nil)
            
            Task { @MainActor in
                do {
                    let result = try await Auth.auth().signIn(with: credential)
                    let firebaseUser = result.user
                    print("User \(firebaseUser.uid) signed in with email \(firebaseUser.email ?? "unknown")")
                    // Başarılı giriş işlemleri burada yapılabilir
                    self.performSegue(withIdentifier: "toTabBarVC", sender: nil)
                } catch {
                    print("Apple sign in error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple failed: \(error.localizedDescription)")
    }
}

extension LogInViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
