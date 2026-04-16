import SwiftUI
import SharedKit

/// Multi-step widget installation walkthrough (Duolingo pattern).
/// 4 steps, each shows a phone mockup with the current step highlighted.
/// ← Back returns to the previous step (step 1 returns to Widget Intro via onBack).
struct WidgetWalkthroughView: View {
    let onBack: () -> Void
    let onComplete: () -> Void

    @State private var step: Int = 0

    private let steps: [WidgetWalkthroughStep] = [
        .init(
            title: "Press and hold\nanywhere on your Home Screen",
            mockup: .emptyGrid(showPulse: true)
        ),
        .init(
            title: "Tap the \"+\" button\non the top left",
            mockup: .jiggleGrid(showPlus: true)
        ),
        .init(
            title: "Search for \"wttr\"\nin the widget gallery",
            mockup: .search(query: "wttr")
        ),
        .init(
            title: "Choose your size\nand tap Add Widget",
            mockup: .widgetPreview
        )
    ]

    var body: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 8)

            Text(steps[step].title)
                .font(.system(size: 22, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            PhoneMockup(kind: steps[step].mockup)
                .frame(maxHeight: .infinity)
                .padding(.vertical, 8)

            VStack(spacing: 12) {
                Button(action: advance) {
                    Text(isLastStep ? "Got It" : "Next")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .padding(.top, 56)
        .overlay(alignment: .topLeading) {
            Button(action: goBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.primary)
                    .padding(12)
                    .contentShape(Rectangle())
            }
            .padding(.leading, 8)
            .padding(.top, 44)  // clear top progress bar (16 top + 4 bar + buffer)
        }
    }

    private var isLastStep: Bool { step >= steps.count - 1 }

    private func advance() {
        if isLastStep {
            onComplete()
        } else {
            withAnimation(.easeInOut) { step += 1 }
        }
    }

    private func goBack() {
        if step == 0 {
            onBack()
        } else {
            withAnimation(.easeInOut) { step -= 1 }
        }
    }
}

private struct WidgetWalkthroughStep {
    let title: String
    let mockup: PhoneMockup.Kind
}

private struct PhoneMockup: View {
    enum Kind {
        case emptyGrid(showPulse: Bool)
        case jiggleGrid(showPlus: Bool)
        case search(query: String)
        case widgetPreview
    }

    let kind: Kind

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 36)
                .stroke(Color.secondary.opacity(0.4), lineWidth: 4)
                .background(
                    RoundedRectangle(cornerRadius: 36)
                        .fill(Color("Surface"))
                )
                .frame(width: 220, height: 400)

            content
                .frame(width: 200, height: 380)
                .clipShape(RoundedRectangle(cornerRadius: 30))
        }
    }

    @ViewBuilder
    private var content: some View {
        switch kind {
        case .emptyGrid(let pulse):
            appGrid(showPlus: false, pulse: pulse)
        case .jiggleGrid(let showPlus):
            appGrid(showPlus: showPlus, pulse: false)
        case .search(let query):
            searchView(query: query)
        case .widgetPreview:
            widgetSizeGrid
        }
    }

    private func appGrid(showPlus: Bool, pulse: Bool) -> some View {
        VStack(spacing: 0) {
            if showPlus {
                HStack {
                    ZStack {
                        Capsule().fill(.tint)
                            .frame(width: 36, height: 22)
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                }
                .padding(.top, 12)
                .padding(.leading, 12)
            } else {
                Spacer().frame(height: 34)
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 16) {
                ForEach(0..<12, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: 40, height: 40)
                }
            }
            .padding(.horizontal, 16)
            .overlay(alignment: .center) {
                if pulse {
                    Circle()
                        .stroke(.tint, lineWidth: 3)
                        .frame(width: 48, height: 48)
                        .opacity(0.7)
                }
            }
            Spacer()
        }
    }

    private func searchView(query: String) -> some View {
        VStack(spacing: 12) {
            Spacer().frame(height: 30)
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                Text(query)
                    .font(.system(size: 14, weight: .medium))
                Spacer()
            }
            .padding(10)
            .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 12)

            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.15))
                .frame(width: 140, height: 140)
                .overlay(
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "umbrella.fill")
                                .foregroundStyle(Color("Warning"))
                            Text("Rain 3PM")
                                .font(.system(size: 12, weight: .bold))
                        }
                        Text("wttr")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                )
            Spacer()
        }
    }

    private var widgetSizeGrid: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 20)
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.tint, lineWidth: 2)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.1)))
                    .frame(width: 54, height: 54)
                    .overlay(Text("Small").font(.system(size: 9, weight: .semibold)))
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
                    .frame(width: 110, height: 54)
                    .overlay(Text("Medium").font(.system(size: 9, weight: .semibold)))
            }
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
                .frame(width: 160, height: 100)
                .overlay(Text("Large").font(.system(size: 10, weight: .semibold)))
            Capsule().fill(.tint)
                .frame(width: 140, height: 32)
                .overlay(Text("Add Widget").font(.system(size: 13, weight: .semibold)).foregroundStyle(.white))
            Spacer()
        }
    }
}
