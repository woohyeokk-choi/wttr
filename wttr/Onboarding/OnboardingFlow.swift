import SwiftUI
import SharedKit

/// Top-level onboarding flow (Duolingo pattern).
///
/// Progression is strictly forward (no global Skip button). The only opt-out is
/// "No Thanks" on the Widget Intro, which skips the widget walkthrough and jumps
/// directly to completion.
struct OnboardingFlow: View {
    @Environment(PreferencesStore.self) private var preferencesStore
    @State private var currentStep: Step = .welcome
    let onComplete: () -> Void

    enum Step: Int, CaseIterable {
        case welcome
        case location
        case decisions
        case notifications
        case widgetIntro
        case widgetWalkthrough
        case completion

        /// Steps that contribute to the top progress bar. The walkthrough is a
        /// sub-flow of widgetIntro so it reuses the same progress fraction.
        static var progressable: [Step] {
            [.welcome, .location, .decisions, .notifications, .widgetIntro, .completion]
        }

        var progressIndex: Int {
            switch self {
            case .welcome: return 0
            case .location: return 1
            case .decisions: return 2
            case .notifications: return 3
            case .widgetIntro, .widgetWalkthrough: return 4
            case .completion: return 5
            }
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            content
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)))

            LinearProgressBar(progress: progress)
                .padding(.horizontal, 24)
                .padding(.top, 16)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch currentStep {
        case .welcome:
            WelcomeView { advance(to: .location) }
        case .location:
            LocationPermissionView { advance(to: .decisions) }
        case .decisions:
            DecisionSelectionView { advance(to: .notifications) }
        case .notifications:
            NotificationSetupView { advance(to: .widgetIntro) }
        case .widgetIntro:
            WidgetSetupView(
                onSeeHowToInstall: { advance(to: .widgetWalkthrough) },
                onSkip: { advance(to: .completion) }
            )
        case .widgetWalkthrough:
            WidgetWalkthroughView(
                onBack: { advance(to: .widgetIntro) },
                onComplete: { advance(to: .completion) }
            )
        case .completion:
            CompletionView {
                preferencesStore.hasCompletedOnboarding = true
                preferencesStore.save()
                onComplete()
            }
        }
    }

    private var progress: Double {
        let total = Double(Step.progressable.count)
        let current = Double(currentStep.progressIndex + 1)
        return min(1.0, current / total)
    }

    private func advance(to step: Step) {
        withAnimation(.easeInOut(duration: 0.3)) { currentStep = step }
    }
}

/// Linear progress bar rendered at the top of the onboarding container.
struct LinearProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.secondary.opacity(0.2))
                Capsule()
                    .fill(Color.primary)
                    .frame(width: max(0, geo.size.width * CGFloat(progress)))
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 4)
    }
}
