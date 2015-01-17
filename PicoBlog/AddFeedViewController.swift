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
    @IBOutlet weak var saveButton: UIBarButtonItem?
    
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
    
    private let downloadManager: DownloadManager = DownloadManager(identifier: .SingleSubscription)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Add Subscription", comment: "")
        
        // register for notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "subscriptionDownloadedSuccessfully:", name: "newMessagesDownloadedForSingleSubscription", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "subscriptionDownloadFailed:", name: "newMessagesFailedToDownloadForSingleSubscription", object: nil)
        
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
    }
    
    @IBAction private func feedURLTextDidChange(sender: UITextField) {
        self.feedIsValid = false
        self.changeUIToDownloadingState()
        if let timer = self.feedURLTextFieldTimer {
            timer.invalidate()
        }
        self.feedURLTextFieldTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "urlSessionShouldStartTimerFired:", userInfo: nil, repeats: true)
    }
    @IBAction private func didTapSaveButton(sender: UIBarButtonItem) {
        if let subscription = self.createSubscriptionFromTextField() {
            if let error = PicoDataSource.sharedInstance.subscriptionManager.appendSubscriptionToDisk(subscription) {
                // do some error handling
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    @objc private func urlSessionShouldStartTimerFired(timer: NSTimer) {
        timer.invalidate()
        if let url = NSURL(string: self.feedURLTextField!.text) {
            self.downloadManager.downloadURLArray([url])
        }
    }
    
    @objc private func subscriptionDownloadedSuccessfully(notification: NSNotification) {
        self.changeUIToNotDownloadingState()
        if self.downloadManager.picoMessagesFinished.count == 1 {
            self.feedIsValid = true
            for (key, value) in self.downloadManager.picoMessagesFinished {
                self.messages = value
            }
        } else {
            NSLog("\(self): Somehow there was more than 1 array of messages. This should not happen since we are downloading a single Subscription.")
        }
        self.downloadManager.picoMessagesFinished = [:]
        self.view.endEditing(true)
        self.feedPreviewTableView?.reloadData()
    }
    
    @objc private func subscriptionDownloadFailed(notification: NSNotification) {
        //self.feedIsValid = false
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
                identifierString = "PicoMessageCellWithImage" //"PicoMessageCellWithImage"
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
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
