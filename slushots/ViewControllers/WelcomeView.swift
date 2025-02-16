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
    @StateObject private var viewModel = YandexLoginViewModel()
    @StateObject private var motionManager = ParallaxMotionManager()
    @State private var animateGradient = false
    @State private var shouldNavigate = false
    
    var body: some View {
        ZStack {
            Color.init(hex: "F5F5F5").ignoresSafeArea()
            VStack {
                ZStack {
                    Image("spotyCat")
                        .resizable()
                        .frame(width: 140, height: 140)
                        .offset(x: -57, y: -224)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .frame(maxWidth: .infinity, maxHeight: 330)
                            .foregroundStyle(Color(hex: "5C7285"))
                        
                        VStack {
                            Text("Proslushots")
                                .font(.title)
                                .bold()
                                .foregroundStyle(Color.init(hex: "FFF2F2"))
                            Text("Your personal assistant for discovering music videos of your favorite songs! Simply import playlist and explore videos that might become your new favorites!")
                                .font(.title3)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Color.init(hex: "FFF2F2"))
                                .padding(.horizontal, 20)
                            
                            Button(action: {}) {
                                HStack (spacing: 10) {
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
                                .foregroundColor(.secondary)
                                .background(.white)
                                .cornerRadius(16)
                            }.padding(.horizontal, 20)
                                .padding(.top, 10)
                                Button(action: {}) {
                                    HStack (spacing: 10) {
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
                                        .foregroundColor(.secondary)
                                        .background(.white)
                                        .cornerRadius(16)
                                
                            }.padding(.horizontal, 20)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Image("yaDog")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .offset(x: 57, y: -230)
                        .zIndex(1)
                }
            }.offset(x: 0, y: 35)
        }
    }
}


#Preview {
    WelcomeView()
}

