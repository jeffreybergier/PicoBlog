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

class FeedTableViewController: UITableViewController {
    
    var subscriptions: [String : Subscription] = [:] {
        didSet {
            self.messages = []
            if self.subscriptions.count > 1 {
                self.title = NSLocalizedString("Feed", comment: "")
            } else {
                for (i, (url, subscription)) in enumerate(self.subscriptions) {
                    if i == self.subscriptions.count - 1 {
                        self.title = subscription.username
                    }
                }
            }
            self.didSetSubscriptionsProperty()
        }
    }
    private var errorTimer: NSTimer?
    private var messagesDictionary: [String : [PicoMessage]] = [:]
    private var messages: [PicoMessage] = [PicoMessage]() {
        didSet {
            if self.messages.count == 0 {
                let pointlessRefreshControlTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "pointlessRefreshControlTimer:", userInfo: nil, repeats: false)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // configure the navigation bar for the splitviewcontroller
        if self.navigationItem.leftBarButtonItem == nil {
            self.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
        }
        if self.navigationItem.leftItemsSupplementBackButton != true {
            self.navigationItem.leftItemsSupplementBackButton = true
        }
        
        // register for notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "subscriptionDownloadedSuccessfully:", name: "newMessagesConfirmedByDataSource", object: PicoDataSource.sharedInstance)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "subscriptionDownloadFailed:", name: "dataDownloadFailed", object: PicoDataSource.sharedInstance.messageDownloadManager)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "subscriptionDownloadFailed:", name: "invalidMessageDataDownloaded", object: PicoDataSource.sharedInstance)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // de-register notifications
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func didSetSubscriptionsProperty(IgnoreNewDownloads ignoreNewDownloads: Bool = false) {
        var urlStringArray: [String] = []
        for (urlString, subscription) in subscriptions {
            if let newMessages = PicoDataSource.sharedInstance.downloadedMessages[urlString] {
                self.messagesDictionary[urlString] = newMessages
            } else {
                if ignoreNewDownloads == false {
                    if let task = PicoDataSource.sharedInstance.messageDownloadManager.tasksInProgress[subscription.verifiedURL.string] {
                        task.resume()
                    } else {
                        urlStringArray.append(subscription.verifiedURL.string)
                    }
                }
            }
        }
        
        if urlStringArray.count > 0 {
            PicoDataSource.sharedInstance.messageDownloadManager.downloadURLStringArray(urlStringArray)
        }
        
        if self.subscriptions.count == self.messagesDictionary.count || ignoreNewDownloads == true {
            let startTime = NSDate(timeIntervalSinceNow: 0)
            if self.messagesDictionary.count > 0 {
                var unsortedMessagesArray = [PicoMessage]()
                for (url, newMessages) in self.messagesDictionary {
                    unsortedMessagesArray += newMessages
                }
                self.messages = self.sortPicoMessageArrayByDate(unsortedMessagesArray)
                self.tableView.reloadData()
            } else {
                if self.refreshControl?.refreshing == true {
                    self.refreshControl?.endRefreshing()
                }
            }
            let endTime = NSDate(timeIntervalSinceNow: 0)
            NSLog("\(self): Sorting messages took: \(endTime.timeIntervalSinceDate(startTime)) seconds.")
        }
    }
    
    private func sortPicoMessageArrayByDate(inputArray: [PicoMessage]) -> [PicoMessage] {
        let sortedArray = inputArray.sorted({
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
        if let timer = self.errorTimer {
            timer.invalidate()
            self.errorTimer = nil
        }
        self.errorTimer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: "errorWhileDownloadingTimerFired:", userInfo: nil, repeats: false)
        
    }
    
    @objc private func errorWhileDownloadingTimerFired(timer: NSTimer) {
        var tasksInProgress = 0
        for (url, subscription) in subscriptions {
            if let task = PicoDataSource.sharedInstance.messageDownloadManager.tasksInProgress[subscription.verifiedURL.string] {
                tasksInProgress++
            }
        }
        if tasksInProgress == 0 {
            self.didSetSubscriptionsProperty(IgnoreNewDownloads: true)
            let errorTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "errorPresentationTimerFired:", userInfo: nil, repeats: false)
        }
    }
    
    @objc private func errorPresentationTimerFired(timer: NSTimer) {
        timer.invalidate()
        self.tableView.reloadData()
        
        var matchedErrors: [Subscription : (response: NSHTTPURLResponse, downloadError: DownloadError)] = [:]
        var matchedInvalidData: [Subscription] = []
        for (url, subscription) in subscriptions {
            if let matchingResponse = PicoDataSource.sharedInstance.messageDownloadManager.tasksWithErrors[subscription.verifiedURL.string] {
                matchedErrors[subscription] = matchingResponse
            }
            if let matchedInvalid = PicoDataSource.sharedInstance.messageDownloadManager.tasksWithInvalidData[subscription.verifiedURL.string] {
                matchedInvalidData.append(subscription)
            }
        }
        
        let errorTitleString = NSLocalizedString("Error Downloading Messages", comment: "")
        let invalidDataString: String = NSLocalizedString("Invalid Data", comment: "")
        var messageString: String = "\nThere was an error downloading messages for the following subscription \n\n"
        if ((matchedErrors.count + matchedInvalidData.count) > 1) {
            var messageString: String = "\nThere was an error downloading messages for the following subscriptions \n\n"
        }
        
        if matchedInvalidData.count > 0 {
            for (i, subscription) in enumerate(matchedInvalidData) {
                var lineBreak = "\n\n"
                if i == matchedErrors.count - 1 && matchedErrors.count == 0 {
                    lineBreak = ""
                }
                messageString += "Username: \(subscription.username)\nError: " + invalidDataString + lineBreak
            }
        }
        
        if matchedErrors.count > 0 {
            for (i, (subscription, tuple)) in enumerate(matchedErrors) {
                var lineBreak = "\n\n"
                if i == matchedErrors.count - 1 {
                    lineBreak = ""
                }
                messageString += "Username: \(subscription.username)\nError Code: \(tuple.response.statusCode)" + lineBreak
            }
        }
        
        if matchedErrors.count > 0 || matchedInvalidData.count > 0 {
            let alertViewController = UIAlertController(title: errorTitleString, message: messageString, preferredStyle: UIAlertControllerStyle.Alert)
            alertViewController.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""),
                style: UIAlertActionStyle.Cancel,
                handler: { (action: UIAlertAction!) -> Void in
                    for (subscription, response) in matchedErrors {
                        PicoDataSource.sharedInstance.messageDownloadManager.tasksWithErrors.removeValueForKey(subscription.verifiedURL.string)
                        PicoDataSource.sharedInstance.messageDownloadManager.tasksWithInvalidData.removeValueForKey(subscription.verifiedURL.string)
                    }
            }))
            self.presentViewController(alertViewController, animated: true, completion: nil)
        }
    }
    
    @objc private func userPulledToRefresh(sender: UIRefreshControl) {
        // clear out the messages array
        self.messages = []
        self.messagesDictionary = [:]
        
        // remove the messages already downloaded in the data source dictionary
        for (urlString, subscription) in subscriptions {
            PicoDataSource.sharedInstance.downloadedMessages.removeValueForKey(urlString)
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
        return messages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: FeedTableViewCell?
        let identifierString: String
        if let message = self.messages.optionalItemAtIndex(indexPath.row) {
            if message.verifiedPictureURL == nil {
                identifierString = "PicoMessageCellWithoutImage"
            } else {
                identifierString = "PicoMessageCellWithImage"
            }
        } else {
            identifierString = "PicoMessageCellWithImage"
        }
        cell = tableView.dequeueReusableCellWithIdentifier(identifierString) as? FeedTableViewCell
        cell?.messagePost = messages[indexPath.row]
        return cell !! FeedTableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.All.rawValue)
    }
}
