import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: PaywallPlan = .yearly
    @State private var isPurchasing = false
    @State private var showingError = false
    @State private var errorMessage = ""

    private let storeService = StoreKitService.shared

    enum PaywallPlan {
        case monthly, yearly
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero
                    heroSection

                    // Features
                    featuresList

                    // Plans
                    planSelector

                    // CTA
                    purchaseButton

                    // Restore & Terms
                    footerLinks
                }
                .padding(.horizontal, Theme.horizontalPadding)
                .padding(.bottom, 32)
            }
            .background(Theme.backgroundWarm.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .alert("Purchase Error", isPresented: $showingError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Theme.primaryColor, Theme.primaryColor.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "crown.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.white)
            }
            .padding(.top, 16)

            Text("PetLog Premium")
                .font(.title.bold())

            Text("Unlock the full power of PetLog\nand give your pet the best care")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Features List

    private var featuresList: some View {
        VStack(spacing: 0) {
            FeatureComparisonRow(feature: "Track 1 Pet", free: true, pro: true)
            Divider().padding(.horizontal)
            FeatureComparisonRow(feature: "Unlimited Pets", free: false, pro: true)
            Divider().padding(.horizontal)
            FeatureComparisonRow(feature: "Health Records", free: true, pro: true)
            Divider().padding(.horizontal)
            FeatureComparisonRow(feature: "Data Export (CSV)", free: false, pro: true)
            Divider().padding(.horizontal)
            FeatureComparisonRow(feature: "Emergency Card", free: false, pro: true)
            Divider().padding(.horizontal)
            FeatureComparisonRow(feature: "Photo Attachments", free: false, pro: true)
            Divider().padding(.horizontal)
            FeatureComparisonRow(feature: "Weight Charts", free: false, pro: true)
            Divider().padding(.horizontal)
            FeatureComparisonRow(feature: "Family Sharing", free: false, pro: true)
        }
        .background(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        )
    }

    // MARK: - Plan Selector

    private var planSelector: some View {
        VStack(spacing: 12) {
            // Yearly (Best Value)
            PlanCard(
                title: "Yearly",
                price: storeService.yearlyProduct?.displayPrice ?? Constants.StoreKit.yearlyPrice,
                subtitle: "Save 50% — just $2.50/mo",
                isSelected: selectedPlan == .yearly,
                badge: "BEST VALUE"
            )
            .onTapGesture {
                selectedPlan = .yearly
                HapticManager.selection()
            }

            // Monthly
            PlanCard(
                title: "Monthly",
                price: storeService.monthlyProduct?.displayPrice ?? Constants.StoreKit.monthlyPrice,
                subtitle: "Cancel anytime",
                isSelected: selectedPlan == .monthly,
                badge: nil
            )
            .onTapGesture {
                selectedPlan = .monthly
                HapticManager.selection()
            }
        }
    }

    // MARK: - Purchase Button

    private var purchaseButton: some View {
        Button {
            Task { await purchase() }
        } label: {
            HStack {
                if isPurchasing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Start Premium")
                        .font(.headline)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [Theme.primaryColor, Color(hex: "FF8F35")],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 16)
            )
        }
        .disabled(isPurchasing)
    }

    // MARK: - Footer

    private var footerLinks: some View {
        VStack(spacing: 8) {
            Button("Restore Purchases") {
                Task { await storeService.restorePurchases() }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                Link("Privacy", destination: URL(string: "https://petlog.app/privacy")!)
                Text("·").foregroundStyle(.secondary)
                Link("Terms", destination: URL(string: "https://petlog.app/terms")!)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - Actions

    @MainActor
    private func purchase() async {
        let product: Product?
        switch selectedPlan {
        case .monthly: product = storeService.monthlyProduct
        case .yearly: product = storeService.yearlyProduct
        }

        guard let product else {
            errorMessage = "Product not available. Please try again later."
            showingError = true
            return
        }

        isPurchasing = true
        do {
            if let _ = try await storeService.purchase(product) {
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
        isPurchasing = false
    }
}

// MARK: - Feature Comparison Row

private struct FeatureComparisonRow: View {
    let feature: String
    let free: Bool
    let pro: Bool

    var body: some View {
        HStack {
            Text(feature)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 32) {
                checkmark(active: free, label: "Free")
                checkmark(active: pro, label: "Pro")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func checkmark(active: Bool, label: String) -> some View {
        Image(systemName: active ? "checkmark.circle.fill" : "xmark.circle")
            .foregroundStyle(active ? .green : Color(.systemGray4))
            .font(.body)
            .frame(width: 40)
    }
}

// MARK: - Plan Card

private struct PlanCard: View {
    let title: String
    let price: String
    let subtitle: String
    let isSelected: Bool
    let badge: String?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.headline)

                    if let badge {
                        Text(badge)
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Theme.primaryColor.gradient, in: Capsule())
                    }
                }

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(price)
                .font(.title3.bold())
                .foregroundStyle(isSelected ? Theme.primaryColor : .primary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isSelected ? Theme.primaryColor.opacity(0.06) : Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isSelected ? Theme.primaryColor : .clear, lineWidth: 2)
        )
    }
}

#Preview {
    PaywallView()
}
