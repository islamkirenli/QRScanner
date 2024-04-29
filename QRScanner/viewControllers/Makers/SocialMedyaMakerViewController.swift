import UIKit

class SocialMedyaMakerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    
    let socialMediaPlatforms = ["Facebook", "Twitter", "Instagram"]
    var selectedSocialMediaPlatform: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        pickerView.dataSource = self
        pickerView.delegate = self
        
        selectedSocialMediaPlatform = socialMediaPlatforms[0]
        pickerView.selectRow(0, inComponent: 0, animated: false)
        
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return socialMediaPlatforms.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return socialMediaPlatforms[row]
    }

    // MARK: - UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedSocialMediaPlatform = socialMediaPlatforms[row]
    }
    
    
    @IBAction func designButton(_ sender: Any) {
    }
    
    @IBAction func generateQRCodeButtonTapped(_ sender: Any) {
        guard let socialMedia = selectedSocialMediaPlatform,
                let username = accountTextField.text,
                !username.isEmpty else {
            showAlert(message: "Lütfen bir sosyal medya platformu seçin ve bir kullanıcı adı girin.")
            return
        }

                let socialMediaURL = "https://www.\(socialMedia.lowercased()).com/\(username)"

        if let qrCodeImage = GenerateAndDesign.generate(from: socialMediaURL) {
            imageView.image = qrCodeImage
            saveButtonOutlet.isHidden = false
        }else{
            showAlert(message: "QR kodu oluşturulamadı")
        }
    }
    

    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

