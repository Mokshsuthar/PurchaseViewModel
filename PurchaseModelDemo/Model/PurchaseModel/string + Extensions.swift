//
//  string + Extensions.swift
//  PurcheseModels
//
//  Created by Moksh on 18/12/23.
//

import Foundation
extension String {
    
    var toJsonString : String {
        "\"\(self)\""
    }
    
   mutating func replaceString(with purchaseID : PurchaseId? = nil){
       
       var whileLoopCount : Int = 0
       
        while self.contains("*#") {
            whileLoopCount += 1
            Log.debug("while Running #\(whileLoopCount)",file: #file,line: #line)
            
            if whileLoopCount > 20 {
                Log.error("while Not Stoping for : \(self)",file: #file, line: #line)
                break
            }
            
            if let first = self.extractStringBetweenMarkers() {
                switch first {
                case "Price":
                    if let purchaseID {
                        self = self.replacingOccurrences(of: "*#Price#*", with: purchaseID.getPriceString())
                    } else {
                        self = self.replacingOccurrences(of: "*#Price#*", with: "")
                    }
                  
                case "offerSubString":
                    if let purchaseID {
                        self = self.replacingOccurrences(of: "*#offerSubString#*", with: purchaseID.getSubPeriodString() ?? "")
                    } else {
                        self = self.replacingOccurrences(of: "*#offerSubString#*", with: "")
                    }
                   
                case "offerPrice":
                    self = self.replacingOccurrences(of: "*#offerPrice#*", with: purchaseID!.getPriceString(withOutPostFix: true))
                case "Price*12":
                    if let price = purchaseID?.priceDouble {
                        let yearlyPrice = (price * 12).truncate(places: 2)
                        self = self.replacingOccurrences(of: "*#Price*12#*", with: "\(purchaseID?.currencySymbol ?? "") \(yearlyPrice)")
                    } else {
                        self = self.replacingOccurrences(of: "*#Price*12#*", with: "")
                    }
                case "Price/12":
                    if let price = purchaseID?.priceDouble {
                        let monthlyPrice = (price/12).truncate(places: 2)
                        self = self.replacingOccurrences(of: "*#Price/12#*", with: "\(purchaseID?.getCurrencySymbol() ?? "") \(monthlyPrice)")
                    } else {
                        self = self.replacingOccurrences(of: "*#Price/12#*", with: "")
                    }
                case "Name":
                    self = self.replacingOccurrences(of: "*#Name#*", with: PurchaseModel.shared.userName ?? "")
                case "currencySymbol":
                    self = self.replacingOccurrences(of: "*#currencySymbol#*", with: purchaseID?.getCurrencySymbol() ?? "")
                case "onlyPrice":
                    self = self.replacingOccurrences(of: "*#onlyPrice#*", with:  String(format: "%.2f", purchaseID?.getDoublePrice() ?? 0))
                case "onlyPrice/12":
                    if let price = purchaseID?.getDoublePrice() {
                        let monthlyPrice = (price/12).truncate(places: 2)
                        self = self.replacingOccurrences(of: "*#onlyPrice/12#*", with: "\(purchaseID?.getCurrencySymbol() ?? "") \(monthlyPrice)")
                    } else {
                        self = self.replacingOccurrences(of: "*#Price/12#*", with: "N/A")
                    }
                default :
                    break
                }
            } else {
                break
            }
         }
    }
    
    
    func extractStringBetweenMarkers() -> String? {
        // Define the start and end markers
        let startMarker = "*#"
        let endMarker = "#*"

        // Find the range of the first occurrence of the start marker
        guard let startIndex = self.range(of: startMarker)?.upperBound else {
            return nil
        }

        // Find the range of the first occurrence of the end marker after the start marker
        guard let endIndex = self[startIndex...].range(of: endMarker)?.lowerBound else {
            return nil
        }

        // Extract the substring between the markers
        let extractedString = String(self[startIndex..<endIndex])

        return extractedString
    }
    
    
}
