//
//  FindUserCell.swift
//  ChatChat
//
//  Created by Doan Tuan on 4/27/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit

public protocol FindUserDelegate: class {
    func findingUser(text: String)
}

public class FindUserCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    
    public weak var findingUserDelegate: FindUserDelegate?

    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        searchTextField.delegate = self
        searchTextField.returnKeyType = .done
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidEnd)
    }

    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            self.findingUserDelegate?.findingUser(text: text)
        } else {
            self.findingUserDelegate?.findingUser(text: "")
        }
    }
    
}
