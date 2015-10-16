//
//  SearchViewController.swift
//  BonjourTestProject
//
//  Created by Ivan Grachev on 6/5/15.
//  Copyright (c) 2015 Ivan Grachev. All rights reserved.
//

import UIKit
import RealmSwift

let requiredServiceName = ""
let defaultWebServiceType = "_http._tcp."
let defaultDomain = "local."

class SearchViewController: UITableViewController, NSNetServiceBrowserDelegate {
    
    private var netServiceBrowser: NSNetServiceBrowser?
    private var services: [NSNetService] = []
    private var explanationLabel: UILabel?
    private var activityIndicator: UIActivityIndicatorView?
    
    private func searchForServicesOfType(type: String) {
        netServiceBrowser?.stop()
        services.removeAll(keepCapacity: false)
        netServiceBrowser = NSNetServiceBrowser()
        netServiceBrowser?.delegate = self
        netServiceBrowser?.searchForServicesOfType(type, inDomain: defaultDomain)
        tableView.reloadData()
    }
    
    private func shouldAddService(service: NSNetService) -> Bool {
        if requiredServiceName == "" {
            return true
        }
        else if service.name.lowercaseString.rangeOfString(requiredServiceName) != nil {
            return true
        }
        else {
            return false
        }
    }
    
    // MARK: - UI related
    
    private func prepareExplanationViews() {
        if explanationLabel == nil && activityIndicator == nil {
            let explanationView = UIView(frame: tableView.frame)
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            activityIndicator!.center = explanationView.center
            explanationView.addSubview(activityIndicator!)
            explanationLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
            explanationLabel!.center = CGPoint(x: explanationView.center.x, y: explanationView.center.y - 2 * activityIndicator!.frame.height)
            explanationLabel!.textAlignment = NSTextAlignment.Center
            explanationLabel!.textColor = UIColor.grayColor()
            explanationView.addSubview(explanationLabel!)
            tableView.backgroundView = explanationView
        }
    }
    
    private func updateExplanationViewsAfterSearch() {
        if services.count == 0 {
            showNothingFoundState()
        }
        else {
            hideExplanationViews()
        }
    }
    
    private func showSearchingState() {
        explanationLabel!.text = "Searching for services..."
        activityIndicator!.startAnimating()
    }
    
    private func showNothingFoundState() {
        explanationLabel!.text = "Sorry, nothing found"
        activityIndicator!.stopAnimating()
    }
    
    private func hideExplanationViews() {
        explanationLabel!.text = ""
        activityIndicator!.stopAnimating()
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        searchForServicesOfType(defaultWebServiceType)
        prepareExplanationViews()
        showSearchingState()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        hideExplanationViews()
        netServiceBrowser?.stop()
    }
    
    // MARK: - Net Service Browser Delegate
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveService aNetService: NSNetService, moreComing: Bool) {
        services.removeAtIndex(services.indexOf(aNetService)!)
        if !moreComing {
            tableView.reloadData()
            updateExplanationViewsAfterSearch()
        }
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
        if shouldAddService(aNetService) {
            services.append(aNetService)
        }
        if !moreComing {
            tableView.reloadData()
            updateExplanationViewsAfterSearch()
        }
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        tableView.reloadData()
        updateExplanationViewsAfterSearch()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchResultCell", forIndexPath: indexPath) 
        cell.textLabel?.text = services[indexPath.row].name
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let serviceDisplayController = segue.destinationViewController as? ServiceDisplayViewController {
            let currentService = services[tableView.indexPathForCell((sender as! UITableViewCell))!.row]
            storeServiceInDatabase(currentService, isSeen: true, isFavorited: nil)
            serviceDisplayController.serviceToDisplayName = currentService.name
            serviceDisplayController.serviceToDisplay = currentService
        }
    }

}
