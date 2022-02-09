//
//  MarketDataService.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-01-26.
//

import Foundation
import Combine

class MarketDataService {
    @Published var marketData: MarketDataModel? = nil
    
    var marketDataSubscription: AnyCancellable?
    
    init() {
        getMarketData()
    }
    
    func getMarketData() {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/global") else {
            return
        }
        
        marketDataSubscription = NetworkingManager.download(url: url)
            .decode(type: GlobalData.self, decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] returnedMarketData in
                self?.marketData = returnedMarketData.data
                self?.marketDataSubscription?.cancel()
            })
    }
}
