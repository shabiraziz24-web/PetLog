import SwiftUI
import SwiftData

struct JournalListView: View {
    @Query(sort: \Pet.name) private var pets: [Pet]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAdd = false
    @State private var filterMood: PetMood?
    @State private var showMilestonesOnly = false

    private var allEntries: [JournalEntry] {
        var entries = pets.flatMap { $0.journalEntries }
        if let mood = filterMood {
            entries = entries.filter { $0.mood == mood }
        }
        if showMilestonesOnly {
            entries = entries.filter { $0.isMilestone }
        }
        return entries.sorted { $0.date > $1.date }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(title: "All", isSelected: filterMood == nil && !showMilestonesOnly) {
                            filterMood = nil
                            showMilestonesOnly = false
                        }
                        FilterChip(title: "⭐ Milestones", isSelected: showMilestonesOnly) {
                            showMilestonesOnly.toggle()
                            filterMood = nil
                        }
                        ForEach(PetMood.allCases) { mood in
                            FilterChip(title: "\(mood.emoji) \(mood.displayName)", isSelected: filterMood == mood) {
                                filterMood = filterMood == mood ? nil : mood
                                showMilestonesOnly = false
                            }
                        }
                    }
                }

                if allEntries.isEmpty {
                    EmptyStateView(
                        icon: "book.fill",
                        title: "No Journal Entries",
                        message: "Capture memories, milestones, and daily moments.",
                        buttonTitle: "New Entry",
                        action: { showingAdd = true }
                    )
                } else {
                    ForEach(allEntries) { entry in
                        JournalEntryCard(entry: entry)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    modelContext.delete(entry)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Journal")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAdd = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            if let pet = pets.first {
                AddJournalEntryView(pet: pet)
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.selection()
            action()
        }) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Theme.primaryColor : Color(.systemGray5), in: Capsule())
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

struct JournalEntryCard: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.mood.emoji)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(entry.date.shortDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if entry.isMilestone {
                    HStack(spacing: 4) {
                        Image(systemName: entry.milestoneType.icon)
                        Text(entry.milestoneType.displayName)
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.yellow)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.yellow.opacity(0.15), in: Capsule())
                }
            }

            if !entry.text.isEmpty {
                Text(entry.text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            if !entry.photosData.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(entry.photosData.indices, id: \.self) { index in
                            if let uiImage = UIImage(data: entry.photosData[index]) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
            }
        }
        .cardStyle()
    }
}

#Preview {
    NavigationStack {
        JournalListView()
    }
    .modelContainer(for: [Pet.self, JournalEntry.self], inMemory: true)
}
