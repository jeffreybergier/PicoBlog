//
// PicoDataSource.swift
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

class PicoDataSource: NSObject, UITableViewDataSource {
    
    var currentUser = User(username: "jeffburg", feedURL: NSURL(string: "http://www.jeffburg.com/pico/feed1.pico")!, avatarImageURL: NSURL(string: "http://www.jeffburg.com/pico/images/123456789_small.jpeg")!)
    var downloadedMessages: [PicoMessage] = [] {
        didSet {
            self.downloadedMessages.sort({ $0.date.compare($1.date) == NSComparisonResult.OrderedAscending })
            NSNotificationCenter.defaultCenter().postNotificationName("DataSourceUpdated", object: nil)
        }
    }
    
    let dateFormatter = NSDateFormatter()
    let downloadManager = PicoDownloadManager()
    let postManager = PicoPostManager()
    let subscriptionManager = PicoSubscriptionManager()
    
    class var sharedInstance: PicoDataSource {
        struct Static {
            static var instance: PicoDataSource?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = PicoDataSource()
        }
        
        return Static.instance!
    }
    
    override init() {
        super.init()
        
        self.dateFormatter.dateFormat = "YYYY-MM-dd'-'HH:mm:ssZZZ"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.downloadedMessages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var identifierString: NSString
        if self.downloadedMessages[indexPath.row].picture?.url == nil {
            identifierString = "PicoMessageCellWithoutImage"
        } else {
            identifierString = "PicoMessageCellWithImage"
        }
        if let cell = tableView.dequeueReusableCellWithIdentifier(identifierString) as? FeedTableViewCell {
            cell.messagePost = self.downloadedMessages[indexPath.row]
            return cell
        } else {
            return UITableViewCell()
        }
    }

    func dictionaryFromPicoMessage(picoMessage: PicoMessage) -> [NSString : NSObject] {
        
        let date = picoMessage.date
        let username = picoMessage.user.username
        let userFeedURL = picoMessage.user.feedURL.description
        let userAvatarImageURL = picoMessage.user.avatar.url.description
        let messageText = picoMessage.text
        
        var dictionary: [NSString : NSObject] = [
            "date" : self.dateFormatter.stringFromDate(date),
            "username" : username,
            "userFeedURL" : userFeedURL,
            "userAvatarImageURL" : userAvatarImageURL,
            "messageText" : messageText,
        ]
        if let messagePictureImage = picoMessage.picture?.image {
            dictionary["messagePictureImage"] = messagePictureImage
        }
        if let messagePictureURL = picoMessage.picture?.url {
            dictionary["messagePictureURL"] = messagePictureURL.description
        }
        
        return dictionary
    }
    
    func picoMessageFromDictionary(dictionary: [NSString : NSObject]) -> PicoMessage? {
        
        var username: NSString?
        var userFeedURL: NSURL?
        var userAvatarImageURL: NSURL?
        var messageDate: NSDate?
        var messageText: NSString?
        var messagePictureImage: UIImage?
        var messagePictureURL: NSURL?

        //REQUIRED
        if let dateString = dictionary["date"] as? NSString {
            messageDate = self.dateFormatter.dateFromString(dateString)
        }
        
        if let verifiedUsername = dictionary["username"] as? NSString {
            username = verifiedUsername
        }
        
        if let verifiedUserFeedURL = dictionary["userFeedURL"] as? NSString {
            userFeedURL = NSURL(string: verifiedUserFeedURL)
        }
        
        if let verifiedUserAvatarImageURL = dictionary["userAvatarImageURL"] as? NSString {
            userAvatarImageURL = NSURL(string: verifiedUserAvatarImageURL)
        }
        
        if let verifiedMessageText = dictionary["messageText"] as? NSString {
            messageText = verifiedMessageText
        }
        
        //OPTIONAL
        if let verifiedMessagePictureImage = dictionary["messagePictureImage"] as? UIImage {
            messagePictureImage = verifiedMessagePictureImage
        }
        
        if let verifiedMessagePictureURL = dictionary["messagePictureURL"] as? NSString {
            messagePictureURL = NSURL(string: verifiedMessagePictureURL)
        }
        
        //CREATE THE MESSAGE
        //nesting the if lets leads to really unreadable code, so I'm doing this nil check
        if (username != nil &&
            userFeedURL != nil &&
            userAvatarImageURL != nil &&
            messageDate != nil &&
            messageText != nil)
        {
            var picoMessage = PicoMessage(IncompleteUsername: username!,
                avatarImageURL: userAvatarImageURL!,
                userFeedURL: userFeedURL!,
                messageDate: messageDate!,
                messageText: messageText!,
                messagePicture: (image: messagePictureImage, url: messagePictureURL))
            return picoMessage
        } else {
            return nil
        }
    }
}
