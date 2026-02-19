import Foundation
import StoreKit
import Observation

@Observable
class StoreManager {
    static let shared = StoreManager()
    var products: [Product] = []
    
    private let productIds = ["com.yourapp.calm.monthly"]
    
    init() {
        Task {
            await listenForTransactions()
        }
    }
    func loadProducts() async {
        do {
            self.products = try await Product.products(for: productIds)
            self.products.sort { $0.price < $1.price }
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
                
            default:
                break
            }
        } catch {
            print("Purchase error: \(error)")
        }
    }
    
    func restorePurchases() async {
        try? await AppStore.sync()
    }
    
    private func listenForTransactions() async {
        for await result in Transaction.updates {
            await handleTransaction(result)
        }
    }
    
    private func handleTransaction(_ verification: VerificationResult<Transaction>) async {
        switch verification {
        case .verified(let transaction):
            await MainActor.run {
                UserManager.shared.buyPremium()
            }
            
            await transaction.finish()
            
        case .unverified:
            print("Transaction failed authentication")
        }
    }
    
    func checkSubscriptionStatus() async {
        var hasActive = false
        
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if productIds.contains(transaction.productID) {
                    hasActive = true
                }
            }
        }
        
        await MainActor.run {
            UserManager.shared.isPremium = hasActive
        }
    }
}
