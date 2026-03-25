import SwiftUI
import SwiftData
import PhotosUI

struct PhotoGalleryView: View {
    @Bindable var pet: Pet
    @Environment(\.modelContext) private var modelContext
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPhoto: PetPhoto?
    @State private var isLoadingPhoto = false

    private let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]

    private var sortedPhotos: [PetPhoto] {
        pet.photos.sorted { $0.date > $1.date }
    }

    var body: some View {
        ScrollView {
            if sortedPhotos.isEmpty {
                emptyState
            } else {
                photoGrid
            }
        }
        .background(Theme.backgroundWarm.ignoresSafeArea())
        .navigationTitle("Photos")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.primaryColor)
                }
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            isLoadingPhoto = true
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    let photo = PetPhoto(imageData: data, pet: pet)
                    modelContext.insert(photo)
                    pet.photos.append(photo)
                    try? modelContext.save()
                    HapticManager.notification(.success)
                }
                isLoadingPhoto = false
                selectedPhotoItem = nil
            }
        }
        .sheet(item: $selectedPhoto) { photo in
            NavigationStack {
                PhotoDetailView(photo: photo, pet: pet)
            }
        }
        .overlay {
            if isLoadingPhoto {
                ProgressView("Adding photo...")
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 60)

            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 56))
                .foregroundStyle(Theme.primaryColor.opacity(0.5))

            Text("No Photos Yet")
                .font(.title3.bold())

            Text("Add photos of \(pet.name) to build a gallery of memories.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Label("Add First Photo", systemImage: "plus.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Theme.primaryColor.gradient, in: Capsule())
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Photo Grid

    private var photoGrid: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(sortedPhotos) { photo in
                photoThumbnail(photo)
            }
        }
        .padding(4)
    }

    private func photoThumbnail(_ photo: PetPhoto) -> some View {
        Button {
            selectedPhoto = photo
        } label: {
            ZStack(alignment: .topTrailing) {
                if let uiImage = UIImage(data: photo.imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fill)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .aspectRatio(1, contentMode: .fill)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.secondary)
                        }
                }

                if photo.isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.caption2)
                        .foregroundStyle(.white)
                        .padding(4)
                        .background(.red.opacity(0.8), in: Circle())
                        .padding(6)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PhotoGalleryView(pet: Pet(name: "Buddy", species: .dog, breed: "Golden Retriever"))
    }
    .modelContainer(for: [Pet.self, PetPhoto.self], inMemory: true)
}
