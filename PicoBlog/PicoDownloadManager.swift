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

class PicoDownloadManager: NSObject, NSURLSessionDelegate, NSURLSessionDataDelegate {
    
    private lazy var session: NSURLSession = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue:NSOperationQueue.mainQueue())
        return session
        }()
    
    // CellImages Properties
    var dataFinished: [NSURL : NSData] = [:]
    var tasksInProgress: [NSURL : NSURLSessionTask] = [:]
    var tasksWithErrors: [NSURL : NSHTTPURLResponse] = [:]
    var tasksWithInvalidData: [NSURL : NSData] = [:]
    private var dataInProgress: [NSURLSessionTask : NSMutableData] = [:]
    
    func downloadURLArray(urlArray: [NSURL]) {
        for url in urlArray {
            let task = self.session.dataTaskWithURL(url)
            task.resume()
            self.tasksInProgress[url] = task
        }
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if let existingData = self.dataInProgress[dataTask] {
            existingData.appendData(data)
        } else {
            self.dataInProgress[dataTask] = NSMutableData(data: data)
        }
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
        var shouldContinue = false
        
        if let httpResponse = response as? NSHTTPURLResponse {
            if httpResponse.statusCode == 200 {
                shouldContinue = true
            } else {
                NSLog("\(self): Cancelling Download URL: \(dataTask.originalRequest.URL). Status Code: \(httpResponse.statusCode)")
                tasksWithErrors[dataTask.originalRequest.URL] = httpResponse
            }
        }
        
        if shouldContinue {
            completionHandler(NSURLSessionResponseDisposition.Allow)
        } else {
            completionHandler(NSURLSessionResponseDisposition.Cancel)
        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError!) {
        if error == nil {
            if let mutableData = self.dataInProgress[task] {
                let immutableData = NSData(data: mutableData)
                self.dataFinished[task.originalRequest.URL] = immutableData
                NSNotificationCenter.defaultCenter().postNotificationName("dataDownloadedSuccessfully", object: self)
            }
        } else {
            NSLog("\(self): Error downloading data: \(error)")
            NSNotificationCenter.defaultCenter().postNotificationName("dataDownloadFailed", object: self)
        }
        self.dataInProgress.removeValueForKey(task)
        self.tasksInProgress.removeValueForKey(task.originalRequest.URL)
    }
}
