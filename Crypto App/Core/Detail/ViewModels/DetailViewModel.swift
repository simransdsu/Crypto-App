//
//  DetailViewModel.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-02-16.
//

import Foundation
import Combine


class DetailViewModel: ObservableObject {
    
    @Published var overviewStatistics: [StatisticModel] = []
    @Published var additionalStatistics: [StatisticModel] = []
    @Published var coin: CoinModel
    @Published var coinDescription: String? = nil
    @Published var websiteURL: String? = nil
    @Published var redditURL: String? = nil
    
    private let coinDetailService: CoinDetailService
    private var cancellable = Set<AnyCancellable>()
    
    init(withCoin coin: CoinModel) {
        self.coin = coin
        self.coinDetailService = CoinDetailService(withCoin: coin)
        self.addSubscribers()
    }
    
    private func addSubscribers() {
        coinDetailService
            .$coinDetails
            .combineLatest($coin)
            .map(mapDataToStatistics)
            .sink { [weak self] returnedArrays in
                self?.overviewStatistics = returnedArrays.overview
                self?.additionalStatistics = returnedArrays.additional
                }.store(in: &cancellable)
        
        coinDetailService
        .$coinDetails
        .sink { [weak self] returnedCoinDetails in
            self?.coinDescription = returnedCoinDetails?.readableDescription
            self?.websiteURL = returnedCoinDetails?.links?.homepage?.first
            self?.redditURL = returnedCoinDetails?.links?.subredditURL
        }.store(in: &cancellable)
    }
    
    private func mapDataToStatistics(coinDetailModel: CoinDetailModel?, coin: CoinModel) -> (overview:  [StatisticModel], additional:  [StatisticModel]) {
        
        return (createOverviewArray(coinModel: coinDetailModel), createAdditionArray(coinDetailModel: coinDetailModel, coin: coin))
    }
    
    func createOverviewArray(coinModel: CoinDetailModel?) -> [StatisticModel] {
        // Overview
        let price = coin.currentPrice.asCurrencyWith6Decimals()
        let priceChange = coin.priceChangePercentage24H
        let priceState = StatisticModel(title: "Current Price", value: price, percentageChange: priceChange)
        
        
        let marketCap = "$" + (coin.marketCap?.formattedWithAbbreviations() ?? "")
        let marketCapPercentChange = coin.marketCapChangePercentage24H
        let marketState = StatisticModel(title: "Market Capitalization", value: marketCap, percentageChange: marketCapPercentChange)
        
        let rank = "\(coin.rank)"
        let rankState = StatisticModel(title: "Rank", value: rank, percentageChange: nil)
        
        let volume = "$" + (coin.totalVolume?.formattedWithAbbreviations() ?? "")
        let volumeState = StatisticModel(title: "Volume", value: volume, percentageChange: nil)
        
        let overviewArray: [StatisticModel] = [priceState, marketState, rankState, volumeState]
        
        return overviewArray
    }
    
    func createAdditionArray(coinDetailModel: CoinDetailModel?, coin: CoinModel) -> [StatisticModel] {
        // Additional
        let high = coin.high24H?.asCurrencyWith6Decimals() ?? "n/a"
        let highState = StatisticModel(title: "24h High", value: high)
        
        let low = coin.low24H?.asCurrencyWith6Decimals() ?? "n/a"
        let lowState = StatisticModel(title: "24h low", value: low)
        
        let priceChange24 = coin.priceChange24H?.asCurrencyWith6Decimals() ?? "n/a"
        let priceChange2 = coin.priceChangePercentage24H
        let priceChangestate = StatisticModel(title: "24h Price Change", value: priceChange24, percentageChange: priceChange2)
        
        let marketCapChange = "$" + (coin.marketCapChange24H?.formattedWithAbbreviations() ?? "")
        let marketCapPercentChange2 = coin.marketCapChangePercentage24H
        let marketCapChangeState = StatisticModel(title: "24h Market Cap Change", value: marketCapChange, percentageChange: marketCapPercentChange2)
        
        let blockTime = coinDetailModel?.blockTimeInMinutes ?? 0
        let blockTimeString = blockTime == 0 ? "n/a" : "\(blockTime)"
        let blockState = StatisticModel(title: "Block Time", value: blockTimeString)
        
        let hasing = coinDetailModel?.hashingAlgorithm ?? "n/a"
        let hashingStat = StatisticModel(title: "Hasing Algorithm", value: hasing)
        
        let additionalArray = [highState, lowState, priceChangestate, marketCapChangeState, blockState, hashingStat]
        return additionalArray
    }
}
