//
// PicoNonClassTypes.swift
// PicoBlog
//
// Created by Jeffrey Bergier on 1/1/15.
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
import CoreLocation

struct PicoMessage {
    
    let id: NSString
    let date: NSDate
    let user: User
    let text: NSString
    
    var picture: (image: UIImage?, url: NSURL?)?
    var location: CLLocation?
    
    init(CompleteUser messageUser: User, messageDate: NSDate, messageText: NSString, messagePicture: (image: UIImage?, url: NSURL?)?) {
        
        self.date = messageDate
        self.user = messageUser
        self.text = messageText
        self.picture = messagePicture
        
        self.id = messageDate.description + messageText
    }
    
    init(IncompleteUsername username: NSString, avatarImageURL: NSURL, userFeedURL: NSURL, messageDate: NSDate, messageText: NSString, messagePicture: (image: UIImage?, url: NSURL?)?) {
        
        self.date = messageDate
        self.text = messageText
        self.picture = messagePicture
        self.user = User(username: username, feedURL: userFeedURL, avatarImageURL: avatarImageURL)
        
        self.id = messageDate.description + messageText
    }
    
    private func generateMD5(#seedString: NSString) -> NSString {
        return seedString
    }
}

struct Subscription: Writable {
    let url: NSURL
    let date: NSDate
    let username: NSString
    
    init(url: NSURL, date: NSDate, username: NSString) {
        self.url = url
        self.date = date
        self.username = username
    }
    
    init?(dictionary: NSDictionary) {
        // NSUserDefaults can only accept NSData, NSString, NSNumber, NSDate
        // We need to convert everything to that.
        
        let date = dictionary["date"] as? NSDate
        let username = dictionary["username"] as? NSString
        let urlString = dictionary["urlString"] as? NSString
        var url: NSURL?
        if let urlString = urlString {
            url = NSURL(string: urlString)
        }
        if date != nil && username != nil && url != nil {
            self.url = url!
            self.date = date!
            self.username = username!
        } else {
            return nil
        }
    }
    
    func prepareForDisk() -> NSDictionary {
        // NSUserDefaults can only accept NSData, NSString, NSNumber, NSDate
        // We need to convert everything to that.
        let urlString: NSString! = self.url.absoluteString
        let dictionary: NSDictionary = ["urlString" : urlString, "date" : self.date, "username" : self.username]
        return dictionary
    }
}

struct User {
    
    let username: NSString
    let feedURL: NSURL
    var avatar: (image: UIImage?, url: NSURL)
    
    var bio: NSString?
    
    init(username: NSString, feedURL: NSURL, avatarImageURL: NSURL) {
        self.username = username
        self.avatar = (nil, avatarImageURL)
        self.feedURL = feedURL
    }
}

protocol Writable {
    // Requires that a Value/Object should be writable and readable from NSUserDefaults
    // NSUserDefaults can only accept NSData, NSString, NSNumber, NSDate
    // All other types will have to be converted in these two methods.
    init?(dictionary: NSDictionary)
    func prepareForDisk() -> NSDictionary
}