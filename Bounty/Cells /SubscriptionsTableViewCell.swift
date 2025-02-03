//
//  SubscriptionsTableViewCell.swift
//  Bounty
//
//  Created by Keleabe M. on 6/8/20.
//  Copyright © 2020 FireflyGlobe. All rights reserved.
//

import UIKit
import Kingfisher

class SubscriptionsTableViewCell: UITableViewCell {

    @IBOutlet weak var subCount: UILabel!
    @IBOutlet weak var channelName: UILabel!
    @IBOutlet weak var SubImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureSubscriptionCell (channelInfo : ChannelInfo){
        subCount.text = (channelInfo.followerCount.withCommas() ) + " Subscribers"
        channelName.text = channelInfo.channelName
        SubImage.layer.cornerRadius = SubImage.frame.size.width/2
        
        
        
        if let url = URL(string: channelInfo.image){
            // rounds the corners of the link image
            //let processor = RoundCornerImageProcessor(cornerRadius: 20)
            //ExploreImage.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)])
            SubImage.kf.setImage(with: url)
        }
        
    }

}
