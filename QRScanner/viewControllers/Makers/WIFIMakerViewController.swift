import UIKit


class WIFIMakerViewController: UIViewController{

    @IBOutlet weak var ssidTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeKapat))
        view.addGestureRecognizer(gestureRecognizer)
        
        saveButtonOutlet.isHidden = true
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
    }
    
    @IBAction func saveButton(_ sender: Any) {
        performSegue(withIdentifier: "toSaveVC", sender: nil)
    }
    
    @IBAction func designButton(_ sender: Any) {
    }
    
    
    @IBAction func generateQRCodeButtonTapped(_ sender: Any) {
        guard let ssid = ssidTextField.text, !ssid.isEmpty else {
            showAlert(message: "Please enter SSID")
            return
        }

        guard let code = passwordTextField.text, !code.isEmpty else {
            showAlert(message: "Please enter code")
            return
        }

        if let qrImage = WifiQR(name: ssid, password: code, size: 100) {
            imageView.image = qrImage
            saveButtonOutlet.isHidden = false
        } else {
            showAlert(message: "Failed to generate QR code")
        }
    }
    
    func WifiQR(name ssid: String, password code: String, size: CGFloat = 10) -> UIImage? {
        return GenerateAndDesign.generate(from: "WIFI:T:WPA;S:\(ssid);P:\(code);;")
    }
    
    func sanitizeTurkishCharacters(_ text: String) -> String {
            let turkishCharacters: [Character: Character] = ["ı": "i", "İ": "I", "ğ": "g", "Ğ": "G", "ü": "u", "Ü": "U", "ş": "s", "Ş": "S", "ö": "o", "Ö": "O", "ç": "c", "Ç": "C"]
            var sanitizedText = text
            for (turkishCharacter, asciiCharacter) in turkishCharacters {
                sanitizedText = sanitizedText.replacingOccurrences(of: String(turkishCharacter), with: String(asciiCharacter))
            }
            return sanitizedText
    }
    

    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

