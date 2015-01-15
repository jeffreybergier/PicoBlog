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
            NSNotificationCenter.defaultCenter().postNotificationName("newCellImageDownloaded", object: nil)
        }
    }
    private var imageDataInProgress: [NSURLSessionTask : NSMutableData] = [:]
    
    // Subscriptions Properties
    var picoMessageDataFinished: [PicoMessage] = []
    private var picoMessageTasksInProgress: [NSURL : NSURLSessionTask] = [:]
    private var picoMessageDataInProgress: [NSURLSessionTask : NSMutableData] = [:]
    
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
                self.picoMessageTasksInProgress[url] = task
            }
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
            if error == nil {
                if let data = self.imageDataInProgress[task] {
                    if let image = UIImage(data: data) {
                        self.imageDataFinished[task.originalRequest.URL] = image
                    }
                }
            }
            self.imageDataInProgress.removeValueForKey(task)
            self.imageTasksInProgress.removeValueForKey(task.originalRequest.URL)
        case .Subscriptions:
            if error == nil {
                if let data = self.picoMessageDataInProgress[task] {
                    let jsonData: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
                    if let jsonArray = jsonData as? [NSDictionary] {
                        for jsonDictionary in jsonArray {
                            if let downloadedMessage = PicoMessage(dictionary: jsonDictionary) {
                                self.picoMessageDataFinished.append(downloadedMessage)
                            }
                        }
                    }
                }
            }
        }
    }
}
