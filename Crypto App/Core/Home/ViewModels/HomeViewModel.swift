//
//  HomeViewModel.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-01-14.
//

import Foundation
import Combine

enum SortOption {
    case rank, rankReverse
    case holdings, holdingsReverse
    case price, priceReverse
}

class HomeViewModel: ObservableObject {
    
    @Published var statistics: [StatisticModel] = []
    @Published var isLoading: Bool = false
    @Published var allCoins: [CoinModel] = []
    @Published var portfolioCoins: [CoinModel] = []
    @Published var searchText: String = ""
    @Published var sortOption: SortOption = .holdings
    
    private let coinDataService = CoinDataService()
    private let marketDataService = MarketDataService()
    private let portfolioDataService = PortfolioDataService()
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    func addSubscribers() {
        
        // Updates all coins from API or from Search Text
        $searchText
            .combineLatest(coinDataService.$allCoins, $sortOption)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterAndSort)
            .sink { [weak self] returnedCoins in
                self?.allCoins = returnedCoins
            }.store(in: &cancellable)
        
        // update portfolioCoins
        $allCoins
            .combineLatest(portfolioDataService.$savedEntities)
            .map (mapAllCoinsToPortfolioCoins)
            .sink { [weak self] returnedCoins in
                guard let self = self else { return }
                self.portfolioCoins = self.sortPortfolioCoinsIfNeeded(coins: returnedCoins)
            }
            .store(in: &cancellable)
            
        // updates marketData
        marketDataService.$marketData
            .combineLatest($portfolioCoins)
            .map(mapGlobalMarketData)
            .sink { [weak self] statisticsModels in
                self?.statistics = statisticsModels
                self?.isLoading = false
            }
            .store(in: &cancellable)
    }
    
    func updatePortfolio(coin:CoinModel, amount: Double) {
        portfolioDataService.updatePortfolio(coin: coin, amount: amount)
    }
    
    func reloadData() {
        isLoading = true
        coinDataService.getCoins()
        marketDataService.getMarketData()
        HapticManager.notification(type: .success)
    }
    
    private func mapAllCoinsToPortfolioCoins(coinModels: [CoinModel], portfolioEntities: [PortfolioEntity]) -> [CoinModel] {
            return coinModels.compactMap { coin -> CoinModel? in
                guard let entity = portfolioEntities.first(where: { $0.coinID == coin.id }) else { return nil }
                return coin.updateHoldings(amount: entity.amount)
            }
    }
    
    private func sortPortfolioCoinsIfNeeded(coins: [CoinModel]) -> [CoinModel] {
        switch sortOption {
        case .holdings:
            return coins.sorted(by: {$0.currentHoldingsValue > $1.currentHoldingsValue})
        case .holdingsReverse:
            return coins.sorted(by: {$0.currentHoldingsValue < $1.currentHoldingsValue})
        default:
            return coins
        }
    }
    
    private func mapGlobalMarketData(marketDataModel: MarketDataModel?, portfolioCoins: [CoinModel]) ->  [StatisticModel] {
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
        
        let previousValue = portfolioCoins
            .map { coin -> Double in
                let currentValue = coin.currentHoldingsValue
                let percentChange = coin.priceChangePercentage24H ?? 0 / 100
                let previousValue = currentValue / (1 + percentChange)
                return previousValue
            }
            .reduce(0, +)
        
        let portfolioValue = portfolioCoins
            .map { coin -> Double in return coin.currentHoldingsValue }
            .reduce(0, +)
        
        let percentageChange = ((portfolioValue - previousValue) / previousValue) / 100
        
        let portfolio = StatisticModel(title: "Portfolio Value",
                                       value: portfolioValue.asCurrencyWith2Decimals(),
                                       percentageChange: percentageChange)
        
        stats.append(contentsOf: [marketCap, volume, bitcoinDominance, portfolio])
        return stats
    }
    
    
    private func filterAndSort(text: String, coins: [CoinModel], sortOption: SortOption) -> [CoinModel] {
        var filteredCoins = filterCoins(text: text, coins: coins)
        filteredCoins = sortCoins(sort: sortOption, coins: filteredCoins)
        return filteredCoins
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
    
    private func sortCoins(sort: SortOption, coins: [CoinModel]) -> [CoinModel] {
        switch sortOption {
        case .rank, .holdings:
            return coins.sorted { $0.rank < $1.rank }
        case .rankReverse, .holdingsReverse:
            return coins.sorted { $0.rank > $1.rank }
        case .price:
            return coins.sorted { $0.currentPrice > $1.currentPrice }
        case .priceReverse:
            return coins.sorted { $0.currentPrice < $1.currentPrice }
        }
    }
}
