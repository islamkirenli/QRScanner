import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

class PDFMakerViewController: UIViewController, UIDocumentPickerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    @IBOutlet weak var downloadButtonOutlet: UIButton!
    
    let currentUser = Auth.auth().currentUser
    
    var documentURL = ""
    
    var selectedPDFURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        saveButtonOutlet.isHidden = true
        downloadButtonOutlet.isHidden = true
    }

    
    @IBAction func selectPDFButtonTapped(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else {
            return
        }
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        if let currentUserEmail = currentUser?.email{
            let userFolder = storageReference.child(currentUserEmail)
            let uuid = UUID().uuidString
            let documentReference = userFolder.child("Documents").child("\(uuid)")
            
            documentReference.putFile(from: selectedURL, metadata: nil) { (storagemetadata, error) in
                if error != nil{
                    self.showAlert(message: error?.localizedDescription ?? "döküman yüklenemedi.")
                }else{
                    documentReference.downloadURL { url, error in
                        guard let downloadURL = url else {
                            self.showAlert(message: error?.localizedDescription ?? "dosya urlsi alınırken hata alındı.")
                            return
                        }
                        self.documentURL = downloadURL.absoluteString
                        
                        let firestoreDB = Firestore.firestore()
                        
                        let firestoreDocumentArray = ["documenturl" : self.documentURL, "email" : Auth.auth().currentUser!.email, "tarih" : FieldValue.serverTimestamp()] as [String : Any]
                        
                        firestoreDB.collection("Documents").addDocument(data: firestoreDocumentArray) { error in
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
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Doküman seçim işlemi iptal edildi")
    }
    
    
    
    @IBAction func generateQRCodeButtonTapped(_ sender: Any) {
        if documentURL.isEmpty == false{
            if let qrCodeImage = GenerateAndDesign.generate(from: documentURL) {
                // QR kodunu imageView'a atayın
                imageView.image = qrCodeImage
                saveButtonOutlet.isHidden = false
                downloadButtonOutlet.isHidden = false
            } else {
                // QR kodu oluşturulamazsa hata mesajı gösterin
                showAlert(message: "QR kodu oluşturulamadı")
            }
        }else{
            showAlert(message: "bir hata alındı.")
        }
    }
    
    
    @IBAction func designButton(_ sender: Any) {
        performSegue(withIdentifier: "toDesignVC", sender: nil)
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
                destinationVC.receivedText = documentURL
            }
        }
    }
    
    @IBAction func saveButton(_ sender: Any) {
        performSegue(withIdentifier: "toSaveVC", sender: nil)
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
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

