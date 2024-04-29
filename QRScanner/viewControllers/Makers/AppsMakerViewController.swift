import UIKit

class AppsMakerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let appStores = ["App Store", "Google Play Store", "Amazon App Store"]
    var selectedAppStore: String?
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        pickerView.selectRow(0, inComponent: 0, animated: false)
        selectedAppStore = appStores[0]
        
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
                destinationVC.receivedImage = qrCodeImageView.image
            }
        }
    }
    
    @IBAction func saveButton(_ sender: Any) {
        performSegue(withIdentifier: "toSaveVC", sender: nil)
    }
    
    // UIPickerViewDataSource protocol methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return appStores.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return appStores[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedAppStore = appStores[row]
    }
    
    
    @IBAction func generateQRCodeButtonTapped(_ sender: Any) {
        guard let appId = idTextField.text, !appId.isEmpty else {
            showAlert(message: "Lütfen uygulama ID'sini girin.")
            return
        }
        
        guard let selectedAppStore = selectedAppStore else {
            showAlert(message: "Lütfen bir uygulama mağazası seçin.")
            return
        }
        
        // App Store URL oluşturma işlemi
        var appStoreURL = ""
        switch selectedAppStore {
        case "App Store":
            appStoreURL = "https://itunes.apple.com/app/id\(appId)"
        case "Google Play Store":
            appStoreURL = "https://play.google.com/store/apps/details?id=\(appId)"
        case "Amazon App Store":
            appStoreURL = "https://www.amazon.com/dp/\(appId)"
        default:
            break
        }
        
        // QR kodu oluşturma işlemi
        if let qrCodeImage = GenerateAndDesign.generate(from: appStoreURL) {
            qrCodeImageView.image = qrCodeImage
            saveButtonOutlet.isHidden = false
        } else {
            showAlert(message: "QR kodu oluşturulamadı.")
        }
    }
    
    @IBAction func designButton(_ sender: Any) {
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Uyarı", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

