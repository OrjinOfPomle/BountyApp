//
//  ExploreTableViewCell.swift
//  Bounty
//
//  Created by Keleabe M. on 6/7/20.
//  Copyright © 2020 FireflyGlobe. All rights reserved.
//

import UIKit
import Kingfisher

class ExploreTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ExploreImage: UIImageView!
    @IBOutlet weak var subCount: UILabel!
    @IBOutlet weak var ChannelName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configureExploreCell (channelInfo : ChannelInfo){
        subCount.text = (channelInfo.followerCount.withCommas() ) + " Subscribers"
        ChannelName.text = channelInfo.channelName
        ExploreImage.layer.cornerRadius = ExploreImage.frame.size.width/2
        
        
        
        if let url = URL(string: channelInfo.image){
            // rounds the corners of the link image
            //let processor = RoundCornerImageProcessor(cornerRadius: 20)
            //ExploreImage.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)])
            ExploreImage.kf.setImage(with: url)
        }
        
    }

}
