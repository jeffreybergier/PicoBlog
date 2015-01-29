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
    
    @IBOutlet private weak var bottomLayoutConstraint: NSLayoutConstraint?
    @IBOutlet private weak var messageTextView: UITextView?
    @IBOutlet private weak var buttonView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        var textViewEdgeInsets = self.messageTextView?.contentInset !! UIEdgeInsetsZero
        textViewEdgeInsets.bottom = self.buttonView?.frame.size.height !! 50.0
        self.messageTextView?.contentInset = textViewEdgeInsets
        
        self.title = NSLocalizedString("Compose", comment: "")
        
        self.messageTextView?.becomeFirstResponder()
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        var shouldPerformSegue = true
        
        if let identifier = identifier {
            switch identifier {
            case "cancelSegue":
                var shouldPerformSegue = true
            case "saveSegue":
                // do a bunch of work to save the message
                var shouldPerformSegue = true
            default:
                break
            }
        }
        
        return shouldPerformSegue
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.view.endEditing(true)
    }
    
    @IBAction func didSwipeKeyboardDown(sender: UISwipeGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        let keyboardSize = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size !! CGSize(width: 414, height: 271) //default US English keyboard size
        let keyboardAnimationNumber = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber !! NSNumber(double: 0.4) // default animation duration
        let keyboardAnimationDuration = keyboardAnimationNumber.doubleValue

        UIView.animateWithDuration(keyboardAnimationDuration, animations: { () -> Void in
            self.bottomLayoutConstraint?.constant = keyboardSize.height
            self.view.layoutIfNeeded()
            }, completion: { (finished: Bool) -> Void in
                var textViewEdgeInsets = self.messageTextView?.contentInset !! UIEdgeInsetsZero
                textViewEdgeInsets.bottom = self.buttonView?.frame.size.height !! 50.0
                textViewEdgeInsets.bottom += keyboardSize.height
                self.messageTextView?.contentInset = textViewEdgeInsets
        })
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        let keyboardSize = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size !! CGSize(width: 414, height: 271) //default US English keyboard size
        let keyboardAnimationNumber = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber !! NSNumber(double: 0.4) // default animation duration
        let keyboardAnimationDuration = keyboardAnimationNumber.doubleValue
        
        UIView.animateWithDuration(keyboardAnimationDuration, animations: { () -> Void in
            self.bottomLayoutConstraint?.constant = 0.0
            self.view.layoutIfNeeded()
            }, completion: { (finished: Bool) -> Void in
                var textViewEdgeInsets = self.messageTextView?.contentInset !! UIEdgeInsetsZero
                textViewEdgeInsets.bottom = self.buttonView?.frame.size.height !! 50.0
                self.messageTextView?.contentInset = textViewEdgeInsets
        })
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}