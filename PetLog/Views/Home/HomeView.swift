import SwiftUI
import SwiftData
import Charts

struct HomeView: View {
    @Query(sort: \Pet.name) private var pets: [Pet]
    @State private var viewModel = HomeViewModel()
    @State private var showingAddPet = false
    @State private var showingQuickAdd = false

    // Quick add states
    @State private var showingAddWeight = false
    @State private var showingAddFeeding = false
    @State private var showingAddExpense = false
    @State private var showingWalkView = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    petSelectorSection
                    
                    if let pet = viewModel.selectedPet {
                        statsSection(for: pet)
                        quickActionsSection(for: pet)
                        remindersSection(for: pet)
                        recentJournalSection(for: pet)
                        expenseChartSection(for: pet)
                    } else if pets.isEmpty {
                        addPetPrompt
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("PetLog")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddPet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPet) {
                PetSetupView()
            }
            .sheet(isPresented: $showingAddWeight) {
                if let pet = viewModel.selectedPet {
                    AddWeightEntryView(pet: pet)
                }
            }
            .sheet(isPresented: $showingAddFeeding) {
                if let pet = viewModel.selectedPet {
                    AddFeedingLogView(pet: pet)
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                if let pet = viewModel.selectedPet {
                    AddExpenseView(pet: pet)
                }
            }
            .sheet(isPresented: $showingWalkView) {
                if let pet = viewModel.selectedPet {
                    WalkTrackingView(pet: pet)
                }
            }
            .onAppear {
                viewModel.loadSelectedPet(from: pets)
            }
            .onChange(of: pets) {
                viewModel.loadSelectedPet(from: pets)
            }
        }
    }

    // MARK: - Pet Selector
    private var petSelectorSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(pets) { pet in
                    VStack(spacing: 4) {
                        PetAvatarView(
                            pet: pet,
                            size: 56,
                            isSelected: viewModel.selectedPet?.id == pet.id
                        )
                        Text(pet.name)
                            .font(.caption)
                            .fontWeight(viewModel.selectedPet?.id == pet.id ? .semibold : .regular)
                    }
                    .onTapGesture {
                        viewModel.selectPet(pet)
                    }
                }

                Button {
                    showingAddPet = true
                } label: {
                    VStack(spacing: 4) {
                        Circle()
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                            .foregroundStyle(.secondary)
                            .frame(width: 56, height: 56)
                            .overlay {
                                Image(systemName: "plus")
                                    .foregroundStyle(.secondary)
                            }
                        Text("Add Pet")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: - Add Pet Prompt
    private var addPetPrompt: some View {
        VStack(spacing: 16) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 64))
                .foregroundStyle(Theme.primaryColor.opacity(0.3))

            Text("Welcome to PetLog!")
                .font(.title2)
                .fontWeight(.bold)

            Text("Add your first pet to start tracking their health, activities, and more.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showingAddPet = true
            } label: {
                Label("Add Your Pet", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Theme.primaryColor, in: Capsule())
            }
        }
        .padding(.top, 60)
    }

    // MARK: - Stats
    private func statsSection(for pet: Pet) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(
                title: "Age",
                value: pet.age,
                icon: "birthday.cake"
            )
            StatCard(
                title: "Weight",
                value: pet.latestWeight?.weightFormatted ?? "Not logged",
                icon: "scalemass",
                trendIcon: pet.weightTrend.icon,
                trendColor: pet.weightTrend.color
            )
            StatCard(
                title: "Next Vet Visit",
                value: pet.nextVetVisit?.date.shortDate ?? "None",
                icon: "cross.case.fill",
                accentColor: .red
            )
            StatCard(
                title: "Active Meds",
                value: "\(pet.activeMedications.count)",
                icon: "pill.fill",
                accentColor: .blue
            )
        }
    }

    // MARK: - Quick Actions
    private func quickActionsSection(for pet: Pet) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)

            HStack(spacing: 0) {
                QuickActionButton(title: "Log\nWeight", icon: "scalemass.fill") {
                    showingAddWeight = true
                }
                QuickActionButton(title: "Log\nFood", icon: "fork.knife", color: .green) {
                    showingAddFeeding = true
                }
                QuickActionButton(title: "Start\nWalk", icon: "figure.walk", color: .blue) {
                    showingWalkView = true
                }
                QuickActionButton(title: "Add\nExpense", icon: "dollarsign.circle.fill", color: .purple) {
                    showingAddExpense = true
                }
            }
            .cardStyle()
        }
    }

    // MARK: - Reminders
    private func remindersSection(for pet: Pet) -> some View {
        let reminders = viewModel.upcomingReminders(for: pet)
        return Group {
            if !reminders.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Upcoming Reminders")
                            .font(.headline)
                        Spacer()
                        Text("\(reminders.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    ForEach(reminders) { reminder in
                        HStack(spacing: 12) {
                            Image(systemName: reminder.type.icon)
                                .foregroundStyle(reminder.type.color)
                                .frame(width: 32, height: 32)
                                .background(reminder.type.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(reminder.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(reminder.date.shortDate)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if reminder.isDueToday {
                                Text("Today")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                }
                .cardStyle()
            }
        }
    }

    // MARK: - Recent Journal
    private func recentJournalSection(for pet: Pet) -> some View {
        let entries = viewModel.recentJournalEntries(for: pet)
        return Group {
            if !entries.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Journal")
                        .font(.headline)

                    ForEach(entries) { entry in
                        HStack(spacing: 12) {
                            Text(entry.mood.emoji)
                                .font(.title2)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                                Text(entry.date.shortDate)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if entry.isMilestone {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundStyle(.yellow)
                            }
                        }
                    }
                }
                .cardStyle()
            }
        }
    }

    // MARK: - Expense Chart
    private func expenseChartSection(for pet: Pet) -> some View {
        let total = viewModel.monthlyExpenseTotal(for: pet)
        let categories = viewModel.expensesByCategory(for: pet)
        return Group {
            if total > 0 {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("This Month's Expenses")
                            .font(.headline)
                        Spacer()
                        Text(total.currencyFormatted)
                            .font(.headline)
                            .foregroundStyle(Theme.primaryColor)
                    }

                    Chart(categories, id: \.category) { item in
                        SectorMark(
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.6),
                            angularInset: 2
                        )
                        .foregroundStyle(item.category.color)
                        .cornerRadius(4)
                    }
                    .frame(height: 160)

                    ForEach(categories, id: \.category) { item in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(item.category.color)
                                .frame(width: 8, height: 8)
                            Text(item.category.displayName)
                                .font(.caption)
                            Spacer()
                            Text(item.amount.currencyFormatted)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
                .cardStyle()
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Pet.self, VetVisit.self, Vaccination.self, Medication.self, WeightEntry.self, FeedingLog.self, PetActivity.self, Expense.self, JournalEntry.self, Reminder.self], inMemory: true)
}
