//
//  AddDeviceViewController.swift
//  BonjourTestProject
//
//  Created by Ivan Grachev on 6/9/15.
//  Copyright (c) 2015 Ivan Grachev. All rights reserved.
//

import UIKit

class AddDeviceViewController: UITableViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        if textFieldDataIsValid() {
            storeServiceWithUserFilledName(nameTextField.text!, address: addressTextField.text!)
            (parentViewController as! UINavigationController).popToRootViewControllerAnimated(true)
        }
    }

    private func textFieldDataIsValid() -> Bool {
        if storedServiceWithName(nameTextField.text) != nil {
            showAlertWithTitle("Error", message:"Device with this name already exists")
            return false
        }
        if addressTextField.text == "" {
            showAlertWithTitle("Error", message:"Fill the address field")
            return false
        }
        return true
    }
    
    // MARK: - UI Related
    
    private func showAlertWithTitle(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okayAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            (action: UIAlertAction) -> Void in
        }
        alert.addAction(okayAction)
        presentViewController(alert, animated: true, completion: nil)
    }
}
