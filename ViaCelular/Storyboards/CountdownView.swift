//
//  CountdownView.swift
//  Vloom
//
//  Created by Mariano on 17/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CountdownView : UIControl {
    
    @IBOutlet weak var delegate: CountdownViewDelegate?
    @IBOutlet weak var label: UILabel!
    
    @IBInspectable var countdown: NSTimeInterval = 120
    @IBInspectable var autoStart: Bool = false
    
    private var current: NSTimeInterval = 0
    private var timer: NSTimer!
    internal var notificateInOneMinute : Bool = false
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupXib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupXib()
    }
    
    override func didMoveToSuperview() {
        
        super.didMoveToSuperview()
        
        if (self.autoStart) {
            self.start()
        }
        
    }
    
    func start() {
        self.startTimer()
        self.current = self.countdown
        self.updateText()
    }
    
    func resume() {
        self.startTimer()
    }
    
    func stop() {
        if (self.timer != nil) {
            self.timer.invalidate()
            self.timer = nil
        }
    }
    
    func onTick() {
        self.current -= 1
        self.updateText()
        
        if self.notificateInOneMinute
        {
            if self.current <= 60
            {
                self.notificateInOneMinute = false
                self.delegate?.countdownViewDidFinishInOneMinute(self)
            }
        }
        
        if (self.current <= 0) {
            self.stop()
            self.delegate?.countdownViewDidFinish(self)
        }
    }
    
    private func updateText() {
        if (self.current <= 0) {
            self.label.text = ""
        } else {
            self.label.text = "Te llamaremos en \(self.current.minuteSeconds)"
        }
    }
    
    private func startTimer() {
        self.stop()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "onTick", userInfo: nil, repeats: true)
    }
    
    var isRunning: Bool {
        get {
            return self.timer != nil
        }
    }
    
}

@objc(CountdownViewDelegate)
protocol CountdownViewDelegate
{
    func countdownViewDidFinish(countdownView: CountdownView)
    func countdownViewDidFinishInOneMinute(countdownView: CountdownView)
}