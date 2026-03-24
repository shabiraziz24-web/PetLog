import SwiftUI

struct PetAvatarView: View {
    let pet: Pet
    var size: CGFloat = 60
    var isSelected: Bool = false

    var body: some View {
        ZStack {
            if let photoData = pet.photo, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(pet.species.accentColor.gradient)
                    .frame(width: size, height: size)
                    .overlay {
                        Image(systemName: pet.species.icon)
                            .font(.system(size: size * 0.4))
                            .foregroundStyle(.white)
                    }
            }
        }
        .overlay {
            if isSelected {
                Circle()
                    .stroke(Theme.primaryColor, lineWidth: 3)
                    .frame(width: size + 6, height: size + 6)
            }
        }
    }
}

struct SmallPetAvatar: View {
    let pet: Pet

    var body: some View {
        PetAvatarView(pet: pet, size: 32)
    }
}
