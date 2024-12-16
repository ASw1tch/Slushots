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
            AsyncImage(url: imageUrl) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                } else {
                    Text(emojiFull[Int.random(in: 0..<emojiFull.count)])
                        .font(.largeTitle)
                        .frame(width: 50, height: 50)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        //.padding()
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

struct PlaylistCellView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistCellView(
            song: "HOPE",
            artist: "NF",
            imageUrl: URL(string: "https://example.com/image.jpg")
        )
    }
}
