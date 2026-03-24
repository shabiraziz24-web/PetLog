import SwiftUI
import SwiftData
import PhotosUI

struct PetSetupView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = PetSetupViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundWarm.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Progress Bar
                    ProgressView(value: viewModel.progress)
                        .tint(Theme.primaryColor)
                        .padding(.horizontal, Theme.horizontalPadding)
                        .padding(.top, 8)

                    // Step Content
                    TabView(selection: $viewModel.currentStep) {
                        SpeciesStepView(viewModel: viewModel)
                            .tag(PetSetupStep.species)

                        BreedStepView(viewModel: viewModel)
                            .tag(PetSetupStep.breed)

                        NamePhotoStepView(viewModel: viewModel)
                            .tag(PetSetupStep.namePhoto)

                        DetailsStepView(viewModel: viewModel)
                            .tag(PetSetupStep.details)

                        CompleteStepView(viewModel: viewModel)
                            .tag(PetSetupStep.complete)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.spring(response: 0.3), value: viewModel.currentStep)

                    // Navigation Buttons
                    if viewModel.currentStep != .complete {
                        HStack(spacing: 12) {
                            if viewModel.currentStep != .species {
                                Button {
                                    viewModel.previousStep()
                                } label: {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("Back")
                                    }
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.secondary)
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 20)
                                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                                }
                            }

                            Spacer()

                            Button {
                                viewModel.nextStep()
                            } label: {
                                HStack {
                                    Text("Next")
                                    Image(systemName: "chevron.right")
                                }
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.vertical, 14)
                                .padding(.horizontal, 32)
                                .background(
                                    Theme.primaryColor.gradient.opacity(viewModel.canProceed ? 1 : 0.5),
                                    in: RoundedRectangle(cornerRadius: 12)
                                )
                            }
                            .disabled(!viewModel.canProceed)
                        }
                        .padding(.horizontal, Theme.horizontalPadding)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle(viewModel.currentStep.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func savePet() {
        let pet = viewModel.createPet()
        modelContext.insert(pet)
        try? modelContext.save()
        HapticManager.notification(.success)
        dismiss()
    }
}

// MARK: - Species Step

private struct SpeciesStepView: View {
    @Bindable var viewModel: PetSetupViewModel

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Choose your pet type")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.top, 24)

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Species.allCases) { species in
                        SpeciesCard(
                            species: species,
                            isSelected: viewModel.selectedSpecies == species
                        )
                        .onTapGesture {
                            viewModel.selectedSpecies = species
                            viewModel.selectedBreed = ""
                            viewModel.breedSearchText = ""
                            HapticManager.selection()
                        }
                    }
                }
                .padding(.horizontal, Theme.horizontalPadding)
            }
        }
    }
}

private struct SpeciesCard: View {
    let species: Species
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: species.icon)
                .font(.system(size: 36))
                .foregroundStyle(isSelected ? .white : species.accentColor)

            Text(species.displayName)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .fill(isSelected ? species.accentColor.gradient : Color(.systemGray6).gradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .stroke(isSelected ? species.accentColor : .clear, lineWidth: 2)
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Breed Step

private struct BreedStepView: View {
    @Bindable var viewModel: PetSetupViewModel

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search breeds...", text: $viewModel.breedSearchText)
            }
            .padding(12)
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, Theme.horizontalPadding)
            .padding(.top, 16)

            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(viewModel.filteredBreeds, id: \.self) { breed in
                        Button {
                            viewModel.selectedBreed = breed
                            HapticManager.selection()
                        } label: {
                            HStack {
                                Text(breed)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if viewModel.selectedBreed == breed {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Theme.primaryColor)
                                }
                            }
                            .padding(.horizontal, Theme.horizontalPadding)
                            .padding(.vertical, 14)
                            .background(
                                viewModel.selectedBreed == breed
                                    ? Theme.primaryColor.opacity(0.08)
                                    : Color.clear,
                                in: RoundedRectangle(cornerRadius: 10)
                            )
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

// MARK: - Name & Photo Step

private struct NamePhotoStepView: View {
    @Bindable var viewModel: PetSetupViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Spacer().frame(height: 16)

                // Photo Picker
                PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images) {
                    ZStack {
                        if let data = viewModel.photoData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(viewModel.selectedSpecies.accentColor.gradient)
                                .frame(width: 120, height: 120)
                                .overlay {
                                    VStack(spacing: 4) {
                                        Image(systemName: "camera.fill")
                                            .font(.title2)
                                        Text("Add Photo")
                                            .font(.caption)
                                    }
                                    .foregroundStyle(.white)
                                }
                        }

                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 32, height: 32)
                            .overlay {
                                Image(systemName: "pencil")
                                    .font(.caption.bold())
                            }
                            .offset(x: 42, y: 42)
                    }
                }
                .onChange(of: viewModel.selectedPhotoItem) { _, _ in
                    Task { await viewModel.loadPhoto() }
                }

                // Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pet Name")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)

                    TextField("What's your pet's name?", text: $viewModel.name)
                        .font(.title3)
                        .padding(14)
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, Theme.horizontalPadding)
            }
        }
    }
}

// MARK: - Details Step

private struct DetailsStepView: View {
    @Bindable var viewModel: PetSetupViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Gender
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gender")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)

                    Picker("Gender", selection: $viewModel.gender) {
                        ForEach(PetGender.allCases) { gender in
                            Text(gender.displayName).tag(gender)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Birth Date
                VStack(alignment: .leading, spacing: 8) {
                    Toggle(isOn: $viewModel.hasBirthDate) {
                        Text("Birth Date")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    .tint(Theme.primaryColor)

                    if viewModel.hasBirthDate {
                        DatePicker("", selection: $viewModel.birthDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }
                }

                // Adoption Date
                VStack(alignment: .leading, spacing: 8) {
                    Toggle(isOn: $viewModel.hasAdoptionDate) {
                        Text("Adoption Date")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    .tint(Theme.primaryColor)

                    if viewModel.hasAdoptionDate {
                        DatePicker("", selection: $viewModel.adoptionDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }
                }

                // Weight
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weight")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)

                    TextField("Weight (optional)", text: $viewModel.weight)
                        .keyboardType(.decimalPad)
                        .padding(14)
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                }

                // Color
                VStack(alignment: .leading, spacing: 8) {
                    Text("Color / Markings")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)

                    TextField("e.g., Golden, Black & White", text: $viewModel.color)
                        .padding(14)
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                }

                // Microchip
                VStack(alignment: .leading, spacing: 8) {
                    Text("Microchip Number")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)

                    TextField("Optional", text: $viewModel.microchipNumber)
                        .padding(14)
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                }

                // Neutered
                Toggle(isOn: $viewModel.isNeutered) {
                    Text("Spayed / Neutered")
                        .font(.subheadline.weight(.medium))
                }
                .tint(Theme.primaryColor)
            }
            .padding(.horizontal, Theme.horizontalPadding)
            .padding(.top, 16)
        }
    }
}

// MARK: - Complete Step

private struct CompleteStepView: View {
    @Bindable var viewModel: PetSetupViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var isAnimated = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Theme.primaryColor.opacity(0.1))
                    .frame(width: 160, height: 160)
                    .scaleEffect(isAnimated ? 1.0 : 0.5)

                if let data = viewModel.photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .scaleEffect(isAnimated ? 1.0 : 0.3)
                } else {
                    Image(systemName: viewModel.selectedSpecies.icon)
                        .font(.system(size: 56))
                        .foregroundStyle(Theme.primaryColor)
                        .scaleEffect(isAnimated ? 1.0 : 0.3)
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isAnimated)

            VStack(spacing: 8) {
                Text("Welcome, \(viewModel.name)! 🎉")
                    .font(.title2.bold())

                Text("\(viewModel.selectedSpecies.displayName) · \(viewModel.selectedBreed)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .opacity(isAnimated ? 1 : 0)
            .animation(.easeOut(duration: 0.4).delay(0.3), value: isAnimated)

            Spacer()

            Button {
                savePet()
            } label: {
                Text("Start Tracking")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.primaryColor.gradient, in: RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onAppear { isAnimated = true }
    }

    private func savePet() {
        let pet = viewModel.createPet()
        modelContext.insert(pet)
        try? modelContext.save()
        HapticManager.notification(.success)
        dismiss()
    }
}

#Preview {
    PetSetupView()
        .modelContainer(for: Pet.self, inMemory: true)
}
