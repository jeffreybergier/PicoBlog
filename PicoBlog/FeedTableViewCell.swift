//
// FeedTableViewCell.swift
// PicoBlog
//
// Created by Jeffrey Bergier on 1/2/15.
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

class FeedTableViewCell: UITableViewCell {
    
    var messagePost: PicoMessage? {
        didSet {
            if let newMessage = self.messagePost{
                self.updateViewWithNewPicoMessage(newMessage)
            }
        }
    }
    
    private let dateFormatter = NSDateFormatter()
    
    @IBOutlet private weak var userImageView: UIImageView?
    @IBOutlet private weak var messageImageView: UIImageView?
    @IBOutlet private weak var messageTextLabel: UILabel?
    @IBOutlet private weak var usernameTextLabel: UILabel?
    @IBOutlet private weak var messageDateTextLabel: UILabel?
    
    override func awakeFromNib() {
        self.dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        self.dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        self.messageTextLabel?.text = ""
        self.usernameTextLabel?.text = ""
        self.messageDateTextLabel?.text = ""
    }
    
    private func updateViewWithNewPicoMessage(newMessage: PicoMessage) {
        self.messageTextLabel?.text = ""
        self.usernameTextLabel?.text = ""
        self.messageDateTextLabel?.text = ""
        self.userImageView?.image = nil
        self.messageImageView?.image = nil
        
        self.messageTextLabel?.text = newMessage.text
        self.usernameTextLabel?.text = newMessage.user.username
        self.messageDateTextLabel?.text = self.dateFormatter.stringFromDate(newMessage.date)
        
        var avatarRequest = NSURLRequest(URL: newMessage.user.avatar.url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        if let avatarURLConnection = NSURLConnection(request: avatarRequest, delegate: PicoDataSource.sharedInstance.cellDownloadManager, startImmediately: true) {
            PicoDataSource.sharedInstance.cellDownloadManager.connectionsInProgress[avatarURLConnection.description] = self
        }
        if let messageImageURL = newMessage.picture?.url {
            var messageImageRequest = NSURLRequest(URL: messageImageURL, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
            if let messageImageURLConnection = NSURLConnection(request: messageImageRequest, delegate: PicoDataSource.sharedInstance.cellDownloadManager, startImmediately: true) {
                PicoDataSource.sharedInstance.cellDownloadManager.connectionsInProgress[messageImageURLConnection.description] = self
            }
        }
    }
    
    func receivedImage(image: UIImage, ForConnection connection: NSURLConnection) {
        if connection.originalRequest.URL == self.messagePost?.user.avatar.url {
            self.userImageView?.image = image
        }
        if connection.originalRequest.URL == self.messagePost?.picture?.url {
            self.messageImageView?.image = image
        }
    }
}