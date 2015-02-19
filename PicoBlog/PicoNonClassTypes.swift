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

struct PicoMessage: Writable, Hashable, Printable {
    
    let user: User
    let text: String
    let verifiedDate: VerifiedDate
    
    var verifiedPictureURL: VerifiedURL?
    var location: CLLocation?
    var unknownItems: [String : String]?
    
    // PRINTABLE
    var description: String {
        get {
            return "PicoMessage: \(self.verifiedDate.string): \(self.user.username): \(self.text)"
        }
    }
    
    init?(CompleteUser messageUser: User, unverifiedDateString: String, messageText: String, unverifiedPictureURLString: String?, unknownItems: [String : String]?) {
        self.user = messageUser
        self.text = messageText
        self.verifiedPictureURL = VerifiedURL(unverifiedURLString: unverifiedPictureURLString)
        self.unknownItems = unknownItems
        
        if let verifiedDate = VerifiedDate(unverifiedDateString: unverifiedDateString) {
            self.verifiedDate = verifiedDate
        } else {
            return nil
        }
    }
    
    init?(IncompleteUsername username: String, unverifiedUserAvatarURLString: String, unverifiedUserFeedURLString: String, unverifiedMessageDateString: String, messageText: String, unverifiedPictureURLString: String?, unknownItems: [String : String]?) {
        
        if let user = User(username: username, unverifiedFeedURLString: unverifiedUserFeedURLString, unverifiedAvatarURLString: unverifiedUserAvatarURLString) {
            self.init(CompleteUser: user, unverifiedDateString: unverifiedMessageDateString, messageText: messageText, unverifiedPictureURLString: unverifiedPictureURLString, unknownItems: nil)
        } else {
            return nil
        }
    }
    
    init?(dictionary: NSDictionary) {
        // REQUIRED
        var messageDate: String?
        var username: String?
        var userFeedURL: String?
        var userAvatarImageURL: String?
        var messageText: String?
        
        // OPTIONAL
        var messagePictureURL: String?
        
        // Extras
        var extrasDictionary: [String : String]?
        
        // Loop through the dictionary so that expected data can be pulled out.
        // Unexpected data will be put into a dictionary for possible use later.
        for (value, key) in dictionary {
            if let stringValue = value as? String {
                switch stringValue {
                case "date":
                    messageDate = key as? String
                case "username":
                    username = key as? String
                case "userFeedURL":
                    userFeedURL = key as? String
                case "userAvatarImageURL":
                    userAvatarImageURL = key as? String
                case "messageText":
                    messageText = key as? String
                case "messagePictureURL":
                    messagePictureURL = key as? String
                default:
                    extrasDictionary = [:] //allocate the dictionary
                    extrasDictionary![stringValue] = key as? String //now we know its safe, thus the !
                }
            }
        }
        
        // CREATE THE MESSAGE
        var user: User?
        var message: PicoMessage?
        
        if let username = username, let userFeedURL = userFeedURL, userAvatarImageURL = userAvatarImageURL {
            user = User(username: username, unverifiedFeedURLString: userFeedURL, unverifiedAvatarURLString: userAvatarImageURL)
        } else {
            return nil
        }
        
        if let user = user, messageDate = messageDate, messageText = messageText {
            self.init(CompleteUser: user, unverifiedDateString: messageDate, messageText: messageText, unverifiedPictureURLString: messagePictureURL, unknownItems: extrasDictionary)
        } else {
            return nil
        }
    }
    
    func prepareForDisk() -> [String : String] {
        var dictionary = [
            "date" : self.verifiedDate.string,
            "username" : self.user.username,
            "userFeedURL" : self.user.verifiedFeedURL.string,
            "userAvatarImageURL" : self.user.verifiedAvatarURL.string,
            "messageText" : self.text,
        ]
        if let messagePictureURLString = self.verifiedPictureURL {
            dictionary["messagePictureURL"] = messagePictureURLString.string
        }
        return dictionary
    }
    
    var hashValue: Int {
        get {
            let combinedString = self.verifiedDate.string + self.text
            return combinedString.hashValue
        }
    }
}

// This is for Equatable on PicoMessage struct
func ==(lhs: PicoMessage, rhs: PicoMessage) -> Bool {
    return lhs.verifiedDate.string == rhs.verifiedDate.string && lhs.text == rhs.text
}

struct User: Printable {
    let username: String
    let verifiedFeedURL: VerifiedURL
    let verifiedAvatarURL: VerifiedURL
    
    var bio: String?
    
    // PRINTABLE
    var description: String {
        get {
            return "User: \(self.username): \(self.verifiedFeedURL.string)"
        }
    }
    
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

struct Subscription: Writable, Hashable, Printable {
    let username: String
    let verifiedDate: VerifiedDate
    let verifiedURL: VerifiedURL
    
    // PRINTABLE
    var description: String {
        get {
            return "Subscription: \(self.username): \(self.verifiedURL.string)"
        }
    }
    
    init?(username: String?, unverifiedURLString: String?, unverifiedDateString: String?) {
        if let username = username {
            self.username = username
        } else {
            return nil
        }
        
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
    
    func prepareForDisk() -> [String : String] {
        let dictionary = ["urlString" : self.verifiedURL.string, "dateString" : self.verifiedDate.string, "username" : self.username]
        return dictionary
    }
    
    var hashValue: Int {
        get {
            let combinedString = self.verifiedURL.string + self.verifiedDate.string
            return combinedString.hashValue
        }
    }
}
// This is for Equatable on Subscription struct
func ==(lhs: Subscription, rhs: Subscription) -> Bool {
    return lhs.verifiedURL.string == rhs.verifiedURL.string && lhs.verifiedDate.string == rhs.verifiedDate.string
}

struct VerifiedDate: DateVerifiable, Printable {
    let string: String
    var date: NSDate {
        get {
            return PicoDataSource.sharedInstance.dateFormatter.dateFromString(self.string)!
        }
    }
    
    // PRINTABLE
    var description: String {
        get {
            return "VerifiedDate: \(self.string)"
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
    let trimmedString: String
    var url: NSURL {
        get {
            return NSURL(string: self.string)!
        }
    }
    
    // PRINTABLE
    var description: String {
        get {
            return "VerifiedURL: \(self.string)"
        }
    }
    
    init?(unverifiedURLString: String?) {
        var success = false
        if let unverifiedURLString = unverifiedURLString {
            if VerifiedURL.stringContainsURL(unverifiedURLString) {
                if let url = NSURL(string: unverifiedURLString) {
                    success = true
                }
            }
        }
        if success {
            self.string = unverifiedURLString!
            self.trimmedString = VerifiedURL.trimURLString(unverifiedURLString!)
        } else {
            return nil
        }
    }
    
    static func stringContainsURL(string: String) -> Bool {
        var matches = false
        let urlRegEx = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        let predicate = NSPredicate(format: "SELF MATCHES %@", urlRegEx)
        matches = predicate.evaluateWithObject(string)
//        if let predicate = NSPredicate(format: "SELF MATCHES %@", urlRegEx) {
//            matches = predicate.evaluateWithObject(string)
//        }
        return matches
    }
    
    static func trimURLString(string: String) -> String {
        var compiledString = ""
        var slashStringArray: [String] = []
        let separatedBySlash = string.componentsSeparatedByString("/")
        for string in separatedBySlash {
            if string == "http:" || string == "https:" || string == "" {
                // do nothing
            } else {
                slashStringArray.append(string)
            }
        }
        
        let dotStringArray = slashStringArray[0].componentsSeparatedByString(".")
        for var i = 0; i < dotStringArray.count; i++ {
            if dotStringArray[i] == "www" {
                // do nothing
            } else {
                compiledString += dotStringArray[i]
                if i < dotStringArray.count - 1 {
                    compiledString += "."
                }
            }
        }
    
        for var i = 0; i<slashStringArray.count; i++ {
            if i == 0 {
                compiledString += "/"
            } else {
                compiledString += slashStringArray[i]
                if i < slashStringArray.count - 1 {
                    compiledString += "/"
                }
            }
        }
        
        return compiledString
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
    func prepareForDisk() -> [String : String]
}

// Operator Overloading!!
// AssertingNilCoalescing operator crashes when LHS is nil when App is in Debug Build.
// When App is in release build, it performs ?? operator
// Crediting http://blog.human-friendly.com/theanswer-equals-maybeanswer-or-a-good-alternative

infix operator !! { associativity right precedence 110 }
public func !!<A>(lhs:A?, @autoclosure rhs:()->A)->A {
    assert(lhs != nil)
    return lhs ?? rhs()
}

// Extending array
// There were several cases where I was checking to make sure the index was in range before extracting the value
// This code seemed clumsy, so I added this so I can deal with an optional instead.
extension Array {
    func optionalItemAtIndex(index: Int) -> T? {
        if self.count > index && index >= 0 {
            return self[index] // this returns nil if out of range.
        }
        return nil
    }
    
    func itemAtIndex(index: Int) -> T? {
        return self[index] // this crashes if out of range
    }
}

enum DownloadError {
    case FileTooLarge, FileNotFound, Other
}