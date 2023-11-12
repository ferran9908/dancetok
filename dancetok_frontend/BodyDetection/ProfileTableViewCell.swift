//
//  ProfileTableViewCell.swift
//  BodyDetection
//
//  Created by Kewal Kishan Gokuldas on 11/11/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var danceLabel: UILabel!
    @IBOutlet weak var danceDate: UILabel!
    @IBOutlet weak var dancerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
