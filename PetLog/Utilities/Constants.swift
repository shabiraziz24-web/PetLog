import Foundation

enum Constants {
    static let appName = "PetLog"
    static let bundleId = "com.petlog.app"

    enum StoreKit {
        static let monthlyProductId = "com.petlog.premium.monthly"
        static let yearlyProductId = "com.petlog.premium.yearly"
        static let monthlyPrice = "$4.99/mo"
        static let yearlyPrice = "$29.99/yr"
        static let groupId = "com.petlog.premium"
    }

    enum Limits {
        static let freePetLimit = 1
        static let maxPhotosPerEntry = 10
    }

    enum UserDefaultsKeys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let selectedPetId = "selectedPetId"
        static let useMetricUnits = "useMetricUnits"
        static let selectedCurrency = "selectedCurrency"
        static let notificationsEnabled = "notificationsEnabled"
    }

    enum BreedLists {
        static let dogBreeds = [
            "Labrador Retriever", "German Shepherd", "Golden Retriever", "French Bulldog",
            "Bulldog", "Poodle", "Beagle", "Rottweiler", "German Shorthaired Pointer",
            "Dachshund", "Pembroke Welsh Corgi", "Australian Shepherd", "Yorkshire Terrier",
            "Boxer", "Cavalier King Charles Spaniel", "Doberman Pinscher", "Miniature Schnauzer",
            "Shih Tzu", "Boston Terrier", "Bernese Mountain Dog", "Pomeranian", "Havanese",
            "Siberian Husky", "Shetland Sheepdog", "Brittany", "English Springer Spaniel",
            "Cocker Spaniel", "Border Collie", "Chihuahua", "Maltese", "Mixed Breed", "Other"
        ]

        static let catBreeds = [
            "Domestic Shorthair", "Domestic Longhair", "Siamese", "Persian", "Maine Coon",
            "Ragdoll", "Bengal", "Abyssinian", "Birman", "Oriental Shorthair", "Sphynx",
            "Devon Rex", "Scottish Fold", "American Shorthair", "British Shorthair",
            "Norwegian Forest Cat", "Russian Blue", "Burmese", "Tonkinese", "Mixed Breed", "Other"
        ]

        static let birdBreeds = [
            "Budgerigar", "Cockatiel", "Lovebird", "Parrotlet", "Conure",
            "African Grey", "Cockatoo", "Macaw", "Finch", "Canary",
            "Parakeet", "Amazon Parrot", "Eclectus", "Other"
        ]

        static let fishBreeds = [
            "Betta", "Goldfish", "Guppy", "Neon Tetra", "Angelfish", "Oscar",
            "Clownfish", "Discus", "Molly", "Platy", "Corydoras", "Other"
        ]

        static let rabbitBreeds = [
            "Holland Lop", "Mini Rex", "Netherland Dwarf", "Lionhead", "Flemish Giant",
            "Dutch", "Mini Lop", "Rex", "English Lop", "Other"
        ]

        static let hamsterBreeds = [
            "Syrian", "Dwarf Campbell", "Dwarf Winter White", "Roborovski", "Chinese", "Other"
        ]

        static let reptileBreeds = [
            "Leopard Gecko", "Bearded Dragon", "Ball Python", "Corn Snake",
            "Crested Gecko", "Red-Eared Slider", "Chameleon", "Blue-Tongued Skink",
            "Green Iguana", "Tortoise", "Other"
        ]

        static func breeds(for species: Species) -> [String] {
            switch species {
            case .dog: return dogBreeds
            case .cat: return catBreeds
            case .bird: return birdBreeds
            case .fish: return fishBreeds
            case .rabbit: return rabbitBreeds
            case .hamster: return hamsterBreeds
            case .reptile: return reptileBreeds
            case .other: return ["Other"]
            }
        }
    }
}
