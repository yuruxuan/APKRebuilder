//
//  ProcessCallback.swift
//  APKRebuilder
//
//  Created by Yu. on 2020/2/1.
//  Copyright © 2020年 Yu. All rights reserved.
//

import Foundation

protocol ProcessCallback {
    
    func processStarted(cmd:String) -> Void
    
    func stdoutUpdated(cmd:String, out:String) -> Void
    
    func stderrUpdated(cmd:String, err:String) -> Void
    
    func processEnded(cmd:String, code:Int) -> Void
}
