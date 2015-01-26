//
// ComposeMessageTableViewController.swift
// PicoBlog
//
// Created by Jeffrey Bergier on 1/25/15.
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

class ComposeMessageViewController: UIViewController {
    
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint?
    @IBOutlet weak var messageTextView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        let keyboardSize = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size
        let keyboardAnimationNumber = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber
        let keyboardAnimationDuration = keyboardAnimationNumber?.doubleValue

//        if let verifiedUserInfo = notification.userInfo {
//            if let animationValue = verifiedUserInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
//                let animationDuration = animationValue.doubleValue
//                keyboardAnimationDuration = animationDuration
        //                let curveValue = verifiedUserInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
        //                let animationCurve = curveValue?.integerValue
        //            }
        //        }
        if keyboardSize != nil && keyboardAnimationDuration != nil {
            UIView.animateWithDuration(keyboardAnimationDuration!, animations: { () -> Void in
                self.bottomLayoutConstraint?.constant = keyboardSize!.height
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        
    }
}