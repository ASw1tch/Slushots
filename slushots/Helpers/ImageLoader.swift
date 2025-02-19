//
//  ImageLoader.swift
//  slushots
//
//  Created by Anatoliy Petrov on 1.2.25..
//


import SwiftUI
import Combine

class ImageLoader: ObservableObject {
    @Published var uiImage: UIImage?
    private var cancellable: AnyCancellable?
    
    init(url: URL?) {
        guard let url = url else { return }
        
        if let cachedData = CacheManager.getSongCache(url.absoluteString),
           let cachedImage = UIImage(data: cachedData) {
            self.uiImage = cachedImage
        } else {
            cancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { data in
                        if let image = UIImage(data: data) {
                            self.uiImage = image
                            CacheManager.setSongCache(url.absoluteString, data)
                        }
                    }
                )
        }
    }
}
