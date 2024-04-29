//
//  SaveViewController.swift
//  QRScanner
//
//  Created by islam kirenli on 29.04.2024.
//

import UIKit

class SaveViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var receivedImage : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.image = receivedImage
        
        
    }
    
    @IBAction func saveButton(_ sender: Any) {
    }
    
    

}
