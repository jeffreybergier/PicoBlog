//
// FeedTableViewController.swift
// PicoBlog
//
// Created by Jeffrey Bergier on 12/31/14.
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Feed"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dataSourceUpdated:", name: "DataSourceUpdated", object: nil)
        
        self.updateDataSource()
        
        self.tableView.registerNib(UINib(nibName: "FeedTableViewCellWithImage", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PicoMessageCellWithImage")
        self.tableView.registerNib(UINib(nibName: "FeedTableViewCellWithoutImage", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PicoMessageCellWithoutImage")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 112.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "didPullToRefresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    @objc private func didPullToRefresh(refreshControl: UIRefreshControl) {
        self.updateDataSource()
    }
    
    @objc private func dataSourceUpdated(notification: NSNotification) {
        self.tableView.reloadData()
        let pointlessTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "refreshControlFinished:", userInfo: nil, repeats: false)
    }
    
    @objc private func refreshControlFinished(timer: NSTimer) {
        timer.invalidate()
        if let refreshControl = self.refreshControl {
            if refreshControl.refreshing {
                refreshControl.endRefreshing()
            }
        }
    }
    
    private func updateDataSource() {
        if let subscriptionArray = PicoDataSource.sharedInstance.subscriptionManager.readSubscriptionsFromDisk() {
            PicoDataSource.sharedInstance.downloadManager.downloadSubscriptions(subscriptionArray)
        }
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let feedCell = cell as? FeedTableViewCell {
            feedCell.cellDidDisappear()
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let feedCell = cell as? FeedTableViewCell {
            feedCell.cellWillAppear()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        PicoDataSource.sharedInstance.cellDownloadManager.imageDataFinished = [:]
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PicoDataSource.sharedInstance.downloadedMessages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var identifierString: NSString
        if PicoDataSource.sharedInstance.downloadedMessages[indexPath.row].verifiedPictureURL == nil {
            identifierString = "PicoMessageCellWithoutImage"
        } else {
            identifierString = "PicoMessageCellWithImage" //"PicoMessageCellWithImage"
        }
        let cell: AnyObject = tableView.dequeueReusableCellWithIdentifier(identifierString, forIndexPath: indexPath)
        if let cell = cell as? FeedTableViewCell {
            cell.messagePost = PicoDataSource.sharedInstance.downloadedMessages[indexPath.row]
        }
        return cell as UITableViewCell
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
