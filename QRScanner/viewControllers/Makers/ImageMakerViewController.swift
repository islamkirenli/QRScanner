import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore
import GoogleMobileAds

class ImageMakerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var originalImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    @IBOutlet weak var downloadButtonOutlet: UIButton!
    @IBOutlet weak var designButtonOutlet: UIButton!
    @IBOutlet weak var checkmark: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    
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
        designButtonOutlet.isHidden = true
        progressView.isHidden = true
        progressView.progress = 0.0
        checkmark.isHidden = true
        
        AdManager.shared.setupBannerAd(viewController: self, adUnitID: Ads.bannerAdUnitID)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AdManager.shared.invalidateTimer()
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
        
        if segue.identifier == "toDesignVC"{
            if let destinationVC = segue.destination as? DesignViewController{
                destinationVC.receivedImage = imageView.image
                destinationVC.receivedText = originalImageURLForQR
            }
        }
    }
    
    @IBAction func saveButton(_ sender: Any) {
        if Auth.auth().currentUser != nil{
            performSegue(withIdentifier: "toSaveVC", sender: nil)
        }else{
            Alerts.showAlert2Button(title: "Alert", message: "You need to log in to use the save feature.", buttonTitle: "Log In", viewController: self) {
                self.performSegue(withIdentifier: "toLogInVC", sender: nil)
            }
        }
    }
    
    @IBAction func generateQRTapped(_ sender: Any) {
        if let image = originalImageView.image{
            if originalImageURLForQR.isEmpty == false{
                if let qrCodeImage = GenerateAndDesign.generate(from: originalImageURLForQR) {
                    // QR kodunu imageView'a atayın
                    print(originalImageURLForQR)
                    imageView.image = qrCodeImage
                    designButtonOutlet.isHidden = false
                    saveButtonOutlet.isHidden = false
                    downloadButtonOutlet.isHidden = false
                } else {
                    // QR kodu oluşturulamazsa hata mesajı gösterin
                    Alerts.showAlert(title: "Alert", message: "The QR code could not be generated.", viewController: self)
                }
            }
        }else{
            Alerts.showAlert(title: "Alert", message: "Please select a photo.", viewController: self)
        }
        
        
    }
    
    @IBAction func designButton(_ sender: Any) {
        performSegue(withIdentifier: "toDesignVC", sender: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            originalImageView.image = selectedImage
            
            progressView.isHidden = false
                    
            let storage = Storage.storage()
            let storageReference = storage.reference()
            
            if let currentUserEmail = currentUser?.email {
                let userFolder = storageReference.child(currentUserEmail)
                
                if let data = originalImageView.image?.jpegData(compressionQuality: 0.5) {
                    let maxSize: Int = 15 * 1024 * 1024 // 15 MB
                    if data.count > maxSize {
                        Alerts.showAlert(title: "Error", message: "The photo size cannot be more than 15 MB.", viewController: self)
                        progressView.isHidden = true
                        checkmark.isHidden = true
                        return
                    }
                    
                    let uuid = UUID().uuidString
                    let imageReference = userFolder.child("Images").child("\(uuid).jpg")
                    
                    // Görsel yükleme işlemi için progress view
                    let uploadTask = imageReference.putData(data, metadata: nil) { (storagemetadata, error) in
                        if error != nil {
                            DispatchQueue.main.async {
                                Alerts.showAlert(title: "Error", message: error?.localizedDescription ?? "There is an error.", viewController: self)
                            }
                        } else {
                            imageReference.downloadURL { (url, error) in
                                if error == nil {
                                    let originalImageURL = url?.absoluteString
                                    
                                    if let originalImageURL = originalImageURL {
                                        self.originalImageURLForQR = originalImageURL
                                        
                                        let firestoreDB = Firestore.firestore()
                                        
                                        let firestoreImageArray = ["gorselurl" : originalImageURL, "email" : Auth.auth().currentUser!.email, "tarih" : FieldValue.serverTimestamp()] as [String : Any]
                                        
                                        firestoreDB.collection("Images").addDocument(data: firestoreImageArray) { error in
                                            if error != nil {
                                                DispatchQueue.main.async {
                                                    Alerts.showAlert(title: "Error", message: error?.localizedDescription ?? "There is an error.", viewController: self)
                                                }
                                            } else {
                                                // Veritabanı işlemi başarıyla tamamlandı
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Progress view güncellemesi
                    uploadTask.observe(.progress) { snapshot in
                        guard let progress = snapshot.progress else { return }
                        DispatchQueue.main.async {
                            let percentComplete = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
                            // Progress view güncelleme işlemi
                            self.progressView.progress = percentComplete
                            
                            if percentComplete == 1.0{
                                self.checkmark.isHidden = false
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

