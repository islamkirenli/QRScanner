import UIKit

class EmailMakerViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextView!
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
    
    @IBAction func generateQRCodeButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty else {
            // Kullanıcı e-posta adresi girmeden butona tıklarsa hata mesajı gösterin
            showAlert(message: "Lütfen bir e-posta adresi girin")
            return
        }
        
        // Konuyu ve mesajı kullanıcıdan alın
        let subject = subjectTextField.text ?? ""
        let message = messageTextField.text ?? ""
        
        // QR kodu oluşturmak için e-posta adresi, konu ve mesajı birleştir
        let emailString = "mailto:\(email)?subject=\(subject)&body=\(message)"
        
        let sanitizedText = sanitizeTurkishCharacters(emailString)
        
        if let qrCodeImage = GenerateAndDesign.generate(from: sanitizedText) {
            // Oluşturulan QR kodunu imageView'a atayın
            imageView.image = qrCodeImage
            saveButtonOutlet.isHidden = false
        } else {
            // QR kodu oluşturulamazsa hata mesajı gösterin
            showAlert(message: "QR kodu oluşturulamadı")
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
    


    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

