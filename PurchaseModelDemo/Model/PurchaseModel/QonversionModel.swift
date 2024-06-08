//
//  Qonversion.swift
//  PurcheseModels
//
//  Created by Moksh on 07/12/23.
//


#if canImport(Qonversion)

import Foundation
import Qonversion


enum QonversionLaunchMode {
    case subscriptionManagement
    case analytics
}

class QonversionModel  {
    static var shared = QonversionModel()
    
    private init() { }
    
    
    func configure(projectKey : String, launchMode : QonversionLaunchMode,userID : String? = nil) {
        let config1 = Qonversion.Configuration(projectKey: projectKey, launchMode: launchMode == .analytics ? .analytics : .subscriptionManagement)
        Qonversion.initWithConfig(config1)
        
        if let userID {
            Qonversion.shared().setUserProperty(.userID, value: userID)
        }
        
        Qonversion.shared().collectAppleSearchAdsAttribution()
    }
    
    func reportPurchase() {
        QonversionSwift.shared.syncStoreKit2Purchases()
    }
    
//
//    func getRemoteConfig(){
//        Thread.OnBackGroudThread {
////            Qonversion.shared().attachUser(toExperiment: "1720a9a2-ffcf-4fca-b955-650881a28edc", groupId: "addea2f4") { success, error in
////                if success {
//                    Qonversion.shared().remoteConfig(contextKey: "OBTesting", completion: { remoteConfig, error in
//                        if let error {
//                            print(error)
//                        }
//                            
//                        if let dict = remoteConfig?.payload as? [String: Any]{
//                            if let isNewOnboarding = dict["isNewOnboarding"] as? Bool {
//                                print("isNewOnboarding : \(isNewOnboarding)")
//                                UserDefaults.isNewOnboardingToShow  = isNewOnboarding
//                            }
//                            NSNotification.QonversionDidUpdated.fire()
//                        }
//                    })
//                  
//                    
//                } else{
//                    print(error ?? "")
//                    NSNotification.QonversionDidUpdated.fire()
//                }
//            }
//            
//            
//             
//         }
//    }
}


#endif
