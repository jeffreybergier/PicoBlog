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

class PicoDownloadManager {
    
    func downloadFileURL(url: NSURL) {
        NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: url),
            queue: NSOperationQueue.mainQueue())
            { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                
                if error == nil {
                    let downloadedData: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
                    if let downloadedArray = downloadedData as? [[NSString : NSObject]] {
                        for downloadedDictionary in downloadedArray {
                            if let downloadedMessage = PicoDataSource.sharedInstance.picoMessageFromDictionary(downloadedDictionary) {
                                PicoDataSource.sharedInstance.downloadedMessages.append(downloadedMessage)
                            }
                        }
                    }
                } else {
                    NSLog("\(self): Error downloading files: \(error.description)")
                }
        }
    }
    
}