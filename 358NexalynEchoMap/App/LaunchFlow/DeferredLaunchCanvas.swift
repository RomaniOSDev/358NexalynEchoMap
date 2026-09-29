//
//  DeferredLaunchCanvas.swift
//

import SwiftUI

struct DeferredLaunchCanvas: View {
    @ObservedObject var state: LaunchStagingState

    @State private var pulse = false
    @State private var glowBreath = false
    @State private var sprocketShift = false
    @State private var framePulse = false

    private var clampedProgress: Double { min(1.0, max(0.05, state.progress)) }

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            let ringSize: CGFloat = isLandscape ? min(geo.size.height * 0.58, 168) : 220
            let titleSize: CGFloat = isLandscape ? 28 : 34

            ZStack {
                backgroundLayer

                Group {
                    if isLandscape {
                        landscapeContent(ringSize: ringSize, titleSize: titleSize)
                            .padding(.horizontal, max(24, geo.safeAreaInsets.leading + 16))
                            .padding(.vertical, 12)
                    } else {
                        portraitContent(ringSize: ringSize, titleSize: titleSize)
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
        .onAppear {
            pulse = true
            glowBreath = true
            sprocketShift = true
            framePulse = true
        }
    }

    // MARK: - Layouts

    private func portraitContent(ringSize: CGFloat, titleSize: CGFloat) -> some View {
        VStack(spacing: 28) {
            Spacer(minLength: 12)

            titleLabel(size: titleSize)
            progressRing(size: ringSize)
            filmstripProgress
            statusLabel
                .padding(.horizontal, 36)

            Spacer()
                .frame(height: 72)
        }
    }

    private func landscapeContent(ringSize: CGFloat, titleSize: CGFloat) -> some View {
        HStack(spacing: 28) {
            VStack(spacing: 14) {
                titleLabel(size: titleSize)
                progressRing(size: ringSize)
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 18) {
                filmstripProgress
                statusLabel
                    .frame(maxWidth: 280)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func titleLabel(size: CGFloat) -> some View {
        Text("Studio")
            .font(.system(size: size, weight: .regular, design: .serif).italic())
            .foregroundColor(Color("AppTextPrimary"))
            .opacity(pulse ? 1 : 0.78)
            .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
    }

    private var statusLabel: some View {
        Text(state.statusMessage)
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundColor(Color("AppTextPrimary"))
            .multilineTextAlignment(.center)
            .opacity(pulse ? 1 : 0.72)
            .animation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true), value: pulse)
    }

    private func progressRing(size: CGFloat) -> some View {
        let track: CGFloat = size * 0.76
        let percentOffset = size * 0.39

        return ZStack {
            Circle()
                .fill(Color("AppPrimary").opacity(glowBreath ? 0.26 : 0.1))
                .frame(width: size, height: size)
                .blur(radius: 28)
                .scaleEffect(pulse ? 1.06 : 0.94)

            Circle()
                .stroke(Color("AppPrimary").opacity(0.2), lineWidth: 2)
                .frame(width: track, height: track)

            Circle()
                .trim(from: 0, to: CGFloat(clampedProgress))
                .stroke(
                    AngularGradient(
                        colors: [
                            Color("AppPrimary"),
                            Color("AppAccent"),
                            Color("AppPrimary")
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: size > 180 ? 4 : 3.2, lineCap: .round)
                )
                .frame(width: track, height: track)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.35), value: clampedProgress)
                .shadow(color: Color("AppPrimary").opacity(0.55), radius: 10)

            studioAperture(diameter: size * 0.54)
                .scaleEffect(framePulse ? 1.04 : 0.96)
                .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: framePulse)

            Text("\(Int(clampedProgress * 100))%")
                .font(.system(size: size > 180 ? 14 : 12, weight: .bold, design: .rounded))
                .foregroundColor(Color("AppTextPrimary"))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color("AppBackground").opacity(0.78))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color("AppPrimary").opacity(0.35), lineWidth: 1)
                )
                .offset(y: percentOffset)
        }
        .frame(width: size, height: size + 24)
    }

    private func studioAperture(diameter: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color("AppSurface"))
                .frame(width: diameter + 18, height: diameter + 18)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.45), radius: 18, y: 10)

            VStack(spacing: 6) {
                sprocketRow(count: 7)
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color("AppBackground"),
                                    Color.black.opacity(0.92)
                                ],
                                center: .center,
                                startRadius: 8,
                                endRadius: diameter / 2
                            )
                        )
                        .frame(width: diameter * 0.72, height: diameter * 0.72)

                    ForEach(0..<6, id: \.self) { index in
                        Capsule()
                            .fill(Color("AppPrimary").opacity(0.55))
                            .frame(width: max(8, diameter * 0.08), height: diameter * 0.22)
                            .offset(y: -diameter * 0.18)
                            .rotationEffect(.degrees(Double(index) * 60))
                    }

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color("AppPrimary"), Color("AppAccent")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: diameter * 0.22, height: diameter * 0.22)
                        .shadow(color: Color("AppPrimary").opacity(0.7), radius: 8)

                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: max(9, diameter * 0.09), weight: .bold))
                        .foregroundColor(.white)
                }
                sprocketRow(count: 7)
            }
            .padding(.vertical, 8)
        }
        .allowsHitTesting(false)
    }

    private func sprocketRow(count: Int) -> some View {
        HStack(spacing: 5) {
            ForEach(0..<count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color("AppBackground"))
                    .frame(width: 5, height: 7)
                    .offset(x: sprocketShift && index % 2 == 0 ? 1.5 : -1.5)
                    .animation(
                        .easeInOut(duration: 0.55)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.04),
                        value: sprocketShift
                    )
            }
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            Color("AppBackground")
                .ignoresSafeArea()

            Image("bg_studio")
                .resizable()
                .scaledToFill()
                .opacity(0.26)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color("AppPrimary").opacity(0.18),
                    Color.clear,
                    Color("AppAccent").opacity(0.14)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [Color("AppPrimary").opacity(0.28), Color.clear],
                center: .center,
                startRadius: 20,
                endRadius: 320
            )
            .ignoresSafeArea()
            .scaleEffect(glowBreath ? 1.12 : 0.92)
            .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: glowBreath)
        }
    }

    private var filmstripProgress: some View {
        HStack(spacing: 6) {
            ForEach(0..<8, id: \.self) { index in
                let filled = Double(index) / 7.0 <= clampedProgress
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(Color("AppSurface"))
                    .overlay {
                        if filled {
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color("AppPrimary"), Color("AppAccent")],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                        }
                    }
                    .frame(width: 18, height: filled ? 28 : 16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .animation(.easeInOut(duration: 0.3), value: clampedProgress)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color("AppSurface").opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

#Preview("Staging — mid") {
    DeferredLaunchCanvas(state: {
        let state = LaunchStagingState()
        state.progress = 0.58
        state.statusMessage = "Developing your frames..."
        return state
    }())
}
