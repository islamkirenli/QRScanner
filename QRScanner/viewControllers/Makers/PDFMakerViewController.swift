import UIKit
import PDFKit

class PDFMakerViewController: UIViewController, UIDocumentPickerDelegate {

    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    var selectedPDFURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    @IBAction func selectPDFButtonTapped(_ sender: Any) {
        
                let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
                documentPicker.delegate = self
                documentPicker.allowsMultipleSelection = false
                self.present(documentPicker, animated: true, completion: nil)
            
    }
    
    @IBAction func designButton(_ sender: Any) {
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
                    qrCodeImageView.image = qrCodeImage
                } else {
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
}

