//
//  PlaylistCellView.swift
//  slushots
//
//  Created by Anatoliy Petrov on 16.12.24..
//
import SwiftUI

struct PlaylistCellView: View {
    
    let song: String
    let artist: String
    let imageUrl: URL?
    
    private let fallbackEmoji: String
    
    @State private var triedCoverLoad = false
    @State private var isImageLoaded = false
    @State private var timedOut = false
    
    private let emojiFull = EmojiFile.emojis
    
    init(song: String, artist: String, imageUrl: URL?) {
        self.song = song
        self.artist = artist
        self.imageUrl = imageUrl
        self.fallbackEmoji = emojiFull.randomElement() ?? "🎵"
    }
    
    var body: some View {
        HStack {
            AsyncImage(url: imageUrl) { phase in
                switch phase {
                case .empty:
                    if !timedOut {
                        ProgressView()
                            .frame(width: 50, height: 50)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    if !isImageLoaded {
                                        timedOut = true
                                    }
                                }
                            }
                    } else {
                        fallbackView
                    }
                    
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                        .onAppear {
                            isImageLoaded = true
                            timedOut = false
                        }
                case .failure:
                    fallbackView
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 50, height: 50)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            
            VStack(alignment: .leading) {
                Text(song)
                    .font(.headline)
                Text(artist)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    private var fallbackView: some View {
        Text(fallbackEmoji)
            .font(.largeTitle)
            .frame(width: 50, height: 50)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
    }
}

extension Image {
    func asUIImage() -> UIImage? {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = CGSize(width: 400, height: 400)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

struct PlaylistCellView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistCellView(
            song: "HOPE",
            artist: "NF",
            imageUrl: URL(string: "https://example.com/image.jpg")
        )
    }
}
