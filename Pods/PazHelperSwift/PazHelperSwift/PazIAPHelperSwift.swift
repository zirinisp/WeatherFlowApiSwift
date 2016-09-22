//
//  PazIAPHelperSwift.swift
//  PazHelperSwift
//
//  Created by Pantelis Zirinis on 18/11/2015.
//  Copyright © 2015 paz-labs. All rights reserved.
//

import UIKit
import StoreKit

@available(iOS 8.0, *)
public class PazIAPHelperSwift: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    public enum UpdateNotification {
        /// Posted when one or some of the products become available after a product request to the App Store
        case ProductsAvailable
        /// POsted after a fetch all products request is completed.
        case ProductsRequestCompleted
        /// Posted when product is purchase/restored
        case ActiveProducts
        /// Posted when products are restored from App Store
        case RestoredProductsAppStore
        
        public var name: Notification.Name {
            switch self {
            case .ProductsAvailable:
                return Notification.Name("PazIAPHelperSwift.UpdateNotificationProductsAvailable")
            case .ProductsRequestCompleted:
                return  Notification.Name("PazIAPHelperSwift.UpdateNotificationProductsRequestCompleted")
            case .ActiveProducts:
                return Notification.Name("PazIAPHelperSwift.UpdateNotificationActiveProducts")
            case .RestoredProductsAppStore:
                return Notification.Name("PazIAPHelperSwift.UpdateNotificationRestoredProductsAppStore")
            }
        }
    }

    private static var _shared: PazIAPHelperSwift = {
        let shared = PazIAPHelperSwift()
        shared.restoreProductsFromMemery()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidEnterBackground, object: nil, queue: OperationQueue.main, using: { [unowned shared] (notification) -> Void in
            shared.saveProductsToMemory()
            })
        
        return shared
    }()
    
    public class var shared: PazIAPHelperSwift {
        // this way we can easily subclass and change the shared.
        return PazIAPHelperSwift._shared
    }
    
    let notificationManager = PazNotificationManager()
    
    public override init() {
        self.products = Set<PazIAPProduct>()
        super.init()
        self.notificationManager.registerObserver(PazIAPProduct.UpdateNotification.ProductPurchase(success: true).name) { [unowned self] (notification) -> Void in
            if let product = notification.object as? PazIAPProduct {
                if self.products.contains(product) {
                    NotificationCenter.default.post(name: PazIAPHelperSwift.UpdateNotification.ActiveProducts.name, object: self, userInfo: notification.userInfo)
                }
            }
        }
        self.notificationManager.registerObserver(PazIAPProduct.UpdateNotification.ProductRequest(success: true).name) { [unowned self] (notification) -> Void in
            if let product = notification.object as? PazIAPProduct {
                if self.products.contains(product) {
                    NotificationCenter.default.post(name: PazIAPHelperSwift.UpdateNotification.ProductsAvailable.name, object: self)
                }
            }
        }
    }
    
    public func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    public func isStoreReachable() -> Bool {
        // check connection
        let hostname = "appstore.com"
        let hostinfo = gethostbyname(hostname)
        return hostinfo != nil
    }
    
    public var products: Set<PazIAPProduct>
    
    public func getProductWithID(productID: String) -> PazIAPProduct? {
        for product in self.products {
            if product.productID == productID {
                return product
            }
        }
        return nil
    }
    
    public private (set) var fetchingProducts = false
    private var _lastFetch: Date?
    public var lastFetch: Date? {
        get {
            if let last = self._lastFetch {
                return last
            }
            // If no last fetch try to get the earliest date from the products
            var last: Date?
            for product in self.products {
                if let date = product.lastFetch {
                    if let letLast = last {
                        if date.isLaterThan(letLast) {
                            last = date
                        }
                    } else {
                        last = date
                    }
                }
            }
            return last
        }
    }
    /// Fetch all products
    public func fetchAllProducts() -> Bool {
        if self.fetchingProducts {
            return true
        }
        if self.products.count == 0 {
            return false
        }
        self.fetchingProducts = true
        
        var productIDs = [String]()
        for product in products {
            productIDs.append(product.productID)
        }
        let productsRequest = SKProductsRequest(productIdentifiers: Set(productIDs))
        productsRequest.delegate = self
        productsRequest.start()
        return true
    }
    
    /// Should be used only when we want to delete all purchases
    public func resetAllPurchases() {
        for product in self.products {
            product.resetPurchase()
        }
        NotificationCenter.default.post(name: PazIAPHelperSwift.UpdateNotification.ProductsAvailable.name, object: self)
    }
    
    /// The maximum level that the user has active. 0 if none is active.
    public var level: Int {
        var level = 0
        for product in self.products {
            if product.active {
                level = MAX(level, product.level)
            }
        }
        return level
    }
    
    /// Returns the product with the maximum level that is currently active
    public var activeProduct: PazIAPProduct? {
        var levelProduct: PazIAPProduct?
        for product in self.products {
            if product.active {
                if let current = levelProduct {
                    if product.level > current.level {
                        levelProduct = product
                    }
                } else {
                    levelProduct = product
                }
            }
        }
        return levelProduct
    }
    
    // MARK: Restore Transactions from App Store
    public private (set) var restorePurchasesFromAppStoreActive = false
    /// Used to restore purchases that have been made on the app store
    public func restorePurchasesFromAppStore() {
        if self.restorePurchasesFromAppStoreActive {
            return
        }
        SKPaymentQueue.default().add(self)
        self.restorePurchasesFromAppStoreActive = true
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        self.restorePurchasesFromAppStoreActive = false
        NotificationCenter.default.post(name: PazIAPHelperSwift.UpdateNotification.RestoredProductsAppStore.name, object: self, userInfo: nil)
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        self.restorePurchasesFromAppStoreActive = false
        NotificationCenter.default.post(name: PazIAPHelperSwift.UpdateNotification.RestoredProductsAppStore.name, object: self, userInfo: ["error": error])
    }
    // MARK: SKPaymentTransactionObserver
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        // This is handled from individual products
    }
    
    // MARK: SKProductsRequestDelegate
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.fetchingProducts = false
        self._lastFetch = Date()
        for product in self.products {
            product.productsRequest(request, didReceive: response)
        }
        NotificationCenter.default.post(name: PazIAPHelperSwift.UpdateNotification.ProductsRequestCompleted.name, object: self)
    }
}

@available(iOS 8.0, *)
public extension PazIAPHelperSwift { // Store file managment
    
    func productsFilePath() -> String? {
        return self.productsFilePathUrl()?.path
    }

    func productsFilePathUrl() -> URL? {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        let documentsDirectoruUrl = URL(string: documentsDirectory)
        return  documentsDirectoruUrl?.appendingPathComponent("products.plist")
    }
    
    public func restoreProductsFromMemery()  {
        guard let path = self.productsFilePath() else {
            print("Error restoring products from memory")
            return
        }
        if let items = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? Set<PazIAPProduct> {
            self.products.formUnion(items)
        }
    }
    
    public func saveProductsToMemory() {
        guard let url = self.productsFilePathUrl() else {
            print("Error saving products to memory")
            return
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: self.products)
        var error: Error?
        do {
            try data.write(to: url, options: [.atomicWrite, .completeFileProtection])
        } catch let error1 {
            error = error1
            print("Failed to save purchased items: \(error)")
        }
    }
}

public class PazIAPProduct: NSCoder, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    public enum UpdateNotification {
        /// Posted when product request is successful/failed
        case ProductRequest(success: Bool)
        /// Posted when product request is successful/failed
        case ProductPurchase(success: Bool)

        /// This is the key to access more information on a successfull or failed notification
        public static var ProductPurchaseTransactionKey = "PazIAPProduct.UpdateNotificationProductPurchaseTransactionKey"

        public var name: Notification.Name {
            switch self {
            case .ProductPurchase(let success):
                return Notification.Name(success ? "PazIAPProduct.UpdateNotificationProductRequestSuccess" : "PazIAPProduct.UpdateNotificationProductRequestFailed")
            case .ProductRequest(let success):
                return Notification.Name(success ? "PazIAPProduct.UpdateNotificationProductPurchaseSuccess" : "PazIAPProduct.UpdateNotificationProductPurchaseFailed")
            }
        }
    }

    public var title: String

    public var subtitle: String
    
    /// Product ID registered with apple servers
    public var productID: String
    
    private var _product: SKProduct?
    /// Set to automatically fetch product when product variable is nil and it is accessed
    public var autoFetch = true
    /// When the product is fetched this variable is set
    public var product: SKProduct? {
        get {
            if let product = self._product {
                return product
            } else {
                if self.autoFetch {
                    self.fetchProduct()
                }
                return nil
            }
        }
    }
    /// When was the product last fetched
    public var lastFetch: Date?
    
    /// Dictionary to store any relevant information
    public var userInfo = [String: AnyObject]()
    
    /// Used to store purchases on keychain. If changed all previous purchases will become inactive.
    public var keychainPassword = "fdjUHUK348@$%fgkgf"

    /// Message to display once purchase is successfull.
    public var purchaseMessage: String
    
    /// Message to display when user is asked to make a purchase.
    public var purchasePromptMessage: String
    
    /// Set to bypass active
    public var bypassActive: Bool = false
    
    /// Price with currency symbol, local for the user
    public var localPriceFormatted: String? {
        if let price = self.product?.price, let locale = self.product?.priceLocale {
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = NumberFormatter.Behavior.behavior10_4
            numberFormatter.numberStyle = NumberFormatter.Style.currency
            numberFormatter.locale = locale
            let formattedPrice = numberFormatter.string(from: price)
            return formattedPrice
        } else {
            return nil
        }
    }
    
    /// Local price
    public var localPrice: Double? {
        return self.product?.price.doubleValue
    }
    
    public var localizedTitle: String? {
        return self.product?.localizedTitle
    }
    
    public var localizedDescription: String? {
        return self.product?.localizedDescription
    }
    
    private var _active: Bool = false
    /// Returns wheather the product has been purchased or not
    public var active: Bool {
        get {
            if self.bypassActive {
                return true
            }
            return self._active
        }
    }
    
    public private (set) var fetchingProduct = false
    
    public private (set) var purchasingProduct = false
    
    /// Helper variable to determine what level the user has unlocked. Premium = 1, Pro = 2, etc
    public var level = 0
    
    /// Init
    public init(title: String, subtitle: String, productID: String, purchasePromptMessage: String, purchaseMessage: String, level: Int) {
        self.title = title
        self.subtitle = subtitle
        self.productID = productID
        self.purchasePromptMessage = purchasePromptMessage
        self.purchaseMessage = purchaseMessage
        self.level = level
        super.init()
        self.updateActive()
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    public convenience init(title: String, subtitle: String, productID: String, purchasePromptMessage: String, purchaseMessage: String) {
        self.init(title: title, subtitle: subtitle, productID: productID, purchasePromptMessage: purchasePromptMessage, purchaseMessage: purchaseMessage, level: 0)
    }
    
    public func fetchProduct() {
        if self.fetchingProduct {
            return
        }
        self.fetchingProduct = true
        let productsRequest = SKProductsRequest(productIdentifiers: NSSet(array: [self.productID]) as! Set)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    /// Should be used only when a fetch is made externaly. Ex. from IAPHelper
    public func setFetchingProduct() {
        self.fetchingProduct = true
    }
    
    public func purchaseProduct() {
        if self.purchasingProduct {
            return
        }
        
        if let product = self.product {
            self.purchasingProduct = true
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            NotificationCenter.default.post(name: PazIAPProduct.UpdateNotification.ProductPurchase(success: false).name, object: self)
        }
    }
    
    /// Activates product. Should be used only when valid purchase is made.
    func activateProduct() {
        let passwordData = self.keychainPassword.data(using: String.Encoding.utf8)
        
        var keychainQuery = self.keychainDictionary()
        keychainQuery[kSecValueData as String] = passwordData! as AnyObject?
        
        // Delete any existing items
        SecItemDelete(keychainQuery as CFDictionary)
        
        // Add the new keychain item
        let status: OSStatus = SecItemAdd(keychainQuery as CFDictionary, nil)
        
        // Check that it worked ok
        print("In App Purchase Activated: \(status)")
        
        self.updateActive()
    }
    
    /// Checks keychain wheather purchase has been made and updated product
    public func updateActive() {
        var keychainQuery = self.keychainDictionary()
        keychainQuery[kSecReturnData as String] = kCFBooleanTrue
        keychainQuery[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var result :AnyObject?
        
        // Search
        let status = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(keychainQuery as CFDictionary, UnsafeMutablePointer($0))
        }
        
        if status == noErr {
            if let data = result as? NSData {
                let password = String(data: data as Data, encoding: String.Encoding.utf8)
                self._active = self.keychainPassword == password
            }
        } else {
            self._active = false
        }
    }
    
    func keychainDictionary() -> [String: AnyObject] {
        let keychainDictionary: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.productID as AnyObject,
            kSecAttrAccount as String: Bundle.main.bundleIdentifier! as AnyObject
        ]
        return keychainDictionary
    }
    
    /// Should be used only when we want to delete the purchase from memory
    func resetPurchase() {
        let passwordData = self.keychainPassword.data(using: String.Encoding.utf8)
        
        var keychainQuery = self.keychainDictionary()
        keychainQuery[kSecValueData as String] = passwordData! as AnyObject?
        
        // Delete any existing items
        SecItemDelete(keychainQuery as CFDictionary)
        self.updateActive()
    }
    
    // MARK: SKProductsRequestDelegate
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.fetchingProduct = false
        for product in response.products {
            if product.productIdentifier == self.productID {
                self._product = product
                self.lastFetch = Date()
                NotificationCenter.default.post(name: PazIAPProduct.UpdateNotification.ProductRequest(success: true).name, object: self)
                return
            }
        }
        NotificationCenter.default.post(name: PazIAPProduct.UpdateNotification.ProductRequest(success: false).name, object: self)
    }
    
    // MARK: SKPaymentTransactionObserver
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.payment.productIdentifier == self.productID {
                switch transaction.transactionState {
                case .failed:
                    self.purchasingProduct = false
                    print("Purchase failed \(self.productID)")
                    NotificationCenter.default.post(name: PazIAPProduct.UpdateNotification.ProductPurchase(success: false).name, object: self, userInfo: [PazIAPProduct.UpdateNotification.ProductPurchaseTransactionKey : transaction])
                    SKPaymentQueue.default().finishTransaction(transaction)
                case .purchased, .restored:
                    self.purchasingProduct = false
                    self.activateProduct()
                    print("Purchase successful \(self.productID)")
                    NotificationCenter.default.post(name: PazIAPProduct.UpdateNotification.ProductPurchase(success: true).name, object: self, userInfo: [PazIAPProduct.UpdateNotification.ProductPurchaseTransactionKey : transaction])
                    SKPaymentQueue.default().finishTransaction(transaction)
                case .purchasing, .deferred:
                    break
                }
            }
        }
    }

    // MARK: NSCoder
    public func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encode(self.title, forKey:"name")
        aCoder.encode(self.subtitle, forKey:"subtitle")
        aCoder.encode(self.productID, forKey:"productID")
        aCoder.encode(self.purchaseMessage, forKey: "puchaseMessage")
        aCoder.encode(self.purchasePromptMessage, forKey:  "purchasePromptMessage")
        aCoder.encode(self.level, forKey: "level")
        aCoder.encode(self.userInfo, forKey: "userInfo")
        aCoder.encode(self.keychainPassword, forKey: "keychainPassword")
    }
    
    public convenience init (coder aDecoder: NSCoder!) {
        let title = StringOrEmpty(aDecoder.decodeObject(forKey: "name") as? String)
        let subtitle = StringOrEmpty(aDecoder.decodeObject(forKey: "subtitle") as? String)
        let productID = StringOrEmpty(aDecoder.decodeObject(forKey: "productID") as? String)
        let purchaseMessage = StringOrEmpty(aDecoder.decodeObject(forKey: "purchaseMessage") as? String)
        let purchasePromptMessage = StringOrEmpty(aDecoder.decodeObject(forKey: "purchasePromptMessage") as? String)
        let level = aDecoder.decodeObject(forKey: "level") as! Int
        self.init(title: title, subtitle: subtitle, productID: productID, purchasePromptMessage: purchasePromptMessage, purchaseMessage: purchaseMessage, level: level)
        if let userInfo = aDecoder.decodeObject(forKey: "userInfo") as? [String: AnyObject] {
            self.userInfo = userInfo
        }
        if let password = aDecoder.decodeObject(forKey: "keychainPassword") as? String {
            self.keychainPassword = password
        }
        self.updateActive()
    }
}

public func == (lhs: PazIAPProduct, rhs: PazIAPProduct) -> Bool {
    return lhs.productID == rhs.productID
}
