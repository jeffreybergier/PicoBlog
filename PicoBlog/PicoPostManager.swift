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
    
    func createFakeDataAndSaveToDisk() {
        
        let date = NSDate(timeIntervalSinceNow: 0)
        let username = "jeffberg"
        let message = "This is a message that has less than 120 characters"
        let userPicture: (image: UIImage?, url: NSURL?) = (nil, nil)
        
        var fakeMessage1 = picoMessage(date: date, username: username, message: message, userPicture: userPicture)
        
        let date2 = NSDate(timeIntervalSinceNow: 2000)
        let username2 = "bravislavsky"
        let message2 = "This is a more complicated message with less than 120 characters"
        let userPicture2: (image: UIImage?, url: NSURL?) = (nil, nil)
        
        var fakeMessage2 = picoMessage(date: date2, username: username2, message: message2, userPicture: userPicture2)
        
        let error = NSErrorPointer()
        let dirPaths = NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true, error: error)
        let fullURL = dirPaths?.URLByAppendingPathComponent("file.json")
        let data = NSJSONSerialization.dataWithJSONObject(self.createJSONFile([fakeMessage1, fakeMessage2]), options: NSJSONWritingOptions.PrettyPrinted, error: error)
        data!.writeToURL(fullURL!, atomically: true)
    }
    
    func createJSONFile(picoMessageArray: [picoMessage]) -> [[NSString : NSObject]] {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("YYYY-MM-dd'T'HH:mm:ssZZZ")
        
        var arrayOfDictionaries: [[NSString : NSObject]] = []
        for picoMessage in picoMessageArray {
            let date = picoMessage.date
            let username = picoMessage.username
            let message = picoMessage.message
            let userPicture = picoMessage.userPicture
            
            var messageDictionary: [NSString : NSObject] = [
                "date" : dateFormatter.stringFromDate(date),
                "username" : username,
                "message" : message,
            ]
            if let newImage = userPicture.image {
                messageDictionary["userPicture"] = newImage
            }
            if let newImageURL = userPicture.url {
                messageDictionary["userPictureURL"] = newImageURL
            }
            
            arrayOfDictionaries.append(messageDictionary)
        }
    
        return arrayOfDictionaries
    }
    
}