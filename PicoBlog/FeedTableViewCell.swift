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
    
    private var avatarURLString: String?
    private var messagePictureURLString: String?
    
    @IBOutlet private weak var userImageView: UIImageView?
    @IBOutlet private weak var messageImageView: UIImageView?
    @IBOutlet private weak var messageTextLabel: UILabel?
    @IBOutlet private weak var usernameTextLabel: UILabel?
    @IBOutlet private weak var messageDateTextLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newCellImageDownloaded:", name: "newImagesConfirmedByDataSource", object: PicoDataSource.sharedInstance)
        
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
        self.avatarURLString = nil
        self.messagePictureURLString = nil
        
        self.messageTextLabel?.text = newMessage.text
        self.usernameTextLabel?.text = newMessage.user.username
        self.messageDateTextLabel?.text = self.dateFormatter.stringFromDate(newMessage.verifiedDate.date)
        
        self.avatarURLString = newMessage.user.verifiedAvatarURL.string
        if let verifiedMessagePictureURL = self.messagePost?.verifiedPictureURL {
            self.messagePictureURLString = verifiedMessagePictureURL.string
        }

        self.cellWillAppear()
    }
    
    @objc private func newCellImageDownloaded(notification: NSNotification) {
        self.cellWillAppear()
    }
    
    func cellDidDisappear() {
        if let avatarURL = self.avatarURLString {
            PicoDataSource.sharedInstance.cellImageDownloadManager.tasksInProgress[avatarURL]?.suspend()
        }
        if let messagePictureURL = self.messagePictureURLString {
            PicoDataSource.sharedInstance.cellImageDownloadManager.tasksInProgress[messagePictureURL]?.suspend()
        }
    }
    
    func cellWillAppear() {
        if let avatarURLString = self.avatarURLString {
            if let avatarImageView = self.userImageView {
                self.populateImageView(avatarImageView, WithURLString: avatarURLString)
            }
        }
        if let messagePictureURLString = self.messagePictureURLString {
            if let messageImageView = self.messageImageView {
                self.populateImageView(messageImageView, WithURLString: messagePictureURLString)
            }
        }
    }
    
    private func populateImageView(imageView: UIImageView, WithURLString urlString: String) {
        if imageView.image == nil {
            if let image = PicoDataSource.sharedInstance.downloadedImages[urlString] {
                imageView.image = image
            } else {
                if let existingTask = PicoDataSource.sharedInstance.cellImageDownloadManager.tasksInProgress[urlString] {
                    existingTask.resume()
                } else {
                    PicoDataSource.sharedInstance.cellImageDownloadManager.downloadURLStringArray([urlString])
                }
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}