//
//  ExistingChannelCell.swift
//  ChatChat
//
//  Created by Doan Tuan on 5/7/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit

class ExistingChannelCell: UITableViewCell {

    @IBOutlet weak var avartarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        self.avartarImageView.layer.masksToBounds = true
        self.avartarImageView.layer.cornerRadius = self.avartarImageView.frame.width * 0.5
    }
    
    
    func configChannel(channel: Channel) {
        self.nameLabel?.text        = channel.name
        self.lastMessageLabel.text  = channel.lastMessage
        self.avartarImageView?.sd_setImage(with: URL(string: channel.receiveUrlImage), placeholderImage: UIImage(named: ""), options: [.refreshCached], progress: nil, completed: nil)
    }
}
