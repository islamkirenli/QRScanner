//
//  ProfilViewController.swift
//  QRScanner
//
//  Created by islam kirenli on 28.04.2024.
//

import UIKit
import FirebaseAuth

class ProfilViewController: UIViewController {
    
    let guncelKullanici = Auth.auth().currentUser

    @IBOutlet weak var signOutButtonOutlet: UIButton!
    @IBOutlet weak var signInButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if guncelKullanici != nil{
            signInButtonOutlet.isHidden = true
            signOutButtonOutlet.isHidden = false
        }else{
            signOutButtonOutlet.isHidden = true
            signInButtonOutlet.isHidden = false
        }
        
    }
    

    @IBAction func signOutButton(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            performSegue(withIdentifier: "toLogInVC", sender: nil)
        }catch{
            print("hata var.")
        }
    }
    
    @IBAction func signInButton(_ sender: Any) {
        performSegue(withIdentifier: "toLogInVC", sender: nil)
    }
    
}
