//
//  MakerViewController.swift
//  QRScanner
//
//  Created by islam kirenli on 20.04.2024.
//

import UIKit

class MakerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let QRCodeChoises = ["URL", "TEXT", "E-MAIL", "VCARD", "WIFI", "TWITTER", "FACEBOOK", "INSTAGRAM", "PDF", "MP3", "IMAGE"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return QRCodeChoises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = QRCodeChoises[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if QRCodeChoises[indexPath.row] == "URL"{
            performSegue(withIdentifier: "toURLMakerVC", sender: nil)
        }else if QRCodeChoises[indexPath.row] == "TEXT"{
            performSegue(withIdentifier: "toTextMakerVC", sender: nil)
        }else if QRCodeChoises[indexPath.row] == "E-MAIL"{
            performSegue(withIdentifier: "toEmailMakerVC", sender: nil)
        }else if QRCodeChoises[indexPath.row] == "VCARD"{
            performSegue(withIdentifier: "toVcardMakerVC", sender: nil)
        }
        
    }
    

}
