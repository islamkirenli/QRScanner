import UIKit

class ImageMakerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var originalImageView: UIImageView!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    var selectedImageData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImageTapped))
        originalImageView.addGestureRecognizer(tapGesture)
        originalImageView.isUserInteractionEnabled = true
    }
    
    @objc func selectImageTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func generateQRTapped(_ sender: Any) {
        if let image = originalImageView.image {
            if let imageURL = saveImageToTemporaryDirectory(image: image) {
                if let qrCode = generateQRCode(from: imageURL) {
                    print(imageURL)
                    qrCodeImageView.image = qrCode
                } else {
                    print("Failed to generate QR code.")
                }
            } else {
                print("Error saving image to temporary directory.")
            }
        } else {
            print("Please select an image first.")
        }
    }
    
    func generateQRCode(from url: URL) -> UIImage? {
        let data = url.absoluteString.data(using: String.Encoding.ascii)
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        
        guard let ciImage = filter?.outputImage else { return nil }
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledCIImage = ciImage.transformed(by: transform)
        
        if let cgImage = CIContext().createCGImage(scaledCIImage, from: scaledCIImage.extent) {
            let qrCodeImage = UIImage(cgImage: cgImage)
            return qrCodeImage
        }
        
        return nil
    }
    
    func saveImageToTemporaryDirectory(image: UIImage) -> URL? {
        guard let imageData = image.jpegData(compressionQuality: 1) else {
            return nil
        }
        
        let fileName = "\(UUID().uuidString).jpg"
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
        let fileURL = temporaryDirectoryURL.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image to temporary directory: \(error.localizedDescription)")
            return nil
        }
    }


    
    
    @IBAction func designButton(_ sender: Any) {
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            originalImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Uyarı", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

/*
 import UIKit

 class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
     
     @IBOutlet weak var imageView: UIImageView!
     
     override func viewDidLoad() {
         super.viewDidLoad()
         // Do any additional setup after loading the view.
     }
     
     @IBAction func selectImage(_ sender: UIButton) {
         let imagePicker = UIImagePickerController()
         imagePicker.delegate = self
         imagePicker.sourceType = .photoLibrary
         present(imagePicker, animated: true, completion: nil)
     }
     
     @IBAction func generateQRCode(_ sender: UIButton) {
         if let image = imageView.image {
             if let qrCode = generateQRCode(from: image) {
                 imageView.image = qrCode
             }
         } else {
             print("Please select an image first.")
         }
     }
     
     func generateQRCode(from image: UIImage) -> UIImage? {
         guard let ciImage = CIImage(image: image) else { return nil }
         
         let context = CIContext()
         let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
         let features = detector?.features(in: ciImage)
         
         if let feature = features?.first as? CIQRCodeFeature {
             let transformedImage = createNonInterpolatedUIImage(from: feature.messageString ?? "", width: 200, height: 200)
             return transformedImage
         }
         
         return nil
     }
     
     func createNonInterpolatedUIImage(from string: String, width: CGFloat, height: CGFloat) -> UIImage? {
         let data = string.data(using: String.Encoding.ascii)
         
         if let filter = CIFilter(name: "CIQRCodeGenerator") {
             filter.setValue(data, forKey: "inputMessage")
             let transform = CGAffineTransform(scaleX: 10, y: 10)
             if let output = filter.outputImage?.transformed(by: transform) {
                 let context = CIContext()
                 if let cgImage = context.createCGImage(output, from: output.extent) {
                     UIGraphicsBeginImageContext(CGSize(width: width, height: height))
                     if let context = UIGraphicsGetCurrentContext() {
                         context.interpolationQuality = .none
                         context.draw(cgImage, in: context.boundingBoxOfClipPath)
                         if let cgImage = context.makeImage() {
                             let processedImage = UIImage(cgImage: cgImage)
                             UIGraphicsEndImageContext()
                             return processedImage
                         }
                     }
                 }
             }
         }
         
         return nil
     }
     
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         if let selectedImage = info[.originalImage] as? UIImage {
             imageView.image = selectedImage
         }
         dismiss(animated: true, completion: nil)
     }
     
     func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         dismiss(animated: true, completion: nil)
     }
 }

 */

