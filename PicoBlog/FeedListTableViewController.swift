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
    
    var subscriptionList: [Subscription]?
    
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
        self.subscriptionList = PicoDataSource.sharedInstance.subscriptionManager.readSubscriptionsFromDisk()
        if let subscriptionList = self.subscriptionList {
            var urlArray: [NSURL] = []
            for subscription in subscriptionList {
                urlArray.append(subscription.verifiedURL.url)
            }
            if urlArray.count > 0 {
                PicoDataSource.sharedInstance.messageDownloadManager.downloadURLArray(urlArray)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let navigationController = segue.destinationViewController as? UINavigationController {
            if let singleFeedTableViewController = navigationController.viewControllers.last as? SingleFeedTableViewController {
                if let selectedIndexPath = self.tableView.indexPathForSelectedRow() {
                    if let subscriptionList = self.subscriptionList {
                        if selectedIndexPath.section == 0 {
                            var subscriptionDictionary: [NSURL : Subscription] = [:]
                            for subscription in subscriptionList {
                                subscriptionDictionary[subscription.verifiedURL.url] = subscription
                            }
                            singleFeedTableViewController.subscriptions = subscriptionDictionary
                        } else {
                            let individualSubscription = subscriptionList[selectedIndexPath.row]
                            singleFeedTableViewController.subscriptions = [individualSubscription.verifiedURL.url : individualSubscription]
                        }
                    }
                }
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if let subscriptionListCount = self.subscriptionList?.count {
                return subscriptionListCount //+ self.cellIndexPathOffset
            } else {
                return 0
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: AnyObject!
        cell = tableView.dequeueReusableCellWithIdentifier("FeedListTableViewCell")
        if let cell = cell as? FeedListTableViewCell {
            if indexPath.section == 0 {
                cell.feedUsernameTextLabel?.text = "All Subscriptions"
            } else {
                cell.feedUsernameTextLabel?.text = self.subscriptionList![indexPath.row /*- self.cellIndexPathOffset */].username
            }
        }
        return cell as UITableViewCell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section > 0 {
            if editingStyle == UITableViewCellEditingStyle.Delete {
                if let error = PicoDataSource.sharedInstance.subscriptionManager.deleteSubscriptionsFromDisk([self.subscriptionList![indexPath.row]]) {
                    // do some error handling
                } else {
                    tableView.beginUpdates()
                    self.subscriptionList = PicoDataSource.sharedInstance.subscriptionManager.readSubscriptionsFromDisk()
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
                    tableView.endUpdates()
                    //tableView.endEditing(true)
                }
            }
        }
    }
    
    @IBAction private func unwindFromAddFeedViewController(segue: UIStoryboardSegue) {
        self.readSubscriptionsFromDisk()
        self.tableView.reloadData()
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
        var collapse = false
        if let secNavController = secondaryViewController as? UINavigationController {
            if let feedListVC = secNavController.viewControllers.last as? SingleFeedTableViewController {
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