//
//  CommentsTableViewCell.swift
//  SalesTeamTracker
//
//  Created by Jeyavijay on 09/11/17.
//  Copyright © 2017 Pluggdd Mobile OPC Private Limited. All rights reserved.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {

    @IBOutlet var labelDate: UILabel!
    @IBOutlet var textViewMessage: UITextView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var imageViewUserImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
