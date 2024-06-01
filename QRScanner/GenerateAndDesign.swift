import UIKit
import SwiftUI


class GenerateAndDesign {
    /*
    static func generate(from string: String) -> UIImage? {
            let data = string.data(using: String.Encoding.ascii)
            if let filter = CIFilter(name: "CIQRCodeGenerator") {
                filter.setValue(data, forKey: "inputMessage")
                let transform = CGAffineTransform(scaleX: 10, y: 10)

                if let output = filter.outputImage?.transformed(by: transform) {
                    return UIImage(ciImage: output)
                }
            }
            return nil
    }
    */
    static func generate(from string: String, foregroundColor: UIColor = .black, backgroundColor: UIColor = .white) -> UIImage? {
        let data = string.data(using: .ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                let coloredOutput = output.applyingFilter("CIFalseColor", parameters: ["inputColor0": CIColor(cgColor: foregroundColor.cgColor), "inputColor1": CIColor(cgColor: backgroundColor.cgColor)])
                
                if let cgImage = CIContext().createCGImage(coloredOutput, from: coloredOutput.extent) {
                    let uiImage = UIImage(cgImage: cgImage)
                    // Convert UIImage to Data with JPG representation
                    if let jpgData = uiImage.jpegData(compressionQuality: 1.0) {
                        // Create UIImage from JPG Data
                        return UIImage(data: jpgData)
                    }
                }
            }
        }
        
        return nil
    
    }
    
    
    static func generateIcon(withIcon icon: UIImage, from string: String, foregroundColor: UIColor = .black, backgroundColor: UIColor = .white) -> UIImage? {
        let data = string.data(using: .ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                let coloredOutput = output.applyingFilter("CIFalseColor", parameters: ["inputColor0": CIColor(cgColor: foregroundColor.cgColor), "inputColor1": CIColor(cgColor: backgroundColor.cgColor)])
                
                if let cgImage = CIContext().createCGImage(coloredOutput, from: coloredOutput.extent) {
                    let qrImage = UIImage(cgImage: cgImage)
                    
                    // Calculate the center position for the icon
                    let iconSize = CGSize(width: qrImage.size.width / 4, height: qrImage.size.height / 4)
                    let center = CGPoint(x: qrImage.size.width / 2 - iconSize.width / 2, y: qrImage.size.height / 2 - iconSize.height / 2)
                    let iconRect = CGRect(origin: center, size: iconSize)
                    
                    // Draw QR code and icon
                    UIGraphicsBeginImageContextWithOptions(qrImage.size, false, UIScreen.main.scale)
                    qrImage.draw(in: CGRect(origin: .zero, size: qrImage.size))
                    
                    // Draw a frame around the icon
                    let frameSize = CGSize(width: iconSize.width + 10, height: iconSize.height + 10)
                    let frameOrigin = CGPoint(x: iconRect.origin.x - 5, y: iconRect.origin.y - 5)
                    let frameRect = CGRect(origin: frameOrigin, size: frameSize)
                    backgroundColor.setFill() // Set background color
                    UIRectFill(frameRect) // Fill the frame with background color
                    
                    // Draw the frame
                    UIColor.white.setStroke()
                    UIBezierPath(rect: frameRect).stroke()
                    
                    icon.draw(in: iconRect)
                    
                    // Get the merged image
                    let mergedImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    return mergedImage
                }
            }
        }
        
        return nil
    }
   
    
}
    
    
    
    
    
    
    
    


