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
    private var users:[User] = []
    
    private lazy var userRef: FIRDatabaseReference = FIRDatabase.database().reference().child("users")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.observeUseres()
        registerCell()
    }

    deinit {
        if let refHandle = userRefHandle {
            userRef.removeObserver(withHandle: refHandle)
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
            if let name = userData["userName"] as! String!, name.characters.count > 0 {
                guard let email = userData["email"] as? String else {return}
                guard let urlImage = userData["urlImageProfile"] as? String else {return}
                self.users.append(User(id: id, name: name, email: email, urlImage: urlImage))
                self.tableView.reloadData()
            } else {
                print("Error! Could not decode channel data")
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
}
