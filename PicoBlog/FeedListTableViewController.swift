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
    private var loadedOnceAlready = false
    private var cellIndexPathOffset = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Menu", comment: "")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 86.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        self.splitViewController?.delegate = self
        
        self.subscriptionList = PicoDataSource.sharedInstance.subscriptionManager.readSubscriptionsFromDisk()
        if let subscriptionList = self.subscriptionList {
            PicoDataSource.sharedInstance.downloadManager.downloadSubscriptionArray(subscriptionList)
        }
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let selectedCellIndex = self.tableView.indexPathForSelectedRow() {
            self.tableView.deselectRowAtIndexPath(selectedCellIndex, animated: true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let navigationController = segue.destinationViewController as? UINavigationController {
            if let singleFeedTableViewController = navigationController.viewControllers.last as? SingleFeedTableViewController {
                if let selectedIndexPath = self.tableView.indexPathForSelectedRow() {
                    if let subscriptionList = self.subscriptionList {
                        if selectedIndexPath.row < self.cellIndexPathOffset {
                            singleFeedTableViewController.subscriptions = subscriptionList
                            singleFeedTableViewController.title = NSLocalizedString("Feed", comment: "")
                        } else {
                            singleFeedTableViewController.subscriptions = [subscriptionList[selectedIndexPath.row - self.cellIndexPathOffset]]
                            singleFeedTableViewController.title = NSLocalizedString("\(subscriptionList[selectedIndexPath.row - self.cellIndexPathOffset].username)", comment: "")
                        }
                    }
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let subscriptionListCount = self.subscriptionList?.count {
            return subscriptionListCount + self.cellIndexPathOffset
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: AnyObject!
        cell = tableView.dequeueReusableCellWithIdentifier("FeedListTableViewCell")
        if let cell = cell as? FeedListTableViewCell {
            if indexPath.row < self.cellIndexPathOffset {
                cell.feedUsernameTextLabel?.text = "All Subscriptions"
            } else {
                cell.feedUsernameTextLabel?.text = self.subscriptionList![indexPath.row - self.cellIndexPathOffset].username
            }
        }
        return cell as UITableViewCell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            if let error = PicoDataSource.sharedInstance.subscriptionManager.deleteSubscriptionsFromDisk([self.subscriptionList![indexPath.row]]) {
                // do some error handling
            } else {
                tableView.beginUpdates()
                self.subscriptionList = PicoDataSource.sharedInstance.subscriptionManager.readSubscriptionsFromDisk()
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
                tableView.endUpdates()
            }
        }
    }
    
    @IBAction private func unwindFromAddFeedViewController(segue: UIStoryboardSegue) {
        self.subscriptionList = PicoDataSource.sharedInstance.subscriptionManager.readSubscriptionsFromDisk()
        self.tableView.reloadData()
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
        // this is such a weird issue and a bad way to solve it. But even apple's Master/Detail template does this an its awful.
        // It fixes a bug where when the splitViewController loads it automatically shows the detail view instead of the master view.
        var collapse = false
        
        if self.loadedOnceAlready == false {
            collapse = true
            self.loadedOnceAlready = true
        }
        
        return collapse
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.All.rawValue)
    }
}