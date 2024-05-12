//
//  SaveViewController.swift
//  QRScanner
//
//  Created by islam kirenli on 29.04.2024.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

class SaveViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    
    let currentUser = Auth.auth().currentUser
    
    var receivedImage : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.image = receivedImage
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeKapat))
        view.addGestureRecognizer(gestureRecognizer)
        
    }
    
    @objc func klavyeKapat(){
        view.endEditing(true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        if titleTextField.text?.isEmpty == true{
            showAlert(message: "Lütfen başlık girin.")
        }else{
            let storage = Storage.storage()
            let storageReference = storage.reference()
            
            if let currentUserEmail = currentUser?.email{
                let userFolder = storageReference.child(currentUserEmail)
                
                if let data = imageView.image?.jpegData(compressionQuality: 0.5){
                    let uuid = UUID().uuidString
                    let imageReference = userFolder.child("QR_Codes").child("\(uuid).jpg")
                    
                    imageReference.putData(data, metadata: nil) { (storagemetadata, error) in
                        if error != nil{
                            self.showAlert(message: error?.localizedDescription ?? "hata alındı.")
                        }else{
                            imageReference.downloadURL { (url, error) in
                                if error == nil{
                                    let imageURL = url?.absoluteString
                                    
                                    if let imageURL = imageURL{
                                        let firestoreDB = Firestore.firestore()
                                        
                                        let firestoreQRArray = ["gorselurl" : imageURL, "baslik" : self.titleTextField.text!, "email" : Auth.auth().currentUser!.email ?? "user-mail@gmail.com", "tarih" : FieldValue.serverTimestamp()] as [String : Any]
                                        
                                        firestoreDB.collection("QRCodes").addDocument(data: firestoreQRArray) { error in
                                            if error != nil{
                                                self.showAlert(message: error?.localizedDescription ?? "hata aldınız.")
                                            }else{
                                                self.dismiss(animated: true)
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    

}
