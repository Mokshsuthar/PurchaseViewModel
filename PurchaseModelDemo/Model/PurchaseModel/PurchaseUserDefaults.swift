//
//  PurchaseUserDefaults.swift
//  PurcheseModels
//
//  Created by Moksh on 01/11/23.
//

import Foundation
extension UserDefaults {
    
    
    class var isPurchase : Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isProUser")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isProUser")
        }
    }
    
    class var isProUser : Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isProUser")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isProUser")
        }
    }
    
    class var isPro : Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isProUser")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isProUser")
        }
    }
    
    class var currentAssignedProScreen : String {
        get {
            return UserDefaults.standard.string(forKey: "currentAssignedProScreen") ?? PurchaseModel.shared.defaultPurchaseScreen
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "currentAssignedProScreen")
        }
    }
  
    class var currencySymbol : String? {
        get {
            return UserDefaults.standard.object(forKey: "currencySymbol") as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "currencySymbol")
        }
    }
    
//    class var isOnboardingCompleted: Bool {
//
//    }
//    
// 
//    func getValue<T>(forKey key: String, type: T.Type) -> T? {
//        return UserDefaults.standard.value(forKey: key) as? T
//    }
    
    func getSavedPurchaseValue<T>(forKey key: String,postFix : UserdefaultPriceType ,type: T.Type) -> T? {
        return UserDefaults.standard.value(forKey: "\(key)\(postFix.rawValue)") as? T
    }
    
    
    
}
