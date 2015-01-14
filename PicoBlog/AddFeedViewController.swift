//
// AddFeedViewController.swift
// PicoBlog
//
// Created by Jeffrey Bergier on 1/13/15.
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

class AddFeedViewController: UIViewController {
    
    @IBOutlet private weak var feedURLTitleLabel: UILabel!
    @IBOutlet private weak var feedURLTextField: UITextField!
    @IBOutlet private weak var feedPreviewTableView: UITableView!
    @IBOutlet private weak var feedLoadingSpinner: UIActivityIndicatorView!
    @IBOutlet private weak var feedURLTextFieldTrailingConstraint: NSLayoutConstraint!
    
    private var feedURLTextFieldConstraint: (loading: CGFloat, notLoading: CGFloat) = (0.0, 0.0)
    private var feedURLIsDownloading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.feedURLTitleLabel.text = NSLocalizedString("Feed URL:", comment: "")
        self.feedLoadingSpinner.stopAnimating()
        
        // prepare the constants for animating the text input field
        self.feedURLTextFieldConstraint.loading = self.feedURLTextFieldTrailingConstraint.constant
        self.feedURLTextFieldConstraint.notLoading = -1 * self.feedLoadingSpinner.frame.size.width
        self.feedURLTextFieldTrailingConstraint.constant = self.feedURLTextFieldConstraint.notLoading
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        

    }
    
    @IBAction private func feedURLTextDidChange(sender: UITextField) {
        if let url = NSURL(string: sender.text) {
            self.changeUIToDownloadingState()
        }
    }
    
    @objc private func testTimer(timer: NSTimer) {
        timer.invalidate()
        self.changeUIToNotDownloadingState()
    }
    
    private func changeUIToDownloadingState() {
        self.feedURLIsDownloading = true
        self.feedLoadingSpinner.startAnimating()
        UIView.animateWithDuration(0.3,
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            options: UIViewAnimationOptions.AllowUserInteraction,
            animations: { () -> Void in
                self.feedURLTextFieldTrailingConstraint.constant = self.feedURLTextFieldConstraint.loading
                self.view.layoutIfNeeded()
            }, completion: { (finished) -> Void in
                NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "testTimer:", userInfo: nil, repeats: false)
                return ()
        })
    }
    
    private func changeUIToNotDownloadingState() {
        UIView.animateWithDuration(0.3,
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            options: UIViewAnimationOptions.AllowUserInteraction,
            animations: { () -> Void in
                self.feedURLTextFieldTrailingConstraint.constant = self.feedURLTextFieldConstraint.notLoading
                self.view.layoutIfNeeded()
            }, completion: { (finished) -> Void in
                self.feedURLIsDownloading = false
                self.feedLoadingSpinner.stopAnimating()
        })
    }
    
}
