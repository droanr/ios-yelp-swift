//
//  BusinessCell.swift
//  Yelp
//
//  Created by drishi on 9/21/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!

    var business: Business! {
        didSet {
            nameLabel.text = business.name
            reviewLabel.text = (business.reviewCount?.stringValue)! + " Reviews"
            thumbImageView.setImageWith(business.imageURL!)
            categoriesLabel.text = business.categories
            addressLabel.text = business.address
            ratingImageView.setImageWith(business.ratingImageURL!)
            distanceLabel.text = business.distance
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        thumbImageView.layer.cornerRadius = 4
        thumbImageView.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
