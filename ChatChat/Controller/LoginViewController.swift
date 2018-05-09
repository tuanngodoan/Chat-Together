
import UIKit
import Firebase
import GoogleSignIn
import SpriteKit
import SVProgressHUD


class LoginViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    // MARK: Properties
    @IBOutlet weak var signInView: UIView!
    @IBOutlet weak var ggImageView: UIImageView!
    
    var user: User? = nil
    
    var didAddedLayer: Bool = false
    var duration = 0.8
    
    private lazy var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        self.navigationController?.isNavigationBarHidden = true
        // Add action signInView
        self.signInView.isUserInteractionEnabled = true
        let gesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(loginWithGG))
        gesture.numberOfTapsRequired = 1
        self.signInView.addGestureRecognizer(gesture)
    }
    
    override func viewDidLayoutSubviews() {
        signInView.layer.cornerRadius = signInView.frame.width * 0.5
        signInView.layer.borderWidth  = 1.0
        signInView.layer.borderColor  = UIColor.gray.cgColor
        setUpLayer()
    }
    
    // MARK: - GIDSignInDelegate
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        self.removeAnimation()
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        SVProgressHUD.dismiss()
        setUpLayer()
        self.dismiss(animated: true, completion: nil)
    }
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
                       withError error: Error!) {
        SVProgressHUD.show()
        if (error == nil) {
            
            let userId = user.userID                  // For client-side use only!
            let fullName = user.profile.name
            let email = user.profile.email
            let urlImageProfile = user.profile.imageURL(withDimension: UInt(480))
            
            //save user
            let userInfo = User(id: userId, name: fullName, email: email, urlImage: urlImageProfile?.absoluteString)
            self.user = userInfo
            
            guard let authentication = user.authentication else { return }
            let credential: FIRAuthCredential = FIRGoogleAuthProvider.credential(withIDToken:
                                                                                authentication.idToken,
                                                                                accessToken: authentication.accessToken)
            self.loginToFIR(credential: credential)
        } else {
            SVProgressHUD.dismiss()
            print("\(error.localizedDescription)")
        }
    }
    
    @objc func loginWithGG() {
        self.removeAnimation()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate=self
        GIDSignIn.sharedInstance().signIn()
    }

    
    func loginToFIR(credential: FIRAuthCredential) {
        SVProgressHUD.dismiss()
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if let err:Error = error {
                print(err.localizedDescription)
                return
            }
            self.saveUserInfo()
            self.performSegue(withIdentifier: "LoginToChat", sender: nil)
        })
    }
    
    func saveUserInfo() {
        if let userInfo = self.user {
            // id
            guard let id = userInfo.userId    else {return}
            let userIdRef = self.ref.child(USERS).child(id)
        
            guard let name = userInfo.fullName else {return}
            guard let email = userInfo.email   else {return}
            guard let url = userInfo.urlImage  else {return}
            
            //save Data local
            AppConfig.USER_ID           = id
            AppConfig.USER_NAME         = name
            AppConfig.USER_URL_IMAGE    = url
            
            //saveData to fireBase
            userIdRef.setValue([Constant.userName: name, Constant.email: email, Constant.urlImageProfile: url])
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let navVc = segue.destination as! UINavigationController
        let channelVc = navVc.viewControllers.first as! ChannelListViewController
        
        channelVc.senderDisplayName = self.user?.fullName
    }
}

extension LoginViewController {
    func setUpLayer() {
        if didAddedLayer {
            didAddedLayer = false
            return
        }
        for layer: CALayer in signInView.layer.sublayers! {
            if layer != ggImageView.layer {
                layer.removeFromSuperlayer()
            }
        }
        addAnimation(layer: ggImageView.layer, scale: 1.2)
        addAnimation(layer: signInView.layer,  scale: 1.4)
        
        didAddedLayer = true
    }
    
    func addAnimation(layer: CALayer, scale: CGFloat) -> Void {
        let opacityAnimation = CABasicAnimation(keyPath: "transform.scale")
        opacityAnimation.toValue = scale
        opacityAnimation.fromValue = 1.0
        opacityAnimation.autoreverses = true
        opacityAnimation.repeatCount = .infinity
        opacityAnimation.duration = duration
        layer.add(opacityAnimation, forKey: nil)
    }
    
    func removeAnimation() {
        self.signInView.layer.removeAllAnimations()
        self.ggImageView.layer.removeAllAnimations()
    }
}

