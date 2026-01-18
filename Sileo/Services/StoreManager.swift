import Foundation
import StoreKit
import Observation

@Observable
class StoreManager {
    static let shared = StoreManager()
    
    // Сюда загрузится наш продукт (Premium)
    var products: [Product] = []
    
    // Идентификатор продукта (тот, что ты вписал в .storekit файл)
    private let productIds = ["com.yourapp.calm.monthly"] // ⚠️ ЗАМЕНИ НА СВОЙ ID
    
    init() {
        // Начинаем слушать обновления транзакций (например, если купили на другом устройстве)
        Task {
            await listenForTransactions()
        }
    }
    
    // 1. Загрузка товаров из магазина
    func loadProducts() async {
        do {
            self.products = try await Product.products(for: productIds)
            // Сортируем по цене (если товаров будет несколько)
            self.products.sort { $0.price < $1.price }
        } catch {
            print("Ошибка загрузки товаров: \(error)")
        }
    }
    
    // 2. Покупка товара
    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Проверяем подпись транзакции
                await handleTransaction(verification)
                
            case .pending:
                print("Транзакция ожидает подтверждения (например, родительский контроль)")
                
            case .userCancelled:
                print("Пользователь отменил покупку")
                
            default:
                break
            }
        } catch {
            print("Ошибка покупки: \(error)")
        }
    }
    
    // 3. Восстановление покупок
    func restorePurchases() async {
        try? await AppStore.sync()
    }
    
    // Слушатель транзакций (фоновый процесс)
    private func listenForTransactions() async {
        for await result in Transaction.updates {
            await handleTransaction(result)
        }
    }
    
    // Обработка успешной транзакции
    private func handleTransaction(_ verification: VerificationResult<Transaction>) async {
        switch verification {
        case .verified(let transaction):
            // ✅ Успешная покупка!
            // Открываем доступ в UserManager
            await MainActor.run {
                UserManager.shared.buyPremium()
            }
            
            // Сообщаем Apple, что мы обработали покупку
            await transaction.finish()
            
        case .unverified:
            print("Транзакция не прошла проверку подлинности")
        }
    }
    
    // 4. Проверка статуса при запуске приложения
        func checkSubscriptionStatus() async {
            var hasActive = false
            
            // Спрашиваем у Apple: "Какие товары сейчас куплены у этого юзера?"
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    // Если ID совпадает с нашим Premium ID
                    if productIds.contains(transaction.productID) {
                        // Значит подписка активна!
                        hasActive = true
                    }
                }
            }
            
            // Обновляем статус в приложении (строго на главном потоке)
            await MainActor.run {
                UserManager.shared.isPremium = hasActive
            }
        }
}
