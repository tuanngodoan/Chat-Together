//
//  SearchUserViewController.swift
//  ChatChat
//
//  Created by Doan Tuan on 4/9/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit
import Firebase

enum Section: Int {
    case findUserByEmail = 0
    case currentUsersSection
}

class SearchUserTableViewController: UITableViewController {
    
    private var userRefHandle: FIRDatabaseHandle?
    private var channelRefHandle: FIRDatabaseHandle?
    private var users:[User] = []
    
    private lazy var userRef: FIRDatabaseReference = FIRDatabase.database().reference().child("users")
    private lazy var channelRef: FIRDatabaseReference = FIRDatabase.database().reference().child("chatHistory")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.observeUseres()
        registerCell()
    }
    
    deinit {
        if let refHandle = userRefHandle {
            userRef.removeObserver(withHandle: refHandle)
        }
        
        if let refHandle = channelRefHandle {
            channelRef.removeObserver(withHandle: refHandle)
        }
    }
    
    func registerCell() {
        self.tableView.register(UINib(nibName: "FindUserCell", bundle: nil), forCellReuseIdentifier: "FindUser")
        self.tableView.register(UINib(nibName: "ExitsUsersCell", bundle: nil), forCellReuseIdentifier: "ExitsUsers")
    }
    
    private func observeUseres() {
        // We can use the observe method to listen for new
        // channels being written to the Firebase DB
        userRefHandle = userRef.observe(.childAdded, with: { (snapshot) -> Void in
            let userData = snapshot.value as! Dictionary<String, AnyObject>
            let id = snapshot.key
            if let name = userData["userName"] as? String, id != AppConfig.USER_ID {
                guard let email = userData["email"] as? String else {return}
                guard let urlImage = userData["urlImageProfile"] as? String else {return}
                self.users.append(User(id: id, name: name, email: email, urlImage: urlImage))
                self.tableView.reloadData()
            }
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection: Section = Section(rawValue: section) {
            switch currentSection {
            case .findUserByEmail:
                return 1
            case .currentUsersSection:
                return users.count
            }
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = (indexPath as NSIndexPath).section == Section.findUserByEmail.rawValue ? "FindUser" : "ExitsUsers"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        if (indexPath as NSIndexPath).section == Section.findUserByEmail.rawValue {
            if let findUserCell = cell as? FindUserCell {
                return findUserCell
            }
        } else if (indexPath as NSIndexPath).section == Section.currentUsersSection.rawValue {
            if let exitsUsersCell = cell as? ExitsUsersCell {
                if users.count > 0 {
                    exitsUsersCell.setUserInfo(user: users[indexPath.row])
                    return exitsUsersCell
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = users[indexPath.row]
        
        createChannel(user: user)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func pushToChatVC(user: User, channelID: String) {
        if let chatVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
            
            guard let friendName = user.fullName else {return}
            guard let friendID  = user.userId else {return}
            let channel = Channel(id: channelID, name: friendName, receiveID: friendID)
            
            chatVC.channel = channel
            chatVC.senderDisplayName = AppConfig.USER_NAME
            chatVC.channelRef = self.channelRef.child(AppConfig.USER_ID).child(channelID)
            chatVC.channelFriendRef = self.channelRef.child(channel.receiveID).child(channelID)
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    
    
    func createChannel(user: User) {
        
        guard let friendID = user.userId     else {return}
        guard let friendName = user.fullName else {return}
        
        let channelID = "\(AppConfig.USER_ID)_\(friendID)"
        let channelIDReverse = ("\(friendID)_\(AppConfig.USER_ID)")
        
        
        
        if checkChannelIsExits(channelID: channelID, channelIDReverse: channelIDReverse) {
            guard let id = getChannelID(channelID: channelID, channelIDReverse: channelIDReverse) else {return}
            pushToChatVC(user: user, channelID: id)
            return
        }
        
        // with user
        let userRef = self.channelRef.child(AppConfig.USER_ID).child(channelID)
        userRef.setValue([Constant.receiveID : friendID, Constant.name : friendName]) { (error, firDataReference) in
            if error == nil {
                // with friend
                let friendRef = self.channelRef.child(friendID).child(channelID)
                friendRef.setValue([Constant.receiveID : AppConfig.USER_ID, Constant.name : AppConfig.USER_NAME], withCompletionBlock: { (error, firDataReference) in
                    if error == nil {
                        self.pushToChatVC(user: user, channelID: channelID)
                    }
                })
            }
        }
    }
    
    func getChannelID(channelID: String, channelIDReverse: String) -> String? {
        for channel in ChannelListViewController.channels {
            return channel.id == channelID ? channelID : channelIDReverse
        }
        return nil
    }
    
    func checkChannelIsExits(channelID: String, channelIDReverse: String) -> Bool {
        for channel in ChannelListViewController.channels {
            if channel.id == channelID || channel.id == channelIDReverse {
                return true
            }
        }
        return false
    }
}
