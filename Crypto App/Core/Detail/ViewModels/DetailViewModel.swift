//
//  DetailViewModel.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-02-16.
//

import Foundation
import Combine


class DetailViewModel: ObservableObject {
    
    private let coinDetailService: CoinDetailService
    private var cancellable = Set<AnyCancellable>()
    
    init(withCoin coin: CoinModel) {
        self.coinDetailService = CoinDetailService(withCoin: coin)
        self.addSubscribers()
    }
    
    private func addSubscribers() {
        coinDetailService
            .$coinDetails
            .sink { returnedCoinDetails in
                print("RECEIVED COIN DETAIL DATA")
                print(returnedCoinDetails)
            }.store(in: &cancellable)
    }
}
