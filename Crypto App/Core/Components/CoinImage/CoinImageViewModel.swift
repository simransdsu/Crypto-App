//
//  CoinImageViewModel.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-01-18.
//

import Foundation
import SwiftUI
import Combine

class CoinImageViewModel: ObservableObject {
    
    @Published var image: UIImage?
    @Published var isLoading: Bool = false
    
    
    private let coin: CoinModel
    private let dataService: CoinImageService
    private var cancellable = Set<AnyCancellable>()
    
    init(coin: CoinModel) {
        self.coin = coin
        self.dataService = CoinImageService(coin: coin)
        
        addSubscribers()
    }
    
    private func addSubscribers() {
        self.isLoading = true
        dataService
            .$image
            .sink(receiveCompletion: { _ in
                self.isLoading = false
            }, receiveValue: {  [weak self] image in
                self?.image = image
            })
            .store(in: &cancellable)
    }
}
