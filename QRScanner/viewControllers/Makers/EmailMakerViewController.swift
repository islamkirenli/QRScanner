import UIKit
import FirebaseAuth
import GoogleMobileAds

class EmailMakerViewController: UIViewController, UITextViewDelegate{

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var characterCountLabel: UILabel!
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    @IBOutlet weak var downloadButtonOutlet: UIButton!
    @IBOutlet weak var designButtonOutlet: UIButton!
    
    var emailString = ""
    
    let maxLength = 500

    
    var bannerView: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeKapat))
        view.addGestureRecognizer(gestureRecognizer)
        
        // Çerçeve ayarları
        emailTextField.layer.borderColor = UIColor.lightGray.cgColor
        emailTextField.layer.borderWidth = 1.0
        emailTextField.layer.cornerRadius = 10.0
        emailTextField.layer.masksToBounds = true
        let placeholderText = "e-Mail"
        let placeholderColor = UIColor.gray
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
        // Çerçeve ayarları
        subjectTextField.layer.borderColor = UIColor.lightGray.cgColor
        subjectTextField.layer.borderWidth = 1.0
        subjectTextField.layer.cornerRadius = 10.0
        subjectTextField.layer.masksToBounds = true
        let placeholderTextsubject = "Subject"
        subjectTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderTextsubject,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
        // Placeholder Text
        messageTextField.text = "Enter your message"
        messageTextField.textColor = UIColor.lightGray

        // Border
        messageTextField.layer.borderColor = UIColor.gray.cgColor
        messageTextField.layer.borderWidth = 1.0
        messageTextField.layer.cornerRadius = 5.0
        
        // Delegate
        messageTextField.delegate = self
        
        saveButtonOutlet.isHidden = true
        downloadButtonOutlet.isHidden = true
        designButtonOutlet.isHidden = true
        
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
        let currentText = messageTextField.text ?? ""
        //let remainingCharacters = maxLength - currentText.count
        
        // Kalan karakter sayısını etikete yazdır
        characterCountLabel.text = "\(currentText.count)/\(maxLength)"
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
            textView.text = "Enter your message"
            textView.textColor = UIColor.lightGray
        }
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
                destinationVC.receivedText = emailString
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
        guard let email = emailTextField.text, !email.isEmpty else {
            // Kullanıcı e-posta adresi girmeden butona tıklarsa hata mesajı gösterin
            Alerts.showAlert(title: "Alert", message: "Please enter an email address.", viewController: self)
            return
        }
        
        // Konuyu ve mesajı kullanıcıdan alın
        let subject = subjectTextField.text ?? ""
        let message = messageTextField.text ?? ""
        
        // QR kodu oluşturmak için e-posta adresi, konu ve mesajı birleştir
        emailString = "mailto:\(email)?subject=\(subject)&body=\(message)"
        
        let sanitizedText = sanitizeTurkishCharacters(emailString)
        
        if let qrCodeImage = GenerateAndDesign.generate(from: sanitizedText) {
            // Oluşturulan QR kodunu imageView'a atayın
            imageView.image = qrCodeImage
            designButtonOutlet.isHidden = false
            saveButtonOutlet.isHidden = false
            downloadButtonOutlet.isHidden = false
        } else {
            // QR kodu oluşturulamazsa hata mesajı gösterin
            Alerts.showAlert(title: "Error", message: "The QR code could not be generated.", viewController: self)
        }
    }
    
    
    @IBAction func designButton(_ sender: Any) {
        performSegue(withIdentifier: "toDesignVC", sender: nil)
    }
    
    func sanitizeTurkishCharacters(_ text: String) -> String {
            let turkishCharacters: [Character: Character] = ["ı": "i", "İ": "I", "ğ": "g", "Ğ": "G", "ü": "u", "Ü": "U", "ş": "s", "Ş": "S", "ö": "o", "Ö": "O", "ç": "c", "Ç": "C"]
            var sanitizedText = text
            for (turkishCharacter, asciiCharacter) in turkishCharacters {
                sanitizedText = sanitizedText.replacingOccurrences(of: String(turkishCharacter), with: String(asciiCharacter))
            }
            return sanitizedText
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

