//
//  PlayerController.swift
//  slushots
//
//  Created by Anatoliy Petrov on 24.12.24..
//

import SwiftUI

struct PlayerController: View {
    @Binding var isLoading: Bool
    let songName: String
    let artistName: String
    
    var body: some View {
        ZStack{
            Rectangle()
                .fill(Color.init(hex: "#111111"))
                .opacity(1)
                .cornerRadius(20)
                .modifier(ShimmerEffect(isActive: isLoading))
            if isLoading {
                HStack(alignment: .center, spacing: 20) {
                    Text("Finding:")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                    Text("\(songName) by \(artistName)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }.padding()
            } else {
                HStack(spacing: 20) {  Button(action: {
                    print("Shuffle button tapped")
                }) {
                    Image(systemName: "shuffle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                }
                    
                    Button(action: {
                        print("Backward button tapped")
                    }) {
                        Image(systemName: "backward.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        print("Play button tapped")
                    }) {
                        Image(systemName: "play.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        print("Forward button tapped")
                    }) {
                        Image(systemName: "forward.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 30)
            }
            
        }.frame(maxWidth: .infinity, maxHeight: 100)
            .padding(.horizontal, 10)
            .animation(.easeOut(duration: 0.5), value: isLoading)
    }
}

struct ShimmerEffect: ViewModifier {
    @State private var startPoint: CGFloat = -2.0
    @State private var endPoint: CGFloat = 0.0
    var isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.01), Color.white.opacity(0.1), Color.white.opacity(0.2)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .mask(content)
                .offset(x: isActive ? startPoint * 300 : 0, y: 0)
                .opacity(isActive ? 1 : 0)
                .onAppear {
                    guard isActive else { return }
                    withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        startPoint = 2.0
                    }
                }
            )
            .mask(content)
    }
}

#Preview {
    PlayerController(isLoading: .constant(false), songName: "Hope", artistName: "NF")
}
