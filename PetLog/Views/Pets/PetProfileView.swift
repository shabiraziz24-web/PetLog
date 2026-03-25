import SwiftUI
import SwiftData
import PhotosUI

struct PetProfileView: View {
    @Bindable var pet: Pet
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    @State private var showingEmergencyCard = false
    @State private var showingDeleteAlert = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    // Edit state
    @State private var editName: String = ""
    @State private var editBreed: String = ""
    @State private var editGender: PetGender = .unknown
    @State private var editBirthDate: Date = Date()
    @State private var editHasBirthDate: Bool = false
    @State private var editColor: String = ""
    @State private var editWeight: String = ""
    @State private var editMicrochipNumber: String = ""
    @State private var editIsNeutered: Bool = false
    @State private var editBloodType: String = ""
    @State private var editAllergies: String = ""
    @State private var editNotes: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                profileHeader

                // Info Cards
                if isEditing {
                    editForm
                } else {
                    infoCards
                }
            }
            .padding(.horizontal, Theme.horizontalPadding)
            .padding(.bottom, 32)
        }
        .background(Theme.backgroundWarm.ignoresSafeArea())
        .navigationTitle(pet.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(isEditing ? "Done" : "Edit") {
                    if isEditing {
                        saveEdits()
                    } else {
                        startEditing()
                    }
                    isEditing.toggle()
                }
                .fontWeight(.medium)
            }
        }
        .sheet(isPresented: $showingEmergencyCard) {
            NavigationStack {
                EmergencyCardView(pet: pet)
            }
        }
        .alert("Delete Pet", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                modelContext.delete(pet)
                try? modelContext.save()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \(pet.name)? This will remove all associated health records, activities, and data. This action cannot be undone.")
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                PetAvatarView(pet: pet, size: 100)

                if isEditing {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 32, height: 32)
                            .overlay {
                                Image(systemName: "camera.fill")
                                    .font(.caption)
                                    .foregroundStyle(Theme.primaryColor)
                            }
                    }
                    .onChange(of: selectedPhotoItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                pet.photo = data
                            }
                        }
                    }
                }
            }

            VStack(spacing: 4) {
                Text(pet.name)
                    .font(.title2.bold())

                Text("\(pet.species.displayName) · \(pet.breed)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if pet.birthDate != nil {
                    Text(pet.age)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !isEditing {
                HStack(spacing: 12) {
                    Button {
                        showingEmergencyCard = true
                    } label: {
                        Label("Emergency Card", systemImage: "staroflife.fill")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.red.gradient, in: Capsule())
                    }

                    ShareLink(item: emergencyShareText) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Theme.primaryColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Theme.primaryColor.opacity(0.1), in: Capsule())
                    }
                }
            }
        }
        .padding(.top, 16)
    }

    // MARK: - Info Cards

    private var infoCards: some View {
        VStack(spacing: 16) {
            // Basic Info
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Basic Info", icon: "info.circle.fill")

                InfoRow(label: "Species", value: pet.species.displayName)
                InfoRow(label: "Breed", value: pet.breed)
                InfoRow(label: "Gender", value: pet.gender.displayName)
                if let birthDate = pet.birthDate {
                    InfoRow(label: "Birth Date", value: birthDate.shortDate)
                }
                if let adoptionDate = pet.adoptionDate {
                    InfoRow(label: "Adoption Date", value: adoptionDate.shortDate)
                }
                if !pet.color.isEmpty {
                    InfoRow(label: "Color", value: pet.color)
                }
                InfoRow(label: "Spayed/Neutered", value: pet.isNeutered ? "Yes" : "No")
            }
            .cardStyle()

            // Health Info
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Health Info", icon: "heart.fill")

                if let latest = pet.latestWeight {
                    InfoRow(label: "Weight", value: latest.weightFormatted)
                }
                if !pet.bloodType.isEmpty {
                    InfoRow(label: "Blood Type", value: pet.bloodType)
                }
                if !pet.allergies.isEmpty {
                    InfoRow(label: "Allergies", value: pet.allergies.joined(separator: ", "))
                }
                if !pet.microchipNumber.isEmpty {
                    InfoRow(label: "Microchip", value: pet.microchipNumber)
                }

                // Quick stats
                HStack(spacing: 12) {
                    MiniStatView(
                        title: "Vet Visits",
                        value: "\(pet.vetVisits.count)",
                        color: .blue
                    )
                    MiniStatView(
                        title: "Vaccinations",
                        value: "\(pet.vaccinations.count)",
                        color: .green
                    )
                    MiniStatView(
                        title: "Medications",
                        value: "\(pet.activeMedications.count)",
                        color: .purple
                    )
                }
            }
            .cardStyle()

            // Photos
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    SectionHeader(title: "Photos", icon: "photo.fill")
                    Spacer()
                    if !pet.photos.isEmpty {
                        NavigationLink {
                            PhotoGalleryView(pet: pet)
                        } label: {
                            Text("See All")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(Theme.primaryColor)
                        }
                    }
                }

                if pet.recentPhotos.isEmpty {
                    NavigationLink {
                        PhotoGalleryView(pet: pet)
                    } label: {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.title2)
                                    .foregroundStyle(Theme.primaryColor.opacity(0.5))
                                Text("Add photos of \(pet.name)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 16)
                            Spacer()
                        }
                    }
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(pet.recentPhotos) { photo in
                                if let uiImage = UIImage(data: photo.imageData) {
                                    NavigationLink {
                                        PhotoGalleryView(pet: pet)
                                    } label: {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: Theme.smallCornerRadius))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .cardStyle()

            // Notes
            if !pet.notes.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Notes", icon: "note.text")
                    Text(pet.notes)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .cardStyle()
            }

            // Delete
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Delete \(pet.name)")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Edit Form

    private var editForm: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Basic Info", icon: "info.circle.fill")

                EditField(label: "Name", text: $editName)
                EditField(label: "Breed", text: $editBreed)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Gender")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Picker("Gender", selection: $editGender) {
                        ForEach(PetGender.allCases) { gender in
                            Text(gender.displayName).tag(gender)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Toggle(isOn: $editHasBirthDate) {
                    Text("Birth Date")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .tint(Theme.primaryColor)

                if editHasBirthDate {
                    DatePicker("", selection: $editBirthDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                }

                EditField(label: "Color / Markings", text: $editColor)

                Toggle(isOn: $editIsNeutered) {
                    Text("Spayed / Neutered")
                        .font(.subheadline)
                }
                .tint(Theme.primaryColor)
            }
            .cardStyle()

            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Health Info", icon: "heart.fill")

                EditField(label: "Weight", text: $editWeight, keyboard: .decimalPad)
                EditField(label: "Blood Type", text: $editBloodType)
                EditField(label: "Microchip Number", text: $editMicrochipNumber)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Allergies (comma separated)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("e.g., Chicken, Pollen", text: $editAllergies)
                        .padding(12)
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
                }
            }
            .cardStyle()

            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Notes", icon: "note.text")

                TextEditor(text: $editNotes)
                    .frame(minHeight: 80)
                    .padding(8)
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
            }
            .cardStyle()
        }
    }

    // MARK: - Helpers

    private func startEditing() {
        editName = pet.name
        editBreed = pet.breed
        editGender = pet.gender
        editBirthDate = pet.birthDate ?? Date()
        editHasBirthDate = pet.birthDate != nil
        editColor = pet.color
        editWeight = pet.latestWeight.map { String(format: "%.1f", $0.weight) } ?? ""
        editMicrochipNumber = pet.microchipNumber
        editIsNeutered = pet.isNeutered
        editBloodType = pet.bloodType
        editAllergies = pet.allergies.joined(separator: ", ")
        editNotes = pet.notes
    }

    private func saveEdits() {
        pet.name = editName
        pet.breed = editBreed
        pet.gender = editGender
        pet.birthDate = editHasBirthDate ? editBirthDate : nil
        pet.color = editColor
        pet.microchipNumber = editMicrochipNumber
        pet.isNeutered = editIsNeutered
        pet.bloodType = editBloodType
        pet.allergies = editAllergies.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        pet.notes = editNotes
        pet.updatedAt = Date()
        try? modelContext.save()
        HapticManager.notification(.success)
    }

    private var emergencyShareText: String {
        var text = "🐾 Emergency Info for \(pet.name)\n"
        text += "Species: \(pet.species.displayName)\n"
        text += "Breed: \(pet.breed)\n"
        if !pet.microchipNumber.isEmpty {
            text += "Microchip: \(pet.microchipNumber)\n"
        }
        if !pet.allergies.isEmpty {
            text += "Allergies: \(pet.allergies.joined(separator: ", "))\n"
        }
        if !pet.activeMedications.isEmpty {
            text += "Medications: \(pet.activeMedications.map(\.name).joined(separator: ", "))\n"
        }
        return text
    }
}

// MARK: - Supporting Views

private struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        Label(title, systemImage: icon)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.primaryColor)
    }
}

private struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
        }
    }
}

private struct MiniStatView: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(color)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
    }
}

private struct EditField: View {
    let label: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField(label, text: $text)
                .keyboardType(keyboard)
                .padding(12)
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    NavigationStack {
        PetProfileView(pet: Pet(name: "Buddy", species: .dog, breed: "Golden Retriever", color: "Golden", microchipNumber: "123456789", allergies: ["Chicken"]))
    }
    .modelContainer(for: [Pet.self, PetPhoto.self], inMemory: true)
}
