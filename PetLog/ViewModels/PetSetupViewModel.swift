import Foundation
import SwiftUI
import PhotosUI

enum PetSetupStep: Int, CaseIterable {
    case species = 0
    case breed
    case namePhoto
    case details
    case complete

    var title: String {
        switch self {
        case .species: return "What kind of pet?"
        case .breed: return "What breed?"
        case .namePhoto: return "Name & Photo"
        case .details: return "Details"
        case .complete: return "All Set!"
        }
    }
}

@Observable
final class PetSetupViewModel {
    var currentStep: PetSetupStep = .species
    var selectedSpecies: Species = .dog
    var selectedBreed: String = ""
    var name: String = ""
    var selectedPhotoItem: PhotosPickerItem?
    var photoData: Data?
    var birthDate: Date = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
    var hasBirthDate: Bool = false
    var adoptionDate: Date = Date()
    var hasAdoptionDate: Bool = false
    var gender: PetGender = .unknown
    var color: String = ""
    var weight: String = ""
    var microchipNumber: String = ""
    var isNeutered: Bool = false
    var breedSearchText: String = ""

    var progress: Double {
        Double(currentStep.rawValue) / Double(PetSetupStep.allCases.count - 1)
    }

    var filteredBreeds: [String] {
        let breeds = Constants.BreedLists.breeds(for: selectedSpecies)
        if breedSearchText.isEmpty { return breeds }
        return breeds.filter { $0.localizedCaseInsensitiveContains(breedSearchText) }
    }

    var canProceed: Bool {
        switch currentStep {
        case .species: return true
        case .breed: return !selectedBreed.isEmpty
        case .namePhoto: return !name.isEmpty
        case .details: return true
        case .complete: return true
        }
    }

    func nextStep() {
        guard let next = PetSetupStep(rawValue: currentStep.rawValue + 1) else { return }
        withAnimation(.spring(response: 0.3)) {
            currentStep = next
        }
        HapticManager.impact(.light)
    }

    func previousStep() {
        guard let prev = PetSetupStep(rawValue: currentStep.rawValue - 1) else { return }
        withAnimation(.spring(response: 0.3)) {
            currentStep = prev
        }
    }

    func createPet() -> Pet {
        let pet = Pet(
            name: name,
            species: selectedSpecies,
            breed: selectedBreed,
            birthDate: hasBirthDate ? birthDate : nil,
            adoptionDate: hasAdoptionDate ? adoptionDate : nil,
            gender: gender,
            weight: Double(weight),
            color: color,
            microchipNumber: microchipNumber,
            photo: photoData,
            isNeutered: isNeutered
        )
        return pet
    }

    @MainActor
    func loadPhoto() async {
        guard let item = selectedPhotoItem else { return }
        if let data = try? await item.loadTransferable(type: Data.self) {
            photoData = data
        }
    }
}
