import UIKit
import FirebaseAuth
import GoogleMobileAds

class WIFIMakerViewController: UIViewController{

    @IBOutlet weak var ssidTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    @IBOutlet weak var downloadButtonOutlet: UIButton!
    @IBOutlet weak var designButtonOutlet: UIButton!
    
    var wifiString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Çerçeve ayarları
        ssidTextField.layer.borderColor = UIColor.lightGray.cgColor
        ssidTextField.layer.borderWidth = 1.0
        ssidTextField.layer.cornerRadius = 10.0
        ssidTextField.layer.masksToBounds = true
        let placeholderText = "Network Name"
        let placeholderColor = UIColor.gray
        ssidTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
        // Çerçeve ayarları
        passwordTextField.layer.borderColor = UIColor.lightGray.cgColor
        passwordTextField.layer.borderWidth = 1.0
        passwordTextField.layer.cornerRadius = 10.0
        passwordTextField.layer.masksToBounds = true
        let placeholderTextpassword = "Password"
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderTextpassword,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeKapat))
        view.addGestureRecognizer(gestureRecognizer)
        
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
                destinationVC.receivedText = wifiString
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
    
    @IBAction func designButton(_ sender: Any) {
        AdManager.shared.loadInterstitialAd(adUnitID: Ads.interstitialAdUnitID)
        AdManager.shared.showInterstitialAd(from: self)
        performSegue(withIdentifier: "toDesignVC", sender: nil)
    }
    
    
    @IBAction func generateQRCodeButtonTapped(_ sender: Any) {
        guard let ssid = ssidTextField.text, !ssid.isEmpty else {
            Alerts.showAlert(title: "Alert", message: "Enter the Wi-Fi name.", viewController: self)
            return
        }

        guard let code = passwordTextField.text, !code.isEmpty else {
            Alerts.showAlert(title: "Alert", message: "Enter the password.", viewController: self)
            return
        }

        if let qrImage = WifiQR(name: ssid, password: code, size: 100) {
            imageView.image = qrImage
            designButtonOutlet.isHidden = false
            saveButtonOutlet.isHidden = false
            downloadButtonOutlet.isHidden = false
        } else {
            Alerts.showAlert(title: "Error", message: "The QR code could not be generated.", viewController: self)
        }
    }
    
    func WifiQR(name ssid: String, password code: String, size: CGFloat = 10) -> UIImage? {
        wifiString = "WIFI:T:WPA;S:\(ssid);P:\(code);;"
        return GenerateAndDesign.generate(from: wifiString)
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

