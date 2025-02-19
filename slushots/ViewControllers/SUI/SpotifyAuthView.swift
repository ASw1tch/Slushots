import SwiftUI
import WebKit

struct SpotifyAuthView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            AuthWebView { success in
                if success {
                    coordinator.currentView = .mediaListSpotify(owner: "", spotify: SpotifySongResponse(href: "",items: []))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dismiss()
                    }
                }
            }
            .ignoresSafeArea()
            
            Button(action: {
                dismiss()
            }) {
                Text("Cancel")
                    .foregroundColor(.black)
                    .padding(8)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(8)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct AuthWebView: UIViewRepresentable {
    var onAuthComplete: (Bool) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, onAuthComplete: onAuthComplete)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        
        if let url = SPTFAuthManager.shared.signInURL {
            webView.load(URLRequest(url: url))
        } else {
            print("There is no Sign in URL")
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: AuthWebView
        var onAuthComplete: (Bool) -> Void
        
        init(_ parent: AuthWebView, onAuthComplete: @escaping (Bool) -> Void) {
            self.parent = parent
            self.onAuthComplete = onAuthComplete
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            guard let url = webView.url else {
                print("There is no WebView URL")
                return
            }
            if let code = URLComponents(string: url.absoluteString)?
                .queryItems?
                .first(where: { $0.name == "code" })?
                .value {
                
                webView.isHidden = true
                
                SPTFAuthManager.shared.exchangeCodeForToken(code: code) { [weak self] success in
                    DispatchQueue.main.async {
                        self?.onAuthComplete(success)
                    }
                }
            }
        }
    }
}

#Preview {
    SpotifyAuthView()
}
