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
    @IBOutlet var textViewMessage: UILabel!
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
       // textViewMessage.sizeToFit()
       // textViewMessage.lineBreakMode = .byWordWrapping
        imageViewUserImage.frame = CGRect(x: imageViewUserImage.frame.origin.x, y: imageViewUserImage.frame.origin.y, width: imageViewUserImage.frame.width, height: imageViewUserImage.frame.width)

    }
    
}
