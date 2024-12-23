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
    
    let emojiFull = EmojiFile.emojis
    
    var body: some View {
        HStack {
            if let cachedData = CacheManager.getSongCache(imageUrl?.absoluteString ?? ""),
               let uiImage = UIImage(data: cachedData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
            } else {
                AsyncImage(url: imageUrl) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)
                            .onAppear {
                                if let data = image.asUIImage()?.jpegData(compressionQuality: 0.1),
                                   let url = imageUrl?.absoluteString {
                                    CacheManager.setSongCache(url, data)
                                }
                            }
                    } else if phase.error != nil {
                        Text("❌")
                            .frame(width: 50, height: 50)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    } else {
                        Text(emojiFull[Int.random(in: 0..<emojiFull.count)])
                            .font(.largeTitle)
                            .frame(width: 50, height: 50)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
            
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
