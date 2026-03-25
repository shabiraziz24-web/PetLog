import SwiftUI
import SwiftData

struct PhotoDetailView: View {
    @Bindable var photo: PetPhoto
    var pet: Pet
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    @State private var isEditingCaption = false
    @State private var editCaption: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Full-size photo
                if let uiImage = UIImage(data: photo.imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
                        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                }

                // Info section
                VStack(alignment: .leading, spacing: 16) {
                    // Date & Favorite
                    HStack {
                        Label(photo.dateFormatted, systemImage: "calendar")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Button {
                            photo.isFavorite.toggle()
                            try? modelContext.save()
                            HapticManager.impact(.light)
                        } label: {
                            Image(systemName: photo.isFavorite ? "heart.fill" : "heart")
                                .font(.title3)
                                .foregroundStyle(photo.isFavorite ? .red : .secondary)
                                .contentTransition(.symbolEffect(.replace))
                        }
                    }

                    // Caption
                    if isEditingCaption {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Caption")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            TextField("Add a caption...", text: $editCaption, axis: .vertical)
                                .lineLimit(3...6)
                                .padding(12)
                                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: Theme.smallCornerRadius))

                            HStack {
                                Button("Cancel") {
                                    isEditingCaption = false
                                }
                                .foregroundStyle(.secondary)

                                Spacer()

                                Button("Save") {
                                    photo.caption = editCaption
                                    try? modelContext.save()
                                    isEditingCaption = false
                                    HapticManager.notification(.success)
                                }
                                .fontWeight(.medium)
                                .foregroundStyle(Theme.primaryColor)
                            }
                            .font(.subheadline)
                        }
                    } else {
                        Button {
                            editCaption = photo.caption
                            isEditingCaption = true
                        } label: {
                            HStack {
                                if photo.caption.isEmpty {
                                    Text("Add a caption...")
                                        .font(.body)
                                        .foregroundStyle(.tertiary)
                                } else {
                                    Text(photo.caption)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                        .multilineTextAlignment(.leading)
                                }
                                Spacer()
                                Image(systemName: "pencil")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .cardStyle()

                // Delete button
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("Delete Photo")
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, Theme.horizontalPadding)
            .padding(.bottom, 32)
        }
        .background(Theme.backgroundWarm.ignoresSafeArea())
        .navigationTitle(pet.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .alert("Delete Photo", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                modelContext.delete(photo)
                try? modelContext.save()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this photo? This action cannot be undone.")
        }
    }
}

#Preview {
    NavigationStack {
        PhotoDetailView(
            photo: PetPhoto(caption: "Playing in the park"),
            pet: Pet(name: "Buddy", species: .dog, breed: "Golden Retriever")
        )
    }
    .modelContainer(for: [Pet.self, PetPhoto.self], inMemory: true)
}
