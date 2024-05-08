//
//  ProfilViewController.swift
//  QRScanner
//
//  Created by islam kirenli on 28.04.2024.
//

import UIKit
import FirebaseAuth

class ProfilViewController: UIViewController {
    
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var signOutButtonOutlet: UIButton!
    @IBOutlet weak var signInButtonOutlet: UIButton!
    
    let currentUser = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if currentUser != nil{
            signInButtonOutlet.isHidden = true
            signOutButtonOutlet.isHidden = false
            userEmailLabel.text = currentUser?.email
        }else{
            signOutButtonOutlet.isHidden = true
            signInButtonOutlet.isHidden = false
            userEmailLabel.text = "özellikleri kullanabilmek için giriş yapın."
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
