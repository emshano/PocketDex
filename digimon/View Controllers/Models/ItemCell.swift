//
//  ItemCell.swift
//  digimon
//
//  Created by Emira Hajj on 4/14/21.
//

import UIKit

class ItemCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var itemImage2: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
