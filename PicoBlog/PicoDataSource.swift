//
// PicoDataSource.swift
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

class PicoDataSource {
    
    let dateFormatter = NSDateFormatter()
    let postManager = PicoPostManager()
    let subscriptionManager = PicoSubscriptionManager()
    let downloadManager = DownloadManager(identifier: .Subscriptions)
    let cellDownloadManager = DownloadManager(identifier: .CellImages)
    
    var currentUser = User(username: "jeffburg", unverifiedFeedURLString: "http://www.jeffburg.com/pico/feed1.pico", unverifiedAvatarURLString: "http://www.jeffburg.com/pico/images/123456789_small.jpeg")!
    var downloadedMessages: [PicoMessage] = []
    
    class var sharedInstance: PicoDataSource {
        struct Static {
            static var instance: PicoDataSource?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = PicoDataSource()
        }
        
        return Static.instance!
    }
    
    init() {
        self.dateFormatter.dateFormat = "YYYY-MM-dd'-'HH:mm:ssZZZ"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newMessagesDownloaded:", name: "newMessagesDownloaded", object: self.downloadManager)
    }
    
    @objc private func newMessagesDownloaded(notification: NSNotification) {
        let messageDictionary = self.downloadManager.picoMessagesFinished
        var messageArray: [PicoMessage] = []
        for (key, value) in messageDictionary {
            messageArray += value
        }
        messageArray.sort({
            let firstDate = $0.verifiedDate.date
            let secondDate = $1.verifiedDate.date
            return firstDate.compare(secondDate) == NSComparisonResult.OrderedAscending
        })
        self.downloadedMessages = messageArray
        if messageDictionary.count == self.subscriptionManager.readSubscriptionsFromDisk()?.count {
            NSNotificationCenter.defaultCenter().postNotificationName("DataSourceUpdated", object: self)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
