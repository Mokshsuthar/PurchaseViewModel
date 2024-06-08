//
//  ContenViewModel.swift
//  PurchaseModelDemo
//
//  Created by Moksh on 08/06/24.
//

import Foundation
import SwiftyStoreKit

class ContentViewModel : ObservableObject {
    
    //Mansion all you purchase id here
    var yearlyPurchaseID = PurchaseModel.shared.getPurchaseID(value: "com.maximaapps.passportphoto.yearly")
    var weeklyPurchaseID = PurchaseModel.shared.getPurchaseID(value: "com.maximaapps.passportphoto.weekly")
    
    @Published var isLoading : Bool = false
    
    init() {
        // provide app delegate for implementing purchase delegate methods
        PurchaseModel.shared.delegate = self
    }
    
    func yealryPurchaseAction() {
        self.purchase(yearlyPurchaseID)
    }
    
    func weeklyPurchaseAction() {
        self.purchase(weeklyPurchaseID)
    }
    
    //start purchasing for purchase id
    func purchase(_ purchaseID : PurchaseId) {
        PurchaseModel.shared.purchase(purchaseID)
    }
    
    // Check Restore Purchase for all purchase IDs
    // show alert : if you want to show alert to user
    func restorePurchase() {
        PurchaseModel.shared.verifySubscriptions(showAlerts: true)
    }
    
    // If you wish, you can choose to check restore purchase for specific ID/IDs
    // show alert : if you want to show alert to user
    func restorePurchaseForYearly() {
        PurchaseModel.shared.verifySubscriptions([yearlyPurchaseID.purchaseId], showAlerts: true)
    }
    
}
// those are PurchaseModelDelegate methods all are optionals which one is required you implement and not needed then you can remove it
extension ContentViewModel : PurchaseModelDelegate {
    // to toggle loading screen
    func purchase(didStartLoading isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    //called once after purchase
    func purchase(didPurchaseSuccessWith result: PurchaseDetails, purchaseID: PurchaseId) {
        print("Purchased success \(purchaseID.purchaseId)")
        
    }
    //called once after purchase failed for any reason
    func purchase(didPurchaseFailWith error: any Error) {
        print("Purchased failed \(error.localizedDescription)")
    }
    
    //called once after restore purchase called and did restore purchase
    func purchase(didVerifySubscriptionsFor result: VerifySubscriptionResult, showAlert: Bool) {
        
    }
    
    //called once if you need any Receipt after purchase
    func purchase(id: String, didReceiveReceiptFor receipt: String) {
        
    }
}
