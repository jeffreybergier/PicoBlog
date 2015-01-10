//
// PicoDownloadManager.swift
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

class PicoDownloadManager: NSObject, NSURLSessionDelegate, NSURLSessionDataDelegate {
    
    private var tasksInProgress: [NSURLSessionTask] = []
    private var dataInProgress: [NSURLSessionTask : NSMutableData] = [:]
    private var messagePlaceholder: [PicoMessage] = []
    private lazy var session: NSURLSession = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue:NSOperationQueue.mainQueue())
        return session
    }()
    
    override init() {
        super.init()
        
        
    }
    
    func downloadSubscriptions(array: [Subscription]) {
        for subscription in array {
            let task = self.session.dataTaskWithURL(subscription.url)
            task.resume()
            self.tasksInProgress.append(task)
            //self.connectionsInProgress.append(connection)
        }
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if let mutableData = self.dataInProgress[dataTask] {
            mutableData.appendData(data)
        } else {
            self.dataInProgress[dataTask] = NSMutableData(data: data)
        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let error = error {
            NSLog("\(self): Error while downloading feed: \(task.originalRequest.URL)")
        } else {
            if let data = self.dataInProgress[task] {
                let downloadedData: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
                if let downloadedArray = downloadedData as? [[NSString : NSObject]] {
                    for downloadedDictionary in downloadedArray {
                        if let downloadedMessage = PicoDataSource.sharedInstance.picoMessageFromDictionary(downloadedDictionary) {
                            self.messagePlaceholder.append(downloadedMessage)
                        } else {
                            NSLog("\(self): Unable to convert dictionaryObject into PicoMessage: \(downloadedDictionary)")
                        }
                    }
                } else {
                    NSLog("\(self): Feed doesn't appear to be valid JSON: \(task.originalRequest.URL)")
                }
            }
            self.dataInProgress.removeValueForKey(task)
        }
        for var i=0; i<self.tasksInProgress.count; i++ {
            if task == self.tasksInProgress[i] {
                self.tasksInProgress.removeAtIndex(i)
            }
        }
        //if all the connections are done, set the downloaded messages property on the data source and clear the placeholder array
        if self.tasksInProgress.count == 0 {
            PicoDataSource.sharedInstance.downloadedMessages = self.messagePlaceholder
            self.messagePlaceholder = []
        }
    }
}