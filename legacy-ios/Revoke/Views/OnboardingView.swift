import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var settings: UserSettings
    @State private var step = 0
    @State private var name = ""
    @State private var email = ""
    @State private var selectedState = "CA"
    @State private var animateIcon = false
    
    let states = PrivacyLaw.allLaws
    private let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    private func nextStep() {
        haptic.impactOccurred()
        withAnimation(.easeInOut(duration: 0.35)) { step += 1 }
    }
    
    private func prevStep() {
        haptic.impactOccurred()
        withAnimation(.easeInOut(duration: 0.35)) { step -= 1 }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Back button
                HStack {
                    if step > 0 {
                        Button(action: prevStep) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white.opacity(0.5))
                        }
                        .transition(.opacity)
                    }
                    Spacer()
                }
                .frame(height: 44)
                .padding(.horizontal, 32)
                
                Spacer()
                
                Group {
                    if step == 0 {
                        welcomeStep
                    } else if step == 1 {
                        whyStep
                    } else if step == 2 {
                        nameStep
                    } else if step == 3 {
                        stateStep
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                
                Spacer()
                
                // Progress dots
                HStack(spacing: 8) {
                    ForEach(0..<4) { i in
                        Capsule()
                            .fill(i == step ? Color.accentColor : Color.white.opacity(0.15))
                            .frame(width: i == step ? 24 : 8, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: step)
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 32)
        }
    }
    
    // MARK: - Step 0: Welcome
    
    var welcomeStep: some View {
        VStack(spacing: 24) {
            Text("🛡️")
                .font(.system(size: 72))
                .scaleEffect(animateIcon ? 1.0 : 0.5)
                .opacity(animateIcon ? 1.0 : 0)
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        animateIcon = true
                    }
                }
            
            Text("Revoke")
                .font(.system(size: 40, weight: .black))
                .foregroundColor(.white)
            
            Text("Your data. Your rights.\nTake them back.")
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 12) {
                featureRow(icon: "envelope.fill", text: "Auto-generate legal deletion emails")
                featureRow(icon: "hand.raised.fill", text: "One tap to send per company pack")
                featureRow(icon: "lock.shield.fill", text: "100% on-device. We collect nothing.")
                featureRow(icon: "building.columns.fill", text: "Cite the right law for your state")
            }
            .padding(.vertical, 20)
            
            Button(action: nextStep) {
                Text("Get Started")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.accentColor)
                    .cornerRadius(14)
            }
        }
    }
    
    // MARK: - Step 1: Why This Matters
    
    var whyStep: some View {
        VStack(spacing: 24) {
            // Stat callout
            VStack(spacing: 8) {
                Text("240+")
                    .font(.system(size: 64, weight: .black))
                    .foregroundColor(Color.accentColor)
                
                Text("companies hold data on the\naverage American")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            
            VStack(alignment: .leading, spacing: 14) {
                whyRow(icon: "dollarsign.circle", color: .green,
                       title: "Your data is worth $240/year",
                       detail: "Companies profit from selling your personal information to advertisers, insurers, and employers.")
                
                whyRow(icon: "eye.trianglebadge.exclamationmark", color: .orange,
                       title: "Most people don't know",
                       detail: "Data brokers build profiles with your name, address, habits, location, and health data without asking.")
                
                whyRow(icon: "building.columns", color: Color.accentColor,
                       title: "The law is on your side",
                       detail: "17+ US states give you the legal right to demand deletion. Companies must comply within 45 days.")
            }
            .padding(.vertical, 8)
            
            Button(action: nextStep) {
                Text("I Want My Data Back")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.accentColor)
                    .cornerRadius(14)
            }
        }
    }
    
    // MARK: - Step 2: Name & Email
    
    var nameStep: some View {
        VStack(spacing: 24) {
            Text("Who are you?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("This goes directly into your emails.\nStored only on YOUR device. Never transmitted.")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                TextField("Full Name", text: $name)
                    .textFieldStyle(RevokeFieldStyle())
                
                TextField("Email Address", text: $email)
                    .textFieldStyle(RevokeFieldStyle())
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
            }
            .padding(.vertical, 12)
            
            Button(action: {
                settings.userName = name
                settings.userEmail = email
                nextStep()
            }) {
                Text("Continue")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(name.isEmpty || email.isEmpty ? Color.gray : Color.accentColor)
                    .cornerRadius(14)
            }
            .disabled(name.isEmpty || email.isEmpty)
        }
    }
    
    // MARK: - Step 3: State Selection
    
    var stateStep: some View {
        VStack(spacing: 24) {
            Text("Where do you live?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("We'll cite the right privacy law.\nYour legal rights depend on your state.")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
            
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(states) { law in
                        Button(action: {
                            UISelectionFeedbackGenerator().selectionChanged()
                            selectedState = law.id
                        }) {
                            HStack {
                                Text(law.state)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text(law.lawName)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white.opacity(0.4))
                                
                                if selectedState == law.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color.accentColor)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedState == law.id ? Color.accentColor.opacity(0.1) : Color.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedState == law.id ? Color.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
                                    )
                            )
                        }
                    }
                    
                    // Other state option
                    Button(action: { selectedState = "OTHER" }) {
                        HStack {
                            Text("I live somewhere else")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            if selectedState == "OTHER" {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color.accentColor)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedState == "OTHER" ? Color.accentColor.opacity(0.1) : Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedState == "OTHER" ? Color.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
                                )
                        )
                    }
                }
            }
            .frame(maxHeight: 280)
            
            // Note for other states
            if selectedState == "OTHER" {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(Color.accentColor)
                    Text("Your state doesn't have a specific privacy law yet, but most companies honor deletion requests from all US residents. Your emails will cite the California CCPA, which large companies typically apply nationwide.")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(12)
                .background(Color.accentColor.opacity(0.08))
                .cornerRadius(12)
            }
            
            Button(action: {
                settings.userState = selectedState
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                settings.hasCompletedOnboarding = true
            }) {
                Text("Start Revoking →")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.accentColor)
                    .cornerRadius(14)
            }
        }
    }
    
    // MARK: - Helpers
    
    func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color.accentColor)
                .frame(width: 24)
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    func whyRow(icon: String, color: Color, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Text(detail)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.4))
                    .lineSpacing(2)
            }
        }
    }
}

// MARK: - Custom Text Field Style

struct RevokeFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.07))
            .cornerRadius(12)
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}
