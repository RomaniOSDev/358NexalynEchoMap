import SwiftUI
import Combine
import UIKit

struct FocusTimerView: View {
    @StateObject private var viewModel = FocusTimerViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                BrushSectionTitle(title: "Focus")
                Text(viewModel.clock)
                    .font(.system(size: 56, weight: .regular, design: .serif).italic())
                    .foregroundColor(Color("AppTextPrimary"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(Color("AppSurface"))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                HStack(spacing: 10) {
                    ForEach(FocusTimerViewModel.presets, id: \.self) { minutes in
                        Button {
                            viewModel.select(minutes)
                        } label: {
                            Text("\(minutes)m")
                                .font(.headline)
                                .foregroundColor(viewModel.selectedMinutes == minutes ? .white : Color("AppTextPrimary"))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background {
                                    if viewModel.selectedMinutes == minutes {
                                        Capsule().fill(
                                            LinearGradient(
                                                colors: [Color("AppPrimary"), Color("AppAccent")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                    } else {
                                        Capsule().fill(Color("AppSurface"))
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                        .disabled(viewModel.running)
                    }
                }
                if viewModel.finished {
                    Text("Session complete.")
                        .font(.system(.body, design: .serif).italic())
                        .foregroundColor(Color("AppPrimary"))
                }
                if viewModel.running {
                    MagentaGradientButton(title: "Stop", systemImage: "stop.fill", fillWidth: true) {
                        viewModel.stop()
                    }
                } else {
                    MagentaGradientButton(title: "Start session", systemImage: "play.fill", fillWidth: true) {
                        viewModel.start()
                    }
                }
            }
            .padding(20)
        }
        .studioCanvas()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Focus")
                    .font(.system(.headline, design: .serif).italic())
                    .foregroundColor(Color("AppTextPrimary"))
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .onDisappear { viewModel.stop() }
    }
}

final class FocusTimerViewModel: ObservableObject {
    static let presets = [15, 25, 45]

    @Published var selectedMinutes = 25
    @Published var remaining = 25 * 60
    @Published var running = false
    @Published var finished = false

    private var timer: AnyCancellable?

    var clock: String {
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func select(_ minutes: Int) {
        guard !running else { return }
        selectedMinutes = minutes
        remaining = minutes * 60
        finished = false
    }

    func start() {
        remaining = selectedMinutes * 60
        running = true
        finished = false
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func stop() {
        running = false
        timer?.cancel()
        timer = nil
        remaining = selectedMinutes * 60
    }

    private func tick() {
        if remaining <= 1 {
            remaining = 0
            running = false
            finished = true
            timer?.cancel()
            timer = nil
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            return
        }
        remaining -= 1
    }
}
