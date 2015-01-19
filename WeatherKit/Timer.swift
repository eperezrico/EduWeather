//
//  Timer.swift
//  EduWeather
//
//  Created by Eduardo on 1/18/15.
//
//

import Foundation

class Timer {
    var timer: NSTimer?
    let handler: () -> ()
    let repeats: Bool
    let interval: NSTimeInterval
    let queue: dispatch_queue_t?
    
    init(interval: NSTimeInterval, queue: dispatch_queue_t?, repeats: Bool, autostart: Bool, handler: () -> ()) {
        self.interval = interval
        self.queue = queue
        self.handler = handler
        self.repeats = repeats
        if autostart {
            self.start()
        }
    }
    
    init(interval: NSTimeInterval, queue: dispatch_queue_t?, handler: () -> ()) {
        self.interval = interval
        self.queue = queue
        self.handler = handler;
        self.repeats = true
        self.start()
    }
    
    func start() {
        let block = {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(self.interval,
                target: self,
                selector: Selector("tick"),
                userInfo: nil,
                repeats: self.repeats)
        }
        
        if NSThread.isMainThread() {
            block()
        } else {
            dispatch_async(dispatch_get_main_queue(), block)
        }
    }
    
    func stop() {
        if NSThread.isMainThread() {
            timer?.invalidate()
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                if self.timer != nil {
                    self.timer!.invalidate()
                }
            }
        }
    }
    
    @objc private func tick() {
        if self.queue != nil {
            dispatch_async(queue, handler)
        } else {
            handler()
        }
    }
    
    deinit {
        stop()
    }
}