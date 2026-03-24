import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showingQuickAdd = false
    @Query private var pets: [Pet]

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            HealthTabView()
                .tabItem {
                    Label("Health", systemImage: "heart.fill")
                }
                .tag(1)

            Color.clear
                .tabItem {
                    Label("Add", systemImage: "plus.circle.fill")
                }
                .tag(2)

            ActivityTabView()
                .tabItem {
                    Label("Activity", systemImage: "figure.walk")
                }
                .tag(3)

            MoreTabView()
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle.fill")
                }
                .tag(4)
        }
        .tint(Theme.primaryColor)
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == 2 {
                showingQuickAdd = true
                selectedTab = oldValue
            }
        }
        .sheet(isPresented: $showingQuickAdd) {
            QuickAddSheet()
        }
        .task {
            await NotificationService.shared.requestAuthorization()
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Pet.self, VetVisit.self, Vaccination.self, Medication.self, WeightEntry.self, FeedingLog.self, PetActivity.self, Expense.self, JournalEntry.self, Reminder.self], inMemory: true)
}
