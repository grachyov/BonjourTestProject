//
//  ServiceDisplayViewController.swift
//  BonjourTestProject
//
//  Created by Ivan Grachev on 6/5/15.
//  Copyright (c) 2015 Ivan Grachev. All rights reserved.
//

import UIKit
import RealmSwift

class ServiceDisplayViewController: UIViewController, NSNetServiceDelegate {

    @IBOutlet weak var presentationView: UIWebView!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    var serviceToDisplay: NSNetService?
    var addressOfServiceToDisplay: String?
    var serviceToDisplayName: String?
    var favorited = false
    
    @IBAction func favoriteButtonTapped(sender: UIBarButtonItem) {
        do {
            if !favorited {
                sender.image = UIImage(named: "FavoritedButtonIcon")
                favorited = true
                try Realm().write {
                    storedServiceWithName(self.serviceToDisplayName)!.favorited = true
                }
            }
            else {
                sender.image = UIImage(named: "UnfavoritedButtonIcon")
                favorited = false
                try Realm().write {
                    storedServiceWithName(self.serviceToDisplayName)!.favorited = false
                }
            }
        }
        catch {}
    }
    
    private func constructURLForResolvedService(service: NSNetService) -> NSURL {
        let dict = NSNetService.dictionaryFromTXTRecordData(service.TXTRecordData()!)
        let hostName = service.hostName!
        var user = copyStringFromTXTDict(dict, which: "u")
        var pass = copyStringFromTXTDict(dict, which: "p")
        var loginString = ""
        
        if user != nil || pass != nil {
            if user == nil {
                user = ""
            }
            if pass == nil {
                pass = ""
            }
            else {
                pass = ":" + pass!
            }
            loginString = user! + pass! + "@"
        }
        
        loginString = "http://" + loginString
        var portString = ""
        let port = service.port
        if port != 0 && port != 80 {
            portString = ":" + String(port)
        }
        var path = copyStringFromTXTDict(dict, which: "path")
        if path == nil {
            path = "/"
        }
        else if !(path!.hasPrefix("/")) {
            path = "/" + path!
        }
        let addressString = loginString + hostName + portString + path!
        return NSURL(string: addressString)!
    }
    
    private func copyStringFromTXTDict(dict: [NSObject : AnyObject], which: String) -> String? {
        if let data = dict[which] as? NSData {
            return NSString(data: data, encoding: NSUTF8StringEncoding) as? String
        }
        else {
            return nil
        }
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = serviceToDisplayName
        if let storedService = storedServiceWithName(serviceToDisplayName) {
            favorited = storedService.favorited
        }
        if favorited {
            favoriteButton.image = UIImage(named: "FavoritedButtonIcon")
        }
        
        if addressOfServiceToDisplay != nil {
            presentationView.loadRequest(NSURLRequest(URL: NSURL(string: addressOfServiceToDisplay!)!))
        }
        else {
            serviceToDisplay?.delegate = self
            serviceToDisplay?.resolveWithTimeout(30.0)
        }
        //TODO: show some kind of activity indicator
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        serviceToDisplay?.stop()
        (parentViewController as! UINavigationController).popToRootViewControllerAnimated(true)
    }
    
    // MARK: - Net Service Delegate
    
    func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        serviceToDisplay?.stop()
        //TODO: show error message
    }
    
    func netServiceDidResolveAddress(sender: NSNetService) {
        serviceToDisplay?.stop()
        presentationView.loadRequest(NSURLRequest(URL: constructURLForResolvedService(sender)))
    }
    
}
