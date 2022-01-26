//
//  HomeViewModel.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-01-14.
//

import Foundation
import Combine


class HomeViewModel: ObservableObject {
    
    @Published var statistics: [StatisticModel] = []
    
    @Published var allCoins: [CoinModel] = []
    @Published var portfolioCoins: [CoinModel] = []
    @Published var searchText: String = ""
    
    private let coinDataService = CoinDataService()
    private let marketDataService = MarketDataService()
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    func addSubscribers() {
        
        // Updates all coins from API or from Search Text
        $searchText
            .combineLatest(coinDataService.$allCoins)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterCoins)
            .sink { [weak self] returnedCoins in
                self?.allCoins = returnedCoins
            }.store(in: &cancellable)
        
        marketDataService.$marketData
            .map(mapGlobalMarketData)
            .sink { [weak self] statisticsModels in
                self?.statistics = statisticsModels
            }
            .store(in: &cancellable)
    }
    
    private func mapGlobalMarketData(marketDataModel: MarketDataModel?) ->  [StatisticModel] {
        var stats = [StatisticModel]()
        
        guard let data = marketDataModel else {
            return stats
        }
        
        let marketCap = StatisticModel(title: "Market Cap",
                                       value: data.marketCap,
                                       percentageChange: data.marketCapChangePercentage24HUsd)
        let volume = StatisticModel(title: "24h Valume",
                                       value: data.volume)
        let bitcoinDominance = StatisticModel(title: "BTC Dominance",
                                       value: data.btcDominance)
        let portfolioValue = StatisticModel(title: "Portfolio Value",
                                       value: "$0.00",
                                       percentageChange: 0)
        
        stats.append(contentsOf: [marketCap, volume, bitcoinDominance, portfolioValue])
        return stats
    }
    
    private func filterCoins(text: String, coins: [CoinModel]) -> [CoinModel] {
        guard !text.isEmpty else {
            return coins
        }
        
        let lowerdcasedText = text.lowercased()
        
        let filteredCoins = coins.filter { coin in
            return coin.name.lowercased().contains(lowerdcasedText) ||
            coin.symbol.lowercased().contains(lowerdcasedText) ||
            coin.id.lowercased().contains(lowerdcasedText)
        }
        
        return filteredCoins
    }
}
