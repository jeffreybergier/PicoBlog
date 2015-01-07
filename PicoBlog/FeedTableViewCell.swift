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
        super.awakeFromNib()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newCellImageDownloaded:", name: "newCellImageDownloaded", object: nil)
        
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
        
        self.cellWillAppear()
    }
    
    @objc private func newCellImageDownloaded(notification: NSNotification) {
        self.cellWillAppear()
    }
    
    func cellDidDisappear() {
        if let message = self.messagePost {
            PicoDataSource.sharedInstance.cellDownloadManager.tasksInProgress[message.user.avatar.url]?.suspend()
            //PicoDataSource.sharedInstance.cellDownloadManager.finishedImages.removeValueForKey(message.user.avatar.url) //this line is optional and it is used to save memory.
        }
        if let messageImageURL = self.messagePost?.picture?.url {
            PicoDataSource.sharedInstance.cellDownloadManager.tasksInProgress[messageImageURL]?.suspend()
            //PicoDataSource.sharedInstance.cellDownloadManager.finishedImages.removeValueForKey(messageImageURL) //this line is optional and it is used to save memory.
        }
    }
    
    func cellWillAppear() {
        if let message = self.messagePost {
            if let avatarImageView = self.userImageView {
                self.populateImageView(avatarImageView, WithURL: message.user.avatar.url)
            }
        }
        if let messageImageURL = self.messagePost?.picture?.url {
            if let messageImageView = self.messageImageView {
                self.populateImageView(messageImageView, WithURL: messageImageURL)
            }
        }
    }
    
    private func populateImageView(imageView: UIImageView, WithURL url: NSURL) {
        if imageView.image == nil {
            if let image = PicoDataSource.sharedInstance.cellDownloadManager.finishedImages[url] {
                imageView.image = image
                PicoDataSource.sharedInstance.cellDownloadManager.tasksInProgress[url]?.cancel()
                PicoDataSource.sharedInstance.cellDownloadManager.tasksInProgress.removeValueForKey(url)
            } else {
                if let existingTask = PicoDataSource.sharedInstance.cellDownloadManager.tasksInProgress[url] {
                    existingTask.resume()
                } else {
                    PicoDataSource.sharedInstance.cellDownloadManager.downloadImageWithURL(url)
                }
            }
        }
    }
    
//    private func populateAvatarImage() {
//        if self.userImageView?.image == nil {
//            if let message = self.messagePost {
//                if let image = PicoDataSource.sharedInstance.cellDownloadManager.finishedImages[message.user.avatar.url] {
//                    self.userImageView?.image = image
//                    PicoDataSource.sharedInstance.cellDownloadManager.tasksInProgress[message.user.avatar.url]?.cancel()
//                    PicoDataSource.sharedInstance.cellDownloadManager.tasksInProgress.removeValueForKey(message.user.avatar.url)
//                } else {
//                    if let existingTask = PicoDataSource.sharedInstance.cellDownloadManager.tasksInProgress[message.user.avatar.url] {
//                        existingTask.resume()
//                    } else {
//                        PicoDataSource.sharedInstance.cellDownloadManager.downloadImageWithURL(message.user.avatar.url)
//                    }
//                }
//            }
//        }
//    }
//    
//    private func populateMessageImage() {
//        if self.messageImageView?.image == nil {
//            if let messageImageURL = self.messagePost?.picture?.url {
//                if let image = PicoDataSource.sharedInstance.cellDownloadManager.finishedImages[messageImageURL] {
//                    self.messageImageView?.image = image
//                    PicoDataSource.sharedInstance.cellDownloadManager.tasksInProgress[messageImageURL]?.cancel()
//                    PicoDataSource.sharedInstance.cellDownloadManager.tasksInProgress.removeValueForKey(messageImageURL)
//                } else {
//                    if let existingTask = PicoDataSource.sharedInstance.cellDownloadManager.tasksInProgress[messageImageURL] {
//                        existingTask.resume()
//                    } else {
//                        PicoDataSource.sharedInstance.cellDownloadManager.downloadImageWithURL(messageImageURL)
//                    }
//                }
//            }
//        }
//    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}