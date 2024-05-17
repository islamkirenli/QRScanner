//
//  ProfilViewController.swift
//  QRScanner
//
//  Created by islam kirenli on 28.04.2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class ProfilViewController: UIViewController, AvatarSelectionDelegate, AvatarSelectionViewController.AvatarSelectionDelegate {
    
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var signOutButtonOutlet: UIButton!
    @IBOutlet weak var signInButtonOutlet: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    
    let currentUser = Auth.auth().currentUser
    let firestoreDB = Firestore.firestore()
    let userID = Auth.auth().currentUser?.uid
    
    var avatarName = "avatar-1"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if currentUser != nil{
            signInButtonOutlet.isHidden = true
            signOutButtonOutlet.isHidden = false
            userEmailLabel.text = currentUser?.email
        }else{
            signOutButtonOutlet.isHidden = true
            signInButtonOutlet.isHidden = false
            userEmailLabel.text = "özellikleri kullanabilmek için giriş yapın."
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImageTapped))
        avatarImageView.addGestureRecognizer(tapGesture)
        avatarImageView.isUserInteractionEnabled = true
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeKapat))
        view.addGestureRecognizer(gestureRecognizer)
        
        firebaseVerileriAl()
    }
    
    @objc func klavyeKapat(){
        view.endEditing(true)
    }
    
    @objc func selectImageTapped(){
        let avatarSelectionVC = AvatarSelectionViewController()
        avatarSelectionVC.delegate = self
        present(avatarSelectionVC, animated: true, completion: nil)
    }
    
    func didSelectIcon(withName avatarName: String) {
        avatarImageView.image = UIImage(named: avatarName)
        self.avatarName = avatarName
    }
    

    @IBAction func signOutButton(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            //GIDSignIn.sharedInstance.signOut()
            performSegue(withIdentifier: "toLogInVC", sender: nil)
        }catch{
            print("hata var.")
        }
    }
    
    @IBAction func signInButton(_ sender: Any) {
        performSegue(withIdentifier: "toLogInVC", sender: nil)
    }
    
    
    @IBAction func changePasswordButton(_ sender: Any) {
    }
    
    @IBAction func saveChangesButton(_ sender: Any) {
        firestoreDB.collection("Users").document(userID!).setData([
            "name": nameTextField.text ?? "",
            "surname": surnameTextField.text ?? "",
            "email": currentUser?.email,
            "avatar": self.avatarName,
        ]) { error in
            if let error = error {
                // Hata durumunu işle
                print("Error writing document: \(error)")
            } else {
                // Başarılı yazma
                Alerts.showAlert(title: "Kaydedildi", message: "Bilgileriniz başarılı bir şekilde kaydedildi.", viewController: self)
                print("Document successfully written!")
            }
        }

    }
    
    func firebaseVerileriAl(){
        if let currentUserEmail = currentUser?.email{
            firestoreDB.collection("Users").whereField("email", isEqualTo: currentUserEmail)
                .addSnapshotListener { (snapshot, error) in
                if error != nil{
                    Alerts.showAlert(title:"Hata!", message: error?.localizedDescription ?? "hata var.", viewController: self)
                }else{
                    if snapshot?.isEmpty != true && snapshot != nil{
                        for document in snapshot!.documents{
                            if let avatarID = document.get("avatar") as? String{
                                self.avatarImageView.image = UIImage(named: avatarID)
                                self.avatarName = avatarID
                            }
                            
                            if let name = document.get("name") as? String{
                                self.nameTextField.text = name
                            }
                            
                            if let surname = document.get("surname") as? String{
                                self.surnameTextField.text = surname
                            }
                        }
                    }
                }
            }
        }
        
    }
    
}
