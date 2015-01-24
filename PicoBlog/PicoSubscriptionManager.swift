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
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    func readSubscriptionsFromDisk() -> [Subscription]? {
        self.userDefaults.synchronize()
        var subscriptions: [Subscription] = []
        if let subscriptionsArray = self.userDefaults.arrayForKey("Subscriptions") as? [NSDictionary] {
            for dictionary in subscriptionsArray {
                if let subscription = Subscription(dictionary: dictionary) {
                    subscriptions.append(subscription)
                }
            }
        }
        if subscriptions.count > 0 {
            return subscriptions
        } else {
            return nil
        }
    }
    
    func overwriteSubscriptionsToDisk(subscriptions: [Subscription]) -> NSError? {
        var mutableArray = NSMutableArray()
        
        for subscription in subscriptions {
            mutableArray.addObject(subscription.prepareForDisk())
        }
        if mutableArray.count > 0 {
            let array = NSArray(array: mutableArray)
            self.userDefaults.setObject(array, forKey: "Subscriptions")
        } else {
            self.userDefaults.removeObjectForKey("Subscriptions")
        }
        self.userDefaults.synchronize()
        return nil
    }
    
    func deleteSubscriptionsFromDisk(deletedSubscriptions: [Subscription]) -> NSError? {
        if var currentSubscriptions = self.readSubscriptionsFromDisk() {
            for deletedSubscription in deletedSubscriptions {
                for (index, currentSubscription) in enumerate(currentSubscriptions) {
                    if deletedSubscription.verifiedURL.string == currentSubscription.verifiedURL.string {
                        currentSubscriptions.removeAtIndex(index)
                        break
                    }
                }
            }
            if let error = self.overwriteSubscriptionsToDisk(currentSubscriptions) {
                return error
            }
        } else {
            return NSError(domain: "PicoBlog", code: 502, userInfo: nil)
        }
        return nil
    }
    
    func appendSubscriptionToDisk(newSubscription: Subscription) -> NSError? {
        if var subsriptionsAlreadyOnDisk = self.readSubscriptionsFromDisk() {
            var subscriptionAlreadyExists = false
            for existingSubscription in subsriptionsAlreadyOnDisk {
                if existingSubscription.verifiedURL.trimmedString == newSubscription.verifiedURL.trimmedString {
                    subscriptionAlreadyExists = true
                    break
                }
            }
            if subscriptionAlreadyExists == false {
                subsriptionsAlreadyOnDisk.append(newSubscription)
                if let error = self.overwriteSubscriptionsToDisk(subsriptionsAlreadyOnDisk) {
                    // error provided by nsuserdefaults method
                    return error
                }
            } else {
                // made up error for subscription already exists
                return NSError(domain: "PicoBlog", code: 501, userInfo: nil)
            }
        } else {
            // nothing is on the disk, so just set it
            if let error = self.overwriteSubscriptionsToDisk([newSubscription]) {
                // error provided by nsuserdefaults method
                return error
            }
        }
        return nil
    }
}