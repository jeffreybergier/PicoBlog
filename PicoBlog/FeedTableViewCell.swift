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
        self.messageTextLabel?.text = newMessage.text
        self.usernameTextLabel?.text = newMessage.user.username
        self.messageDateTextLabel?.text = self.dateFormatter.stringFromDate(newMessage.date)
        
        self.downloadImageForAvatar(true, WithURL: newMessage.user.avatar.url)
        if let messageImageURL = newMessage.picture?.url {
            self.downloadImageForAvatar(false, WithURL: messageImageURL)
        }
    }
    
    private func downloadImageForAvatar(avatar: Bool, WithURL url: NSURL) {
        NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: url),
            queue: NSOperationQueue.mainQueue())
            { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                
                if error == nil {
                    if let verifiedResponseURL = response.URL {
                        if avatar {
                            if verifiedResponseURL == self.messagePost?.user.avatar.url {
                                if let avatarImage = UIImage(data: data) {
                                    self.userImageView?.image = avatarImage
                                }
                            } else {
                                NSLog("\(self): Received new Avatar Image but URL didn't match the current cell. The user probably scrolled and the cell was recycled. Throwing away results.")
                            }
                        } else {
                            if verifiedResponseURL == self.messagePost?.picture?.url {
                                if let messageImage = UIImage(data: data) {
                                    self.messageImageView?.image = messageImage
                                }
                            } else {
                                NSLog("\(self): Received new Message Image but URL didn't match the current cell. The user probably scrolled and the cell was recycled. Throwing away results.")
                            }
                        }
                    }
                } else {
                    NSLog("\(self): Error downloading files: \(error.description)")
                }
        }
    }
    
}