import SwiftUI
import SwiftData
import Charts

struct ActivityTabView: View {
    @Query(sort: \Pet.name) private var pets: [Pet]
    @State private var viewModel = ActivityViewModel()
    @State private var selectedPet: Pet?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let pet = selectedPet ?? pets.first {
                    Picker("Section", selection: $viewModel.selectedSection) {
                        ForEach(ActivitySection.allCases) { section in
                            Text(section.displayName).tag(section)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                    ScrollView {
                        switch viewModel.selectedSection {
                        case .walks:
                            WalksView(pet: pet, viewModel: viewModel)
                        case .feeding:
                            FeedingView(pet: pet, viewModel: viewModel)
                        case .all:
                            AllActivityView(pet: pet, viewModel: viewModel)
                        }
                    }
                } else {
                    EmptyStateView(
                        icon: "figure.walk",
                        title: "No Pets",
                        message: "Add a pet to start tracking activities."
                    )
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Activity")
            .onAppear { selectedPet = pets.first }
        }
    }
}

// MARK: - Walks View
struct WalksView: View {
    let pet: Pet
    let viewModel: ActivityViewModel
    @State private var showingWalkTracking = false

    var body: some View {
        VStack(spacing: 16) {
            // Walk Stats
            let stats = viewModel.thisWeekWalkStats(for: pet)
            HStack(spacing: 12) {
                StatCard(
                    title: "This Week",
                    value: "\(stats.count) walks",
                    icon: "figure.walk",
                    accentColor: .blue
                )
                StatCard(
                    title: "Distance",
                    value: String(format: "%.1f mi", stats.totalDistance),
                    icon: "map",
                    accentColor: .green
                )
            }

            // Start Walk Button
            Button {
                showingWalkTracking = true
            } label: {
                HStack {
                    Image(systemName: "figure.walk")
                        .font(.title2)
                    Text("Start a Walk")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Theme.secondaryColor, in: RoundedRectangle(cornerRadius: 16))
            }

            // Walk History
            let walks = viewModel.recentWalks(for: pet)
            if !walks.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Walk History")
                        .font(.headline)

                    ForEach(walks.prefix(10)) { walk in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(walk.date.shortDate)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(walk.durationFormatted)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(walk.distanceFormatted)
                                .font(.subheadline)
                                .foregroundStyle(Theme.secondaryColor)
                        }
                        .padding(.vertical, 4)
                        Divider()
                    }
                }
                .cardStyle()
            } else {
                EmptyStateView(
                    icon: "figure.walk",
                    title: "No Walks Yet",
                    message: "Start your first walk to begin tracking."
                )
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
        .sheet(isPresented: $showingWalkTracking) {
            WalkTrackingView(pet: pet)
        }
    }
}

// MARK: - Walk Tracking View
struct WalkTrackingView: View {
    let pet: Pet
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ActivityViewModel()
    @State private var isActive = false
    @State private var showingSaveConfirmation = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // Timer Display
                Text(viewModel.locationService.elapsedTimeFormatted)
                    .font(.system(size: 64, weight: .thin, design: .monospaced))

                // Stats
                HStack(spacing: 32) {
                    VStack {
                        Text(String(format: "%.2f", viewModel.locationService.distanceInMiles))
                            .font(.title)
                            .fontWeight(.bold)
                        Text("miles")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // Control Buttons
                HStack(spacing: 32) {
                    if isActive {
                        Button {
                            stopWalk()
                        } label: {
                            Image(systemName: "stop.fill")
                                .font(.title)
                                .foregroundStyle(.white)
                                .frame(width: 80, height: 80)
                                .background(.red, in: Circle())
                        }
                    } else {
                        Button {
                            startWalk()
                        } label: {
                            Image(systemName: "play.fill")
                                .font(.title)
                                .foregroundStyle(.white)
                                .frame(width: 80, height: 80)
                                .background(Theme.secondaryColor, in: Circle())
                        }
                    }
                }

                Spacer()
            }
            .navigationTitle("Walk with \(pet.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        if isActive {
                            _ = viewModel.stopWalk()
                        }
                        dismiss()
                    }
                }
            }
            .alert("Save Walk?", isPresented: $showingSaveConfirmation) {
                Button("Save") { saveWalk() }
                Button("Discard", role: .destructive) { dismiss() }
                Button("Cancel", role: .cancel) { }
            } message: {
                let dist = viewModel.locationService.distanceInMiles
                Text("Distance: \(String(format: "%.2f", dist)) mi\nDuration: \(viewModel.locationService.elapsedTimeFormatted)")
            }
        }
    }

    private func startWalk() {
        viewModel.startWalk()
        isActive = true
    }

    private func stopWalk() {
        _ = viewModel.stopWalk()
        isActive = false
        showingSaveConfirmation = true
    }

    private func saveWalk() {
        let activity = PetActivity(
            date: Date(),
            type: .walk,
            duration: viewModel.locationService.elapsedTime,
            distance: viewModel.locationService.distanceInMiles,
            route: viewModel.locationService.encodeRoute(),
            pet: pet
        )
        modelContext.insert(activity)
        HapticManager.notification(.success)
        dismiss()
    }
}

// MARK: - Feeding View
struct FeedingView: View {
    let pet: Pet
    let viewModel: ActivityViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var showingAdd = false

    var body: some View {
        VStack(spacing: 16) {
            // Today's Summary
            let todayLogs = viewModel.todaysFeedingLogs(for: pet)
            let totalCalories = viewModel.todaysCalories(for: pet)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Today's Feeding")
                        .font(.headline)
                    Spacer()
                    if totalCalories > 0 {
                        Text("\(totalCalories) cal")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(Theme.primaryColor)
                    }
                }

                if todayLogs.isEmpty {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "fork.knife")
                                .font(.title)
                                .foregroundStyle(.secondary)
                            Text("No meals logged today")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 20)
                        Spacer()
                    }
                } else {
                    ForEach(todayLogs) { log in
                        HStack(spacing: 12) {
                            Image(systemName: log.foodType.icon)
                                .foregroundStyle(Theme.primaryColor)
                                .frame(width: 32, height: 32)
                                .background(Theme.primaryColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(log.foodBrand.isEmpty ? log.foodType.displayName : log.foodBrand)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(log.timeFormatted)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if let amount = log.amount {
                                Text("\(String(format: "%.1f", amount)) \(log.unit)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .cardStyle()

            Button {
                showingAdd = true
            } label: {
                Label("Log Feeding", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.primaryColor, in: RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
        .sheet(isPresented: $showingAdd) {
            AddFeedingLogView(pet: pet)
        }
    }
}

// MARK: - All Activity View
struct AllActivityView: View {
    let pet: Pet
    let viewModel: ActivityViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var showingAdd = false

    var body: some View {
        VStack(spacing: 12) {
            let activities = viewModel.allActivities(for: pet)
            if activities.isEmpty {
                EmptyStateView(
                    icon: "star.fill",
                    title: "No Activities",
                    message: "Log walks, play time, training, and more.",
                    buttonTitle: "Add Activity",
                    action: { showingAdd = true }
                )
            } else {
                ForEach(activities) { activity in
                    HStack(spacing: 12) {
                        Image(systemName: activity.type.icon)
                            .foregroundStyle(activity.type.color)
                            .frame(width: 36, height: 36)
                            .background(activity.type.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(activity.type.displayName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(activity.date.shortDate)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text(activity.durationFormatted)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            if let distance = activity.distance {
                                Text(String(format: "%.1f mi", distance))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .cardStyle()
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            modelContext.delete(activity)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
        .overlay(alignment: .bottomTrailing) {
            Button {
                showingAdd = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(Theme.primaryColor, in: Circle())
                    .shadow(radius: 4, y: 2)
            }
            .padding(24)
        }
        .sheet(isPresented: $showingAdd) {
            AddActivityView(pet: pet)
        }
    }
}

#Preview {
    ActivityTabView()
        .modelContainer(for: [Pet.self, PetActivity.self, FeedingLog.self], inMemory: true)
}
