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
    }
    
    init(IncompleteUsername username: NSString, avatarImageURL: NSURL, userFeedURL: NSURL, messageDate: NSDate, messageText: NSString, messagePicture: (image: UIImage?, url: NSURL?)?) {
        
        self.date = messageDate
        self.text = messageText
        self.picture = messagePicture
        self.user = User(username: username, feedURL: userFeedURL, avatarImageURL: avatarImageURL)
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