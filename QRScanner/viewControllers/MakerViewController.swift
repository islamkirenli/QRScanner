//
//  MakerViewController.swift
//  QRScanner
//
//  Created by islam kirenli on 20.04.2024.
//

import UIKit
import FirebaseAuth
import GoogleMobileAds

class MakerViewController: UIViewController{
    
    let guncelKullanici = Auth.auth().currentUser
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AdManager.shared.setupBannerAd(viewController: self, adUnitID: Ads.bannerAdUnitID)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AdManager.shared.invalidateTimer()
    }
    
    @IBAction func urlButton(_ sender: Any) {
        performSegue(withIdentifier: "toURLMakerVC", sender: nil)
    }
    @IBAction func textButton(_ sender: Any) {
        performSegue(withIdentifier: "toTextMakerVC", sender: nil)
    }
    @IBAction func emailButton(_ sender: Any) {
        performSegue(withIdentifier: "toEmailMakerVC", sender: nil)
    }
    @IBAction func vcardButton(_ sender: Any) {
        performSegue(withIdentifier: "toVcardMakerVC", sender: nil)
    }
    @IBAction func wifiButton(_ sender: Any) {
        performSegue(withIdentifier: "toWIFIMakerVC", sender: nil)
    }
    @IBAction func socialMedyaButton(_ sender: Any) {
        performSegue(withIdentifier: "toSocialMediaMakerVC", sender: nil)
    }
    @IBAction func documentButton(_ sender: Any) {
        if guncelKullanici != nil{
            performSegue(withIdentifier: "toPDFMakerVC", sender: nil)
        }else{
            performSegue(withIdentifier: "toLogInVC", sender: nil)
        }
    }
    @IBAction func imageButton(_ sender: Any) {
        if guncelKullanici != nil{
            performSegue(withIdentifier: "toImageMakerVC", sender: nil)
        }else{
            performSegue(withIdentifier: "toLogInVC", sender: nil)
        }
    }
    @IBAction func appsButton(_ sender: Any) {
        performSegue(withIdentifier: "toAppsMakerVC", sender: nil)
    }
    
    
}
