import SwiftUI
import SwiftData

struct QuickAddSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var pets: [Pet]

    @State private var selectedOption: QuickAddOption?

    enum QuickAddOption: String, CaseIterable, Identifiable {
        case vetVisit, vaccination, medication, weight, feeding, activity, expense, journal, reminder
        var id: String { rawValue }

        var title: String {
            switch self {
            case .vetVisit: return "Vet Visit"
            case .vaccination: return "Vaccination"
            case .medication: return "Medication"
            case .weight: return "Weight"
            case .feeding: return "Feeding"
            case .activity: return "Activity"
            case .expense: return "Expense"
            case .journal: return "Journal"
            case .reminder: return "Reminder"
            }
        }

        var icon: String {
            switch self {
            case .vetVisit: return "cross.case.fill"
            case .vaccination: return "syringe.fill"
            case .medication: return "pill.fill"
            case .weight: return "scalemass.fill"
            case .feeding: return "fork.knife"
            case .activity: return "figure.walk"
            case .expense: return "dollarsign.circle.fill"
            case .journal: return "book.fill"
            case .reminder: return "bell.fill"
            }
        }

        var color: Color {
            switch self {
            case .vetVisit: return .red
            case .vaccination: return .green
            case .medication: return .blue
            case .weight: return .orange
            case .feeding: return .purple
            case .activity: return .teal
            case .expense: return .pink
            case .journal: return .indigo
            case .reminder: return .yellow
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if pets.isEmpty {
                    EmptyStateView(
                        icon: "pawprint.fill",
                        title: "No Pets Yet",
                        message: "Add a pet first before logging data."
                    )
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(QuickAddOption.allCases) { option in
                            Button {
                                HapticManager.impact(.light)
                                selectedOption = option
                            } label: {
                                VStack(spacing: 10) {
                                    Image(systemName: option.icon)
                                        .font(.title2)
                                        .foregroundStyle(option.color)
                                        .frame(width: 56, height: 56)
                                        .background(option.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))

                                    Text(option.title)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle("Quick Add")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(item: $selectedOption) { option in
                quickAddDestination(for: option)
            }
        }
    }

    @ViewBuilder
    private func quickAddDestination(for option: QuickAddOption) -> some View {
        if let pet = pets.first {
            switch option {
            case .vetVisit: AddVetVisitView(pet: pet)
            case .vaccination: AddVaccinationView(pet: pet)
            case .medication: AddMedicationView(pet: pet)
            case .weight: AddWeightEntryView(pet: pet)
            case .feeding: AddFeedingLogView(pet: pet)
            case .activity: AddActivityView(pet: pet)
            case .expense: AddExpenseView(pet: pet)
            case .journal: AddJournalEntryView(pet: pet)
            case .reminder: AddReminderView(pet: pet)
            }
        }
    }
}

#Preview {
    QuickAddSheet()
        .modelContainer(for: Pet.self, inMemory: true)
}
