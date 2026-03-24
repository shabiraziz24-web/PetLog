import SwiftUI
import SwiftData

struct MoreTabView: View {
    @Query(sort: \Pet.name) private var pets: [Pet]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        JournalListView()
                    } label: {
                        Label("Journal", systemImage: "book.fill")
                            .foregroundStyle(.indigo)
                    }

                    NavigationLink {
                        ExpensesView()
                    } label: {
                        Label("Expenses", systemImage: "dollarsign.circle.fill")
                            .foregroundStyle(.pink)
                    }

                    if let pet = pets.first {
                        NavigationLink {
                            PetProfileView(pet: pet)
                        } label: {
                            Label("Pet Profile", systemImage: "pawprint.fill")
                                .foregroundStyle(Theme.primaryColor)
                        }
                    }
                }

                Section {
                    NavigationLink {
                        RemindersListView()
                    } label: {
                        Label("Reminders", systemImage: "bell.fill")
                            .foregroundStyle(.yellow)
                    }

                    NavigationLink {
                        EmergencyView()
                    } label: {
                        Label("Emergency Info", systemImage: "staroflife.fill")
                            .foregroundStyle(.red)
                    }

                    NavigationLink {
                        FamilySharingView()
                    } label: {
                        Label("Family Sharing", systemImage: "person.2.fill")
                            .foregroundStyle(.blue)
                    }
                }

                Section {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Label("Settings", systemImage: "gearshape.fill")
                            .foregroundStyle(.gray)
                    }

                    NavigationLink {
                        PaywallView()
                    } label: {
                        Label {
                            Text("PetLog Premium")
                        } icon: {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.yellow)
                        }
                    }
                }
            }
            .navigationTitle("More")
        }
    }
}

#Preview {
    MoreTabView()
        .modelContainer(for: Pet.self, inMemory: true)
}
