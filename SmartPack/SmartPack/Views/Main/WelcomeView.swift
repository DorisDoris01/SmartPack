//
//  WelcomeView.swift
//  SmartPack
//
//  首次欢迎页 - 底部弹出卡片，介绍 App 并引导选择性别
//  PRD v1.2: 首次启动时展示，未选择性别前不可关闭
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var localization: LocalizationManager
    @Binding var isPresented: Bool
    
    @State private var selectedGender: Gender?
    @State private var cardOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // 半透明背景遮罩
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    // 未选择性别时不允许关闭
                }
            
            VStack {
                Spacer()
                
                // 底部弹出卡片
                welcomeCard
                    .offset(y: cardOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                // 只允许向下拖动，且仅在已选择性别后
                                if value.translation.height > 0 && selectedGender != nil {
                                    cardOffset = value.translation.height
                                }
                            }
                            .onEnded { value in
                                if value.translation.height > 100 && selectedGender != nil {
                                    dismissCard()
                                } else {
                                    withAnimation(.spring()) {
                                        cardOffset = 0
                                    }
                                }
                            }
                    )
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                cardOffset = 0
            }
        }
    }
    
    // MARK: - 欢迎卡片
    
    private var welcomeCard: some View {
        VStack(spacing: 24) {
            // 拖动指示条
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.systemGray4))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .opacity(selectedGender != nil ? 1 : 0.3)
            
            // App Logo 和标题
            VStack(spacing: Spacing.sm) {
                Image(systemName: "suitcase.rolling.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.primary)
                
                Text("SmartPack")
                    .font(Typography.title1.bold())
                
                Text(localization.currentLanguage == .chinese
                     ? "基于场景的智能行程助手\n帮你减少出行遗漏"
                     : "Smart trip packing assistant\nNever forget essentials again")
                    .font(Typography.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.top, Spacing.xs)
            
            // 性别选择
            VStack(spacing: Spacing.sm) {
                Text(localization.currentLanguage == .chinese
                     ? "选择你的性别"
                     : "Select your gender")
                    .font(Typography.headline)
                
                HStack(spacing: Spacing.md) {
                    ForEach(Gender.allCases) { gender in
                        GenderSelectionCard(
                            gender: gender,
                            isSelected: selectedGender == gender,
                            language: localization.currentLanguage
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedGender = gender
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            
            // 开始使用按钮
            Button {
                if let gender = selectedGender {
                    saveAndDismiss(gender: gender)
                }
            } label: {
                Text(localization.currentLanguage == .chinese ? "开始使用" : "Get Started")
                    .font(Typography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: Spacing.buttonHeight)
                    .background(selectedGender != nil ? AppColors.primary : AppColors.textSecondary)
                    .cornerRadius(CornerRadius.lg)
            }
            .disabled(selectedGender == nil)
            .padding(.horizontal, Spacing.xs)
            .padding(.bottom, Spacing.lg)
        }
        .padding(.horizontal, Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.xl + 8)
                .fill(AppColors.background)
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: -5)
        )
        .padding(.horizontal, Spacing.xs)
    }
    
    // MARK: - 方法
    
    private func dismissCard() {
        withAnimation(.spring(response: 0.3)) {
            cardOffset = 500
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
    
    private func saveAndDismiss(gender: Gender) {
        // 保存性别选择
        UserDefaults.standard.set(gender.rawValue, forKey: "user_gender")
        // 标记已完成欢迎页
        UserDefaults.standard.set(true, forKey: "has_completed_onboarding")
        
        dismissCard()
    }
}

// MARK: - 性别选择卡片

struct GenderSelectionCard: View {
    let gender: Gender
    let isSelected: Bool
    let language: AppLanguage
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: gender.icon)
                    .font(.system(size: 36))
                
                Text(gender.displayName(language: language))
                    .font(.subheadline.weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(isSelected ? AppColors.primary.opacity(0.15) : AppColors.cardBackground)
            .foregroundColor(isSelected ? AppColors.primary : AppColors.text)
            .cornerRadius(CornerRadius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.xl)
                    .stroke(isSelected ? AppColors.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(gender.displayName(language: language))
    }
}

#Preview {
    WelcomeView(isPresented: .constant(true))
        .environmentObject(LocalizationManager.shared)
}
