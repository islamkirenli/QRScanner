import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore
import GoogleMobileAds

class PDFMakerViewController: UIViewController, UIDocumentPickerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    @IBOutlet weak var downloadButtonOutlet: UIButton!
    @IBOutlet weak var designButtonOutlet: UIButton!
    
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var checkmarkView: UIImageView!
    @IBOutlet weak var documentNameLabel: UILabel!
    
    let currentUser = Auth.auth().currentUser
    
    var documentURL = ""
    
    var selectedPDFURL: URL?
    
    var bannerView: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        saveButtonOutlet.isHidden = true
        downloadButtonOutlet.isHidden = true
        designButtonOutlet.isHidden = true
        progressView.isHidden = true
        progressView.progress = 0.0
        checkmarkView.isHidden = true
        
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

    
    @IBAction func selectPDFButtonTapped(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else {
            return
        }
        
        documentNameLabel.text = selectedURL.lastPathComponent
        
        progressView.isHidden = false
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        if let currentUserEmail = currentUser?.email {
            let userFolder = storageReference.child(currentUserEmail)
            let uuid = UUID().uuidString
            let documentReference = userFolder.child("Documents").child(uuid)
            
            DispatchQueue.global().async {
                do {
                    let data = try Data(contentsOf: selectedURL)
                    
                    let maxSize: Int = 50 * 1024 * 1024 // 50 MB
                    if data.count > maxSize {
                        DispatchQueue.main.async {
                            Alerts.showAlert(title: "Hata!", message: "Dosya boyutu 50 MB'dan büyük olamaz.", viewController: self)
                            self.progressView.isHidden = true
                            self.checkmarkView.isHidden = true
                        }
                        return
                    }
                    
                    let uploadTask = documentReference.putData(data, metadata: nil) { (storageMetadata, error) in
                        if let error = error {
                            DispatchQueue.main.async {
                                Alerts.showAlert(title: "Hata!", message: error.localizedDescription, viewController: self)
                            }
                            return
                        }
                        
                        documentReference.downloadURL { (url, error) in
                            guard let downloadURL = url else {
                                DispatchQueue.main.async {
                                    Alerts.showAlert(title: "Hata!", message: error?.localizedDescription ?? "Dosya urlsi alınırken hata alındı.", viewController: self)
                                }
                                return
                            }
                            
                            self.documentURL = downloadURL.absoluteString
                            
                            let firestoreDB = Firestore.firestore()
                            
                            let firestoreDocumentArray = [
                                "documenturl" : self.documentURL,
                                "email" : Auth.auth().currentUser!.email,
                                "tarih" : FieldValue.serverTimestamp()
                            ] as [String : Any]
                            
                            firestoreDB.collection("Documents").addDocument(data: firestoreDocumentArray) { error in
                                if let error = error {
                                    DispatchQueue.main.async {
                                        Alerts.showAlert(title: "Hata!", message: error.localizedDescription, viewController: self)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Observe the upload progress
                    uploadTask.observe(.progress) { snapshot in
                        guard let progress = snapshot.progress else {
                            return
                        }
                        
                        // Update progress view on the main thread
                        DispatchQueue.main.async {
                            let progressValue = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
                            // Update your progress view here with the progressValue
                            // For example:
                            self.progressView.progress = progressValue
                            
                            if progressValue == 1.0{
                                self.checkmarkView.isHidden = false
                            }
                        }
                    }
                    
                    // Observe when the upload is completed
                    uploadTask.observe(.success) { snapshot in
                        
                    }
                    
                } catch {
                    DispatchQueue.main.async {
                        Alerts.showAlert(title: "Hata!", message: error.localizedDescription, viewController: self)
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
                designButtonOutlet.isHidden = false
                saveButtonOutlet.isHidden = false
                downloadButtonOutlet.isHidden = false
            } else {
                // QR kodu oluşturulamazsa hata mesajı gösterin
                Alerts.showAlert(title: "Hata!", message: "QR kodu oluşturulamadı.", viewController: self)
            }
        }else{
            Alerts.showAlert(title: "Uyarı", message: "Bir döküman seçiniz.", viewController: self)
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
        if Auth.auth().currentUser != nil{
            performSegue(withIdentifier: "toSaveVC", sender: nil)
        }else{
            Alerts.showAlert2Button(title: "Uyarı", message: "Kaydetme özelliğini kullanabilmek için kullanıcı girişi yapmanız gerekmektedir.", buttonTitle: "Giriş Yap", viewController: self) {
                self.performSegue(withIdentifier: "toLogInVC", sender: nil)
            }
        }
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

