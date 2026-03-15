import Foundation
import StoreKit
import Observation

@MainActor
@Observable
class StoreManager {
    static let shared = StoreManager()
    
    var products: [Product] = []
    
    private let productIds = ["com.sileo.calmplus.monthly"]
    private var updatesTask: Task<Void, Never>? = nil
    
    private init() {
        updatesTask = Task {
            await listenForTransactions()
        }
    }
    
    func loadProducts() async {
        do {
            let loadedProducts = try await Product.products(for: productIds)
            self.products = loadedProducts.sorted { $0.price < $1.price }
        } catch {
            print("Error loading products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                await handleTransaction(verification)
                
            case .pending:
                print("Transaction is pending approval (e.g., parental control)")
                
            case .userCancelled:
                print("The user canceled the purchase")
                
            @unknown default:
                break
            }
        } catch {
            print("Purchase error: \(error)")
        }
    }
    
    func restorePurchases() async {
        try? await AppStore.sync()
        await checkSubscriptionStatus()
    }
   
    nonisolated private func listenForTransactions() async {
        for await result in Transaction.updates {
            Task { @MainActor in
                await self.handleTransaction(result)
            }
        }
    }
    
    private func handleTransaction(_ verification: VerificationResult<Transaction>) async {
        switch verification {
        case .verified(let transaction):
            
            await checkSubscriptionStatus()
            await transaction.finish()
            
        case .unverified(_, let error):
            print("Transaction failed authentication: \(error.localizedDescription)")
        }
    }
    
    func checkSubscriptionStatus() async {
        var hasActive = false
        
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productType == .autoRenewable {
                    if let expirationDate = transaction.expirationDate, expirationDate > Date() {
                        if productIds.contains(transaction.productID) {
                            hasActive = true
                        }
                    } else if transaction.expirationDate == nil {
                         if productIds.contains(transaction.productID) {
                             hasActive = true
                         }
                    }
                }
            }
        }
        
        UserManager.shared.isPremium = hasActive
    }
}
