
import UIKit
import Firebase

class ChannelListViewController: UITableViewController {
    
    // MARK: Properties
    var senderDisplayName: String?
    
    private var channelRefHandle: FIRDatabaseHandle?
    static var channels: [Channel] = []
    
    private lazy var channelRef: FIRDatabaseReference = FIRDatabase.database().reference().child("\(CHATHISTORY)/\(AppConfig.USER_ID)")
    private lazy var channelFriendRef: FIRDatabaseReference = FIRDatabase.database().reference().child("\(CHATHISTORY)")
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "List Messages"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"logout"), style: .plain, target: self, action: #selector(logout(_:)))
        self.tableView.register(UINib(nibName: "ExistingChannelCell", bundle: nil), forCellReuseIdentifier: "ExistingChannel")
        observeChannels()
    }
    
    deinit {
        if let refHandle = channelRefHandle {
            channelRef.removeObserver(withHandle: refHandle)
        }
        removeAllChannels()
        
    }
    
    // MARK: Firebase related methods
    
    private func observeChannels() {
        // We can use the observe method to listen for new
        // channels being written to the Firebase DB
        channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot) -> Void in
            let channelData = snapshot.value as! Dictionary<String, AnyObject>
            let id = snapshot.key
            guard let name = channelData["name"] as? String else {return}
            guard let receiveID = channelData["receiveID"] as? String else {return}
            guard let urlImage  = channelData[Constant.urlImageProfile] as? String else {return}
            guard let lastMessage = channelData["lastMessage"] as? String else {return}
            
            ChannelListViewController.channels.append(Channel(id: id, name: name, receiveID: receiveID, receiveUrlImage: urlImage, lastMessage: lastMessage))
            self.tableView.reloadData()
        })
        
        channelRefHandle = channelRef.observe(.childChanged, with: { (snapshot) -> Void in
            let channelData = snapshot.value as! Dictionary<String, AnyObject>
            let id = snapshot.key
            guard let name = channelData["name"] as? String else {return}
            guard let receiveID = channelData["receiveID"] as? String else {return}
            guard let urlImage  = channelData[Constant.urlImageProfile] as? String else {return}
            guard let lastMessage = channelData["lastMessage"] as? String else {return}
            
            for channel in ChannelListViewController.channels {
                if channel.id == id {
                    channel.lastMessage = lastMessage
                }
            }
            
            //ChannelListViewController.channels.append(Channel(id: id, name: name, receiveID: receiveID, receiveUrlImage: urlImage, lastMessage: lastMessage))
            self.tableView.reloadData()
        })
    }
    
    //private func getLastMessage()
    
    private func removeAllChannels() {
        ChannelListViewController.channels.removeAll()
    }
    
    // MARK: - logout google firebase
    @IBAction func logout(_ sender: UIBarButtonItem) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            GIDSignIn.sharedInstance().signOut()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                self.navigationController?.setViewControllers([loginVC], animated: true)
            }
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChannelListViewController.channels.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "ExistingChannel"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? ExistingChannelCell
        cell?.configChannel(channel: ChannelListViewController.channels[(indexPath as NSIndexPath).row])
        return cell!
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = ChannelListViewController.channels[(indexPath as NSIndexPath).row]
        
        if let chatVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
            chatVC.senderDisplayName = senderDisplayName
            chatVC.channel = channel
            chatVC.channelRef = channelRef.child(channel.id)
            chatVC.channelFriendRef = channelFriendRef.child(channel.receiveID).child(channel.id)
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
        
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}
