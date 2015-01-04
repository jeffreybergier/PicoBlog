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

class PicoDownloadManager: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    
    private var connectionsInProgress: [NSURLConnection] = []
    private var messagePlaceholder: [PicoMessage] = []
    
    func downloadFiles(#urlArray: [NSURL]) {
        for url in urlArray {
            if let connection = NSURLConnection(request: NSURLRequest(URL: url), delegate: self, startImmediately: true) {
                self.connectionsInProgress.append(connection)
            }
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        //remove the connection from the array. This keeps track of when all the downloads are complete
        for var i=0; i<self.connectionsInProgress.count; i++ {
            if connection == self.connectionsInProgress[i] {
                self.connectionsInProgress.removeAtIndex(i)
            }
        }
        //extract the PicoMessage from the NSData and put it into a placeholder array
        let downloadedData: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
        if let downloadedArray = downloadedData as? [[NSString : NSObject]] {
            for downloadedDictionary in downloadedArray {
                if let downloadedMessage = PicoDataSource.sharedInstance.picoMessageFromDictionary(downloadedDictionary) {
                    self.messagePlaceholder.append(downloadedMessage)
                }
            }
        }
        //if all the connections are done, set the downloaded messages property on the data source and clear the placeholder array
        if self.connectionsInProgress.count == 0 {
            PicoDataSource.sharedInstance.downloadedMessages = self.messagePlaceholder
            self.messagePlaceholder = []
        }

    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        NSLog("\(self): Error downloading file: \(error.description)")
        //remove the connection from the array. This keeps track of when all the downloads are complete
        for var i=0; i<self.connectionsInProgress.count; i++ {
            if connection == self.connectionsInProgress[i] {
                self.connectionsInProgress.removeAtIndex(i)
            }
        }
        //if all the connections are done, set the downloaded messages property on the data source and clear the placeholder array
        if self.connectionsInProgress.count == 0 {
            PicoDataSource.sharedInstance.downloadedMessages = self.messagePlaceholder
            self.messagePlaceholder = []
        }
    }
    
}