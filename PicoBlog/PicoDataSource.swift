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
    
    // Properties for View Controllers
    var downloadedMessages: [NSURL : [PicoMessage]] = [:]
    var downloadedImages: [NSURL : UIImage] = [:]
    
    // Helper Instances
    let dateFormatter = NSDateFormatter()
    let postManager = PicoPostManager()
    let subscriptionManager = PicoSubscriptionManager()
    let messageDownloadManager = PicoDownloadManager()
    let cellImageDownloadManager = PicoDownloadManager()
    
    var currentUser = User(username: "jeffburg", unverifiedFeedURLString: "http://www.jeffburg.com/pico/feed1.pico", unverifiedAvatarURLString: "http://www.jeffburg.com/pico/images/123456789_small.jpeg")!
    
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newImagesDownloaded:", name: "dataDownloadedSuccessfully", object: self.cellImageDownloadManager)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newMessagesDownloaded:", name: "dataDownloadedSuccessfully", object: self.messageDownloadManager)
    }
    
    @objc private func newImagesDownloaded(notification: NSNotification) {
        var confirmed = false
        var allKeys: [NSURL] = []

        for (key, data) in self.cellImageDownloadManager.dataFinished {
            allKeys.append(key)
            if let image = UIImage(data: data) {
                self.downloadedImages[key] = image
                confirmed = true
            } else {
                self.cellImageDownloadManager.tasksWithInvalidData[key] = data
            }
        }
        
        if confirmed { //confirm that there was at least one good piece of data
            NSNotificationCenter.defaultCenter().postNotificationName("newImagesConfirmedByDataSource", object: self)
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName("invalidImageDataDownloaded", object: self)
        }
        
        for key in allKeys {
            self.cellImageDownloadManager.dataFinished.removeValueForKey(key)
        }

    }
    
    @objc private func newMessagesDownloaded(notification: NSNotification) {
        var confirmed = false
        var allKeys: [NSURL] = []
        
        for (key, data) in self.messageDownloadManager.dataFinished {
            allKeys.append(key)
            if let messageArray = self.generatePicoMessagesFromJSONArray(self.verifyJSONData(data)) {
                self.downloadedMessages[key] = messageArray
                confirmed = true
            } else {
                self.messageDownloadManager.tasksWithInvalidData[key] = data
            }
        }
        
        if confirmed { //confirm that there was at least one good piece of data
            NSNotificationCenter.defaultCenter().postNotificationName("newMessagesConfirmedByDataSource", object: self)
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName("invalidMessageDataDownloaded", object: self)
        }
        
        for key in allKeys {
            self.messageDownloadManager.dataFinished.removeValueForKey(key)
        }
    }
    
    private func verifyJSONData(data: NSData?) -> [NSDictionary]? {
        if let data = data {
            let jsonData: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            if let jsonArray = jsonData as? [NSDictionary] {
                return jsonArray
            }
        }
        return nil
    }
    
    private func generatePicoMessagesFromJSONArray(jsonArray: [NSDictionary]?) -> [PicoMessage]? {
        if let array = jsonArray {
            var picoMessageArray: [PicoMessage] = []
            for dictionary in array {
                if let message = PicoMessage(dictionary: dictionary) {
                    picoMessageArray.append(message)
                }
            }
            if picoMessageArray.count > 0 {
                return picoMessageArray
            }
        }
        return nil
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
