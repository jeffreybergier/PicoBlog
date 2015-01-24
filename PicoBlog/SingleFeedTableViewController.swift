//
// SingleFeedTableViewController.swift
// PicoBlog
//
// Created by Jeffrey Bergier on 1/17/15.
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

class SingleFeedTableViewController: UITableViewController {
    
    var subscriptions: [Subscription]? {
        didSet {
            if let subscriptions = self.subscriptions {
                if subscriptions.count > 1 {
                    self.title = NSLocalizedString("Feed", comment: "")
                } else {
                    if let lastObject = subscriptions.last {
                        self.title = NSLocalizedString("\(lastObject.username)", comment: "")
                    }
                }
            }
            self.didSetSubscriptionsProperty()
        }
    }
    weak var fakeSplitViewController: UISplitViewController? { //For some reason, this VC's splitviewcontroller property is nil?!
        didSet {
            // configure the navigation bar for the splitviewcontroller
            self.navigationItem.leftBarButtonItem = self.fakeSplitViewController?.displayModeButtonItem()
            self.navigationItem.leftItemsSupplementBackButton = true
        }
    }
    private var messagesDictionary: [Subscription : [PicoMessage]] = [:]
    private var messages: [PicoMessage]? {
        didSet {
            if self.messages != nil {
                self.tableView.reloadData()
                let pointlessRefreshControlTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "pointlessRefreshControlTimer:", userInfo: nil, repeats: false)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register for notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "subscriptionDownloadedSuccessfully:", name: "subscriptionDownloadedSuccessfully", object: PicoDataSource.sharedInstance.downloadManager)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "subscriptionDownloadFailed:", name: "subscriptionDownloadFailed", object: PicoDataSource.sharedInstance.downloadManager)
        
        // configure pull to refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "userPulledToRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        // configure the tableview
        self.tableView.registerNib(UINib(nibName: "FeedTableViewCellWithImage", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PicoMessageCellWithImage")
        self.tableView.registerNib(UINib(nibName: "FeedTableViewCellWithoutImage", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PicoMessageCellWithoutImage")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 60.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    private func didSetSubscriptionsProperty() {
        if let subscriptions = self.subscriptions {
            for subscription in subscriptions {
                if let newMessages = PicoDataSource.sharedInstance.downloadManager.picoMessagesFinished[subscription] {
                    self.messagesDictionary[subscription] = newMessages
                } else {
                    PicoDataSource.sharedInstance.downloadManager.downloadSubscriptionArray([subscription])
                }
            }
            if self.subscriptions?.count == self.messagesDictionary.count {
                for (key, value) in self.messagesDictionary {
                    if self.messages != nil {
                        var unsortedMessages: [PicoMessage] = self.messages!
                        unsortedMessages += value
                        let sortedMessages = self.sortPicoMessageArrayByDate(unsortedMessages)
                        self.messages = sortedMessages
                    } else {
                        self.messages = self.sortPicoMessageArrayByDate(value)
                    }
                }
            }
        }
    }
    
    private func sortPicoMessageArrayByDate(inputArray: [PicoMessage]) -> [PicoMessage] {
        var sortedArray = inputArray
        sortedArray.sort({
            let firstDate = $0.verifiedDate.date
            let secondDate = $1.verifiedDate.date
            return firstDate.compare(secondDate) == NSComparisonResult.OrderedAscending
        })

        return sortedArray
    }
    
    @objc private func subscriptionDownloadedSuccessfully(notification: NSNotification) {
        self.didSetSubscriptionsProperty()
    }
    
    @objc private func subscriptionDownloadFailed(notification: NSNotification) {
        // do some error handling
        if self.refreshControl?.refreshing == true {
            self.refreshControl?.endRefreshing()
        }
    }
    
    @objc private func userPulledToRefresh(sender: UIRefreshControl) {
        // clear out the messages array
        self.messages = nil
        
        // remove the messages already downloaded in the data source dictionary
        if let subscriptions = self.subscriptions {
            for subscription in subscriptions {
                PicoDataSource.sharedInstance.downloadManager.picoMessagesFinished.removeValueForKey(subscription)
            }
        }
        
        // run through setup as if this view controller were loading for the first time.
        self.didSetSubscriptionsProperty()
    }
    
    @objc private func pointlessRefreshControlTimer(timer: NSTimer) {
        timer.invalidate()
        if self.refreshControl?.refreshing == true {
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: AnyObject!
        if let messages = self.messages {
            var identifierString: NSString
            if messages[indexPath.row].verifiedPictureURL == nil {
                identifierString = "PicoMessageCellWithoutImage"
            } else {
                identifierString = "PicoMessageCellWithImage"
            }
            cell = tableView.dequeueReusableCellWithIdentifier(identifierString, forIndexPath: indexPath)
            if let cell = cell as? FeedTableViewCell {
                cell.messagePost = messages[indexPath.row]
            }
        }
        return cell as FeedTableViewCell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.All.rawValue)
    }
}
