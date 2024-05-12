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
    @IBOutlet weak var downloadButtonOutlet: UIButton!
    
    var vCardString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeKapat))
        view.addGestureRecognizer(gestureRecognizer)
        
        saveButtonOutlet.isHidden = true
        downloadButtonOutlet.isHidden = true
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
        performSegue(withIdentifier: "toSaveVC", sender: nil)
    }
    
    @IBAction func generateQRCode(_ sender: Any) {
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
        // QR kodunu oluştur
        if let qrCode = GenerateAndDesign.generate(from: vCardString) {
            // QR kodunu image view'e ekle
            imageView.image = qrCode
            
            saveButtonOutlet.isHidden = false
            downloadButtonOutlet.isHidden = false
        }
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

