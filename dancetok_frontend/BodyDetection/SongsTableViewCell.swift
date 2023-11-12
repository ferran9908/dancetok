//
//  SongsTableViewCell.swift
//  BodyDetection
//
//  Created by Kewal Kishan Gokuldas on 11/12/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import UIKit

class SongsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
