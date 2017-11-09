//
//  AssignmentsTableViewCell.swift
//  SalesTeamTracker
//
//  Created by Jeyavijay on 27/10/17.
//  Copyright © 2017 Pluggdd Mobile OPC Private Limited. All rights reserved.
//

import UIKit

class AssignmentsTableViewCell: UITableViewCell {

    @IBOutlet var buttonCall: UIButton!
    @IBOutlet var buttonMap: UIButton!
    @IBOutlet var SwitchLocation: UISwitch!
    @IBOutlet var labelCity: UILabel!
    @IBOutlet var labelStreetName: UILabel!
    @IBOutlet var labelShopName: UILabel!
    @IBOutlet var imageViewShops: UIImageView!
    @IBOutlet var viewCardView: UIView!
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
        labelStreetName.sizeToFit()
        labelStreetName.frame = CGRect(x: labelStreetName.frame.origin.x, y: labelStreetName.frame.origin.y, width: labelShopName.frame.width, height: labelStreetName.frame.height)

        
        SwitchLocation.frame = CGRect(x: SwitchLocation.frame.origin.x, y: buttonMap.frame.origin.y, width: SwitchLocation.frame.width, height: SwitchLocation.frame.height)
        CodeReuser().viewCircular(circleView: self.buttonMap)
        CodeReuser().viewCircular(circleView: self.buttonCall)
        self.viewCardView.setCardView(shadowView: self.viewCardView)
    }
    
}
