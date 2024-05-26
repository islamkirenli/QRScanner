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
    
    var bannerView: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeKapat))
        view.addGestureRecognizer(gestureRecognizer)
        
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
            Alerts.showAlert2Button(title: "Uyarı", message: "Kaydetme özelliğini kullanabilmek için kullanıcı girişi yapmanız gerekmektedir.", buttonTitle: "Giriş Yap", viewController: self) {
                self.performSegue(withIdentifier: "toLogInVC", sender: nil)
            }
        }
    }
    
    @IBAction func designButton(_ sender: Any) {
        performSegue(withIdentifier: "toDesignVC", sender: nil)
    }
    
    
    @IBAction func generateQRCodeButtonTapped(_ sender: Any) {
        guard let ssid = ssidTextField.text, !ssid.isEmpty else {
            Alerts.showAlert(title: "Uyarı", message: "Wifi adını girin.", viewController: self)
            return
        }

        guard let code = passwordTextField.text, !code.isEmpty else {
            Alerts.showAlert(title: "Uyarı", message: "Şifre girin.", viewController: self)
            return
        }

        if let qrImage = WifiQR(name: ssid, password: code, size: 100) {
            imageView.image = qrImage
            designButtonOutlet.isHidden = false
            saveButtonOutlet.isHidden = false
            downloadButtonOutlet.isHidden = false
        } else {
            Alerts.showAlert(title: "Hata!", message: "QR kodu oluşturulamadı.", viewController: self)
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

