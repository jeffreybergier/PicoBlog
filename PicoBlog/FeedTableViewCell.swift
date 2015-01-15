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
    
    private var avatarURL: NSURL?
    private var messagePictureURL: NSURL?
    
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
        self.avatarURL = nil
        self.messagePictureURL = nil
        
        self.messageTextLabel?.text = newMessage.text
        self.usernameTextLabel?.text = newMessage.user.username
        self.messageDateTextLabel?.text = self.dateFormatter.stringFromDate(newMessage.verifiedDate.date)
        
        self.avatarURL = newMessage.user.verifiedAvatarURL.url
        if let verifiedMessagePictureURL = self.messagePost?.verifiedPictureURL {
            self.messagePictureURL = verifiedMessagePictureURL.url
        }

        self.cellWillAppear()
    }
    
    @objc private func newCellImageDownloaded(notification: NSNotification) {
        self.cellWillAppear()
    }
    
    func cellDidDisappear() {
        if let avatarURL = self.avatarURL {
            PicoDataSource.sharedInstance.cellDownloadManager.imageTasksInProgress[avatarURL]?.suspend()
        }
        if let messagePictureURL = self.messagePictureURL {
            PicoDataSource.sharedInstance.cellDownloadManager.imageTasksInProgress[messagePictureURL]?.suspend()
        }
    }
    
    func cellWillAppear() {
        if let avatarURL = self.avatarURL {
            if let avatarImageView = self.userImageView {
                self.populateImageView(avatarImageView, WithURL: avatarURL)
            }
        }
        if let messagePictureURL = self.messagePictureURL {
            if let messageImageView = self.messageImageView {
                self.populateImageView(messageImageView, WithURL: messagePictureURL)
            }
        }
    }
    
    private func populateImageView(imageView: UIImageView, WithURL url: NSURL) {
        if imageView.image == nil {
            if let image = PicoDataSource.sharedInstance.cellDownloadManager.imageDataFinished[url] {
                imageView.image = image
                PicoDataSource.sharedInstance.cellDownloadManager.imageTasksInProgress[url]?.cancel()
                PicoDataSource.sharedInstance.cellDownloadManager.imageTasksInProgress.removeValueForKey(url)
            } else {
                if let existingTask = PicoDataSource.sharedInstance.cellDownloadManager.imageTasksInProgress[url] {
                    existingTask.resume()
                } else {
                    PicoDataSource.sharedInstance.cellDownloadManager.downloadURLArray([url])
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