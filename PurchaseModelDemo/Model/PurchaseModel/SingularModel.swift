//
//  SingularModel.swift
//  Passportphoto
//
//  Created by Moksh on 17/05/24.
//


#if canImport(Singular)
import Foundation
import Singular


class SingularModel {
    static var shared = SingularModel()
    
    func customRevenue(_ purchaseID : String) {
        let purchaseID = PurchaseModel.shared.getPurchaseID(value: purchaseID)
        if let doublePrice = purchaseID.priceDouble {
            Singular.customRevenue(purchaseID.type.rawValue, currency: "\(String(describing: Locale.current.currencyCode))", amount: doublePrice)
        }
        
    }
    
    
    func configureSingular(apiKey : String,secret : String) {
        let singularConfig : SingularConfig = SingularConfig(apiKey: apiKey, andSecret: secret)
        singularConfig.skAdNetworkEnabled = true
        Singular.start(singularConfig)
        Singular.event("session_start")
    }
}
#endif
