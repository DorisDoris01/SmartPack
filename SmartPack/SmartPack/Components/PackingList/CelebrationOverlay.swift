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

    var body: some View {
        ZStack {
            // 半透明背景
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissAndComplete()
                }

            // 撒花粒子
            ForEach(confettiPieces) { piece in
                ConfettiView(piece: piece)
            }

            // 中心祝贺内容
            if showContent {
                VStack(spacing: Spacing.lg) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(AppColors.success)

                    Text("🎉")
                        .font(.system(size: 60))

                    Text(title)
                        .font(Typography.title1.bold())
                        .foregroundColor(.white)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
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

        for i in 0..<50 {
            let piece = ConfettiPiece(
                id: i,
                color: colors.randomElement() ?? .blue,
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                delay: Double.random(in: 0...0.5)
            )
            confettiPieces.append(piece)
        }
    }

    private func dismissAndComplete() {
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
    let x: CGFloat
    let delay: Double
}

/// 撒花粒子视图
struct ConfettiView: View {
    let piece: ConfettiPiece
    @State private var yOffset: CGFloat = -50
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1

    var body: some View {
        Rectangle()
            .fill(piece.color)
            .frame(width: 10, height: 10)
            .rotationEffect(.degrees(rotation))
            .offset(x: piece.x - UIScreen.main.bounds.width / 2, y: yOffset)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeIn(duration: 2)
                    .delay(piece.delay)
                ) {
                    yOffset = UIScreen.main.bounds.height + 50
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
