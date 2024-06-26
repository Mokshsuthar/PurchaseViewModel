# PurchaseModel Integration Guide

This document explains how to integrate and use the `PurchaseModel` in your project. Follow the steps below to set up and utilize the purchase model effectively.

## Step 1: Install SwiftyStoreKit
To handle in-app purchases, install the `SwiftyStoreKit` pod.

1. Open your terminal and navigate to your project directory.
2. Open your `Podfile` and add the following line and install pod:

    ```ruby
    pod 'SwiftyStoreKit'
    ```

## Step 2: Copy PurchaseModel Folder
Copy the `PurchaseModel` folder into your project's `model` folder.

## Step 3: AppDelegate Setup
Add the following function in your `AppDelegate` and call it within the `application(_:didFinishLaunchingWithOptions:)` method.

### AppDelegate Code
```swift
class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Call the setup function here
        self.setUpProScreens()
        return true
    }
    
    func setUpProScreens() {
        self.setUpCompleteTransactions()
        
        // Your app's sharedSecret
        PurchaseModel.shared.sharedSecret = "1234567890qwertyuioifdfb"
        
        // Mention all your purchase IDs with their default prices
        PurchaseModel.shared.purchaseIds = [
            .init(type: .yearly, purchaseId: "com.maximaapps.passportphoto.yearly", priceDefaultValue: "$9.99", priceDefaultValueDouble: 9.99),
            .init(type: .lifeTime, purchaseId: "com.maximaapps.passportphoto.lifetime", priceDefaultValue: "$19.99", priceDefaultValueDouble: 19.99, needSplitPrice: true, splitPriceStringSuffix: "Month"),
            .init(type: .lifeTime, purchaseId: "com.maximaapps.passportphoto.lifetimew",priceDefaultValue: "$14.99",priceDefaultValueDouble: 14.99, needSplitPrice: true,splitPriceStringSuffix: "Month",isIncludeVerifySubscription: false), //if provide isIncludeVerifySubscription false it will not include this id during restore purchase
            .init(type: .lifeTime, purchaseId: "com.maximaapps.passportphoto.lifetime2", priceDefaultValue: "$29.99", priceDefaultValueDouble: 29.99),
            .init(type: .weekly, purchaseId: "com.maximaapps.passportphoto.weekly", priceDefaultValue: "$4.99", priceDefaultValueDouble: 4.99),
            .init(type: .yearly, purchaseId: "com.maximaapps.passportphoto.yearly2", priceDefaultValue: "$14.99", priceDefaultValueDouble: 14.99)
        ]
        
        // Run this to get all purchase IDs details and price
        PurchaseModel.shared.getPrice()
        
        // Extra configurations
        // If your project includes Qonversion
        QonversionModel.shared.configure(projectKey: "qwertyuiop", launchMode: .subscriptionManagement)
        
        // If your project includes Singular
        SingularModel.shared.configureSingular(apiKey: "qwertyuiop", secret: "sdfghjkl")
    }
}
```

## Step 4: ViewModel Setup
In your ViewModel, use the following code to manage purchases. This section breaks down the necessary steps for better understanding.

### Import Required Libraries
```swift
import SwiftyStoreKit
```

### Create ViewModel
```swift
class ContentViewModel: ObservableObject {
    
    // Mention all your purchase IDs here
    var yearlyPurchaseID = PurchaseModel.shared.getPurchaseID(value: "com.maximaapps.passportphoto.yearly")
    var weeklyPurchaseID = PurchaseModel.shared.getPurchaseID(value: "com.maximaapps.passportphoto.weekly")
    
    @Published var isLoading: Bool = false
    
    init() {
        // Provide AppDelegate for implementing purchase delegate methods
        PurchaseModel.shared.delegate = self
    }
    
    // Action to start yearly purchase
    func yearlyPurchaseAction() {
        self.purchase(yearlyPurchaseID)
    }
    
    // Action to start weekly purchase
    func weeklyPurchaseAction() {
        self.purchase(weeklyPurchaseID)
    }
    
    // Start purchasing for purchase ID
    func purchase(_ purchaseID: PurchaseId) {
        PurchaseModel.shared.purchase(purchaseID)
    }
    
    // Check and restore purchase for all purchase IDs
    // Show alert if you want to notify the user
    func restorePurchase() {
        PurchaseModel.shared.verifySubscriptions(showAlerts: true)
    }
    
    // Check and restore purchase for specific ID/IDs
    // Show alert if you want to notify the user
    func restorePurchaseForYearly() {
        PurchaseModel.shared.verifySubscriptions([yearlyPurchaseID.purchaseId], showAlerts: true)
    }
}
```

### Implement Delegate Methods
Extend your ViewModel to implement the `PurchaseModelDelegate` methods. All methods are optional, implement only those you need.

```swift
extension ContentViewModel: PurchaseModelDelegate {
    // Toggle loading screen
    func purchase(didStartLoading isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    // Called once after purchase is successful
    func purchase(didPurchaseSuccessWith result: PurchaseDetails, purchaseID: PurchaseId) {
        print("Purchase successful: \(purchaseID.purchaseId)")
    }
    
    // Called once after purchase failed for any reason
    func purchase(didPurchaseFailWith error: any Error) {
        print("Purchase failed: \(error.localizedDescription)")
    }
    
    // Called once after restore purchase is called and purchases are restored
    func purchase(didVerifySubscriptionsFor result: VerifySubscriptionResult, showAlert: Bool) {
        // Handle subscription verification result
    }
    
    // Called once if you need any receipt after purchase
    func purchase(id: String, didReceiveReceiptFor receipt: String) {
        // Handle receipt
    }
}
```

## Checking Purchase Status
There is no need to save any user defaults regarding purchases. Everything is already managed and saved by the `PurchaseModel`. To check if a purchase has been made, you can use any of the following UserDefaults keys:

- `UserDefaults.isPurchase`
- `UserDefaults.isProUser`
- `UserDefaults.isProUser.isPro`

All these keys hold the same value.

With these steps, you should be able to integrate and use the `PurchaseModel` in your project. Ensure you customize the `purchaseIds` and other properties as per your app's requirements.
