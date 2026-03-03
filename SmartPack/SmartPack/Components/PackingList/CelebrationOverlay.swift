//
//  CelebrationOverlay.swift
//  SmartPack
//
//  打包清单组件 - 庆祝动画覆盖层
//

import SwiftUI

/// 庆祝动画覆盖层
struct CelebrationOverlay: View {
    @Binding var isPresented: Bool
    /// Localized title (e.g. "All packed! 🎉" / "全部打包完成！🎉")
    let title: String
    let onComplete: () -> Void

    @State private var confettiPieces: [ConfettiPiece] = []
    @State private var showContent = false
    @State private var hasDismissed = false

    var body: some View {
        // F9: Use GeometryReader instead of deprecated UIScreen.main.bounds
        GeometryReader { geometry in
            ZStack {
                // 半透明背景
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismissAndComplete()
                    }

                // 撒花粒子
                ForEach(confettiPieces) { piece in
                    ConfettiView(piece: piece, viewSize: geometry.size)
                }

                // 中心祝贺内容
                if showContent {
                    VStack(spacing: Spacing.lg) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.success)

                        Text("🎉")
                            .font(.system(size: 60, weight: .regular, design: .rounded))

                        Text(title)
                            .font(Typography.title1.bold())
                            .foregroundColor(.white)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            generateConfetti()
            withAnimation(.spring(response: 0.5)) {
                showContent = true
            }

            // 自动关闭
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                dismissAndComplete()
            }
        }
    }

    private func generateConfetti() {
        let colors: [Color] = [AppColors.error, AppColors.warning, .yellow, AppColors.success, AppColors.primary, .purple, .pink]

        // F9: Store x as fraction (0...1), resolved to actual width in ConfettiView
        for i in 0..<50 {
            let piece = ConfettiPiece(
                id: i,
                color: colors.randomElement() ?? .blue,
                xFraction: CGFloat.random(in: 0...1),
                delay: Double.random(in: 0...0.5)
            )
            confettiPieces.append(piece)
        }
    }

    private func dismissAndComplete() {
        guard !hasDismissed else { return }
        hasDismissed = true

        withAnimation(.easeOut(duration: 0.3)) {
            isPresented = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onComplete()
        }
    }
}

/// 撒花粒子数据模型
struct ConfettiPiece: Identifiable {
    let id: Int
    let color: Color
    /// Horizontal position as fraction of view width (0...1)
    let xFraction: CGFloat
    let delay: Double
}

/// 撒花粒子视图
struct ConfettiView: View {
    let piece: ConfettiPiece
    let viewSize: CGSize
    @State private var yOffset: CGFloat = -50
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1

    var body: some View {
        Rectangle()
            .fill(piece.color)
            .frame(width: 10, height: 10)
            .rotationEffect(.degrees(rotation))
            .offset(x: piece.xFraction * viewSize.width - viewSize.width / 2, y: yOffset)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeIn(duration: 2)
                    .delay(piece.delay)
                ) {
                    yOffset = viewSize.height + 50
                    rotation = Double.random(in: 360...720)
                }

                withAnimation(
                    .easeIn(duration: 0.5)
                    .delay(piece.delay + 1.5)
                ) {
                    opacity = 0
                }
            }
    }
}
