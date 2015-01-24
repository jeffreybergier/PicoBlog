//
// AddFeedViewController.swift
// PicoBlog
//
// Created by Jeffrey Bergier on 1/13/15.
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

class AddFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet private weak var feedURLTitleLabel: UILabel?
    @IBOutlet private weak var feedURLTextField: UITextField?
    @IBOutlet private weak var feedPreviewTableView: UITableView?
    @IBOutlet private weak var feedLoadingSpinner: UIActivityIndicatorView?
    @IBOutlet private weak var feedURLTextFieldTrailingConstraint: NSLayoutConstraint?
    @IBOutlet private weak var saveButton: UIBarButtonItem?
    
    private let downloadManager = PicoDataSource.sharedInstance.downloadManager
    
    private var subscription: Subscription? {
        didSet {
            NSLog("\(self.subscription)")
        }
    }
    private var feedURLTextFieldConstraint: (loading: CGFloat, notLoading: CGFloat) = (0.0, 0.0)
    private var feedURLTextFieldTimer: NSTimer?
    private var messages: [PicoMessage]?
    private var feedIsValid: Bool = false {
        didSet {
            if self.feedIsValid {
                self.changeUIToSuccessfulVerificationState()
            } else {
                self.changeUIToFailedVerificationState()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Add Subscription", comment: "")
        
        // register for notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "subscriptionDownloadedSuccessfully:", name: "subscriptionDownloadedSuccessfully", object: PicoDataSource.sharedInstance.downloadManager)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "subscriptionDownloadFailed:", name: "subscriptionDownloadFailed", object: PicoDataSource.sharedInstance.downloadManager)
        
        // configure text
        self.feedURLTitleLabel?.text = NSLocalizedString("Feed URL:", comment: "")
        self.feedLoadingSpinner?.stopAnimating()
        
        //disable save button
        self.feedIsValid = false
        
        // prepare the constants for animating the text input field
        self.feedURLTextFieldConstraint.loading = self.feedURLTextFieldTrailingConstraint!.constant
        self.feedURLTextFieldConstraint.notLoading = -1 * self.feedLoadingSpinner!.frame.size.width
        self.feedURLTextFieldTrailingConstraint?.constant = self.feedURLTextFieldConstraint.notLoading
        
        // configure the tableview
        self.feedPreviewTableView?.registerNib(UINib(nibName: "FeedTableViewCellWithImage", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PicoMessageCellWithImage")
        self.feedPreviewTableView?.registerNib(UINib(nibName: "FeedTableViewCellWithoutImage", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PicoMessageCellWithoutImage")
        self.feedPreviewTableView?.delegate = self
        self.feedPreviewTableView?.dataSource = self
        self.feedPreviewTableView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -4)
        self.feedPreviewTableView?.estimatedRowHeight = 112.0
        self.feedPreviewTableView?.rowHeight = UITableViewAutomaticDimension
    }
    
    @IBAction private func feedURLTextDidChange(sender: UITextField) {
        self.feedIsValid = false
        self.changeUIToDownloadingState()
        self.subscription = nil
        self.messages = nil
        self.feedPreviewTableView?.reloadData()
        if let timer = self.feedURLTextFieldTimer {
            timer.invalidate()
        }
        self.feedURLTextFieldTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "urlSessionShouldStartTimerFired:", userInfo: nil, repeats: true)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        var shouldSegue = true
        
        if let button = sender as? UIBarButtonItem {
            switch button.tag {
            case 101:
                // cancel button
                break
            case 102:
                // Save Button
                if let subscription = self.createSubscriptionFromTextField() {
                    if let error = PicoDataSource.sharedInstance.subscriptionManager.appendSubscriptionToDisk(subscription) {
                        // do some error handling
                        shouldSegue = false
                    }
                }
            default:
                break
            }
        }
        
        return shouldSegue
    }
    
    @objc private func urlSessionShouldStartTimerFired(timer: NSTimer) {
        timer.invalidate()
        if let originalString: String = self.feedURLTextField?.text {
            let array = originalString.componentsSeparatedByString(":")
            var correctedString: String
            
            if array.first == "http" || array.first == "https" {
                correctedString = originalString
            } else {
                correctedString = "http://" + originalString
            }
            
            if let tempSubscription = Subscription(username: "tempTemp", unverifiedURLString: correctedString, unverifiedDateString: PicoDataSource.sharedInstance.dateFormatter.stringFromDate(NSDate(timeIntervalSinceNow: 0))) {
                self.subscription = tempSubscription
                PicoDataSource.sharedInstance.downloadManager.downloadSubscriptionArray([tempSubscription])
            }
        }
    }
    
    @objc private func subscriptionDownloadedSuccessfully(notification: NSNotification) {
        self.changeUIToNotDownloadingState()
        
        if let subscription = self.subscription {
            if let messages = PicoDataSource.sharedInstance.downloadManager.picoMessagesFinished[subscription] {
                self.feedIsValid = true
                self.messages = messages
            }
        }
        self.feedPreviewTableView?.reloadData()
    }
    
    @objc private func subscriptionDownloadFailed(notification: NSNotification) {
        //self.feedIsValid = false
        self.subscription = nil
        self.changeUIToNotDownloadingState()
    }
    
    private func createSubscriptionFromTextField() -> Subscription? {
        let username: String? = self.messages?.last?.user.username
        let dateString: String = PicoDataSource.sharedInstance.dateFormatter.stringFromDate(NSDate(timeIntervalSinceNow: 0))
        let urlString: String? = self.feedURLTextField?.text
        let subscription = Subscription(username: username, unverifiedURLString: urlString, unverifiedDateString: dateString)
        return subscription
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        if let messages = self.messages {
            rows = messages.count
        }
        return rows
    }

    private func changeUIToFailedVerificationState() {
        self.saveButton?.enabled = false
    }
    
    private func changeUIToSuccessfulVerificationState() {
        self.saveButton?.enabled = true
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    private func changeUIToDownloadingState() {
        self.feedLoadingSpinner?.startAnimating()
        UIView.animateWithDuration(0.3,
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState,
            animations: { () -> Void in
                self.feedURLTextFieldTrailingConstraint?.constant = self.feedURLTextFieldConstraint.loading
                self.view.layoutIfNeeded()
            }, completion: { (finished) -> Void in
                return ()
        })
    }
    
    private func changeUIToNotDownloadingState() {
        UIView.animateWithDuration(0.3,
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState,
            animations: { () -> Void in
                self.feedURLTextFieldTrailingConstraint?.constant = self.feedURLTextFieldConstraint.notLoading
                self.view.layoutIfNeeded()
            }, completion: { (finished) -> Void in
                self.feedLoadingSpinner?.stopAnimating()
                return ()
        })
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.All.rawValue)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
