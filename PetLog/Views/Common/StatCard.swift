import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    var trendIcon: String? = nil
    var trendColor: Color? = nil
    var accentColor: Color = Theme.primaryColor

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(accentColor)
                Spacer()
                if let trendIcon, let trendColor {
                    Image(systemName: trendIcon)
                        .font(.caption2)
                        .foregroundStyle(trendColor)
                }
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    var color: Color = Theme.primaryColor
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.impact(.light)
            action()
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 48, height: 48)
                    .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        HStack {
            StatCard(title: "Age", value: "3y 2m", icon: "birthday.cake")
            StatCard(title: "Weight", value: "65 lbs", icon: "scalemass", trendIcon: "arrow.up.right", trendColor: .orange)
        }
        HStack {
            QuickActionButton(title: "Log Weight", icon: "scalemass.fill") {}
            QuickActionButton(title: "Log Food", icon: "fork.knife", color: .green) {}
            QuickActionButton(title: "Start Walk", icon: "figure.walk", color: .blue) {}
            QuickActionButton(title: "Add Expense", icon: "dollarsign.circle.fill", color: .purple) {}
        }
    }
    .padding()
}
