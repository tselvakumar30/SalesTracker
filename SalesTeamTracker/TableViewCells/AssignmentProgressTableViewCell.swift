//
//  AssignmentProgressTableViewCell.swift
//  SalesTeamTracker
//
//  Created by Jeyavijay on 27/10/17.
//  Copyright © 2017 Pluggdd Mobile OPC Private Limited. All rights reserved.
//

import UIKit

class AssignmentProgressTableViewCell: UITableViewCell {

    @IBOutlet var labelAddress: UILabel!
    @IBOutlet var labelDesignation: UILabel!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelProgress: UILabel!
    @IBOutlet var sliderProgress: UISlider!
    @IBOutlet var imageViewSalesProduct: UIImageView!
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
        CodeReuser().viewCircular(circleView: self.imageViewSalesProduct)
    }
    
}
