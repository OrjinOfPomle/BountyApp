//
//  CommentsTableViewCell.swift
//  Bounty
//
//  Created by Keleabe M. on 6/9/20.
//  Copyright © 2020 FireflyGlobe. All rights reserved.
//

import UIKit
import Kingfisher

protocol CommentCellDelegate : class {
    func contributedToComment(comment : Comment)
}

class CommentsTableViewCell: UITableViewCell {


    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var commentImage: UIImageView!
    @IBOutlet weak var deadline: UILabel!
    @IBOutlet weak var PatronCount: UILabel!
    @IBOutlet weak var commentLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    private var comment : Comment!
    weak var delegate : CommentCellDelegate?
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCommentCell (comment : Comment, delegate : CommentCellDelegate){
        self.comment = comment
        self.delegate = delegate
        
        userName.text = comment.UserName
        PatronCount.text = "Patrons: " + (comment.DonorCount.withCommas())

        commentImage.layer.cornerRadius = commentImage.frame.size.width/2
           
        commentLable.text = comment.Comment
        deadline.text = "Expires in: 43d"
           
        if let url = URL(string: comment.Image){
               // rounds the corners of the link image
               //let processor = RoundCornerImageProcessor(cornerRadius: 20)
               //ExploreImage.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)])
               commentImage.kf.setImage(with: url)
           }
           
       }
    
    @IBAction func contributeClicked(_ sender: Any) {
        delegate?.contributedToComment(comment: comment)
        
    }

}

