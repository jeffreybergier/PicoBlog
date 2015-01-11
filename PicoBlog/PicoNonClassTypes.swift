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

struct PicoMessage: Writable {
    
    let id: String
    let user: User
    let text: String
    let verifiedDate: VerifiedDate
    
    var verifiedPictureURL: VerifiedURL?
    var location: CLLocation?
    
    init?(CompleteUser messageUser: User, unverifiedDateString: String, messageText: String, unverifiedPictureURLString: String?) {
        self.user = messageUser
        self.text = messageText
        self.verifiedPictureURL = VerifiedURL(unverifiedURLString: unverifiedPictureURLString)
        
        if let verifiedDate = VerifiedDate(unverifiedDateString: unverifiedDateString) {
            self.verifiedDate = verifiedDate
            self.id = unverifiedDateString + messageText
        } else {
            return nil
        }
    }
    
    init?(IncompleteUsername username: String, unverifiedUserAvatarURLString: String, unverifiedUserFeedURLString: String, unverifiedMessageDateString: String, messageText: String, unverifiedPictureURLString: String?) {
        
        if let user = User(username: username, unverifiedFeedURLString: unverifiedUserFeedURLString, unverifiedAvatarURLString: unverifiedUserAvatarURLString) {
            self.init(CompleteUser: user, unverifiedDateString: unverifiedMessageDateString, messageText: messageText, unverifiedPictureURLString: unverifiedPictureURLString)
        } else {
            return nil
        }
    }
    
    init?(dictionary: NSDictionary) {
        //REQUIRED
        let messageDate = dictionary["date"] as? String
        let username = dictionary["username"] as? String
        let userFeedURL = dictionary["userFeedURL"] as? String
        let userAvatarImageURL = dictionary["userAvatarImageURL"] as? String
        let messageText = dictionary["messageText"] as? String
        
        //OPTIONAL
        let messagePictureURL = dictionary["messagePictureURL"] as? String
        
        //CREATE THE MESSAGE
        //nesting the if lets leads to really unreadable code, so I'm doing this nil check
        var user: User?
        var message: PicoMessage?
        
        if (username != nil && userFeedURL != nil && userAvatarImageURL != nil) {
            user = User(username: username!, unverifiedFeedURLString: userFeedURL!, unverifiedAvatarURLString: userAvatarImageURL!)
        } else {
            return nil
        }
        
        if (user != nil && messageDate != nil && messageText != nil) {
            self.init(CompleteUser: user!, unverifiedDateString: messageDate!, messageText: messageText!, unverifiedPictureURLString: messagePictureURL)
        } else {
            return nil
        }
    }
    
    func prepareForDisk() -> NSDictionary {
        let mutableDictionary: NSMutableDictionary = [
            "date" : self.verifiedDate.string,
            "username" : self.user.username,
            "userFeedURL" : self.user.verifiedFeedURL.string,
            "userAvatarImageURL" : self.user.verifiedAvatarURL.string,
            "messageText" : self.text,
        ]
        if let messagePictureURLString = self.verifiedPictureURL {
            mutableDictionary["messagePictureURL"] = messagePictureURLString.string
        }
        return NSDictionary(dictionary: mutableDictionary)
    }
    
    private func generateMD5(#seedString: NSString) -> NSString {
        return seedString
    }
}

struct User {
    let username: String
    let verifiedFeedURL: VerifiedURL
    let verifiedAvatarURL: VerifiedURL
    
    var bio: String?
    
    init?(username: String, unverifiedFeedURLString: String, unverifiedAvatarURLString: String) {
        self.username = username
        
        if let verifiedFeedURL = VerifiedURL(unverifiedURLString: unverifiedFeedURLString) {
            self.verifiedFeedURL = verifiedFeedURL
        } else {
            return nil
        }

        if let verifiedAvatarURL = VerifiedURL(unverifiedURLString: unverifiedAvatarURLString) {
            self.verifiedAvatarURL = verifiedAvatarURL
        } else {
            return nil
        }
    }
}

struct Subscription: Writable {
    let username: String
    let verifiedDate: VerifiedDate
    let verifiedURL: VerifiedURL
    
    init?(username: String, unverifiedURLString: String?, unverifiedDateString: String?) {
        self.username = username
        
        if let verifiedDate = VerifiedDate(unverifiedDateString: unverifiedDateString) {
            self.verifiedDate = verifiedDate
        } else {
            return nil
        }
        
        if let verifiedURL = VerifiedURL(unverifiedURLString: unverifiedURLString) {
            self.verifiedURL = verifiedURL
        } else {
            return nil
        }
    }
    
    init?(dictionary: NSDictionary) {        
        let username = dictionary["username"] as? String
        let unverifiedDateString = dictionary["dateString"] as? String
        let unverifiedURLString = dictionary["urlString"] as? String
        
        if username != nil {
            self.init(username: username!, unverifiedURLString: unverifiedURLString, unverifiedDateString: unverifiedDateString)
        } else {
            return nil
        }
    }
    
    func prepareForDisk() -> NSDictionary {
        let dictionary: NSDictionary = ["urlString" : self.verifiedURL.string, "dateString" : self.verifiedDate.string, "username" : self.username]
        return dictionary
    }
}

struct VerifiedDate: DateVerifiable {
    let string: String
    var date: NSDate {
        get {
            return PicoDataSource.sharedInstance.dateFormatter.dateFromString(self.string)!
        }
    }
    init?(unverifiedDateString: String?) {
        var success = false
        if let unverifiedDateString = unverifiedDateString {
            if let date = PicoDataSource.sharedInstance.dateFormatter.dateFromString(unverifiedDateString) {
                success = true
            }
        }
        if success {
            self.string = unverifiedDateString!
        } else {
            return nil
        }
    }
}

struct VerifiedURL: URLVerifiable {
    let string: String
    var url: NSURL {
        get {
            return NSURL(string: self.string)!
        }
    }
    
    init?(unverifiedURLString: String?) {
        var success = false
        if let unverifiedURLString = unverifiedURLString {
            if let url = NSURL(string: unverifiedURLString) {
                success = true
            }
        }
        if success {
            self.string = unverifiedURLString!
        } else {
            return nil
        }
    }
}

protocol DateVerifiable {
    // In an attempt to use only Swift Value types, I need a String to represent an NSDate
    // However, I want the String to be verified as part of the setting the property in the Struct
    // This protocol is designed to ensure that any Value that conform to it has a valid Date string.
    // If it doesn't, the date string will be nil
    
    var date: NSDate { get }
    init?(unverifiedDateString: String?)
}

protocol URLVerifiable {
    // In an attempt to use only Swift Value types, I need a String to represent an NSDate
    // However, I want the String to be verified as part of the setting the property in the Struct
    // This protocol is designed to ensure that any Value that conform to it has a valid Date string.
    // If it doesn't, the date string will be nil
    
    var url: NSURL { get }
    init?(unverifiedURLString: String?)
}

protocol Writable {
    // Requires that a Value/Object should be writable and readable from NSUserDefaults and NSJSONSerialization
    // NSUserDefaults can only accept NSData, NSString, NSNumber, NSDate
    // NSJSONSerialization basically only accepts Strings so that should be the lowest common denominator
    // All other types will have to be converted in these two methods.
    init?(dictionary: NSDictionary)
    func prepareForDisk() -> NSDictionary
}