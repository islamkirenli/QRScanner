import UIKit
import PDFKit

class PDFMakerViewController: UIViewController, UIDocumentPickerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    @IBOutlet weak var downloadButtonOutlet: UIButton!
    
    var selectedPDFURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        saveButtonOutlet.isHidden = true
        downloadButtonOutlet.isHidden = true
    }

    
    @IBAction func selectPDFButtonTapped(_ sender: Any) {
        
                let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
                documentPicker.delegate = self
                documentPicker.allowsMultipleSelection = false
                self.present(documentPicker, animated: true, completion: nil)
            
    }
    
    @IBAction func designButton(_ sender: Any) {
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
        guard let pdfURL = selectedPDFURL else {
                    showAlert(message: "Lütfen bir PDF dosyası seçin.")
                    return
                }

                guard let pdfDocument = PDFDocument(url: pdfURL) else {
                    showAlert(message: "Seçilen dosya açılamadı.")
                    return
                }

                // PDF'den metin verisi al
                var pdfText = ""
                for pageIndex in 0..<pdfDocument.pageCount {
                    if let page = pdfDocument.page(at: pageIndex) {
                        if let pageText = page.string {
                            pdfText += pageText
                        }
                    }
                }

                // Metin verisinden QR kodu oluştur
        if let qrCodeImage = GenerateAndDesign.generate(from: pdfText) {
            imageView.image = qrCodeImage
            saveButtonOutlet.isHidden = false
            downloadButtonOutlet.isHidden = false
        }else{
            showAlert(message: "QR kodu oluşturulamadı.")
        }
    }
    

    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else { return }
        selectedPDFURL = selectedURL
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

