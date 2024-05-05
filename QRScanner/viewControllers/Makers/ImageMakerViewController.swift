import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

class ImageMakerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var originalImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    @IBOutlet weak var downloadButtonOutlet: UIButton!
    
    var originalImageURLForQR = ""
    
    let currentUser = Auth.auth().currentUser
    
    var selectedImageData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImageTapped))
        originalImageView.addGestureRecognizer(tapGesture)
        originalImageView.isUserInteractionEnabled = true
        
        saveButtonOutlet.isHidden = true
        downloadButtonOutlet.isHidden = true
    }
    
    @objc func selectImageTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSaveVC" {
            if let destinationVC = segue.destination as? SaveViewController {
                destinationVC.receivedImage = imageView.image
            }
        }
    }
    
    @IBAction func saveButton(_ sender: Any) {
        performSegue(withIdentifier: "toSaveVC", sender: nil)
    }
    
    @IBAction func generateQRTapped(_ sender: Any) {
        if let image = originalImageView.image{
            if originalImageURLForQR.isEmpty == false{
                if let qrCodeImage = GenerateAndDesign.generate(from: originalImageURLForQR) {
                    // QR kodunu imageView'a atayın
                    print(originalImageURLForQR)
                    imageView.image = qrCodeImage
                    saveButtonOutlet.isHidden = false
                    downloadButtonOutlet.isHidden = false
                } else {
                    // QR kodu oluşturulamazsa hata mesajı gösterin
                    showAlert(message: "QR kodu oluşturulamadı")
                }
            }
        }else{
            showAlert(message: "bir fotoğraf seçin.")
        }
        
        
    }
    
    
    
    
    @IBAction func designButton(_ sender: Any) {
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            originalImageView.image = selectedImage
            
            let storage = Storage.storage()
            let storageReference = storage.reference()
            
            if let currentUserEmail = currentUser?.email{
                let userFolder = storageReference.child(currentUserEmail)
                
                if let data = originalImageView.image?.jpegData(compressionQuality: 0.5){
                    let uuid = UUID().uuidString
                    let imageReference = userFolder.child("Images").child("\(uuid).jpg")
                    
                    imageReference.putData(data, metadata: nil) { (storagemetadata, error) in
                        if error != nil{
                            self.showAlert(message: error?.localizedDescription ?? "görsel yüklenirken hata alındı.")
                        }else{
                            imageReference.downloadURL { (url, error) in
                                if error == nil{
                                    let originalImageURL = url?.absoluteString
                                    
                                    if let originalImageURL = originalImageURL{
                                        self.originalImageURLForQR = originalImageURL
                                        
                                        let firestoreDB = Firestore.firestore()
                                        
                                        let firestoreImageArray = ["gorselurl" : originalImageURL, "email" : Auth.auth().currentUser!.email, "tarih" : FieldValue.serverTimestamp()] as [String : Any]
                                        
                                        firestoreDB.collection("Images").addDocument(data: firestoreImageArray) { error in
                                            if error != nil{
                                                self.showAlert(message: error?.localizedDescription ?? "firestore'a atılırken hata alındı.")
                                            }else{
                                                
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
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Uyarı", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func downloadButton(_ sender: Any) {
        saveImage()
    }
    
    @objc func saveImage() {
        if let pickedImage = imageView.image {
            UIImageWriteToSavedPhotosAlbum(pickedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc func image (_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}

