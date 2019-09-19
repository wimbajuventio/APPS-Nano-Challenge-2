//
//  TableViewCell.swift
//  APPS Nano Challenge 2
//
//  Created by Wimba Juventio Chandra on 19/09/19.
//  Copyright © 2019 Wimba Juventio Chandra. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var historyText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
