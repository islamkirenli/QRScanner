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
    
    let firestoreDB = Firestore.firestore()
    
    let currentUser = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        firebaseVerileriAl()
    }
    
    func firebaseVerileriAl(){
        if let currentUserEmail = currentUser?.email{
            firestoreDB.collection("QRCodes").whereField("email", isEqualTo: currentUserEmail)
                .order(by: "tarih", descending: true) 
                .addSnapshotListener { (snapshot, error) in
                if error != nil{
                    self.showAlert(message: error?.localizedDescription ?? "hata var.")
                }else{
                    if snapshot?.isEmpty != true && snapshot != nil{
                        
                        self.emailDizisi.removeAll(keepingCapacity: false)
                        self.gorselURLDizisi.removeAll(keepingCapacity: false)
                        self.titleDizisi.removeAll(keepingCapacity: false)
                        
                        for document in snapshot!.documents{
                            
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
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Sil") { [weak self] (_, _, completionHandler) in
            // Silme işlemini gerçekleştir
            self?.deleteItem(at: indexPath)
            completionHandler(true)
        }
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfiguration
    }

    func deleteItem(at indexPath: IndexPath) {
        
        firestoreDB.collection("QRCodes").whereField("gorselurl", isEqualTo: self.gorselURLDizisi[indexPath.row])
            .addSnapshotListener { (snapshot, error) in
            if error != nil{
                self.showAlert(message: error?.localizedDescription ?? "hata var.")
            }else{
                if snapshot?.isEmpty != true && snapshot != nil{
                    for document in snapshot!.documents{
                        let documentID = document.documentID
                        
                        let documentRef = self.firestoreDB.collection("QRCodes").document(documentID)
                        
                        documentRef.delete { error in
                            if error != nil{
                                self.showAlert(message: error?.localizedDescription ?? "silinirken hata alındı.")
                            }else{
                                self.showAlert(message: "başarıyla silindi.")
                            }
                        }
                    }
                }
            }
        }
        
        self.titleDizisi.remove(at: indexPath.row)
        self.gorselURLDizisi.remove(at: indexPath.row)
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }


    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let shareAction = UIContextualAction(style: .normal, title: "Paylaş") { (_, _, completionHandler) in
            // Paylaşma işlemini gerçekleştir
            // Örneğin: self.shareItem(at: indexPath)
            completionHandler(true)
        }
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [shareAction])
        return swipeConfiguration
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
