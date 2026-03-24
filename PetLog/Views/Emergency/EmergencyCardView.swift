import SwiftUI

struct EmergencyCardView: View {
    let pet: Pet
    @Environment(\.dismiss) private var dismiss
    @State private var renderedImage: UIImage?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                emergencyCard
                    .padding(.horizontal, Theme.horizontalPadding)
                    .padding(.top, 16)

                // Action Buttons
                HStack(spacing: 16) {
                    ShareLink(item: emergencyShareText) {
                        Label("Share Text", systemImage: "square.and.arrow.up")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.primaryColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Theme.primaryColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                    }

                    if let image = renderedImage {
                        ShareLink(item: Image(uiImage: image), preview: SharePreview("Emergency Card", image: Image(uiImage: image))) {
                            Label("Share Card", systemImage: "photo")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Theme.primaryColor.gradient, in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(.horizontal, Theme.horizontalPadding)
                .padding(.top, 24)

                // Disclaimer
                Text("Keep this card handy for pet sitters, boarding facilities, or emergencies.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 16)
            }
            .padding(.bottom, 32)
        }
        .background(Theme.backgroundWarm.ignoresSafeArea())
        .navigationTitle("Emergency Card")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
        }
        .onAppear { renderCard() }
    }

    // MARK: - Emergency Card

    private var emergencyCard: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "staroflife.fill")
                    .font(.title3)
                Text("EMERGENCY INFO")
                    .font(.headline.weight(.heavy))
                Image(systemName: "staroflife.fill")
                    .font(.title3)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.red.gradient)

            // Pet Info
            VStack(spacing: 16) {
                // Pet Identity
                HStack(spacing: 16) {
                    PetAvatarView(pet: pet, size: 64)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(pet.name)
                            .font(.title2.bold())

                        Text("\(pet.species.displayName) · \(pet.breed)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if pet.birthDate != nil {
                            Text("Age: \(pet.age)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()
                }
                .padding(.top, 4)

                Divider()

                // Details Grid
                VStack(spacing: 12) {
                    if !pet.microchipNumber.isEmpty {
                        EmergencyInfoRow(
                            icon: "cpu",
                            label: "Microchip",
                            value: pet.microchipNumber,
                            color: .blue
                        )
                    }

                    if !pet.color.isEmpty {
                        EmergencyInfoRow(
                            icon: "paintpalette.fill",
                            label: "Color",
                            value: pet.color,
                            color: .purple
                        )
                    }

                    EmergencyInfoRow(
                        icon: "scissors",
                        label: "Spayed/Neutered",
                        value: pet.isNeutered ? "Yes" : "No",
                        color: .green
                    )

                    if !pet.bloodType.isEmpty {
                        EmergencyInfoRow(
                            icon: "drop.fill",
                            label: "Blood Type",
                            value: pet.bloodType,
                            color: .red
                        )
                    }

                    if let weight = pet.latestWeight {
                        EmergencyInfoRow(
                            icon: "scalemass.fill",
                            label: "Weight",
                            value: weight.weightFormatted,
                            color: .orange
                        )
                    }
                }

                // Allergies
                if !pet.allergies.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Allergies", systemImage: "exclamationmark.triangle.fill")
                            .font(.subheadline.bold())
                            .foregroundStyle(.red)

                        FlowLayout(spacing: 6) {
                            ForEach(pet.allergies, id: \.self) { allergy in
                                Text(allergy)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.red)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(.red.opacity(0.1), in: Capsule())
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(.red.opacity(0.04), in: RoundedRectangle(cornerRadius: 10))
                }

                // Active Medications
                if !pet.activeMedications.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Current Medications", systemImage: "pills.fill")
                            .font(.subheadline.bold())
                            .foregroundStyle(.purple)

                        ForEach(pet.activeMedications) { med in
                            HStack {
                                Text(med.name)
                                    .font(.subheadline.weight(.medium))
                                Spacer()
                                Text(med.dosage)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("· \(med.frequency.displayName)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(.purple.opacity(0.04), in: RoundedRectangle(cornerRadius: 10))
                }

                // Vet Contact
                if let lastVisit = pet.vetVisits.sorted(by: { $0.date > $1.date }).first,
                   !lastVisit.clinicName.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Veterinarian", systemImage: "cross.case.fill")
                            .font(.subheadline.bold())
                            .foregroundStyle(Theme.secondaryColor)

                        if !lastVisit.vetName.isEmpty {
                            Text("Dr. \(lastVisit.vetName)")
                                .font(.subheadline)
                        }
                        Text(lastVisit.clinicName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        if !lastVisit.clinicPhone.isEmpty {
                            HStack {
                                Image(systemName: "phone.fill")
                                    .font(.caption)
                                Text(lastVisit.clinicPhone)
                                    .font(.subheadline)
                            }
                            .foregroundStyle(.blue)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Theme.secondaryColor.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(16)

            // Footer
            HStack {
                Image(systemName: "pawprint.fill")
                    .font(.caption)
                Text("Generated by PetLog")
                    .font(.caption2.weight(.medium))
            }
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }

    // MARK: - Helpers

    private var emergencyShareText: String {
        var lines: [String] = []
        lines.append("🚨 EMERGENCY INFO — \(pet.name)")
        lines.append("Species: \(pet.species.displayName)")
        lines.append("Breed: \(pet.breed)")
        if pet.birthDate != nil { lines.append("Age: \(pet.age)") }
        if !pet.color.isEmpty { lines.append("Color: \(pet.color)") }
        if !pet.microchipNumber.isEmpty { lines.append("Microchip: \(pet.microchipNumber)") }
        lines.append("Spayed/Neutered: \(pet.isNeutered ? "Yes" : "No")")
        if !pet.bloodType.isEmpty { lines.append("Blood Type: \(pet.bloodType)") }
        if let w = pet.latestWeight { lines.append("Weight: \(w.weightFormatted)") }
        if !pet.allergies.isEmpty { lines.append("⚠️ Allergies: \(pet.allergies.joined(separator: ", "))") }
        if !pet.activeMedications.isEmpty {
            lines.append("💊 Medications: \(pet.activeMedications.map { "\($0.name) \($0.dosage)" }.joined(separator: ", "))")
        }
        if let visit = pet.vetVisits.sorted(by: { $0.date > $1.date }).first, !visit.clinicName.isEmpty {
            lines.append("🏥 Vet: \(visit.clinicName) \(visit.clinicPhone)")
        }
        return lines.joined(separator: "\n")
    }

    @MainActor
    private func renderCard() {
        let renderer = ImageRenderer(content: emergencyCard.frame(width: 360))
        renderer.scale = 3.0
        renderedImage = renderer.uiImage
    }
}

// MARK: - Supporting Views

private struct EmergencyInfoRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
                .frame(width: 24)

            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline.weight(.medium))
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                          proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
    }
}

#Preview {
    NavigationStack {
        EmergencyCardView(pet: Pet(
            name: "Buddy",
            species: .dog,
            breed: "Golden Retriever",
            color: "Golden",
            microchipNumber: "985121033612345",
            isNeutered: true,
            bloodType: "DEA 1.1+",
            allergies: ["Chicken", "Corn", "Pollen"]
        ))
    }
}
