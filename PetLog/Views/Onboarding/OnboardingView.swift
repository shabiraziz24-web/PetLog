import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
}

struct OnboardingView: View {
    @AppStorage(Constants.UserDefaultsKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "pawprint.fill",
            title: "Welcome to PetLog",
            subtitle: "Everything your pet needs, in one place. Track health, activities, and memories with ease.",
            color: Theme.primaryColor
        ),
        OnboardingPage(
            icon: "heart.fill",
            title: "Track Health",
            subtitle: "Log vet visits, vaccinations, medications, and weight — never miss an important detail.",
            color: Theme.secondaryColor
        ),
        OnboardingPage(
            icon: "figure.walk",
            title: "Stay Active",
            subtitle: "Record walks, playtime, and feeding schedules. Build healthy routines together.",
            color: .green
        ),
        OnboardingPage(
            icon: "bell.fill",
            title: "Never Forget",
            subtitle: "Smart reminders for medications, vet appointments, and vaccinations keep you on track.",
            color: .purple
        )
    ]

    var body: some View {
        ZStack {
            Theme.backgroundWarm.ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip Button
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            completeOnboarding()
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .padding()
                    }
                }

                // Page Content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.4), value: currentPage)

                // Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? Theme.primaryColor : Color.gray.opacity(0.3))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 32)

                // Action Button
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation(.spring(response: 0.4)) {
                            currentPage += 1
                        }
                        HapticManager.impact(.light)
                    } else {
                        completeOnboarding()
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Continue" : "Get Started")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.primaryColor.gradient, in: RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func completeOnboarding() {
        HapticManager.notification(.success)
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var isAnimated = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 180, height: 180)
                    .scaleEffect(isAnimated ? 1.0 : 0.6)

                Circle()
                    .fill(page.color.opacity(0.08))
                    .frame(width: 240, height: 240)
                    .scaleEffect(isAnimated ? 1.0 : 0.5)

                Image(systemName: page.icon)
                    .font(.system(size: 64))
                    .foregroundStyle(page.color)
                    .scaleEffect(isAnimated ? 1.0 : 0.3)
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isAnimated)

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .opacity(isAnimated ? 1 : 0)
            .offset(y: isAnimated ? 0 : 20)
            .animation(.easeOut(duration: 0.5).delay(0.2), value: isAnimated)

            Spacer()
            Spacer()
        }
        .onAppear {
            isAnimated = true
        }
        .onDisappear {
            isAnimated = false
        }
    }
}

#Preview {
    OnboardingView()
}
