//
//  PlayerViewController.swift
//  slushots
//
//  Created by Anatoliy Switch on 02.09.2022.
//

import UIKit
import SwiftUI
import WebKit
import ImageIO

struct PlayerView: View {
    @StateObject var viewModel = PlayerViewModel()
    @State private var artistName: String = ""
    @State private var songTitle: String = ""
    @State private var embedUrl: URL? = nil
    @State private var showPlaceholder: Bool = false
    @State private var isLoading: Bool = true
    @State private var fadeOut: Bool = false
    
    let songPassed: String
    let artistPassed: String
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                if isLoading {
                    ZStack(alignment: .center)  {
                        WhiteNoiseView(gifName: "static-glitch2")
                        
                        PlayerController(isLoading: $isLoading, songName: songTitle, artistName: artistName)
                    }.opacity(fadeOut ? 0 : 1)
                        .animation(
                            Animation.timingCurve(0.25, 0.1, 0.25, 1.0, duration: 1),
                            value: fadeOut
                        )
                        .edgesIgnoringSafeArea(.all)
                } else {
                    VStack {
                        Text(artistName)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(songTitle)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    
                    if showPlaceholder {
                        placeholderView
                    } else {
                        webView
#if DEBUG
                        PlayerController(isLoading: $isLoading, songName: songTitle, artistName: artistName)
#endif
                    }
                }
            }.navigationBarTitle("", displayMode: .inline)
        }
        .onAppear {
            prepareVideo()
        }
    }
    
    private var webView: some View {
        WebView(url: $embedUrl, isLoading: $isLoading, fadeOut: $fadeOut)
            .frame(maxWidth: .infinity, maxHeight: 400)
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding()
    }
    
    private var placeholderView: some View {
        VStack {
            Text("Something went wrong")
                .font(.headline)
                .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: 500)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding()
    }
    
    private func prepareRequest(songTitle: String, artistName: String) -> String {
        let query = "\(songTitle) \(artistName)"
        return query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
    }
    
    private func prepareVideo() {
        isLoading = true
        let songString = prepareRequest(songTitle: songPassed, artistName: artistPassed)
        
        YTApiCaller.shared.getVideoFromCell(songTitle: songString) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    fetchVideo(response: response)
                case .failure(let error):
                    print("Ошибка API: \(error)")
                    showPlaceholder = true
                    DispatchQueue.main.async {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            fadeOut = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isLoading = false
                        }
                    }
                }
            }
        }
    }
    
    private func fetchVideo(response: YTResponse) {
        guard let firstItem = response.items.first else {
            showPlaceholder = true
            DispatchQueue.main.async {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.fadeOut = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.isLoading = false
                }
            }
            return
        }
        
        let videoId = firstItem.id.videoId
        _ = firstItem.snippet.title
        
        artistName = artistPassed
        songTitle = songPassed
        embedUrl = URL(string: K.ytEmbedUrl + videoId)
        DispatchQueue.main.async {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.fadeOut = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.isLoading = false
            }
        }
    }
}

struct WhiteNoiseView: UIViewRepresentable {
    let gifName: String
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        if let gifPath = Bundle.main.path(forResource: gifName, ofType: "gif"),
           let gifData = try? Data(contentsOf: URL(fileURLWithPath: gifPath)) {
            imageView.image = UIImage.gif(data: gifData)
        }
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}
struct WebView: UIViewRepresentable {
    @Binding var url: URL?
    @Binding var isLoading: Bool
    @Binding var fadeOut: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url = url else {
            webView.loadHTMLString("<html><body><h2 style='text-align:center;'>Видео не найдено</h2></body></html>", baseURL: nil)
            DispatchQueue.main.async {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.fadeOut = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.isLoading = false
                }
            }
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading, fadeOut: $fadeOut)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var isLoading: Bool
        @Binding var fadeOut: Bool
        
        init(isLoading: Binding<Bool>, fadeOut: Binding<Bool>) {
            _isLoading = isLoading
            _fadeOut = fadeOut
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard webView.isLoading == false else { return }
            DispatchQueue.main.async {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.fadeOut = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.isLoading = false
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("WebView failed to load: \(error.localizedDescription)")
            guard webView.isLoading == false else { return }
            DispatchQueue.main.async {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.fadeOut = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.isLoading = false
                }
            }
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(songPassed: "NF", artistPassed: "HOPE")
    }
}

extension UIImage {
    static func gif(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("Не удалось создать источник для GIF")
            return nil
        }
        
        var images: [UIImage] = []
        var duration: Double = 0
        
        let count = CGImageSourceGetCount(source)
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: cgImage))
                
                let delaySeconds = UIImage.delayForImage(at: i, source: source)
                duration += delaySeconds
            }
        }
        
        return UIImage.animatedImage(with: images, duration: duration)
    }
    
    private static func delayForImage(at index: Int, source: CGImageSource) -> Double {
        let defaultFrameDelay = 0.1
        
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
              let gifInfo = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any],
              let delay = gifInfo[kCGImagePropertyGIFUnclampedDelayTime] as? Double ?? gifInfo[kCGImagePropertyGIFDelayTime] as? Double else {
            return defaultFrameDelay
        }
        
        return delay > 0 ? delay : defaultFrameDelay
    }
}
