//
//  Log.swift
//  PurcheseModels
//
//  Created by Moksh on 13/12/23.
//

import Foundation
public class Log {
    public static func debug(_ msg : String,file : String? = nil,line : Int? = nil) {
        #if DEBUG
        var logMessage = "🟡 Log: \(msg)"
        if let file = file, let line = line {
            logMessage += " - \(file.fileName) \(line)"
        }
        print(logMessage)
        #endif
    }
    
    public static func error(_ msg : String,file : String? = nil,line : Int? = nil) {
        #if DEBUG
        var logMessage = "🔴 Log: \(msg)"
        if let file = file, let line = line {
            logMessage += " - \(file.fileName) \(line)"
        }
        print(logMessage)
        #endif
    }
    
    
    public static func success(_ msg : String,file : String? = nil,line : Int? = nil) {
        #if DEBUG
        var logMessage = "🟢 Log: \(msg)"
        if let file = file, let line = line {
            logMessage += " - \(file.fileName) \(line)"
        }
        print(logMessage)
        #endif
    }
}

extension String {
    var fileName : String {
       URL(fileURLWithPath: self).lastPathComponent
    }
}
