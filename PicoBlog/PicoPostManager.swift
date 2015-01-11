//
// PicoPostManager.swift
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

class PicoPostManager {
    
    /*
    func createFakeDataAndSaveToDisk() {
        
        let date = NSDate(timeIntervalSinceNow: 0)
        let username = "jeffberg"
        let userFeedURL = NSURL(string: "http://www.jeffburg.com/pico")
        let userAvatarImageURL = NSURL(string: "http://www.jeffburg.com/pico/images/123456789_small.jpeg")
        let messageText = "This is a message that has less than 120 characters"
        
        let fakeMessage1 = PicoMessage(IncompleteUsername: username,
            avatarImageURL: userAvatarImageURL!,
            userFeedURL: userFeedURL!,
            messageDate: date,
            messageText: messageText,
            messagePicture: (image: nil, url: NSURL(string: "http://www.jeffburg.com/pico/images/123456789_small.jpeg")))
        let fakeMessage1Dictionary = PicoDataSource.sharedInstance.dictionaryFromPicoMessage(fakeMessage1)
        
        let date2 = NSDate(timeIntervalSinceNow: 2000)
        let username2 = "salmonpink"
        let userFeedURL2 = NSURL(string: "http://www.jeffburg.com/pico")
        let userAvatarImageURL2 = NSURL(string: "http://www.jeffburg.com/pico/images/123456789_small.jpeg")
        let messageText2 = "This is another message that has less than 120 characters"
        
        let fakeMessage2 = PicoMessage(IncompleteUsername: username2,
            avatarImageURL: userAvatarImageURL2!,
            userFeedURL: userFeedURL2!,
            messageDate: date2,
            messageText: messageText2,
            messagePicture: (image: nil, url: NSURL(string: "http://www.jeffburg.com/pico/images/123456789_small.jpeg")))
        let fakeMessage2Dictionary = PicoDataSource.sharedInstance.dictionaryFromPicoMessage(fakeMessage2)
        
        let error = NSErrorPointer()
        let dirPaths = NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true, error: error)
        let fullURL = dirPaths?.URLByAppendingPathComponent("file.json")
        let data = NSJSONSerialization.dataWithJSONObject([fakeMessage1Dictionary, fakeMessage2Dictionary], options: NSJSONWritingOptions.PrettyPrinted, error: error)
        data!.writeToURL(fullURL!, atomically: true)
    }
*/
    
}