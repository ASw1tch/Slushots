//
//  YandexLoginView.swift
//  slushots
//
//  Created by Anatoliy Petrov on 1.2.25..
//

import SwiftUI

struct YandexLoginView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = YandexLoginViewModel()
    @StateObject private var motionManager = ParallaxMotionManager()
    @State private var animateGradient = false
    @State private var shouldNavigate = false
    
    var body: some View {
            VStack {
                Image("yaDog")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .offset(x: motionManager.xOffset, y: motionManager.yOffset)
                
                Text("Enter your email associated with Yandex.Music")
                    .font(.title3)
                    .bold()
                    .lineLimit(2)
                    .foregroundStyle(.secondary)
                    .padding()
                
                TextField("Enter email", text: $viewModel.ownerName)
                    .foregroundColor(Color.black)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                    .overlay(gradientOverlay)
                    .onAppear {
                        animateGradient.toggle()
                    }
                    .padding()
                
                Button("Proceed") {
                    viewModel.search()
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.ownerName.isEmpty)
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                }
                NavigationLink(
                    destination: MediaListView(
                        ownerName: viewModel.ownerName,
                        yaResult: viewModel.yaResult ?? YandexSongResponse(
                            playlist: Playlist(
                                owner: Owner(name: "", avatarHash: ""),
                                tracks: []
                            )
                        )
                    ),
                    isActive: $shouldNavigate,
                    label: { EmptyView() }
                )
            }
            .alert(isPresented: $viewModel.showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: viewModel.shouldNavigate) { newValue in
                if newValue {
                    shouldNavigate = true
                }
            }
        }
    
    @ViewBuilder
    private var gradientOverlay: some View {
        ZStack {
            firstGradient
            secondGradient
        }
    }
    
    private var firstGradient: some View {
        RoundedRectangle(cornerRadius: 12)
            .strokeBorder(
                LinearGradient(
                    gradient: Gradient(colors: animateGradient
                                       ? [Color.pink, Color.orange, Color.blue]
                                       : [Color.blue, Color.purple, Color.yellow]),
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                lineWidth: 3
            )
            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true),
                       value: animateGradient)
    }
    

    private var secondGradient: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: animateGradient
                                       ? [Color.pink.opacity(0.8), Color.orange.opacity(0.8), Color.blue.opacity(0.8)]
                                       : [Color.blue.opacity(0.8), Color.purple.opacity(0.8), Color.yellow.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                lineWidth: 10
            )
            .blur(radius: colorScheme == .light ? 8 : 6)
            .opacity(colorScheme == .light ? 0.4 : 0.7)
            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true),
                       value: animateGradient)
    }
}

#Preview {
    YandexLoginView()
}
