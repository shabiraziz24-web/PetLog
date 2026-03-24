import SwiftUI
import SwiftData
import Charts

struct HealthTabView: View {
    @Query(sort: \Pet.name) private var pets: [Pet]
    @State private var viewModel = HealthViewModel()
    @State private var selectedPet: Pet?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let pet = selectedPet ?? pets.first {
                    Picker("Section", selection: $viewModel.selectedSection) {
                        ForEach(HealthSection.allCases) { section in
                            Text(section.displayName).tag(section)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                    ScrollView {
                        switch viewModel.selectedSection {
                        case .overview:
                            HealthOverviewView(pet: pet, viewModel: viewModel)
                        case .vetVisits:
                            VetVisitsListView(pet: pet)
                        case .vaccinations:
                            VaccinationsListView(pet: pet)
                        case .medications:
                            MedicationsListView(pet: pet)
                        case .weight:
                            WeightTrackingView(pet: pet)
                        }
                    }
                } else {
                    EmptyStateView(
                        icon: "heart.fill",
                        title: "No Pets",
                        message: "Add a pet to start tracking their health."
                    )
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Health")
            .onAppear {
                selectedPet = pets.first
            }
        }
    }
}

// MARK: - Health Overview
struct HealthOverviewView: View {
    let pet: Pet
    let viewModel: HealthViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Health Score
            let score = viewModel.healthScore(for: pet)
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 12)
                        .frame(width: 100, height: 100)

                    Circle()
                        .trim(from: 0, to: CGFloat(score) / 100)
                        .stroke(viewModel.healthScoreColor(score), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring, value: score)

                    Text("\(score)")
                        .font(.title)
                        .fontWeight(.bold)
                }

                Text("Health Score")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .cardStyle()

            // Quick Stats
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(
                    title: "Active Meds",
                    value: "\(pet.activeMedications.count)",
                    icon: "pill.fill",
                    accentColor: .blue
                )
                StatCard(
                    title: "Overdue Vaccines",
                    value: "\(pet.overdueVaccinations.count)",
                    icon: "syringe.fill",
                    accentColor: pet.overdueVaccinations.isEmpty ? .green : .red
                )
            }

            // Weight Chart
            if !pet.weightEntries.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Weight (Last 6 Months)")
                        .font(.headline)

                    let data = viewModel.weightData(for: pet)
                    Chart(data, id: \.date) { entry in
                        LineMark(
                            x: .value("Date", entry.date),
                            y: .value("Weight", entry.weight)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Theme.primaryColor)

                        AreaMark(
                            x: .value("Date", entry.date),
                            y: .value("Weight", entry.weight)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Theme.primaryColor.opacity(0.1).gradient)

                        PointMark(
                            x: .value("Date", entry.date),
                            y: .value("Weight", entry.weight)
                        )
                        .foregroundStyle(Theme.primaryColor)
                    }
                    .frame(height: 200)
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                }
                .cardStyle()
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}

// MARK: - Vet Visits List
struct VetVisitsListView: View {
    let pet: Pet
    @Environment(\.modelContext) private var modelContext
    @State private var showingAdd = false

    var body: some View {
        VStack(spacing: 0) {
            if pet.vetVisits.isEmpty {
                EmptyStateView(
                    icon: "cross.case.fill",
                    title: "No Vet Visits",
                    message: "Record your pet's vet visits to keep track of their medical history.",
                    buttonTitle: "Add Vet Visit",
                    action: { showingAdd = true }
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(pet.vetVisits.sorted { $0.date > $1.date }) { visit in
                        VetVisitRow(visit: visit)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    modelContext.delete(visit)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
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
            AddVetVisitView(pet: pet)
        }
    }
}

struct VetVisitRow: View {
    let visit: VetVisit

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: visit.isUpcoming ? "calendar.badge.clock" : "checkmark.circle.fill")
                    .foregroundStyle(visit.isUpcoming ? .orange : .green)

                Text(visit.date.shortDate)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                if let cost = visit.cost {
                    Text(cost.currencyFormatted)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
            }

            if !visit.reason.isEmpty {
                Text(visit.reason)
                    .font(.body)
            }

            HStack(spacing: 16) {
                if !visit.clinicName.isEmpty {
                    Label(visit.clinicName, systemImage: "building.2.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if !visit.vetName.isEmpty {
                    Label(visit.vetName, systemImage: "person.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !visit.diagnosis.isEmpty {
                Text("Diagnosis: \(visit.diagnosis)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .cardStyle()
    }
}

// MARK: - Vaccinations List
struct VaccinationsListView: View {
    let pet: Pet
    @Environment(\.modelContext) private var modelContext
    @State private var showingAdd = false

    var body: some View {
        VStack(spacing: 0) {
            if pet.vaccinations.isEmpty {
                EmptyStateView(
                    icon: "syringe.fill",
                    title: "No Vaccinations",
                    message: "Keep track of your pet's vaccination schedule.",
                    buttonTitle: "Add Vaccination",
                    action: { showingAdd = true }
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(pet.vaccinations.sorted { ($0.nextDueDate ?? .distantFuture) < ($1.nextDueDate ?? .distantFuture) }) { vax in
                        VaccinationRow(vaccination: vax)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    modelContext.delete(vax)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
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
            AddVaccinationView(pet: pet)
        }
    }
}

struct VaccinationRow: View {
    let vaccination: Vaccination

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: vaccination.status.icon)
                .font(.title2)
                .foregroundStyle(vaccination.status.color)

            VStack(alignment: .leading, spacing: 4) {
                Text(vaccination.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text("Given: \(vaccination.dateAdministered.shortDate)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let nextDue = vaccination.nextDueDate {
                    Text("Next due: \(nextDue.shortDate)")
                        .font(.caption)
                        .foregroundStyle(vaccination.status.color)
                }
            }

            Spacer()

            Text(vaccination.status.label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(vaccination.status.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(vaccination.status.color.opacity(0.12), in: Capsule())
        }
        .cardStyle()
    }
}

// MARK: - Medications List
struct MedicationsListView: View {
    let pet: Pet
    @Environment(\.modelContext) private var modelContext
    @State private var showingAdd = false

    var body: some View {
        VStack(spacing: 0) {
            if pet.medications.isEmpty {
                EmptyStateView(
                    icon: "pill.fill",
                    title: "No Medications",
                    message: "Track your pet's medications and never miss a dose.",
                    buttonTitle: "Add Medication",
                    action: { showingAdd = true }
                )
            } else {
                LazyVStack(spacing: 16) {
                    let active = pet.medications.filter { $0.isActive }
                    let inactive = pet.medications.filter { !$0.isActive }

                    if !active.isEmpty {
                        Section {
                            ForEach(active) { med in
                                MedicationRow(medication: med)
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            modelContext.delete(med)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        } header: {
                            Text("Active")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    if !inactive.isEmpty {
                        Section {
                            ForEach(inactive) { med in
                                MedicationRow(medication: med)
                                    .opacity(0.6)
                            }
                        } header: {
                            Text("Inactive")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
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
            AddMedicationView(pet: pet)
        }
    }
}

struct MedicationRow: View {
    let medication: Medication

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(medication.statusColor)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text("\(medication.dosage) • \(medication.frequency.displayName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if medication.isActive {
                    Text("Next: \(medication.timeOfDayFormatted)")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }

            Spacer()

            if medication.needsRefill {
                Label("Refill", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .cardStyle()
    }
}

// MARK: - Weight Tracking
struct WeightTrackingView: View {
    let pet: Pet
    @Environment(\.modelContext) private var modelContext
    @State private var showingAdd = false

    var body: some View {
        VStack(spacing: 16) {
            if !pet.weightEntries.isEmpty {
                // Chart
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Weight History")
                            .font(.headline)
                        Spacer()
                        if let latest = pet.latestWeight {
                            Text(latest.weightFormatted)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Theme.primaryColor)
                        }
                    }

                    let sorted = pet.weightEntries.sorted { $0.date < $1.date }
                    Chart(sorted) { entry in
                        LineMark(
                            x: .value("Date", entry.date),
                            y: .value("Weight", entry.weight)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Theme.primaryColor)

                        AreaMark(
                            x: .value("Date", entry.date),
                            y: .value("Weight", entry.weight)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Theme.primaryColor.opacity(0.1).gradient)

                        PointMark(
                            x: .value("Date", entry.date),
                            y: .value("Weight", entry.weight)
                        )
                        .foregroundStyle(Theme.primaryColor)
                        .symbolSize(40)
                    }
                    .frame(height: 220)
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                }
                .cardStyle()

                // History
                LazyVStack(spacing: 8) {
                    ForEach(pet.weightEntries.sorted { $0.date > $1.date }) { entry in
                        HStack {
                            Text(entry.date.shortDate)
                                .font(.subheadline)
                            Spacer()
                            Text(entry.weightFormatted)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            if !entry.notes.isEmpty {
                                Image(systemName: "note.text")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                modelContext.delete(entry)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .cardStyle()
            } else {
                EmptyStateView(
                    icon: "scalemass.fill",
                    title: "No Weight Data",
                    message: "Start tracking your pet's weight to see trends over time.",
                    buttonTitle: "Log Weight",
                    action: { showingAdd = true }
                )
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
            AddWeightEntryView(pet: pet)
        }
    }
}

#Preview {
    HealthTabView()
        .modelContainer(for: [Pet.self, VetVisit.self, Vaccination.self, Medication.self, WeightEntry.self], inMemory: true)
}
