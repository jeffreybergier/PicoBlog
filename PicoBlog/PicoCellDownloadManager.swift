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

class PicoCellDownloadManager: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    
    var connectionsInProgress: [NSURLConnection : FeedTableViewCell] = [:]
    private var incompleteDataDictionary: [NSURLConnection : NSData] = [:]
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.incompleteDataDictionary[connection] = data
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        if let data = self.incompleteDataDictionary[connection] {
            if let image = UIImage(data: data) {
                if let cellPointer = self.connectionsInProgress[connection] {
                    cellPointer.receivedImage(image, ForConnection: connection)
                }
            } else {
                NSLog("Image not found in Data")
            }
        } else {
            NSLog("No Data In Dictionary")
        }
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        //self.connectionsInProgress.removeValueForKey(connection)
    }
    
}
