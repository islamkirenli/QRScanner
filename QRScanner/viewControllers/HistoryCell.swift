//
//  HistoryCell.swift
//  QRScanner
//
//  Created by islam kirenli on 4.05.2024.
//

import UIKit

class HistoryCell: UITableViewCell {

    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var titleTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
