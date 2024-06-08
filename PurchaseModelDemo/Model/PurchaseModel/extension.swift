
//
//  Dict + extensions.swift
//  PurcheseModels
//
//  Created by Moksh on 21/11/23.
//

import Foundation
import SwiftUI

typealias string_AnyDict = [String : Any]
typealias voidHandler = () -> Void
//Dictionary extensions
extension Dictionary where Key == String {
    func getString(_ key: String, filterEmpty: Bool = true) -> String? {
        if let value = self[key] as? String {
            if filterEmpty && value.isEmpty {
                Log.error("empaty Value found \"\(key)\"")
                return nil
            } else {
                return value
            }
        } else {
            Log.error("empaty Value found \"\(key)\"")
            return nil
        }
    }
    
    
    
    func getValueForKey<T>(_ key: Key, type: T.Type,defaultValue : T? = nil) -> T? {
        guard let value = self[key] as? T else {
            return defaultValue
        }
        
        return value
    }
    
    func getString_Any(_ key: Key) -> string_AnyDict? {
       return self[key] as? string_AnyDict
    }
    
   
}


extension String  {
   func getFilePath() -> String?{
       let components = self.components(separatedBy: ".")
       guard let fileName = components.first, let fileExtension = components.last else {
                  return nil
       }
       
       if let filePath = Bundle.main.path(forResource: fileName, ofType: fileExtension) {
           return filePath
       } else {
           return nil
       }
    }
}



extension Dictionary where Key == String, Value: Any {
    func extractURLs() -> [URL?] {
        var urls: [String] = []

        // Define a regular expression pattern to match URLs
        let urlPattern = "https?://([-\\w]+\\.)+([A-Za-z]{2,})[/\\w\\d%.-]+"
        let regex = try! NSRegularExpression(pattern: urlPattern, options: [])

        // Function to extract URLs using regex
        func extractURLsFromValue(_ value: Any) {
            if let stringValue = value as? String {
                let matches = regex.matches(in: stringValue, options: [], range: NSRange(location: 0, length: stringValue.utf16.count))
                for match in matches {
                    if let urlRange = Range(match.range, in: stringValue) {
                        let url = String(stringValue[urlRange])
                        urls.append(url)
                    }
                }
            } else if let dictionary = value as? [String: Any] {
                for (_, nestedValue) in dictionary {
                    extractURLsFromValue(nestedValue)
                }
            } else if let array = value as? [Any] {
                for element in array {
                    extractURLsFromValue(element)
                }
            }
        }

        // Extract URLs from the dictionary
        for (_, value) in self {
            extractURLsFromValue(value)
        }

        return urls.map({URL(string: $0)})
    }
}

extension [PurchaseId] {
    mutating func sort() {
        self.sort(by: {$0.priority < $1.priority})
    }
}


#if !canImport(SwiftyUIX)

//get top ViewController
 extension UIApplication {

    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController

            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return topViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    
}


public extension UIViewController {
    //show UIAlert View
    func showAlert(title : String,message : String,actions : [UIAlertAction],preferredStyle : UIAlertController.Style = .alert) {
        
        if let topView = UIApplication.topViewController() {
            let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
            for action in actions {
                alert.addAction(action)
            }
            
            topView.present(alert, animated: true)
        }
    }
    
}

#endif
