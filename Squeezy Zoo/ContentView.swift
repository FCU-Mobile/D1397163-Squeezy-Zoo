import SwiftUI

struct ContentView: View {
    @State private var selectedAnimal: String = "pinkBear"
    @State private var animalNames: [String: String] = [
        "pinkBear": "Teddy",
        "yellowDuck": "Ducky",
        "blueCat": "Kitty",
        "brownDog": "Doggo",
        "hare": "Bunny"
    ]

    let animalIcons: [String: String] = [
        "pinkBear": "teddybear.fill",
        "yellowDuck": "bird",
        "blueCat": "cat",
        "brownDog": "dog",
        "hare": "hare"
    ]

    @State private var isPressed = false
    @State private var isShowing = false
    @State private var hasCentered = false
    @State private var isShaking = true
    @State private var rotationAngle: Double = 0
    @State private var lastTapTime = Date()
    @State private var shouldShake = false

    @State private var energyLevel: Int = 0
    @State private var heartScale: CGFloat = 1.0
    @State private var heartAnimating = false
    private let maxEnergy = 9

    var body: some View {
        VStack(spacing: 20) {
            Text("Squeezy Zoo")
                .font(.largeTitle)
                .fontWeight(.bold)
                .scaleEffect(hasCentered ? 0.7 : 1.0)
                .opacity(hasCentered ? 0.4 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: hasCentered)

            Text("Let the Squishing begin!")
                .foregroundStyle(.secondary)
                .scaleEffect(hasCentered ? 0.7 : 1.0)
                .opacity(hasCentered ? 0.4 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: hasCentered)

            ZStack {
                Image(systemName: "heart.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.pink)
                    .opacity(0.2)
                    .frame(width: 240, height: 240)
                    .scaleEffect(heartScale)
                    .onChange(of: energyLevel) { _, newLevel in
                        if newLevel == maxEnergy && hasCentered {
                            heartAnimating = true
                            animateHeart()
                        }
                    }

                Image(selectedAnimal)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 210)
                    .shadow(radius: 9)
                    .scaleEffect(
                        hasCentered
                        ? (isPressed ? CGSize(width: 1.15, height: 0.85) : CGSize(width: 1.3, height: 1.3))
                        : CGSize(width: 1.0, height: 1.0)
                    )
                    .rotationEffect(.degrees(rotationAngle))
                    .animation(
                        shouldShake
                        ? Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)
                        : .default,
                        value: rotationAngle
                    )
                    .onTapGesture {
                        lastTapTime = Date()
                        if !hasCentered {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                isShaking = false
                                hasCentered = true
                            }
                        } else {
                            isPressed = true
                            if energyLevel < maxEnergy {
                                energyLevel += 1
                            }
                            if energyLevel == maxEnergy {
                                heartAnimating = true
                                animateHeart()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                isPressed = false
                            }
                        }
                        scheduleShakeReset()
                    }
                    .onAppear {
                        startShaking()
                    }
            }

            if energyLevel == 0 {
                HStack(spacing: 6) {
                    Text("😩")
                    Text("Depressed...")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            } else if energyLevel == maxEnergy {
                HStack(spacing: 6) {
                    Text("🎉")
                    Text("You’re stronger than you think! 💪")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }

            HStack(spacing: 4) {
                ForEach(0..<10) { index in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(index <= energyLevel ? Color.pink : Color.gray.opacity(0.2))
                        .frame(width: 18, height: 10)
                }
            }

            VStack(spacing: 5) {
                Text("Name your buddy:")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .scaleEffect(hasCentered ? 0.7 : 1.0)
                    .opacity(hasCentered ? 0.4 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: hasCentered)

                TextField("Enter name", text: Binding(
                    get: { animalNames[selectedAnimal] ?? "" },
                    set: { newValue in animalNames[selectedAnimal] = newValue }
                ))
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
                .frame(width: 160)
                .scaleEffect(hasCentered ? 0.8 : 1.0)
                .opacity(hasCentered ? 0.5 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: hasCentered)
            }

            Button {
                isShowing = true
            } label: {
                Text("Choose Your Buddy")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
            }
        }
        .sheet(isPresented: $isShowing) {
            VStack(spacing: 20) {
                Text("Select a Buddy")
                    .font(.headline)

                HStack(spacing: 12) {
                    ForEach(animalIcons.sorted(by: { $0.key < $1.key }), id: \ .key) { key, icon in
                        Button(action: {
                            selectedAnimal = key
                        }) {
                            Image(systemName: icon)
                                .imageScale(.medium)
                                .foregroundStyle(.gray)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(selectedAnimal == key ? Color.pink : Color.gray, lineWidth: 2)
                                )
                        }
                    }
                }
            }
            .padding()
            .presentationDetents([.medium, .fraction(0.33)])
            .presentationDragIndicator(.visible)
        }
        .padding()
    }

    private func startShaking() {
        shouldShake = true
        rotationAngle = 5 // 觸發動畫
    }
    private func stopShaking() {
        shouldShake = false
        rotationAngle = 0
    }

    private func animateHeart() {
        guard heartAnimating else { return }
        withAnimation(.easeInOut(duration: 0.5)) {
            heartScale = 1.2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                heartScale = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if heartAnimating {
                    animateHeart()
                }
            }
        }
    }

    private func scheduleShakeReset() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if Date().timeIntervalSince(lastTapTime) >= 2 {
                withAnimation(.easeInOut(duration: 0.4)) {
                    isShaking = true
                    hasCentered = false
                    energyLevel = 0
                }
                heartAnimating = false
                heartScale = 1.0
                startShaking()
            }
        }
    }
}

#Preview {
    ContentView()
}
