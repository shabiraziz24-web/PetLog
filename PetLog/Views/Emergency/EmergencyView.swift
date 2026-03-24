import SwiftUI
import SwiftData

struct EmergencyView: View {
    @Query(sort: \Pet.name) private var pets: [Pet]

    var body: some View {
        Group {
            if let pet = pets.first {
                EmergencyCardView(pet: pet)
            } else {
                EmptyStateView(
                    icon: "staroflife",
                    title: "No Pets Yet",
                    message: "Add a pet first to generate an emergency card."
                )
            }
        }
        .navigationTitle("Emergency Info")
    }
}

#Preview {
    NavigationStack {
        EmergencyView()
    }
    .modelContainer(for: Pet.self, inMemory: true)
}
