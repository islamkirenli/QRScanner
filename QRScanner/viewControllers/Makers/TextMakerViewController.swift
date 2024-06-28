import UIKit
import FirebaseAuth
import GoogleMobileAds

class TextMakerViewController: UIViewController, UITextViewDelegate {

    
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var characterCountLabel: UILabel!
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    @IBOutlet weak var downloadButtonOutlet: UIButton!
    @IBOutlet weak var designButtonOutlet: UIButton!
    
    let maxLength = 500
    
    var sanitizedText = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        updateCharacterCount()
        
        // Placeholder Text
        textField.text = "Enter your text"
        textField.textColor = UIColor.lightGray

        // Border
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 5.0
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeKapat))
        view.addGestureRecognizer(gestureRecognizer)
        
        saveButtonOutlet.isHidden = true
        downloadButtonOutlet.isHidden = true
        designButtonOutlet.isHidden = true
        
        AdManager.shared.setupBannerAd(viewController: self, adUnitID: Ads.bannerAdUnitID)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AdManager.shared.invalidateTimer()
    }
    
    // UITextViewDelegate Methods
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter your text"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Mevcut metnin uzunluğunu ve yeni eklenen metnin uzunluğunu hesapla
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        // Maksimum karakter sayısını kontrol et
        return updatedText.count <= maxLength
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // Metin değiştiğinde karakter sayısını güncelle
        updateCharacterCount()
    }
    
    func updateCharacterCount() {
        // Mevcut metin uzunluğunu al ve karakter sayısını hesapla
        let currentText = textField.text ?? ""
        //let remainingCharacters = maxLength - currentText.count
        
        // Kalan karakter sayısını etikete yazdır
        characterCountLabel.text = "\(currentText.count)/\(maxLength)"
    }
    
    @objc func klavyeKapat(){
        view.endEditing(true)
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
                destinationVC.receivedText = sanitizedText
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
    
    @IBAction func generateQRCodeButtonTapped(_ sender: Any) {
        guard let urlString = textField.text, !urlString.isEmpty else {
            // Kullanıcı URL girmeden butona tıklarsa hata mesajı gösterin
            Alerts.showAlert(title: "Alert", message: "Please enter a message.", viewController: self)
            return
        }
        
        sanitizedText = sanitizeTurkishCharacters(urlString)
        
        if let qrCodeImage = GenerateAndDesign.generate(from: sanitizedText) {
            // QR kodunu imageView'a atayın
            imageView.image = qrCodeImage
            designButtonOutlet.isHidden = false
            saveButtonOutlet.isHidden = false
            downloadButtonOutlet.isHidden = false
        } else {
            // QR kodu oluşturulamazsa hata mesajı gösterin
            Alerts.showAlert(title: "Error", message: "The QR code could not be generated.", viewController: self)
        }
    }
    
    func sanitizeTurkishCharacters(_ text: String) -> String {
            let turkishCharacters: [Character: Character] = ["ı": "i", "İ": "I", "ğ": "g", "Ğ": "G", "ü": "u", "Ü": "U", "ş": "s", "Ş": "S", "ö": "o", "Ö": "O", "ç": "c", "Ç": "C"]
            var sanitizedText = text
            for (turkishCharacter, asciiCharacter) in turkishCharacters {
                sanitizedText = sanitizedText.replacingOccurrences(of: String(turkishCharacter), with: String(asciiCharacter))
            }
            return sanitizedText
        }
    
    
    @IBAction func designButton(_ sender: Any) {
        performSegue(withIdentifier: "toDesignVC", sender: nil)
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

