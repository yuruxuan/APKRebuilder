//
//  APKRebuilder.swift
//  APKRebuilder
//
//  Created by Yu. on 2020/1/31.
//  Copyright © 2020年 Yu. All rights reserved.
//

import Cocoa

class APKHandler: NSObject, ProcessCallback{
    
    private let apktoolPath: String
    private let apksignerPath: String
    private let keystorePath: String
    private let jdGUIPath: String
    private let smaliPath: String
    private let baksmaliPath: String
    private let dex2jarPath: String
    private let jar2dexPath: String
    
    private let shell = ProcessShell()
    
    private var tasks = [APKHandler.Task]()
    private var isRunning = false
    
    var handlerCallback: APKHanderCallback?
    
    override init() {
        apktoolPath = Bundle.main.path(forResource: "apktool_2.9.1", ofType: "jar") ?? "apktool_2.9.1"
        apksignerPath = Bundle.main.path(forResource: "apksigner", ofType: "jar") ?? "apksigner"
        keystorePath = Bundle.main.path(forResource: "APKRebuilder", ofType: "keystore") ?? "APKRebuilder"
        jdGUIPath = Bundle.main.path(forResource: "jd-gui-1.6.6", ofType: "jar") ?? "jd-gui-1.6.6"
        smaliPath = Bundle.main.path(forResource: "smali-2.4.0", ofType: "jar") ?? "smali-2.4.0"
        baksmaliPath = Bundle.main.path(forResource: "baksmali-2.4.0", ofType: "jar") ?? "baksmali-2.4.0"
        dex2jarPath = Bundle.main.path(forResource: "dex2jar/d2j-dex2jar", ofType: "sh") ?? "d2j-dex2jar"
        jar2dexPath = Bundle.main.path(forResource: "dex2jar/d2j-jar2dex", ofType: "sh") ?? "d2j-jar2dex"
    }
    
    func execRemoveAPKToolFrameworkRes() -> Bool {
        if isRunning {
            return false
        }
        
        let task = APKHandler.Task(name: "RemoveAPKToolFrameworkRes", arg1: nil, arg2: nil)
        tasks.append(task)
        dispatchTask()
        handlerCallback?.taskflowStarted()
        isRunning = true
        return true
    }
    
    func execDecompileAPK(path: String) -> Bool {
        if isRunning {
            return false
        }
        
        let output = NSString(string: path).deletingPathExtension
        let task = APKHandler.Task(name: "DecompileAPK", arg1: path, arg2: output)
        tasks.append(task)
        dispatchTask()
        handlerCallback?.taskflowStarted()
        isRunning = true
        return true
    }
    
    func execRebuildSignAPK(path: String) -> Bool {
        if isRunning {
            return false
        }
        
        let output = NSString(string: path).deletingPathExtension + "-b.apk"
        let task1 = APKHandler.Task(name: "RebuidAPK", arg1: path, arg2: output)
        let task2 = APKHandler.Task(name: "SignAPK", arg1: output, arg2: nil)
        tasks.append(task1)
        tasks.append(task2)
        dispatchTask()
        handlerCallback?.taskflowStarted()
        isRunning = true
        return true
    }
    
    func execDecompileRebuildSingleJar(path: String) -> Bool {
        if isRunning {
            return false
        }
        
        let decompileOutput = NSString(string: path).deletingPathExtension
        let rebuildOutput = decompileOutput + "-b.apk"
        let singleJarOutput = decompileOutput + ".jar"
        let task1 = APKHandler.Task(name: "DecompileAPK", arg1: path, arg2: decompileOutput)
        let task2 = APKHandler.Task(name: "RebuidAPK", arg1: decompileOutput, arg2: rebuildOutput)
        let task3 = APKHandler.Task(name: "SignAPK", arg1: rebuildOutput, arg2: nil)
        let task4 = APKHandler.Task(name: "Dex2Jar", arg1: path, arg2: singleJarOutput)
        tasks.append(task1)
        tasks.append(task2)
        tasks.append(task3)
        tasks.append(task4)
        dispatchTask()
        handlerCallback?.taskflowStarted()
        isRunning = true
        return true
    }
    
    func execSmali2Dex(path: String) -> Bool {
        if isRunning {
            return false
        }
        
        let output = NSString(string: path).deletingPathExtension + ".dex"
        let task = APKHandler.Task(name: "Smali2Dex", arg1: path, arg2: output)
        tasks.append(task)
        dispatchTask()
        handlerCallback?.taskflowStarted()
        isRunning = true
        return true
    }
    
    func execDex2Smali(path: String) -> Bool {
        if isRunning {
            return false
        }
        
        let output = NSString(string: path).deletingPathExtension
        let task = APKHandler.Task(name: "Dex2Smali", arg1: path, arg2: output)
        tasks.append(task)
        dispatchTask()
        handlerCallback?.taskflowStarted()
        isRunning = true
        return true
    }
    
    func execDex2Jar(path: String) -> Bool {
        if isRunning {
            return false
        }
        
        let output = NSString(string: path).deletingPathExtension + ".jar"
        let task = APKHandler.Task(name: "Dex2Jar", arg1: path, arg2: output)
        tasks.append(task)
        dispatchTask()
        handlerCallback?.taskflowStarted()
        isRunning = true
        return true
    }
    
    func execJar2Dex(path: String) -> Bool {
        if isRunning {
            return false
        }
        
        let output = NSString(string: path).deletingPathExtension + ".dex"
        let task = APKHandler.Task(name: "Jar2Dex", arg1: path, arg2: output)
        tasks.append(task)
        dispatchTask()
        handlerCallback?.taskflowStarted()
        isRunning = true
        return true
    }
    
    func execSignInfo(path: String) -> Bool {
        if isRunning {
            return false
        }
        
        let task = APKHandler.Task(name: "SignInfo", arg1: path, arg2: nil)
        tasks.append(task)
        dispatchTask()
        handlerCallback?.taskflowStarted()
        isRunning = true
        return true
    }
    
    func execSignVersion(path: String) -> Bool {
        if isRunning {
            return false
        }
        
        let task = APKHandler.Task(name: "SignVersion", arg1: path, arg2: nil)
        tasks.append(task)
        dispatchTask()
        handlerCallback?.taskflowStarted()
        isRunning = true
        return true
    }
    
    private func dispatchTask() {
        if tasks.count <= 0 {
            return
        }
        let task = tasks.remove(at: 0)
        let name = task.name!
        let arg1 = task.arg1
        let arg2 = task.arg2
        
        switch name {
        case "RemoveAPKToolFrameworkRes":
            removeAPKToolFrameworkRes()
        case "DecompileAPK":
            decompileAPK(path: arg1!, output: arg2!)
        case "RebuidAPK":
            rebuidAPK(path: arg1!, output: arg2!)
        case "SignAPK":
            signAPK(path: arg1!)
        case "Smali2Dex":
            smali2Dex(path: arg1!, output: arg2!)
        case "Dex2Smali":
            dex2Smali(path: arg1!, output: arg2!)
        case "Dex2Jar":
            dex2Jar(path: arg1!, output: arg2!)
        case "Jar2Dex":
            jar2Dex(path: arg1!, output: arg2!)
        case "SignInfo":
            signInfo(path: arg1!)
        case "SignVersion":
            signVersion(path: arg1!)
        default:
            break
        }
    }
    
    /************* Real Handle *************/
    
    func launchJDGUI() {
        var args = [String]()
        args.append("-jar")
        args.append(jdGUIPath)
        shell.runAsync(launchPath: "/usr/bin/java",
                       arguments: args,
                       environment: [:],
                       callback: nil)
    }
    
    private func removeAPKToolFrameworkRes() {
        var args = [String]()
        args.append("-jar")
        args.append(apktoolPath)
        args.append("empty-framework-dir")
        shell.runAsync(launchPath: "/usr/bin/java",
                       arguments: args,
                       environment: ["JAVA_TOOL_OPTIONS":"-Djdk.util.zip.disableZip64ExtraFieldValidation=true"],
                       callback: self)
    }
    
    // JAVA_TOOL_OPTIONS="-Djdk.util.zip.disableZip64ExtraFieldValidation=true" java -jar apktool_2.9.1.jar d  library.apk
    private func decompileAPK(path: String, output: String) {
        var args = [String]()
        args.append("-jar")
        args.append(apktoolPath)
        args.append("d")
        args.append(path)
        args.append("-o")
        args.append(output)
        shell.runAsync(launchPath: "/usr/bin/java",
                       arguments: args,
                       environment: ["JAVA_TOOL_OPTIONS":"-Djdk.util.zip.disableZip64ExtraFieldValidation=true"],
                       callback: self)
    }
    
    private func rebuidAPK(path: String, output: String) {
        var args = [String]()
        args.append("-jar")
        args.append(apktoolPath)
        args.append("b")
        args.append(path)
        args.append("-o")
        args.append(output)
        shell.runAsync(launchPath: "/usr/bin/java",
                       arguments: args,
                       environment: ["JAVA_TOOL_OPTIONS":"-Djdk.util.zip.disableZip64ExtraFieldValidation=true"],
                       callback: self)
    }
    
    private func signAPK(path: String) {
        var args = [String]()
        args.append("-jar")
        args.append(apksignerPath)
        args.append("sign")
        args.append("--verbose")
        args.append("--ks")
        args.append(keystorePath)
        args.append("--ks-pass")
        args.append("pass:APKRebuilder")
        args.append(path)
        shell.runAsync(launchPath: "/usr/bin/java",
                       arguments: args,
                       environment: ["JAVA_TOOL_OPTIONS":"-Djdk.util.zip.disableZip64ExtraFieldValidation=true"],
                       callback: self)
    }
    
    private func smali2Dex(path: String, output: String) {
        var args = [String]()
        args.append("-jar")
        args.append(smaliPath)
        args.append("assemble")
        args.append(path)
        args.append("-o")
        args.append(output)
        shell.runAsync(launchPath: "/usr/bin/java",
                       arguments: args,
                       environment: ["JAVA_TOOL_OPTIONS":"-Djdk.util.zip.disableZip64ExtraFieldValidation=true"],
                       callback: self)
    }
    
    private func dex2Smali(path: String, output: String) {
        var args = [String]()
        args.append("-jar")
        args.append(baksmaliPath)
        args.append("disassemble")
        args.append(path)
        args.append("-o")
        args.append(output)
        shell.runAsync(launchPath: "/usr/bin/java",
                       arguments: args,
                       environment: ["JAVA_TOOL_OPTIONS":"-Djdk.util.zip.disableZip64ExtraFieldValidation=true"],
                       callback: self)
    }
    
    private func dex2Jar(path: String, output: String) {
        var args = [String]()
        args.append(dex2jarPath)
        args.append(path)
        args.append("-o")
        args.append(output)
        shell.runAsync(launchPath: "/bin/bash",
                       arguments: args,
                       environment: ["JAVA_TOOL_OPTIONS":"-Djdk.util.zip.disableZip64ExtraFieldValidation=true"],
                       callback: self)
    }
    
    private func jar2Dex(path: String, output: String) {
        var args = [String]()
        args.append(jar2dexPath)
        args.append(path)
        args.append("-o")
        args.append(output)
        shell.runAsync(launchPath: "/bin/bash",
                       arguments: args,
                       environment: ["JAVA_TOOL_OPTIONS":"-Djdk.util.zip.disableZip64ExtraFieldValidation=true"],
                       callback: self)
    }
    
    private func signInfo(path: String) {
        var args = [String]()
        args.append("-printcert")
        args.append("-jarfile")
        args.append(path)
        shell.runAsync(launchPath: "/usr/bin/keytool",
                       arguments: args,
                       environment: ["JAVA_TOOL_OPTIONS":"-Djdk.util.zip.disableZip64ExtraFieldValidation=true"],
                       callback: self)
    }
    
    private func signVersion(path: String) {
        var args = [String]()
        args.append("-jar")
        args.append(apksignerPath)
        args.append("verify")
        args.append("-v")
        args.append(path)
        shell.runAsync(launchPath: "/usr/bin/java",
                       arguments: args,
                       environment: ["JAVA_TOOL_OPTIONS":"-Djdk.util.zip.disableZip64ExtraFieldValidation=true"],
                       callback: self)
    }
    
    private func apktoolVersion() {
        var args = [String]()
        args.append("-jar")
        args.append(apktoolPath)
        args.append("-version")
        shell.runAsync(launchPath: "/usr/bin/java",
                       arguments: args,
                       environment: ["JAVA_TOOL_OPTIONS":"-Djdk.util.zip.disableZip64ExtraFieldValidation=true"],
                       callback: self)
    }
    
    /************* ProcessCallback *************/
    
    func processStarted(cmd: String) {
        print("processStarted " + cmd)
    }
    
    func stdoutUpdated(cmd: String, out: String) {
        handlerCallback?.stdoutUpdated(out: out)
        print("stdoutUpdated " + out)
    }
    
    func stderrUpdated(cmd: String, err: String) {
        handlerCallback?.stderrUpdated(err: err)
        print("stderrUpdated " + err)
    }
    
    func processEnded(cmd: String, code: Int) {
        if tasks.count > 0 {
            handlerCallback?.stdoutUpdated(out: "\n")
            dispatchTask()
        } else {
            handlerCallback?.taskflowEnded()
            isRunning = false
        }
        print("processEnded " + String(code))
    }
    
    private class Task {
        var name:String?
        var arg1:String?
        var arg2:String?
        
        init(name:String, arg1: String?, arg2: String?) {
            self.name = name;
            self.arg1 = arg1;
            self.arg2 = arg2;
        }
    }
}
