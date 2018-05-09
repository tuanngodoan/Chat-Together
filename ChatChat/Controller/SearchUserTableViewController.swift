//
//  SearchUserViewController.swift
//  ChatChat
//
//  Created by Doan Tuan on 4/9/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

enum Section: Int {
    case findUserByEmail = 0
    case currentUsersSection
}

class SearchUserTableViewController: UITableViewController, FindUserDelegate {
    
    private var userRefHandle: FIRDatabaseHandle?
    private var channelRefHandle: FIRDatabaseHandle?
    private var users:[User]        = []
    private var usersSearch:[User]  = []
    private var usersAll:[User]     = []
    private var isSearching: Bool = false
    
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
        var numberOfRows: Int = 0
        if let currentSection: Section = Section(rawValue: section) {
            switch currentSection {
            case .findUserByEmail:
                numberOfRows =  1
            case .currentUsersSection:
                if isSearching == true {
                    numberOfRows = usersSearch.count
                } else {
                    numberOfRows =  users.count
                }
            }
        }
        return numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = (indexPath as NSIndexPath).section == Section.findUserByEmail.rawValue ? "FindUser" : "ExitsUsers"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        if (indexPath as NSIndexPath).section == Section.findUserByEmail.rawValue {
            if let findUserCell = cell as? FindUserCell {
                findUserCell.findingUserDelegate = self
                return findUserCell
            }
        } else if (indexPath as NSIndexPath).section == Section.currentUsersSection.rawValue {
            if let exitsUsersCell = cell as? ExitsUsersCell {
                if isSearching == true {
                    if usersSearch.count > 0 {
                        exitsUsersCell.setUserInfo(user: usersSearch[indexPath.row])
                        return exitsUsersCell
                    }
                } else {
                    if users.count > 0 {
                        exitsUsersCell.setUserInfo(user: users[indexPath.row])
                        return exitsUsersCell
                    }
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var user:User?
        
        if isSearching == true {
           user = usersSearch[indexPath.row]
        } else {
           user = users[indexPath.row]
        }
        createChannel(user: user!)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func pushToChatVC(user: User, channelID: String) {
        if let chatVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
            
            guard let friendName = user.fullName else {return}
            guard let friendID  = user.userId else {return}
            guard let urlImage = user.urlImage else {return}
            let channel = Channel(id: channelID, name: friendName, receiveID: friendID, receiveUrlImage: urlImage, lastMessage: "")
            
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
        guard let urlImage = user.urlImage else {return}
        let lastMessage = ""
        
        let channelID = "\(AppConfig.USER_ID)_\(friendID)"
        let channelIDReverse = ("\(friendID)_\(AppConfig.USER_ID)")
        
        if checkChannelIsExits(channelID: channelID, channelIDReverse: channelIDReverse) {
            guard let id = getChannelID(channelID: channelID, channelIDReverse: channelIDReverse) else {return}
            pushToChatVC(user: user, channelID: id)
            return
        }
        
        // with user
        let userRef = self.channelRef.child(AppConfig.USER_ID).child(channelID)
        userRef.setValue([Constant.receiveID : friendID, Constant.name : friendName, Constant.urlImageProfile: urlImage, "lastMessage" : ""]) { (error, firDataReference) in
            if error == nil {
                // with friend
                let friendRef = self.channelRef.child(friendID).child(channelID)
                friendRef.setValue([Constant.receiveID : AppConfig.USER_ID, Constant.name : AppConfig.USER_NAME, Constant.urlImageProfile: AppConfig.USER_URL_IMAGE,  "lastMessage" : ""], withCompletionBlock: { (error, firDataReference) in
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
    
    func findingUser(text: String) {
        if text == "" {
            isSearching = false
        } else {
            isSearching = true
            self.usersSearch.removeAll()
            for user in users {
                if text == user.email! {
                    usersSearch.append(user)
                }
            }
        }
        self.tableView.reloadData()
    }
    
}
