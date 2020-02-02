//
//  MainViewController.swift
//  APKRebuilder
//
//  Created by Yu. on 2020/1/31.
//  Copyright © 2020年 Yu. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, APKHanderCallback {
    
    @IBOutlet var pathTextField1: NSTextField!
    @IBOutlet var pathTextField2: NSTextField!
    @IBOutlet var pathTextField3: NSTextField!
    
    @IBOutlet var outputTextView: NSTextView!
    
    let apkHandler = APKHandler()
    
    var outputStr = ""
    var t3RadioSelect = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apkHandler.handlerCallback = self
    }
    
    @IBAction func decompileClick(_ sender: Any) {
        let button = sender as! NSButton
        var path: String?
        if button.tag == 1 {
            path = pathTextField1.stringValue
        } else if button.tag == 2 {
            path = pathTextField2.stringValue
        }
        
        if !checkPathAndAlert(path: path!) {
            return
        }
        
        _ = apkHandler.execDecompileAPK(path: path!)
    }
    
    @IBAction func rebuildSignClick(_ sender: Any) {
        let button = sender as! NSButton
        var path: String?
        if button.tag == 1 {
            path = pathTextField1.stringValue
        } else if button.tag == 2 {
            path = pathTextField2.stringValue
        }
        
        if !checkPathAndAlert(path: path!) {
            return
        }
        
        _ = apkHandler.execRebuildSignAPK(path: path!)
    }
    
    @IBAction func t3RadioButtonClick(_ sender: Any) {
        let button = sender as! NSButton
        t3RadioSelect = button.tag
    }
    
    @IBAction func t3ExecClick(_ sender: Any) {
        let path = pathTextField3.stringValue
        
        if !checkPathAndAlert(path: path) {
            return
        }
        
        switch t3RadioSelect {
        case 1:
            _ = apkHandler.execDecompileRebuildSingleJar(path: path)
        case 2:
            _ = apkHandler.execDex2Smali(path: path)
        case 3:
            _ = apkHandler.execSmali2Dex(path: path)
        case 4:
            _ = apkHandler.execJar2Dex(path: path)
        case 5:
            _ = apkHandler.execDex2Jar(path: path)
        case 6:
            _ = apkHandler.execSignInfo(path: path)
        default:
            break
        }
    }
    
    @IBAction func jdGUIClick(_ sender: Any) {
        apkHandler.launchJDGUI()
    }
    
    @IBAction func clearApktoolFrameworkResClick(_ sender: Any) {
        _ = apkHandler.execRemoveAPKToolFrameworkRes()
    }
    
    func checkPathAndAlert(path: String) -> Bool {
        var isValid = true
        var msg = ""
        
        if path == "" {
            isValid = false
            msg = "File path can not empty."
        } else if !FileManager.default.fileExists(atPath: path) {
            isValid = false
            msg = "\(path) is not exist."
        }
        
        if !isValid {
            let alert = NSAlert()
            alert.messageText = msg
            alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
        }
        
        return isValid
    }
    
    func updateOutput() {
        outputTextView.string = outputStr
    }
    
    /************* APKHanderCallback *************/
    
    func taskflowStarted() {
        outputStr = "====================== START ======================\n"
        updateOutput()
    }
    
    func stdoutUpdated(out: String) {
        outputStr += out
        updateOutput()
    }
    
    func stderrUpdated(err: String) {
        outputStr += err
        updateOutput()
    }
    
    func taskflowEnded() {
        outputStr += "======================   END   ======================\n"
        updateOutput()
    }
    
}
