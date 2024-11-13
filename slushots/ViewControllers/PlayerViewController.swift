//
//  PlayerViewController.swift
//  slushots
//
//  Created by Anatoliy Switch on 02.09.2022.
//

import UIKit
import WebKit
import AVKit


class PlayerViewController: UIViewController {
    
    @IBOutlet private weak var artistLabel: UILabel?
    @IBOutlet private weak var songLabel: UILabel?
    @IBOutlet private weak var webView: WKWebView!
    
    var songPassed: String = ""
    var artistPassed: String = ""
    let indexPath = IndexPath()
    
    var video: YTResponse?

    func prepareRequest(songTitle: String, artistName: String) -> String {
        // Объединяем название песни и имя исполнителя
        let query = "\(songTitle) \(artistName)"
        
        // Кодируем строку для URL-запроса
        if let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return encodedQuery
        } else {
            print("Ошибка кодирования строки")
            return query
        }
    }
    
    func prepareVideo() {
        
        let songString = prepareRequest(songTitle: songPassed, artistName: artistPassed)
        
        YTApiCaller.shared.getVideoFromCell(songTitle: songString) { [weak self] result in
            guard let self = self else {
                print("Контроллер деинициализирован")
                return
            }
            
            switch result {
            case .success(let response):
                self.fetchVideo(response: response)
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Ошибка API: \(error)")
                    self.showPlaceholder()
                }
            }
        }
    }
    
    func fetchVideo(response: YTResponse) {
        DispatchQueue.main.async {
            // Проверка: если массив пустой, показываем заглушку
            guard !response.items.isEmpty else {
                print("Видео не найдено. Массив пустой.")
                self.showPlaceholder()
                return
            }
            
            // Проверка индекса
            guard let videoId = response.items.first?.id.videoId,
                  let videoTitle = response.items.first?.snippet.title else {
                print("Индекс выходит за пределы массива")
                self.showPlaceholder()
                return
            }
            
            // Установка данных в UI
            let embedUrlString = K.ytEmbedUrl + videoId
            self.artistLabel?.text = videoTitle
            print("Embed URL: \(embedUrlString)")
            
            // Загрузка видео в webView
            if let url = URL(string: embedUrlString) {
                let request = URLRequest(url: url)
                if self.webView != nil {
                    self.webView.load(request)
                } else {
                    print("WKWebView не существует")
                }
            } else {
                print("Невалидный URL для загрузки видео")
                self.showPlaceholder()
            }
        }
    }
    
    @objc private func exitFullScreen() {
        if let avPlayerController = presentedViewController as? AVPlayerViewController {
            avPlayerController.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        exitFullScreen()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard video != nil else {
            print("There is no video")
            return
        }
        songLabel?.text = songPassed
        artistLabel?.text = artistPassed
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.stopLoading()
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
    }
    
    func showPlaceholder() {
        artistLabel?.text = "Видео не найдено"
        songLabel?.text = "Попробуйте другой запрос"
        
        // Показать пустую страницу или заглушку
        let html = """
    <html>
    <body>
    <h2 style="text-align:center;">Видео не найдено</h2>
    <p style="text-align:center;">Попробуйте другой запрос</p>
    </body>
    </html>
    """
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    func setTitle(song: String, artist: String) {
        print(song, artist)
        self.songPassed = song
        self.artistPassed = artist
    }
}
