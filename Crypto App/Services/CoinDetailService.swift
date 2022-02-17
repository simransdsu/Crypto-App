//
//  CoinDataService.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-01-14.
//

import Foundation
import Combine


class CoinDetailService {
    
    @Published var coinDetails: CoinDetailModel? = nil
    
    private var coin: CoinModel
    
    var coinSubscription: AnyCancellable?
    
    init(withCoin coin: CoinModel) {
        self.coin = coin
        getCoinDetails()
    }
    
    func getCoinDetails() {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(coin.id)?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false") else {
            return
        }
        
        coinSubscription = NetworkingManager.download(url: url)
            .decode(type: CoinDetailModel.self, decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] returnedCoin in
                self?.coinDetails = returnedCoin
                self?.coinSubscription?.cancel()
            })
    }
}
