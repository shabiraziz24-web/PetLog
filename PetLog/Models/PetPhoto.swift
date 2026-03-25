import Foundation
import SwiftData

@Model
final class PetPhoto {
    var id: UUID
    @Attribute(.externalStorage) var imageData: Data
    var caption: String
    var date: Date
    var isFavorite: Bool
    var createdAt: Date

    var pet: Pet?

    init(
        imageData: Data = Data(),
        caption: String = "",
        date: Date = Date(),
        isFavorite: Bool = false,
        pet: Pet? = nil
    ) {
        self.id = UUID()
        self.imageData = imageData
        self.caption = caption
        self.date = date
        self.isFavorite = isFavorite
        self.createdAt = Date()
        self.pet = pet
    }

    var dateFormatted: String {
        date.shortDate
    }
}
