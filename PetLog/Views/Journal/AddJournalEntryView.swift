import SwiftUI
import SwiftData
import PhotosUI

struct AddJournalEntryView: View {
    let pet: Pet
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()
    @State private var title = ""
    @State private var text = ""
    @State private var mood: PetMood = .happy
    @State private var milestoneType: MilestoneType = .none
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var photosData: [Data] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Entry") {
                    TextField("Title", text: $title)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Write about your pet's day...", text: $text, axis: .vertical)
                        .lineLimit(4...10)
                }

                Section("Mood") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(PetMood.allCases) { m in
                            VStack(spacing: 4) {
                                Text(m.emoji)
                                    .font(.title)
                                    .padding(8)
                                    .background(
                                        mood == m ? m.color.opacity(0.2) : Color.clear,
                                        in: Circle()
                                    )
                                Text(m.displayName)
                                    .font(.caption2)
                            }
                            .onTapGesture {
                                mood = m
                                HapticManager.selection()
                            }
                        }
                    }
                }

                Section("Milestone") {
                    Picker("Milestone Type", selection: $milestoneType) {
                        ForEach(MilestoneType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }

                Section("Photos") {
                    PhotosPicker(
                        selection: $selectedPhotos,
                        maxSelectionCount: 10,
                        matching: .images
                    ) {
                        Label("Add Photos", systemImage: "photo.on.rectangle.angled")
                    }
                    .onChange(of: selectedPhotos) {
                        Task { await loadPhotos() }
                    }

                    if !photosData.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(photosData.indices, id: \.self) { index in
                                    if let uiImage = UIImage(data: photosData[index]) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Journal Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(title.isEmpty)
                }
            }
        }
    }

    @MainActor
    private func loadPhotos() async {
        photosData = []
        for item in selectedPhotos {
            if let data = try? await item.loadTransferable(type: Data.self) {
                photosData.append(data)
            }
        }
    }

    private func save() {
        let entry = JournalEntry(
            date: date,
            title: title,
            text: text,
            photosData: photosData,
            mood: mood,
            milestoneType: milestoneType,
            pet: pet
        )
        modelContext.insert(entry)
        HapticManager.notification(.success)
        dismiss()
    }
}
