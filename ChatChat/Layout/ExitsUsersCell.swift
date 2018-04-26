//
//  ExitsUsersCell.swift
//  ChatChat
//
//  Created by Doan Tuan on 4/27/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit
import SDWebImage

class ExitsUsersCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        self.avatarImageView.layer.masksToBounds = true
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.width * 0.5
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUserInfo(user: User) {
        if let name = user.fullName {
            self.nameLabel?.text  = name
        }
        
        if let email = user.email {
            self.emailLabel?.text = email
        }
        
        if let url = user.urlImage {
            self.avatarImageView?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: ""), options: [.refreshCached], progress: nil, completed: nil)
        }
    }
    
}
