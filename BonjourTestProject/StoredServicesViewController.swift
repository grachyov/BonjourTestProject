//
//  StoredServicesViewController.swift
//  BonjourTestProject
//
//  Created by Ivan Grachev on 6/8/15.
//  Copyright (c) 2015 Ivan Grachev. All rights reserved.
//

import UIKit
import RealmSwift

//abstract class, should implement fetchServicesFunction
class StoredServicesViewController: UITableViewController {

    private var storedServices: Results<StoredNetService>?
    private var explanationLabel: UILabel?
    
    func fetchStoredServicesFunction() -> Results<StoredNetService>? {
        return nil
    }
    
    // MARK: - UI related
    
    private func prepareExplanationLabel() {
        if explanationLabel == nil {
            let explanationView = UIView(frame: tableView.frame)
            explanationLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
            explanationLabel!.center = explanationView.center
            explanationLabel!.textAlignment = NSTextAlignment.Center
            explanationLabel!.textColor = UIColor.grayColor()
            explanationView.addSubview(explanationLabel!)
            tableView.backgroundView = explanationView
        }
        if storedServices?.count == 0 {
            explanationLabel!.text = "Oops, this list is empty"
        }
        else {
            explanationLabel!.text = ""
        }
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        storedServices = fetchStoredServicesFunction()
        tableView.reloadData()
        prepareExplanationLabel()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storedServices!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StoredServiceCell", forIndexPath: indexPath) 
        cell.textLabel?.text = storedServices![indexPath.row].name
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let serviceDisplayController = segue.destinationViewController as? ServiceDisplayViewController {
            let storedService = storedServices![tableView.indexPathForCell((sender as! UITableViewCell))!.row]
            serviceDisplayController.serviceToDisplayName = storedService.name
            if storedService.address != "" {
                serviceDisplayController.addressOfServiceToDisplay = storedService.address
            }
            else {
                serviceDisplayController.serviceToDisplay = NSNetService(storedNetService: storedService)
            }
            do {
                try Realm().write {
                    storedService.seen = true
                }
            }
            catch {}
        }
    }
}
