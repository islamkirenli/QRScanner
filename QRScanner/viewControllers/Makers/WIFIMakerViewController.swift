import UIKit

class WIFIMakerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var ssidTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var encryptionTypePickerView: UIPickerView!
    @IBOutlet weak var imageView: UIImageView!
    
    
    var encryptionTypes = ["WPA / WPA2-Personal", "WEP", "WPA / WPA2-Enterprise"]
    var selectedEncryptionType: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        encryptionTypePickerView.delegate = self
        encryptionTypePickerView.dataSource = self
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeKapat))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func klavyeKapat(){
        view.endEditing(true)
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return encryptionTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return encryptionTypes[row]
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedEncryptionType = encryptionTypes[row]
    }
    
    
    @IBAction func designButton(_ sender: Any) {
    }
    
    
    @IBAction func generateQRCodeButtonTapped(_ sender: Any) {
        guard let ssid = ssidTextField.text, !ssid.isEmpty else {
            showAlert(message: "Lütfen bir SSID girin")
            return
        }
        
        guard let password = passwordTextField.text else {
            showAlert(message: "Lütfen bir şifre girin")
            return
        }
        
        guard let encryptionType = selectedEncryptionType else {
            showAlert(message: "Lütfen bir şifreleme türü seçin")
            return
        }
        
        let wifiInfo = "WIFI:S:\(ssid);T:\(encryptionType);P:\(password)"
        
        let sanitizedText = sanitizeTurkishCharacters(wifiInfo)
        
        if let qrCodeImage = GenerateAndDesign.generate(from: sanitizedText) {
            imageView.image = qrCodeImage
            print(sanitizedText)
        } else {
            showAlert(message: "QR kodu oluşturulamadı")
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
    

    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

