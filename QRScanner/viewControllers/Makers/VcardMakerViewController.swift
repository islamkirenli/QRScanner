import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
    
    @IBAction func generateQRCode(_ sender: Any) {
        let vCardString = """
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
        // QR kodunu oluştur
        if let qrCode = GenerateAndDesign.generate(from: vCardString) {
            // QR kodunu image view'e ekle
            imageView.image = qrCode
            saveButtonOutlet.isHidden = false
        }
    }
    
    @IBAction func designButton(_ sender: Any) {
    }
    
    
}

