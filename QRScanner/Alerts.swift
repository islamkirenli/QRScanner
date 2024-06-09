import UIKit

class Alerts {
    
    static func showAlert2Button(title: String, message: String, buttonTitle: String, viewController: UIViewController, action: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add custom action button
        let customAction = UIAlertAction(title: buttonTitle, style: .default) { _ in
            // Call action block if provided
            action?()
        }
        alertController.addAction(customAction)
        
        // Add OK button
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cancelAction)
        
        // Show alert
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    static func showAlert(title: String, message: String, viewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
}

