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
    var dataFinished: [URLString : NSData] = [:]
    var tasksInProgress: [URLString : NSURLSessionTask] = [:]
    var tasksWithErrors: [URLString : (response: NSHTTPURLResponse, downloadError: DownloadError)] = [:]
    var tasksWithInvalidData: [URLString : NSData] = [:]
    private var dataInProgress: [URLString : NSMutableData] = [:]
    
    func downloadURLStringArray(urlStringArray: [String]) {
        for string in urlStringArray {
            if let existingTask = self.tasksInProgress[string] {
                existingTask.resume()
            } else {
                if let url = NSURL(string: string) {
                    let newTask = self.session.dataTaskWithURL(url)
                    newTask.resume()
                    self.tasksInProgress[url.description] = newTask
                }
            }
        }
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if let dataTaskURL = dataTask.originalRequest.URL {
            if let existingData = self.dataInProgress[dataTaskURL.description] {
                existingData.appendData(data)
            } else {
                self.dataInProgress[dataTaskURL.description] = NSMutableData(data: data)
            }
        }
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        var shouldContinue = ReceivedResponse.ShouldCancel
        if let httpResponse = (response as? NSHTTPURLResponse) {
            switch httpResponse.statusCode {
            case 200:
                switch self.downloadSizeIsAcceptible(Int(httpResponse.expectedContentLength)) {
                case true:
                    shouldContinue = .ShouldAllow
                case false:
                    NSLog("\(self): Canceling Download URL: \(dataTask.originalRequest.URL): File Too Big: \(httpResponse.expectedContentLength) bytes")
                    if let dataTaskURL = dataTask.originalRequest.URL {
                        self.tasksWithErrors[dataTaskURL.description] = (httpResponse, DownloadError.FileTooLarge)
                    }
                default:
                    break
                }
            case 404:
                NSLog("\(self): Canceling Download URL: \(dataTask.originalRequest.URL). Status Code: \(httpResponse.statusCode)")
                if let dataTaskURL = dataTask.originalRequest.URL {
                    self.tasksWithErrors[dataTaskURL.description] = (httpResponse, DownloadError.FileNotFound)
                }
            default:
                NSLog("\(self): Canceling Download URL: \(dataTask.originalRequest.URL). Status Code: \(httpResponse.statusCode)")
                if let dataTaskURL = dataTask.originalRequest.URL {
                    self.tasksWithErrors[dataTaskURL.description] = (httpResponse, DownloadError.Other)
                }
            }
            
            switch shouldContinue {
            case .ShouldAllow:
                completionHandler(NSURLSessionResponseDisposition.Allow)
            case .ShouldCancel:
                completionHandler(NSURLSessionResponseDisposition.Cancel)
            case .ShouldBecomeDownload:
                completionHandler(NSURLSessionResponseDisposition.BecomeDownload)
            }
        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let dataTaskURL = task.originalRequest.URL {
            if error == nil {
                if let mutableData = self.dataInProgress[dataTaskURL.description] {
                    let immutableData = NSData(data: mutableData)
                    self.dataFinished[dataTaskURL.description] = immutableData
                    NSNotificationCenter.defaultCenter().postNotificationName("dataDownloadedSuccessfully", object: self)
                }
            } else {
                NSLog("\(self): Error downloading data: \(error)")
                NSNotificationCenter.defaultCenter().postNotificationName("dataDownloadFailed", object: self)
            }
            self.dataInProgress.removeValueForKey(dataTaskURL.description)
            self.tasksInProgress.removeValueForKey(dataTaskURL.description)
        }
    }
    
    private func downloadSizeIsAcceptible(downloadSize: Int) -> Bool {
        var downloadSizeIsAcceptible = false
        
        if downloadSize < 250000 {
            downloadSizeIsAcceptible = true
        }
        
        return true //downloadSizeIsAcceptible
    }
    
    enum ReceivedResponse {
        case ShouldAllow, ShouldCancel, ShouldBecomeDownload
    }
}
