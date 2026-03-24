import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage(Constants.UserDefaultsKeys.useMetricUnits) private var useMetricUnits = false
    @AppStorage(Constants.UserDefaultsKeys.selectedCurrency) private var selectedCurrency = "USD"
    @AppStorage(Constants.UserDefaultsKeys.notificationsEnabled) private var notificationsEnabled = true
    @AppStorage(Constants.UserDefaultsKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = true

    @Query(sort: \Pet.name) private var pets: [Pet]
    @Environment(\.modelContext) private var modelContext

    @State private var showingExportSheet = false
    @State private var exportURL: URL?
    @State private var showingResetAlert = false
    @State private var showingPaywall = false

    private let currencies = ["USD", "EUR", "GBP", "CAD", "AUD", "JPY", "INR"]

    var body: some View {
        List {
            // MARK: - Units & Preferences
            Section {
                Toggle(isOn: $useMetricUnits) {
                    Label {
                        VStack(alignment: .leading) {
                            Text("Metric Units")
                            Text(useMetricUnits ? "kg, cm" : "lbs, in")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "ruler.fill")
                            .foregroundStyle(.blue)
                    }
                }
                .tint(Theme.primaryColor)

                Picker(selection: $selectedCurrency) {
                    ForEach(currencies, id: \.self) { currency in
                        Text(currency).tag(currency)
                    }
                } label: {
                    Label {
                        Text("Currency")
                    } icon: {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            } header: {
                Text("Preferences")
            }

            // MARK: - Notifications
            Section {
                Toggle(isOn: $notificationsEnabled) {
                    Label {
                        VStack(alignment: .leading) {
                            Text("Push Notifications")
                            Text("Reminders, medications, vet visits")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(.orange)
                    }
                }
                .tint(Theme.primaryColor)
                .onChange(of: notificationsEnabled) { _, newValue in
                    if newValue {
                        Task { await NotificationService.shared.requestAuthorization() }
                    }
                }

                Button {
                    if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label {
                        Text("System Notification Settings")
                            .foregroundStyle(.primary)
                    } icon: {
                        Image(systemName: "gear")
                            .foregroundStyle(.gray)
                    }
                }
            } header: {
                Text("Notifications")
            }

            // MARK: - Data
            Section {
                Button {
                    exportData()
                } label: {
                    Label {
                        Text("Export All Data")
                            .foregroundStyle(.primary)
                    } icon: {
                        Image(systemName: "square.and.arrow.up.fill")
                            .foregroundStyle(.indigo)
                    }
                }

                Button(role: .destructive) {
                    showingResetAlert = true
                } label: {
                    Label {
                        Text("Reset Onboarding")
                    } icon: {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundStyle(.red)
                    }
                }
            } header: {
                Text("Data")
            }

            // MARK: - Subscription
            Section {
                Button {
                    showingPaywall = true
                } label: {
                    HStack {
                        Label {
                            VStack(alignment: .leading) {
                                Text("PetLog Premium")
                                    .foregroundStyle(.primary)
                                Text(StoreKitService.shared.isPremium ? "Active" : "Unlock all features")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.yellow)
                        }
                        Spacer()
                        if StoreKitService.shared.isPremium {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Button {
                    Task { await StoreKitService.shared.restorePurchases() }
                } label: {
                    Label {
                        Text("Restore Purchases")
                            .foregroundStyle(.primary)
                    } icon: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundStyle(.blue)
                    }
                }
            } header: {
                Text("Subscription")
            }

            // MARK: - About
            Section {
                HStack {
                    Label {
                        Text("Version")
                    } icon: {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.gray)
                    }
                    Spacer()
                    Text(appVersion)
                        .foregroundStyle(.secondary)
                }

                Link(destination: URL(string: "https://petlog.app/privacy")!) {
                    Label {
                        Text("Privacy Policy")
                            .foregroundStyle(.primary)
                    } icon: {
                        Image(systemName: "hand.raised.fill")
                            .foregroundStyle(.blue)
                    }
                }

                Link(destination: URL(string: "https://petlog.app/terms")!) {
                    Label {
                        Text("Terms of Service")
                            .foregroundStyle(.primary)
                    } icon: {
                        Image(systemName: "doc.text.fill")
                            .foregroundStyle(.gray)
                    }
                }

                Button {
                    if let url = URL(string: "mailto:support@petlog.app") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label {
                        Text("Contact Support")
                            .foregroundStyle(.primary)
                    } icon: {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(Theme.primaryColor)
                    }
                }
            } header: {
                Text("About")
            } footer: {
                Text("Made with ❤️ for pet lovers")
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showingExportSheet) {
            if let url = exportURL {
                ShareSheet(activityItems: [url])
            }
        }
        .alert("Reset Onboarding", isPresented: $showingResetAlert) {
            Button("Reset", role: .destructive) {
                hasCompletedOnboarding = false
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will show the onboarding screens again on next launch.")
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private func exportData() {
        guard let pet = pets.first else { return }
        if let url = DataExportService.shared.exportAllDataCSV(pet: pet) {
            exportURL = url
            showingExportSheet = true
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(for: Pet.self, inMemory: true)
}
