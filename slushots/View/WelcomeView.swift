//
//  WelcomeView.swift
//  slushots
//
//  Created by Anatoliy Petrov on 13.2.25..
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = YandexLoginViewModel()
    @StateObject private var motionManager = ParallaxMotionManager()
    @State private var animateGradient = false
    @State private var shouldNavigate = false
    
    var body: some View {
        NavigationStack {
                VStack {
                    ZStack {
                        Image("spotyCat")
                            .resizable()
                            .frame(width: 140, height: 140)
                            .offset(x: -59, y: -241)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .frame(maxWidth: .infinity, maxHeight: 350)
                                .foregroundStyle(Color(hex: "5C7285"))
                            
                            VStack {
                                Text("Proslushots")
                                    .font(.title)
                                    .bold()
                                    .foregroundStyle(Color.init(hex: "FFF2F2"))
                                Text("Your personal assistant for discovering music videos of your favorite songs! Simply import playlist and explore videos that might become your new favorites!")
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(Color.init(hex: "FFF2F2"))
                                    .padding(.horizontal, 20)
                                NavigationLink(value: "spotifyLogin") {
                                    HStack(spacing: 10) {
                                        Image("spotifyLogo")
                                            .resizable()
                                            .frame(width: 22, height: 22)
                                        Text("Spotify")
                                            .font(.title2)
                                            .bold()
                                    }
                                    .frame(maxHeight: 17)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .foregroundColor(.black)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 10)
                                NavigationLink(value: "yandexLogin") {
                                    HStack(spacing: 10) {
                                        Image("yandexLogo")
                                            .resizable()
                                            .frame(width: 18, height: 18)
                                        Text("Yandex")
                                            .font(.title2)
                                            .bold()
                                    }
                                    .frame(maxHeight: 17)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .foregroundColor(.black)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                }
                                .padding(.horizontal, 20)
                            }.padding()
                        }
                        .padding(.horizontal, 20)
                        
                        Image("yaDog")
                            .resizable()
                            .frame(width: 200, height: 200)
                            .offset(x: 62, y: -235)
                            .zIndex(1)
                    }
                }.offset(x: 0, y: 35)
            
            .navigationDestination(for: String.self) { value in
                if value == "spotifyLogin" {
                    SpotifyAuthView()
                } else if value == "yandexLogin" {
                    YandexLoginView()
                }
            }
        }
    }
}

#Preview {
    WelcomeView()
}

