//
//  APKHanderCallback.swift
//  APKRebuilder
//
//  Created by Yu. on 2020/2/1.
//  Copyright © 2020年 Yu. All rights reserved.
//

import Foundation

protocol APKHanderCallback {
    
    func taskflowStarted() -> Void
    
    func stdoutUpdated(out:String) -> Void
    
    func stderrUpdated(err:String) -> Void
    
    func taskflowEnded() -> Void
}
