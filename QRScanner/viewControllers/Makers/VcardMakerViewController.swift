import UIKit
import FirebaseAuth
import GoogleMobileAds

class VcardMakerViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var websiteURLTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var jobTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var faxTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    @IBOutlet weak var downloadButtonOutlet: UIButton!
    @IBOutlet weak var designButtonOutlet: UIButton!
    
    var vCardString = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeKapat))
        view.addGestureRecognizer(gestureRecognizer)
        
        textFieledBorder()
        
        saveButtonOutlet.isHidden = true
        downloadButtonOutlet.isHidden = true
        designButtonOutlet.isHidden = true
        
        AdManager.shared.setupBannerAd(viewController: self, adUnitID: Ads.bannerAdUnitID)
        AdManager.shared.loadInterstitialAd(adUnitID: Ads.interstitialAdUnitID)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AdManager.shared.invalidateTimer()
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
                destinationVC.receivedText = vCardString
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
    
    @IBAction func generateQRCode(_ sender: Any) {
        
        if (nameTextField.text?.isEmpty == true || surnameTextField.text?.isEmpty == true || mobileTextField.text?.isEmpty == true || emailTextField.text?.isEmpty == true){
            Alerts.showAlert(title: "Alert", message: "The fields for first name, last name, phone number, and email address must be filled out.", viewController: self)
        }else{
            vCardString = """
                BEGIN:VCARD
                VERSION:3.0
                N:\(surnameTextField.text ?? "");\(nameTextField.text ?? "")
                TEL;TYPE=CELL:\(mobileTextField.text ?? "")
                TEL;TYPE=HOME,VOICE:\(phoneTextField.text ?? "")
                TEL;TYPE=WORK,FAX:\(faxTextField.text ?? "")
                EMAIL:\(emailTextField.text ?? "")
                ORG:\(companyTextField.text ?? "")
                TITLE:\(jobTextField.text ?? "")
                ADR;TYPE=WORK:;;\(streetTextField.text ?? "");\(cityTextField.text ?? "");\(stateTextField.text ?? "");\(zipTextField.text ?? "");\(countryTextField.text ?? "")
                URL:\(websiteURLTextField.text ?? "")
                END:VCARD
                """
            
            let sanitizedText = sanitizeTurkishCharacters(vCardString)
            // QR kodunu oluştur
            if let qrCode = GenerateAndDesign.generate(from: sanitizedText) {
                // QR kodunu image view'e ekle
                imageView.image = qrCode
                designButtonOutlet.isHidden = false
                saveButtonOutlet.isHidden = false
                downloadButtonOutlet.isHidden = false
            }
        }
    }
    
    @IBAction func designButton(_ sender: Any) {
        AdManager.shared.loadInterstitialAd(adUnitID: Ads.interstitialAdUnitID)
        AdManager.shared.showInterstitialAd(from: self)
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
    
    func textFieledBorder(){
        // Çerçeve ayarları
        nameTextField.layer.borderColor = UIColor.lightGray.cgColor
        nameTextField.layer.borderWidth = 1.0
        nameTextField.layer.cornerRadius = 10.0
        nameTextField.layer.masksToBounds = true
        let placeholderText = "Name"
        let placeholderColor = UIColor.gray
        nameTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
        // Çerçeve ayarları
        surnameTextField.layer.borderColor = UIColor.lightGray.cgColor
        surnameTextField.layer.borderWidth = 1.0
        surnameTextField.layer.cornerRadius = 10.0
        surnameTextField.layer.masksToBounds = true
        let placeholderText2 = "Surname"
        surnameTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText2,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
        // Çerçeve ayarları
        websiteURLTextField.layer.borderColor = UIColor.lightGray.cgColor
        websiteURLTextField.layer.borderWidth = 1.0
        websiteURLTextField.layer.cornerRadius = 10.0
        websiteURLTextField.layer.masksToBounds = true
        let placeholderText3 = "www.your-website.com"
        websiteURLTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText3,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
        // Çerçeve ayarları
        mobileTextField.layer.borderColor = UIColor.lightGray.cgColor
        mobileTextField.layer.borderWidth = 1.0
        mobileTextField.layer.cornerRadius = 10.0
        mobileTextField.layer.masksToBounds = true
        let placeholderText4 = "Mobile"
        mobileTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText4,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
        // Çerçeve ayarları
        phoneTextField.layer.borderColor = UIColor.lightGray.cgColor
        phoneTextField.layer.borderWidth = 1.0
        phoneTextField.layer.cornerRadius = 10.0
        phoneTextField.layer.masksToBounds = true
        let placeholderText5 = "Phone"
        phoneTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText5,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
        // Çerçeve ayarları
        faxTextField.layer.borderColor = UIColor.lightGray.cgColor
        faxTextField.layer.borderWidth = 1.0
        faxTextField.layer.cornerRadius = 10.0
        faxTextField.layer.masksToBounds = true
        let placeholderText6 = "Fax"
        faxTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText6,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
        // Çerçeve ayarları
        emailTextField.layer.borderColor = UIColor.lightGray.cgColor
        emailTextField.layer.borderWidth = 1.0
        emailTextField.layer.cornerRadius = 10.0
        emailTextField.layer.masksToBounds = true
        let placeholderText7 = "your@email.com"
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText7,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
        // Çerçeve ayarları
        companyTextField.layer.borderColor = UIColor.lightGray.cgColor
        companyTextField.layer.borderWidth = 1.0
        companyTextField.layer.cornerRadius = 10.0
        companyTextField.layer.masksToBounds = true
        let placeholderText8 = "Company"
        companyTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText8,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
        // Çerçeve ayarları
        jobTextField.layer.borderColor = UIColor.lightGray.cgColor
        jobTextField.layer.borderWidth = 1.0
        jobTextField.layer.cornerRadius = 10.0
        jobTextField.layer.masksToBounds = true
        let placeholderText9 = "Your Job"
        jobTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText9,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
        // Çerçeve ayarları
        streetTextField.layer.borderColor = UIColor.lightGray.cgColor
        streetTextField.layer.borderWidth = 1.0
        streetTextField.layer.cornerRadius = 10.0
        streetTextField.layer.masksToBounds = true
        let placeholderText10 = "Street"
        streetTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText10,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
        // Çerçeve ayarları
        cityTextField.layer.borderColor = UIColor.lightGray.cgColor
        cityTextField.layer.borderWidth = 1.0
        cityTextField.layer.cornerRadius = 10.0
        cityTextField.layer.masksToBounds = true
        let placeholderText11 = "City"
        cityTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText11,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
        // Çerçeve ayarları
        zipTextField.layer.borderColor = UIColor.lightGray.cgColor
        zipTextField.layer.borderWidth = 1.0
        zipTextField.layer.cornerRadius = 10.0
        zipTextField.layer.masksToBounds = true
        let placeholderText12 = "ZIP"
        zipTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText12,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
        // Çerçeve ayarları
        stateTextField.layer.borderColor = UIColor.lightGray.cgColor
        stateTextField.layer.borderWidth = 1.0
        stateTextField.layer.cornerRadius = 10.0
        stateTextField.layer.masksToBounds = true
        let placeholderText13 = "State"
        stateTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText13,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
        // Çerçeve ayarları
        countryTextField.layer.borderColor = UIColor.lightGray.cgColor
        countryTextField.layer.borderWidth = 1.0
        countryTextField.layer.cornerRadius = 10.0
        countryTextField.layer.masksToBounds = true
        let placeholderText14 = "Country"
        countryTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText14,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
    }
    
    
}

