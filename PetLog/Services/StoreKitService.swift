import Foundation
import StoreKit

@Observable
final class StoreKitService {
    static let shared = StoreKitService()

    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isPremium: Bool = false
    var isLoading: Bool = false

    private let productIDs = [
        Constants.StoreKit.monthlyProductId,
        Constants.StoreKit.yearlyProductId
    ]

    private var updateListenerTask: Task<Void, Error>?

    init() {
        updateListenerTask = listenForTransactions()
        Task { await loadProducts() }
        Task { await updatePurchaseStatus() }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Load Products

    @MainActor
    func loadProducts() async {
        isLoading = true
        do {
            products = try await Product.products(for: productIDs)
                .sorted { $0.price < $1.price }
        } catch {
            print("Failed to load products: \(error)")
        }
        isLoading = false
    }

    // MARK: - Purchase

    @MainActor
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchaseStatus()
            await transaction.finish()
            HapticManager.notification(.success)
            return transaction

        case .userCancelled:
            return nil

        case .pending:
            return nil

        @unknown default:
            return nil
        }
    }

    // MARK: - Restore

    @MainActor
    func restorePurchases() async {
        try? await AppStore.sync()
        await updatePurchaseStatus()
    }

    // MARK: - Status

    @MainActor
    func updatePurchaseStatus() async {
        var purchased: Set<String> = []

        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                purchased.insert(transaction.productID)
            }
        }

        purchasedProductIDs = purchased
        isPremium = !purchased.isEmpty
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                if let transaction = try? self.checkVerified(result) {
                    await self.updatePurchaseStatus()
                    await transaction.finish()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Helpers

    var monthlyProduct: Product? {
        products.first { $0.id == Constants.StoreKit.monthlyProductId }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == Constants.StoreKit.yearlyProductId }
    }

    func canAccessPremiumFeature() -> Bool {
        isPremium
    }

    enum StoreError: Error, LocalizedError {
        case failedVerification
        var errorDescription: String? { "Transaction verification failed." }
    }
}
