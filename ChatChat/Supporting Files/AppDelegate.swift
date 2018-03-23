
import UIKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

  var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        FIRApp.configure()
        self.initSignInGG()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let schem = url.scheme
        print("xxxxx SCHEM = \(String(describing: schem))")
        return GIDSignIn.sharedInstance().handle(url as URL!, sourceApplication: options[.sourceApplication] as! String, annotation: options[.annotation])
    }
    
    
    // MARK: - GIDSignInDelegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // get userInfo
        }
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    func initSignInGG() {
        GIDSignIn.sharedInstance().clientID = AppConfig.CLIENT_ID
        GIDSignIn.sharedInstance().delegate = self
    }
    
    

}

