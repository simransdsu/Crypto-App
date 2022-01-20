//
//  CoinImageService.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-01-18.
//

import Foundation
import UIKit
import Combine


class CoinImageService {
    
    @Published var image: UIImage? = nil
    
    private var imageSubscription: AnyCancellable?
    private var coin: CoinModel
    private let fileManager = LocalFileManager.instance
    private let FOLDER_NAME = "CoinImages"
    
    init(coin: CoinModel) {
        self.coin = coin
        downloadCoinImage()
    }
    
    private func getCoinImage() {
        if let savedImage = fileManager.getImage(imageName: coin.id, folderName: FOLDER_NAME) {
            image = savedImage
        } else {
            downloadCoinImage()
        }
    }
    
    private func downloadCoinImage() {
        
        guard let url = URL(string: coin.image) else {
            return
        }
        
        
        imageSubscription = NetworkingManager.download(url: url)
            .tryMap({ data -> UIImage? in
                return UIImage(data: data)
            })
            .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] returnedImage in
                
                guard
                    let self = self,
                    let saveReturnedImage = returnedImage
                else { return }
                
                self.image = returnedImage
                self.imageSubscription?.cancel()
                self.fileManager.saveImage(image: saveReturnedImage, imageName: self.coin.id, folderName: self.FOLDER_NAME)
            })
    }
}
