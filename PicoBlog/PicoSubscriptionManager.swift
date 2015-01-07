//
// PicoSubscriptionManager.swift
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

class PicoSubscriptionManager {
    
    func readSubscriptionsFromDisk() -> [(username: NSString, url: NSURL)] {
        
        // fake data files for now
        let array: [(username: NSString, url: NSURL?)] = [
            ("jeffberg", NSURL(string: "http://www.jeffburg.com/pico/jeffburg.pico")),
            ("amazeballs", NSURL(string: "http://www.jeffburg.com/pico/amazeballs.pico"))
        ]
        
        // NSURL's are optional. Must check them before returning the array
        var verifiedArray: [(username: NSString, url: NSURL)] = []
        for tuple in array {
            if let url = tuple.url {
                let verifiedTuple: (username: NSString, url: NSURL) = (tuple.username, url)
                verifiedArray.append(verifiedTuple)
            }
        }
        
        return verifiedArray
    }
}