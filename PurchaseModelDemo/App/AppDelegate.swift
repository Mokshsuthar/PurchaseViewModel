//
//  AppDelegate.swift
//  PurchaseModelDemo
//
//  Created by Moksh on 07/06/24.
//

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        //call below function here 
        self.setUpProScreens()
        return true
    }
    
    func setUpProScreens() {
        self.setUpCompleteTransactions()
        //your app's sharedSecret
        PurchaseModel.shared.sharedSecret = "46dc576d6aa1413a93021006f7d880aa"
        
        //mention all you purchase id with their default prices
        PurchaseModel.shared.purchaseIds =  [
            .init(type: .yearly, purchaseId: "com.maximaapps.passportphoto.yearly" ,priceDefaultValue: "$9.99", priceDefaultValueDouble: 9.99),
            .init(type: .lifeTime, purchaseId: "com.maximaapps.passportphoto.lifetime",priceDefaultValue: "$19.99",priceDefaultValueDouble: 19.99, needSplitPrice: true,splitPriceStringSuffix: "Month"),
            .init(type: .lifeTime, purchaseId: "com.maximaapps.passportphoto.lifetimew",priceDefaultValue: "$14.99",priceDefaultValueDouble: 14.99, needSplitPrice: true,splitPriceStringSuffix: "Month"),
            .init(type: .lifeTime, purchaseId: "com.maximaapps.passportphoto.lifetime2", priceDefaultValue: "$29.99", priceDefaultValueDouble: 29.99),
            .init(type: .weekly, purchaseId: "com.maximaapps.passportphoto.weekly", priceDefaultValue: "$4.99", priceDefaultValueDouble: 4.99),
            .init(type: .yearly, purchaseId: "com.maximaapps.passportphoto.yearly2", priceDefaultValue: "$14.99", priceDefaultValueDouble: 14.99)
        ]
        //run this folder to get all purchase ids details and price
        PurchaseModel.shared.getPrice()
    }
}
