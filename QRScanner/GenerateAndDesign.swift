import UIKit

class GenerateAndDesign {
    
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
    
    
    static func applyColor(to image: CIImage?, foregroundColor: CIColor, backgroundColor: CIColor) -> CIImage? {
        guard let image = image else { return nil }
        let colorFilter = CIFilter(name: "CIFalseColor")
        colorFilter?.setValue(image, forKey: "inputImage")
        colorFilter?.setValue(foregroundColor, forKey: "inputColor0")
        colorFilter?.setValue(backgroundColor, forKey: "inputColor1")
        return colorFilter?.outputImage
    }
    
    static func resize(_ image: CIImage?, withSize size: CGSize) -> UIImage? {
        guard let image = image else { return nil }
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(image, from: image.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    
    static func addLogo(to image: UIImage, logo: UIImage, scale: CGFloat = 0.25) -> UIImage? {
        let imageSize = image.size
        let logoSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: imageSize))
        logo.draw(in: CGRect(x: (imageSize.width - logoSize.width) / 2.0,
                             y: (imageSize.height - logoSize.height) / 2.0,
                             width: logoSize.width,
                             height: logoSize.height))
        
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return combinedImage
    }
}

