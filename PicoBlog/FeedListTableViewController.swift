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

class FeedListTableViewController: UITableViewController {
    
    var subscriptionList: [Subscription] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Manage"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 86.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        if let newSubscriptions = PicoDataSource.sharedInstance.subscriptionManager.readSubscriptionsFromDisk() {
            self.subscriptionList = newSubscriptions
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.subscriptionList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("FeedListTableViewCell") as? FeedListTableViewCell {
            cell.feedUsernameTextLabel?.text = self.subscriptionList[indexPath.row].username
            cell.feedURLTextLabel?.text = self.subscriptionList[indexPath.row].verifiedURL.string
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    @IBAction private func unwindFromAddFeedViewController(segue: UIStoryboardSegue) {
        if let newSubscriptions = PicoDataSource.sharedInstance.subscriptionManager.readSubscriptionsFromDisk() {
            self.subscriptionList = newSubscriptions
        }
    }
}