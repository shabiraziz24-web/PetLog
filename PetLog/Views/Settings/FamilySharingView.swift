import SwiftUI

struct FamilySharingView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "person.2.fill")
                .font(.system(size: 56))
                .foregroundStyle(Theme.primaryColor.gradient)

            VStack(spacing: 8) {
                Text("Family Sharing")
                    .font(.title2.bold())

                Text("Share your pet's profile with family members so everyone stays in the loop.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Text("Coming Soon")
                .font(.caption.weight(.medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Theme.primaryColor.gradient, in: Capsule())

            Spacer()
        }
        .navigationTitle("Family Sharing")
    }
}

#Preview {
    NavigationStack {
        FamilySharingView()
    }
}
