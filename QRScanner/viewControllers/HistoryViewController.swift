//
//  HistoryViewController.swift
//  QRScanner
//
//  Created by islam kirenli on 23.04.2024.
//

import UIKit
import FirebaseFirestore
import SDWebImage
import FirebaseAuth

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var gorselURLDizisi = [String]()
    var titleDizisi = [String]()
    var emailDizisi = [String]()
    
    var secilenTitle = ""
    var secilenGorselUrl = ""
    
    let currentUser = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        firebaseVerileriAl()
    }
    
    func firebaseVerileriAl(){
        let firestoreDB = Firestore.firestore()
        if let currentUserEmail = currentUser?.email{
            firestoreDB.collection("QRCodes").whereField("email", isEqualTo: currentUserEmail)
                //.order(by: "tarih", descending: true) 
                .addSnapshotListener { (snapshot, error) in
                if error != nil{
                    self.showAlert(message: error?.localizedDescription ?? "hata var.")
                }else{
                    if snapshot?.isEmpty != true && snapshot != nil{
                        
                        self.emailDizisi.removeAll(keepingCapacity: false)
                        self.gorselURLDizisi.removeAll(keepingCapacity: false)
                        self.titleDizisi.removeAll(keepingCapacity: false)
                        
                        for document in snapshot!.documents{
                            //let documentID = document.documentID
                            
                            if let gorselURL = document.get("gorselurl") as? String{
                                self.gorselURLDizisi.append(gorselURL)
                            }
                            
                            if let title = document.get("baslik") as? String{
                                self.titleDizisi.append(title)
                            }
                            
                            if let email = document.get("email") as? String{
                                self.emailDizisi.append(email)
                            }
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gorselURLDizisi.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
        cell.titleTextLabel.text = titleDizisi[indexPath.row]
        cell.qrImageView.sd_setImage(with: URL(string: self.gorselURLDizisi[indexPath.row]))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        secilenTitle = titleDizisi[indexPath.row]
        secilenGorselUrl = gorselURLDizisi[indexPath.row]
        performSegue(withIdentifier: "toShowHistoryVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toShowHistoryVC"{
            let destinationVC = segue.destination as! ShowHistoryViewController
            destinationVC.alinanTitle = secilenTitle
            destinationVC.alinanGorselURl = secilenGorselUrl
        }
    }
    
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    

}
