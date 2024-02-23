//
//  ProcessShell.swift
//  APKRebuilder
//
//  Created by Yu. on 2020/2/1.
//  Copyright © 2020年 Yu. All rights reserved.
//

import Cocoa

class ProcessShell: NSObject {
    
    func run(launchPath: String, arguments: [String]?, environment: [String:String]?) -> (code:Int, stdout:String, stderr:String) {
        let stdoutPipe = Pipe()
        let stdoutFileHandle = stdoutPipe.fileHandleForReading
        let stderrPipe = Pipe()
        let stderrFileHandle = stderrPipe.fileHandleForReading
        
        let process = Process()
        process.launchPath = launchPath
        process.arguments = arguments ?? []
        process.environment = environment ?? [:]
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe
        process.launch()
        
        let stdoutData = stdoutFileHandle.readDataToEndOfFile();
        let stderrData = stderrFileHandle.readDataToEndOfFile();
        
        let stdoutStr = String(data: stdoutData, encoding: String.Encoding.utf8) ?? ""
        let stderrStr = String(data: stderrData, encoding: String.Encoding.utf8) ?? ""
        
        return (Int(process.terminationStatus), stdoutStr, stderrStr)
    }
    
    func runAsync(launchPath: String, arguments: [String]?, environment: [String:String]?, callback: ProcessCallback?) {
        let stdoutPipe = Pipe()
        let stdoutFileHandle = stdoutPipe.fileHandleForReading
        let stderrPipe = Pipe()
        let stderrFileHandle = stderrPipe.fileHandleForReading
        
        let process = Process()
        process.launchPath = launchPath
        process.arguments = arguments ?? []
        process.environment = environment ?? [:]
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe
        
        let cmd = processCmdStr(process: process)
        
        let stdoutObserver = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: stdoutFileHandle, queue: nil) { notification in
            let handle = notification.object as! FileHandle
            let str = String(data: handle.availableData, encoding: String.Encoding.utf8)!
            callback?.stdoutUpdated(cmd: cmd, out: str)
            handle.waitForDataInBackgroundAndNotify()
        }
        
        let stderrObserver = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: stderrFileHandle, queue: nil) { notification in
            let handle = notification.object as! FileHandle
            let str = String(data: handle.availableData, encoding: String.Encoding.utf8)!
            callback?.stderrUpdated(cmd: cmd, err: str)
            handle.waitForDataInBackgroundAndNotify()
        }
        
        NotificationCenter.default.addObserver(forName: Process.didTerminateNotification, object: process, queue: nil) { notification in
            let process = notification.object as! Process
            callback?.processEnded(cmd: cmd, code: Int(process.terminationStatus))
            NotificationCenter.default.removeObserver(stdoutObserver)
            NotificationCenter.default.removeObserver(stderrObserver)
            NotificationCenter.default.removeObserver(self)
        }
        
        stdoutFileHandle.waitForDataInBackgroundAndNotify()
        stderrFileHandle.waitForDataInBackgroundAndNotify()
        
        callback?.processStarted(cmd: cmd)
        process.launch()
    }
    
    private func processCmdStr(process:Process) -> String {
        var cmd = ""
        cmd += process.launchPath ?? ""
        let args = process.arguments ?? []
        for index in 0..<args.count {
            cmd += " "
            cmd += args[index]
        }
        return cmd
    }
}
