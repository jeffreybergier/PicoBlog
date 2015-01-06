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

class PicoCellDownloadManager: NSObject, NSURLSessionDelegate, NSURLSessionDataDelegate {
    
    var tasksInProgress: [NSURL : NSURLSessionTask] = [:]
    var finishedImages: [NSURL : UIImage] = [:] {
        didSet {
            if finishedImages.count > 50 { self.finishedImages = [:] } //clear out the dictionary if it gets too big.
            NSNotificationCenter.defaultCenter().postNotificationName("newCellImageDownloaded", object: nil)
        }
    }
    
    private var dataInProgress: [NSURLSessionTask : NSMutableData] = [:]
    private lazy var session: NSURLSession = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue:NSOperationQueue.mainQueue())
        return session
        }()
    
    func downloadImageWithURL(url: NSURL) {
        let task = self.session.dataTaskWithURL(url)
        task.resume()
        self.tasksInProgress[url] = task
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if let existingData = self.dataInProgress[dataTask] {
            existingData.appendData(data)
        } else {
            self.dataInProgress[dataTask] = NSMutableData(data: data)
        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let error = error {
            //do nothing
        } else {
            if let data = self.dataInProgress[task] {
                if let image = UIImage(data: data) {
                    self.finishedImages[task.originalRequest.URL] = image
                }
            }
            
        }
        self.dataInProgress.removeValueForKey(task)
        self.tasksInProgress.removeValueForKey(task.originalRequest.URL)
    }    
}
