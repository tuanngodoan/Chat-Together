//
//  Utils.swift
//  Carillon
//
//  Created by NghiaNH on 6/20/17.
//  Copyright © 2017 Carillon. All rights reserved.
//

import UIKit
import AVFoundation

class Utils: NSObject , UIAlertViewDelegate {
    
    static let sharedInstance = Utils();
    static let alertArray = NSMutableArray()
    static let imagePicker = UIImagePickerController()

    
    static func getDeviceUUID() -> String {
        let deviceUUID: String = (UIDevice.current.identifierForVendor?.uuidString)!
        return deviceUUID
    }
    
    static func getSystemVersion() -> String {
        let system:String = (UIDevice.current.systemVersion)
        return system
    }
    
    static func getAppVersion() -> String {
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject
        let appVersion =  nsObject as! String
        return appVersion
    }
    
    static func saveUDString(key : String,value:String) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key)
        defaults.set(value, forKey: key)
    }
    
    static func getUDString(key : String) -> String {
        let defaults = UserDefaults.standard
        if let data = defaults.value(forKey: key) as? String {
            return data
        } else {
            return  ""
        }
    }
    
    static func removeUDString(key : String) {
        let defaults = UserDefaults.standard
        return defaults.removeObject(forKey: key)
    }
    
    static func getImage(name : String) -> UIImage!{
        let data = NSData(contentsOfFile: Utils.filePathInDocumentsDirectory(filename: name))
        let image = UIImage(data: data! as Data)
        return image
    }
    
    static func removeFilewithName(name : String){
        let fileManager = FileManager.default
        let filePath = Utils.filePathInDocumentsDirectory(filename: name)
        do {
            try fileManager.removeItem(atPath: filePath)
            print("removed file \(name)")
        } catch {
            print("unable remove file \(name)")
        }
    }
    
    static func getDocumentsURL() -> NSURL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL as NSURL
    }
    
    static func saveImageToPhotoAlbum(image : UIImage){
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    // Can change file URL here
    static func fileURLInDocumentsDirectory(filename: String) -> NSURL {
        return getDocumentsURL().appendingPathComponent("\(filename).png")! as NSURL
    }
    
    static func filePathInDocumentsDirectory(filename: String) -> String {
        let fileURL = fileURLInDocumentsDirectory(filename: filename)
        return fileURL.path!
    }
    
    static func setBorderForView(view: UIView, borderWidth: CGFloat, borderColor: UIColor) {
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = borderColor.cgColor
    }
    
    static func setRoundForView(view: UIView){
        view.layer.cornerRadius = view.frame.height / 2
    }
    
    func showWarningMessage (title :String, message : String, instack: Bool){
        let alert = UIAlertView(title: title, message: message, delegate: Utils.sharedInstance, cancelButtonTitle: "OK")
        if instack {
            Utils.alertArray.add(alert)
            if Utils.alertArray.count == 1 {
                DispatchQueue.main.async(execute: {
                    alert.show()
                })
            }
        } else {
            Utils.removeAllALert()
            Utils.alertArray.add(alert)
            DispatchQueue.main.async(execute: {
                alert.show()
            })
        }
    }
    
    static func removeAllALert() {
        if Utils.alertArray.count > 0 {
            let alert = Utils.alertArray[0] as? UIAlertView
            let alertVC = Utils.alertArray[0] as? UIAlertController
            Utils.alertArray.removeAllObjects()
            DispatchQueue.main.async(execute: {
                if alert != nil {
                    alert?.dismiss(withClickedButtonIndex: 0, animated: false)
                } else {
                    alertVC?.dismiss(animated: false, completion: nil)
                }
            })
        }
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if Utils.alertArray.count > 0 {
            Utils.alertArray.removeObject(at: 0)
            if Utils.alertArray.count > 0 {
                let alert = Utils.alertArray.firstObject as! UIAlertView
                alert.show()
            }
        }
    }
    
    static func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    static func validate(email: String) -> Bool {
        // Source http://emailregex.com/
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    static func validate(phoneNumber: String) -> Bool {
        let phoneNumRegEx = "^[\\+]?[(]?[0-9]{4}[)]?[-\\s\\.]?[0-9]{4}[-\\s\\.]?[0-9]{0,7}$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", phoneNumRegEx)
        return emailTest.evaluate(with: phoneNumber)

    }
    
    static func validateFirstCharacterLatin(string: String) -> Bool {
        let firstCharacterRegEx = "^[a-zA-Z0-9]"
        let nameTest = NSPredicate(format: "SELF MATCHES %@", firstCharacterRegEx)
        return nameTest.evaluate(with: string)
    }
    
    static func appName() -> String {
       return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
    }

}
