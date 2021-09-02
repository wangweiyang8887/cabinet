// Copyright © 2021 evan. All rights reserved.

import Foundation

public typealias ActionClosure = () -> Void

final class TimerManager : NSObject {
    static let shared = TimerManager()
    
    var timer: Timer?
    
    func fire(blcok: ActionClosure?) {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in blcok?() }
        RunLoop.current.add(timer!, forMode: .common)
    }
}
