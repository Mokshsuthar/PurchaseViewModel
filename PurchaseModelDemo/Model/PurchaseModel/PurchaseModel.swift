//
//  PurchaseModel.swift
//  PurchaseModel
//
//  Created by Moksh on 26/10/23.
//

import Foundation
import SwiftyStoreKit


protocol PurchaseModelDelegate : AnyObject {
    func purchase(id : String,didReceiveReceiptFor receipt : String)
    func purchase(didVerifySubscriptionsFor result : VerifySubscriptionResult)
    func purchase(didVerifySubscriptionsFor error : Error)
    func purchase(didPurchaseSuccessWith result : PurchaseDetails,purchaseID : PurchaseId)
    func purchase(didPurchaseFailWith error : Error)
    func didPriceUpdated()
    func purchase(didStartLoading isLoading : Bool)
    
}

protocol PurchaseModelDataSource {
    var sharedSecret : String? { set get}
    
}

extension PurchaseModelDelegate {
    func purchase (id : String,didReceiveReceiptFor receipt : String){}
    func purchase(didVerifySubscriptionsFor result : VerifySubscriptionResult){}
    func purchase(didPurchaseSuccessWith result : PurchaseDetails,purchaseID : PurchaseId){}
    func purchase(didPurchaseFailWith error : Error){}
    func didPriceUpdated(){}
    func purchase(didStartLoading isLoading : Bool){}
    func purchase(didVerifySubscriptionsFor error : Error){}
}

class PurchaseModel : PurchaseModelDataSource {
    
    static var shared = PurchaseModel()
    weak var delegate : PurchaseModelDelegate?
    var sharedSecret : String?
    var isReviewVersion : Bool = false
    var purchaseIds : [PurchaseId]! 
    var userName : String?
    
    var defaultPurchaseScreen : String = "ProV1"
   
    //get price and set to Userdefaults
    func getPrice(){
        if purchaseIds.isEmpty {
            fatalError("no Ids found in purchaseIds")
        }
        
        let Ids_Set : Set = Set(purchaseIds.map({$0.purchaseId}))
        let Ids_Set_verify : [String] = purchaseIds.filter({$0.isIncludeVerifySubscription == true}).map({$0.purchaseId})
        SwiftyStoreKit.retrieveProductsInfo(Ids_Set) { result in
             if let error = result.error {
                print(error.localizedDescription)
            }
            
            if result.retrievedProducts.first != nil {
                let array = Array(result.retrievedProducts)
                for p in array {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .currency
                    formatter.locale = p.priceLocale
                    let cost = formatter.string(from: p.price)
                    
                    
                    if let firstIndex = self.purchaseIds.firstIndex(where: {$0.purchaseId == p.productIdentifier}) {
                        let pID =  self.purchaseIds[firstIndex]
                        let NormalStringValue = self.getWithPriceSuffix(value: cost, type: pID.type)
                        let NormalDoubleValue = Double(truncating: p.price)
                        
                        self.purchaseIds[firstIndex].setPrice(stringValue: NormalStringValue, doubleValue: NormalDoubleValue, withOutSuffix: cost)
                        
                        Log.success("\(pID.purchaseId) = \(String(describing: cost))")
                        UserDefaults.standard.setValue(cost, forKey: "\(pID.purchaseId)\(UserdefaultPriceType._NormalStringWithOutSuffix.rawValue)")
                        UserDefaults.standard.setValue(NormalStringValue, forKey: "\(pID.purchaseId)\(UserdefaultPriceType.NormalString.rawValue)")
                        UserDefaults.standard.setValue(NormalDoubleValue, forKey: "\(pID.purchaseId)\(UserdefaultPriceType.NormalDouble.rawValue)")
                       
                        
                        UserDefaults.currencySymbol = formatter.currencySymbol
                        self.purchaseIds[firstIndex].setCurrencySymbol(formatter.currencySymbol)
                        if let period = p.introductoryPrice?.subscriptionPeriod {
                            
                            let periodStringValue = "\(period.numberOfUnits) \(self.unitName(unitRawValue: period.unit.rawValue)) \("free trial")"
                            
                            self.purchaseIds[firstIndex].setSubPeriodString(stringValue: periodStringValue)
                            UserDefaults.standard.setValue(periodStringValue,forKey: "\(pID.purchaseId)\(UserdefaultPriceType.PeriodString.rawValue)")
                        }
                        
                        if let offerPrice = p.introductoryPrice?.price {
                           let offerCost = formatter.string(from: offerPrice)
                            
                            let offerStringValue = self.getWithPriceSuffix(value: offerCost, type:  pID.type)
                            let offerDoubleValue = Double(truncating: offerPrice)
                            
                            self.purchaseIds[firstIndex].setOfferPrice(stringValue:  offerStringValue, doubleValue:  offerDoubleValue)
                            
                            UserDefaults.standard.setValue(offerStringValue, forKey: "\(pID.purchaseId)\(UserdefaultPriceType.OfferString.rawValue)")
                            UserDefaults.standard.setValue(offerDoubleValue, forKey: "\(pID.purchaseId)\(UserdefaultPriceType.OfferDouble.rawValue)")
                        }
                        
                        if self.purchaseIds[firstIndex].needSplitPrice{
                            if  let splitPrice = self.getDividePriceInDouble(oneMonthPrice: p.localizedPrice!) {
                                let splitPriceString = formatter.string(from: NSNumber(value: splitPrice)) ?? "\(splitPrice)"
                                self.purchaseIds[firstIndex].setSplitPrice(stringValue:  "\(splitPriceString) / \(pID.splitPriceStringSuffix ?? "")")
                                
                                UserDefaults.standard.setValue(splitPriceString, forKey: "\(pID.purchaseId)\(UserdefaultPriceType.SplitPriceString.rawValue)")
                            }
                        }
                        
                    }
                    
                    
                }
                if let delegate = self.delegate {
                    delegate.didPriceUpdated()
                }
            }
        }
        Log.debug(#function)
        self.verifySubscriptions(Ids_Set_verify)
    }
    
    //get purchase id struct from string purchase id
    func getPurchaseIds(withIds : [String]) -> [PurchaseId] {
        var itemToReturn : [PurchaseId] = purchaseIds.filter({withIds.contains($0.purchaseId)})
        itemToReturn.sort()
        itemToReturn.sort(by: {$0.priority < $1.priority})
        return itemToReturn
    }
    
    func getPurchaseId(purchaseIdDict : string_AnyDict) -> PurchaseId {
        if let id  = purchaseIdDict.getString("purchaseID"), var firstPurchaseId = purchaseIds.first(where: {$0.purchaseId == id}){
            
            if let priceString = purchaseIdDict.getString("subPriceString") {
                firstPurchaseId.subString = priceString
                firstPurchaseId.subString!.replaceString(with: firstPurchaseId)
            }
            
            if let subString = purchaseIdDict.getValueForKey("subHeading", type: String.self) {
                firstPurchaseId.subString = subString
            }
            
            if let isSelected = purchaseIdDict.getValueForKey("isSelected", type: Bool.self) {
                firstPurchaseId.isSelected = isSelected
            }
            return firstPurchaseId
        } else {
            return purchaseIds.first!
        }
    }
    
    func getPurchaseIds(withDict_Ids : [[String : Any]]) -> [PurchaseId] {
        var itemToReturn : [PurchaseId] = []
     
        for purchaseIdDict in withDict_Ids {
            if let id = purchaseIdDict["purchaseID"] as? String {
                if var first = purchaseIds.first(where: {$0.purchaseId == id}){
                    first.displayLabel = purchaseIdDict.getString("displayLabel") ?? first.displayLabel
                    
                    if let priority = purchaseIdDict.getValueForKey("priority", type: Int.self) {
                        first.priority = priority
                    }
                    
                    if let priceString = purchaseIdDict.getString("priceString") {
                        first.priceString = priceString
                        first.priceString!.replaceString(with: first)
                    }
                    if let splitPriceString = purchaseIdDict.getString("splitPrice") {
                        first.splitPriceString = splitPriceString
                        first.splitPriceString!.replaceString(with: first)
                    }
                    
                    if let topHeading = purchaseIdDict.getValueForKey("topHeading",type: String.self) {
                        first.offPercentage = topHeading
                    }
                    
                    if let priceString = purchaseIdDict.getString("subPriceString") {
                        first.subString = priceString
                        first.subString!.replaceString(with: first)
                    }
                    
                    if let subString = purchaseIdDict.getValueForKey("subHeading", type: String.self) {
                        first.subString = subString
                    }
                    
                    if let isSelected = purchaseIdDict.getValueForKey("isSelected", type: Bool.self) {
                        first.isSelected = isSelected
                    }
                
                    itemToReturn.append(first)
                }
            }
        }
        
        itemToReturn.sort(by: {$0.priority < $1.priority})
        
        return itemToReturn
        
    }
   
    func getDividePriceInDouble(oneMonthPrice : String) -> Double? {
        
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        
        if let formattedTipAmount = formatter.number(from: oneMonthPrice) {
            let m_price = (Double(truncating: formattedTipAmount) / 12).truncate(places: 2)
            return m_price
            
        } else {
            let formatter1 = NumberFormatter()
            formatter1.locale = Locale.init(identifier: "en_US")
            formatter1.numberStyle = .currency
            
            if let formattedTipAmount = formatter1.number(from: oneMonthPrice) {
                
                let m_price = (Double(truncating: formattedTipAmount) / 12).truncate(places: 2)
                return m_price
                
            } else {
                if let formattedTipAmount = getNumber(fromString: oneMonthPrice) {
                    print(formattedTipAmount)
                    let m_price = Double(formattedTipAmount/12).truncate(places: 2)
                    return m_price
                } else  {
                    return  nil
                }
            }
        }
    }
    
    func getWithPriceSuffix(value : String?, type : PurchaseIdType) -> String?{
        guard let value else {
            return nil
        }
        
        switch type {
        case .weekly:
            return "\(value)/week"
        case .monthly:
            return "\(value)/month"
        case .yearly:
            return "\(value)/year"
        case .lifeTime:
            return value
        }
    }
    
    func unitName(unitRawValue:UInt) -> String {
        switch unitRawValue {
        case 0: return "day"
        case 1: return "weeks"
        case 2: return "months"
        case 3: return "years"
        default: return ""
        }
    }
    
    func getNumber(fromString : String) -> Double?{
        var n = ""
        let numbers = "1234567890."
        for i in fromString {
            if numbers.contains(i) {
                n = "\(n)\(i)"
            }
        }
        return Double(n)
    }
    //verify Subscriptions to check is pro User or not for all purchase Ids that you include to check VerifySubscription
    func verifySubscriptions(showAlerts : Bool = false) {
        let allPurchaseIDs = self.purchaseIds.compactMap { $0.isIncludeVerifySubscription ? $0.purchaseId : nil }
        self.verifySubscriptions(allPurchaseIDs, showAlerts: showAlerts)
    }
    
    
    //verify Subscriptions to check is pro User or not for specific purchase Ids
    func verifySubscriptions(_ purchases: [String],showAlerts : Bool = false) {
        self.loading(showLoading: true)
        self.verifyReceipt { result in
            self.loading(showLoading: false)
            switch result {
            case .success(let receipt):
                let productIds = Set(purchases.map { $0 })
                let purchaseResult = SwiftyStoreKit.verifySubscriptions(productIds: productIds, inReceipt: receipt)
                switch purchaseResult {
                case .purchased(let expiryDate, _):
                    UserDefaults.isPurchase = true
                    self.showAlert(title: "Product is purchased", message: "\("Product is valid until") \(expiryDate)",showAlert: showAlerts)
                case .expired(let expiryDate, _):
                    self.showAlert(title: "Product expired", message: "\("Product is expired since") \(expiryDate)",showAlert: showAlerts)
                    UserDefaults.isPurchase = false
                case .notPurchased:
                    self.showAlert(title: "Not purchased", message: "This product has never been purchased",showAlert: showAlerts)
                    UserDefaults.isPurchase = false
                    
                }
                if let delegate = self.delegate {
                    delegate.purchase(didVerifySubscriptionsFor: purchaseResult)
                }
            case .error(let error):
                self.showAlert(title: "Unable to verify", message: error.localizedDescription,showAlert: showAlerts)
                Log.error(error.localizedDescription,file: #file,line: #line)
            }
        }
    }
    
    func verifyReceipt(completion: @escaping (VerifyReceiptResult) -> Void) {
        guard let sharedSecret else {
            fatalError("sharedSecret found nil")
        }
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, completion: completion)
    }
   
    func getPurchaseIDs(values : [[String : String]]) -> [PurchaseId] {
        var purchaseIdsToReturn : [PurchaseId] = []
        for value in values {
            if let pId = value["id"] {
                var PID_data = self.getPurchaseID(value: pId)
                let subString = isReviewVersion ? value.getString("subStringReview") : value.getString("subStringNormal")
                PID_data.setSubString(stringValue: subString)
                PID_data.setOffPercentage(value.getString("OffString"))
                purchaseIdsToReturn.append(PID_data)
            }
        }
        return purchaseIdsToReturn
    }
    
    func getPurchaseID(value : String) -> PurchaseId {
        if let first = self.purchaseIds.first(where: {$0.purchaseId == value}) {
            return first
        } else {
            if self.purchaseIds.isEmpty {
                fatalError("purchaseIds are empty")
            } else {
                return self.purchaseIds.first!
            }
        }
    }
    
    
}

extension PurchaseModel {
    //request for purchase popUp
    func purchase(_ purchasesID: PurchaseId) {
        self.loading(showLoading: true)
        SwiftyStoreKit.purchaseProduct(purchasesID.purchaseId, atomically: true) { result in
            switch result{
            case .success(let purchase):
                #if canImport(Singular)
                    SingularModel.shared.customRevenue(purchasesID.purchaseId)
                #endif
                #if canImport(Qonversion)
                QonversionModel.shared.reportPurchase()
                #endif
              
                let downloads = purchase.transaction.downloads
                if !downloads.isEmpty {
                    SwiftyStoreKit.start(downloads)
                }
                
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                UserDefaults.isPurchase = true
                if let delegate = self.delegate {
                    delegate.purchase(didPurchaseSuccessWith: purchase,purchaseID: purchasesID)
                }
                self.loading(showLoading: false)
                
            case .error(let error):
               
                switch error.code {
                case .unknown:  self.showAlert(title: "Purchase failed", message: error.localizedDescription)
                case .clientInvalid: // client is not allowed to issue the request, etc.
                    self.showAlert(title: "Purchase failed", message: "Not allowed to make the payment")
                case .paymentCancelled: // user cancelled the request, etc.
                    print("Purchase paymentCancelled: \(error)")
                case .paymentInvalid: // purchase identifier was invalid, etc.
                    self.showAlert(title: "Purchase failed", message: "The purchase identifier was invalid")
                case .paymentNotAllowed: // this device is not allowed to make the payment
                    self.showAlert(title: "Purchase failed", message: "The device is not allowed to make the payment")
                case .storeProductNotAvailable: // Product is not available in the current storefront
                    self.showAlert(title: "Purchase failed", message: "The product is not available in the current storefront")
                case .cloudServicePermissionDenied: // user has not allowed access to cloud service information
                    self.showAlert(title: "Purchase failed", message: "Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: // the device could not connect to the nework
                    self.showAlert(title: "Purchase failed", message: "Could not connect to the network")
                case .cloudServiceRevoked: // user has revoked permission to use this cloud service
                    self.showAlert(title: "Purchase failed", message: "Cloud service was revoked")
                default:
                    self.showAlert(title: "Alert", message: "Something went wrong")
                }
                
                self.loading(showLoading: false)
                
                if let delegate = self.delegate {
                    delegate.purchase(didPurchaseFailWith: error)
                }
            }
        }
    }
    
    
    func showAlert(title : String,message : String,actions : [UIAlertAction] = [.init(title: "Okay", style: .cancel)],showAlert: Bool = true){
        if showAlert {
            if let topViewController = UIApplication.topViewController() {
                topViewController.showAlert(title: title, message: message, actions: actions)
            }
        }
    }
    
    func loading(showLoading: Bool) {
        if let delegate = self.delegate {
            delegate.purchase(didStartLoading: showLoading)
        }
    }
}


/// Make sure AppDelegate is available in your code, otherwise this extension will cause an error.
extension AppDelegate: PurchaseModelDelegate {
    
    func setUpCompleteTransactions() {
        PurchaseModel.shared.delegate = self
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        UserDefaults.isPurchase = true
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                case .failed, .purchasing, .deferred:
                    UserDefaults.isPurchase = false
                @unknown default:
                    break
                }
            }
        }
    }
    
    func purchase(didVerifySubscriptionsFor result: VerifySubscriptionResult) {
        switch result {
        case .purchased(let expiryDate, _):
            print(expiryDate)
            UserDefaults.isPurchase = true
        case .expired(let expiryDate, _):
            print(expiryDate)
            UserDefaults.isPurchase = false
        case .notPurchased:
            UserDefaults.isPurchase = false
        }
    }
}

