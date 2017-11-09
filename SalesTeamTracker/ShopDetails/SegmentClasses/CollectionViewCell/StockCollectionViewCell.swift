//
//  StockCollectionViewCell.swift
//  SalesTeamTracker
//
//  Created by Jeyavijay on 08/11/17.
//  Copyright © 2017 Pluggdd Mobile OPC Private Limited. All rights reserved.
//

import UIKit

class StockCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageViewProductImage: UIImageView!
    @IBOutlet var labelCountValues: UILabel!
    @IBOutlet var labelProductName: UILabel!
    @IBOutlet var buttonIncrement: UIButton!
    @IBOutlet var buttonDecrement: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        CodeReuser().viewCircular(circleView: self.labelCountValues)
        CodeReuser().viewCircular(circleView: self.buttonIncrement)
        CodeReuser().viewCircular(circleView: self.buttonDecrement)

    }

}
