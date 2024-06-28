//
//  DesignViewController.swift
//  QRScanner
//
//  Created by islam kirenli on 20.04.2024.
//

import UIKit
import GoogleMobileAds
import FirebaseAuth

class DesignViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, IconSelectionDelegate, IconSelectionViewController.IconSelectionDelegate{
    
    @IBOutlet weak var foregroundColor: UIColorWell!
    @IBOutlet weak var backgroundColor: UIColorWell!
    @IBOutlet weak var designQRImage: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    var receivedImage : UIImage?
    var receivedText : String?
    var receivedURL : String?
    
    var isIconSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        foregroundColor.selectedColor = UIColor.black
        backgroundColor.selectedColor = UIColor.white
        
        designQRImage.image = receivedImage
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImageTapped))
        iconImageView.addGestureRecognizer(tapGesture)
        iconImageView.isUserInteractionEnabled = true
        
        AdManager.shared.setupBannerAd(viewController: self, adUnitID: Ads.bannerAdUnitID)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AdManager.shared.invalidateTimer()
    }
    
    func didSelectIcon(withName iconName: String) {
        iconImageView.image = UIImage(named: iconName)
        isIconSelected = true
    }
  
    
    @IBAction func iconsButton(_ sender: Any) {
        let iconSelectionVC = IconSelectionViewController()
        iconSelectionVC.delegate = self
        present(iconSelectionVC, animated: true, completion: nil)
    }
    
    @IBAction func olusturButton(_ sender: Any) {
        if let receivedText = receivedText {
            if isIconSelected == true{
                if let iconImage = iconImageView.image{
                    if let qrImage = GenerateAndDesign.generateIcon(withIcon: iconImage, from: receivedText, foregroundColor: foregroundColor.selectedColor!, backgroundColor: backgroundColor.selectedColor!){
                        designQRImage.image = qrImage
                    }
                }
            }
            else{
                if let qrImage = GenerateAndDesign.generate(from: receivedText, foregroundColor: foregroundColor.selectedColor!, backgroundColor: backgroundColor.selectedColor!){
                    designQRImage.image = qrImage
                }
            }
            
        }
    }
    
    @objc func selectImageTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
        isIconSelected = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            iconImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func downloadButton(_ sender: Any) {
        saveImage()
    }
    
    @objc func saveImage() {
        if let pickedImage = designQRImage.image {
            UIImageWriteToSavedPhotosAlbum(pickedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc func image (_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save Error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        if Auth.auth().currentUser != nil{
            performSegue(withIdentifier: "toSaveVC", sender: nil)
        }else{
            Alerts.showAlert2Button(title: "Alert", message: "You need to log in to use the save feature.", buttonTitle: "Log In", viewController: self) {
                self.performSegue(withIdentifier: "toLogInVC", sender: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSaveVC" {
            if let destinationVC = segue.destination as? SaveViewController {
                destinationVC.receivedImage = designQRImage.image
            }
        }
    }
    
}


