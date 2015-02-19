//
// FeedListTableViewController.swift
// PicoBlog
//
// Created by Jeffrey Bergier on 1/5/15.
//
// The MIT License (MIT)
//
// Copyright (c) 2014 Jeffrey Bergier
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import UIKit

class FeedListTableViewController: UITableViewController, UISplitViewControllerDelegate {
    
    var subscriptionList = [Subscription]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Menu", comment: "")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 86.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        self.splitViewController?.delegate = self
        
        self.readSubscriptionsFromDisk()
        self.tableView.reloadData()
    }
    
    private func readSubscriptionsFromDisk() {
        if let subscriptionListFromDisk = PicoDataSource.sharedInstance.subscriptionManager.readSubscriptionsFromDisk() {
            self.subscriptionList = subscriptionListFromDisk
            let subscriptionURLStrings = subscriptionListFromDisk.map({ return $0.verifiedURL.string })
            if subscriptionURLStrings.count > 0 {
                PicoDataSource.sharedInstance.messageDownloadManager.downloadURLStringArray(subscriptionURLStrings)
            }
        }
    }
    
    @IBAction func didTapAddButton(sender: UIBarButtonItem) {
        let addSubscriptionAction = UIAlertAction(title: NSLocalizedString("Add Subscription", comment: ""),
            style: UIAlertActionStyle.Default)
            { (action: UIAlertAction!) -> Void in
                self.performSegueWithIdentifier("addSubscriptionSegue", sender: nil)
        }
        let composeMessageAction = UIAlertAction(title: NSLocalizedString("Compose Message", comment: ""),
            style: UIAlertActionStyle.Default)
            { (action: UIAlertAction!) -> Void in
                self.performSegueWithIdentifier("composeMessageSegue", sender: nil)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
            style: UIAlertActionStyle.Cancel)
            { (action: UIAlertAction!) -> Void in
                //
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alertController.addAction(composeMessageAction)
        alertController.addAction(addSubscriptionAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        var shouldPerforformSegue = true
        
        let segueIdentifier = identifier !! "invalidSegue"
        switch segueIdentifier {
        case "composeMessageSegue":
            break
        case "addSubscriptionSegue":
            break
        case "viewSubscriptionSegue":
            if self.tableView.indexPathForSelectedRow() == nil {
                shouldPerforformSegue = false
            }
        default:
            break
        }
        
        return shouldPerforformSegue
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let segueIdentifier = segue.identifier !! "invalidSegue"
        switch segueIdentifier {
        case "composeMessageSegue":
            break
        case "addSubscriptionSegue":
            break
        case "viewSubscriptionSegue":
            let selectedIndexPath = self.tableView.indexPathForSelectedRow() !! NSIndexPath(forRow: 0, inSection: 0)
                let navigationController = segue.destinationViewController as? UINavigationController
                let feedTableViewController = navigationController?.viewControllers.last as? FeedTableViewController
                switch selectedIndexPath.section {
                case 0:
                    var subscriptionDictionary: [String : Subscription] = [:]
                    for subscription in self.subscriptionList {
                        subscriptionDictionary[subscription.verifiedURL.string] = subscription
                    }
                    feedTableViewController?.subscriptions = subscriptionDictionary
                case 1:
                    if let individualSubscription = self.subscriptionList.optionalItemAtIndex(selectedIndexPath.row) {
                        feedTableViewController?.subscriptions = [individualSubscription.verifiedURL.string : individualSubscription]
                    }
                default:
                    break
            }
        default:
            break
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return self.subscriptionList.count //+ self.cellIndexPathOffset
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCellWithIdentifier("FeedListTableViewCell") as? FeedListTableViewCell) !! FeedListTableViewCell()
        if indexPath.section == 0 {
            cell.feedUsernameTextLabel?.text = "All Subscriptions"
        } else {
            let subscriptionUsername = self.subscriptionList.optionalItemAtIndex(indexPath.row)?.username !! ""
            cell.feedUsernameTextLabel?.text = subscriptionUsername
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        switch indexPath.section {
        case 0:
            return false
        default:
            return true
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //        if indexPath.section > 0 {
        switch editingStyle {
        case UITableViewCellEditingStyle.Delete :
            if let subscription = self.subscriptionList.optionalItemAtIndex(indexPath.row) {
                if let error = PicoDataSource.sharedInstance.subscriptionManager.deleteSubscriptionsFromDisk([subscription]) {
                    // do some error handling
                } else {
                    tableView.beginUpdates()
                    self.subscriptionList = PicoDataSource.sharedInstance.subscriptionManager.readSubscriptionsFromDisk() !! []
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
                    tableView.endUpdates()
                    //tableView.endEditing(true)
                }
            }
        default:
            break
        }
    }
    
    @IBAction private func unwindFromAddFeedViewController(segue: UIStoryboardSegue) {
        self.readSubscriptionsFromDisk()
        self.tableView.reloadData()
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
        var collapse = false
        if let secNavController = secondaryViewController as? UINavigationController {
            if let feedListVC = secNavController.viewControllers.last as? FeedTableViewController {
                if feedListVC.subscriptions == nil {
                    collapse = true
                }
            }
        }
        return collapse
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.All.rawValue)
    }
}