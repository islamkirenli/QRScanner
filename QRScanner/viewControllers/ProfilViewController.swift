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
import GoogleMobileAds

class ProfilViewController: UIViewController, AvatarSelectionDelegate, AvatarSelectionViewController.AvatarSelectionDelegate {
    
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var signOutButtonOutlet: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    
    let currentUser = Auth.auth().currentUser
    let firestoreDB = Firestore.firestore()
    let userID = Auth.auth().currentUser?.uid
    
    var avatarName = "avatar-1"
    
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if currentUser != nil{
            signOutButtonOutlet.isHidden = false
            userEmailLabel.text = currentUser?.email
        }else{
            self.performSegue(withIdentifier: "toLogInVC", sender: nil)
        }
        
        // Çerçeve ayarları
        nameTextField.layer.borderColor = UIColor.lightGray.cgColor
        nameTextField.layer.borderWidth = 1.0
        nameTextField.layer.cornerRadius = 10.0
        nameTextField.layer.masksToBounds = true
        let placeholderTextname = "Name"
        let placeholderColor = UIColor.gray
        nameTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderTextname,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
        // Çerçeve ayarları
        surnameTextField.layer.borderColor = UIColor.lightGray.cgColor
        surnameTextField.layer.borderWidth = 1.0
        surnameTextField.layer.cornerRadius = 10.0
        surnameTextField.layer.masksToBounds = true
        let placeholderText = "Surname"
        surnameTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImageTapped))
        avatarImageView.addGestureRecognizer(tapGesture)
        avatarImageView.isUserInteractionEnabled = true
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeKapat))
        view.addGestureRecognizer(gestureRecognizer)
        
        firebaseVerileriAl()
        
        let viewWidth = view.frame.inset(by: view.safeAreaInsets).width

        // Here the current interface orientation is used. Use
        // GADLandscapeAnchoredAdaptiveBannerAdSizeWithWidth or
        // GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth if you prefer to load an ad of a
        // particular orientation,
        let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        bannerView = GADBannerView(adSize: adaptiveSize)
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)

        bannerView.adUnitID = Ads.bannerAdUnitID
        bannerView.rootViewController = self

        bannerView.load(GADRequest())
        
        Ads.addBannerViewToView(bannerView, viewController: self)
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
            print("There is an error.")
        }
    }
    
    
    @IBAction func deleteAccountButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Are you sure you want to delete your account?", message: "This action cannot be undone.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteUserAccount()
        }
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func deleteUserAccount() {
        currentUser?.delete { error in
            if let error = error {
                // Hata durumunu ele al
                print("Kullanıcı silme hatası: \(error.localizedDescription)")
            } else {
                // Kullanıcı başarıyla silindi
                self.performSegue(withIdentifier: "toLogInVC", sender: nil)
                print("Kullanıcı başarıyla silindi")
            }
        }
    }
    
    @IBAction func changePasswordButton(_ sender: Any) {
        performSegue(withIdentifier: "toChangePasswordVC", sender: nil)
        //performSegue(withIdentifier: "toLogInVC", sender: nil)
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
                Alerts.showAlert(title: "Saved!", message: "Your information has been successfully saved.", viewController: self)
                print("Document successfully written!")
            }
        }

    }
    
    func firebaseVerileriAl(){
        if let currentUserEmail = currentUser?.email{
            firestoreDB.collection("Users").whereField("email", isEqualTo: currentUserEmail)
                .addSnapshotListener { (snapshot, error) in
                if error != nil{
                    Alerts.showAlert(title:"Error", message: error?.localizedDescription ?? "There is an error.", viewController: self)
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
