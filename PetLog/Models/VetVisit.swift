import Foundation
import SwiftData

@Model
final class VetVisit {
    var id: UUID
    var date: Date
    var vetName: String
    var clinicName: String
    var clinicAddress: String
    var clinicPhone: String
    var reason: String
    var diagnosis: String
    var treatment: String
    var notes: String
    var cost: Double?
    var followUpDate: Date?
    @Attribute(.externalStorage) var attachmentData: [Data]
    var createdAt: Date

    var pet: Pet?

    init(
        date: Date = Date(),
        vetName: String = "",
        clinicName: String = "",
        clinicAddress: String = "",
        clinicPhone: String = "",
        reason: String = "",
        diagnosis: String = "",
        treatment: String = "",
        notes: String = "",
        cost: Double? = nil,
        followUpDate: Date? = nil,
        attachmentData: [Data] = [],
        pet: Pet? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.vetName = vetName
        self.clinicName = clinicName
        self.clinicAddress = clinicAddress
        self.clinicPhone = clinicPhone
        self.reason = reason
        self.diagnosis = diagnosis
        self.treatment = treatment
        self.notes = notes
        self.cost = cost
        self.followUpDate = followUpDate
        self.attachmentData = attachmentData
        self.createdAt = Date()
        self.pet = pet
    }

    var isPast: Bool { date < Date() }
    var isUpcoming: Bool { date > Date() }
    var hasFollowUp: Bool { followUpDate != nil }
}
