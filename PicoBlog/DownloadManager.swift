//
// PicoCellDownloadManager.swift
// PicoBlog
//
// Created by Jeffrey Bergier on 1/3/15.
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

class DownloadManager: NSObject, NSURLSessionDelegate, NSURLSessionDataDelegate {
    
    let identifier: DownloadManagerIdentifier
    
    private lazy var session: NSURLSession = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue:NSOperationQueue.mainQueue())
        return session
        }()
    
    // CellImages Properties
    var imageTasksInProgress: [NSURL : NSURLSessionTask] = [:]
    var imageDataFinished: [NSURL : UIImage] = [:] {
        didSet {
            if imageDataFinished.count > 50 { self.imageDataFinished = [:] } //clear out the dictionary if it gets too big.
        }
    }
    private var imageDataInProgress: [NSURLSessionTask : NSMutableData] = [:]
    
    // Subscriptions Properties
    var picoMessagesFinished: [Subscription : [PicoMessage]] = [:]
    private var picoMessageTasksInProgress: [NSURL : (task: NSURLSessionTask, subscription: Subscription)] = [:]
    private var picoMessageDataInProgress: [NSURLSessionTask : NSMutableData] = [:]
    private var subscriptionTimer: NSTimer?
    
    init(identifier: DownloadManagerIdentifier) {
        self.identifier = identifier
        super.init()
    }
    
    func downloadURLArray(urlArray: [NSURL]) {
        for url in urlArray {
            let task = self.session.dataTaskWithURL(url)
            task.resume()
            switch self.identifier {
            case .CellImages:
                self.imageTasksInProgress[url] = task
            case .Subscriptions:
                NSLog("\(self): This method should not be used on this instance. This is a subscription instance and this method is for images.")
            default:
                break
            }
        }
    }
    
    func downloadSubscriptionArray(subscriptionArray: [Subscription]) {
        for subscription in subscriptionArray {
            let task = self.session.dataTaskWithURL(subscription.verifiedURL.url)
            task.resume()
            switch self.identifier {
            case .Subscriptions:
                self.picoMessageTasksInProgress[subscription.verifiedURL.url] = (task, subscription)
            default:
                break
            }
        }
        switch self.identifier {
        case .Subscriptions:
            // this is an attempt to reset this number to 0 if networking issues happen
            // this is probably important to solve bugs because this object is basically a singleton
            if let timer = self.subscriptionTimer {
                timer.invalidate()
                self.subscriptionTimer = nil
            }
            self.subscriptionTimer = NSTimer.scheduledTimerWithTimeInterval(12.0, target: self, selector: "subscriptionDownloadTimeoutTimerFired:", userInfo: nil, repeats: false)
        default:
            break
        }
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        var dataInProgress: NSMutableData?
        switch self.identifier {
        case .CellImages:
            dataInProgress = self.imageDataInProgress[dataTask]
        case .Subscriptions:
            dataInProgress = self.picoMessageDataInProgress[dataTask]
        }
        
        if let existingData = dataInProgress {
            existingData.appendData(data)
        } else {
            switch self.identifier {
            case .CellImages:
                self.imageDataInProgress[dataTask] = NSMutableData(data: data)
            case .Subscriptions:
                self.picoMessageDataInProgress[dataTask] = NSMutableData(data: data)
            }
        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        switch self.identifier {
        
        case .CellImages:
            if let data = self.imageDataInProgress[task] {
                if let image = UIImage(data: data) {
                    self.imageDataFinished[task.originalRequest.URL] = image
                    self.postAppropriateSuccessNotification()
                }
            }
            self.imageDataInProgress.removeValueForKey(task)
            self.imageTasksInProgress.removeValueForKey(task.originalRequest.URL)
        
        case .Subscriptions:
            if let tuple = self.picoMessageTasksInProgress[task.originalRequest.URL] {
                if let messageArray = self.generatePicoMessagesFromJSONArray(self.verifyJSONData(self.picoMessageDataInProgress[task])) {
                    self.picoMessagesFinished[tuple.subscription] = messageArray
                    self.postAppropriateSuccessNotification()
                }
            }
            self.picoMessageDataInProgress.removeValueForKey(task)
            self.picoMessageTasksInProgress.removeValueForKey(task.originalRequest.URL)
        }
       
        self.postAppropriateFailureNotification(error: error)
    }
    
    @objc private func subscriptionDownloadTimeoutTimerFired(timer: NSTimer) {
        timer.invalidate()
        self.subscriptionTimer = nil
        if self.picoMessageTasksInProgress.count > 0 {
            for (key, value) in self.picoMessageTasksInProgress {
                self.picoMessageTasksInProgress.removeValueForKey(key)
            }
            self.postAppropriateSuccessNotification()
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
    
    private func postAppropriateSuccessNotification() {
        switch self.identifier {
        case .Subscriptions:
            if self.picoMessageTasksInProgress.count == 0 {
                NSNotificationCenter.defaultCenter().postNotificationName("subscriptionDownloadedSuccessfully", object: self)
            }
        case .CellImages:
            NSNotificationCenter.defaultCenter().postNotificationName("newCellImageDownloaded", object: self)
        default:
            break
        }
    }
    
    private func postAppropriateFailureNotification(error: NSError? = nil) {
        if let error = error {
            NSLog("\(self): Error: \(error)")
            switch self.identifier {
            case .Subscriptions:
                NSNotificationCenter.defaultCenter().postNotificationName("subscriptionDownloadFailed", object: self)
            default:
                break
            }
        }
    }
}
