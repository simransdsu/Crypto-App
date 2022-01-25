//
//  HomeViewModel.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-01-14.
//

import Foundation
import Combine


class HomeViewModel: ObservableObject {
    
    @Published var statistics: [StatisticModel] = [
        StatisticModel(title: "Market Cap", value: "$12.5Bn", percentageChange: 25.34),
        StatisticModel(title: "Total Volume", value: "$1.23Tr"),
        StatisticModel(title: "Portfolio Value", value: "$50.4k", percentageChange: -12.34),
        StatisticModel(title: "Market Cap", value: "$12.5Bn", percentageChange: 25.34),
    ]
    
    @Published var allCoins: [CoinModel] = []
    @Published var portfolioCoins: [CoinModel] = []
    @Published var searchText: String = ""
    
    private let dataService = CoinDataService()
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    func addSubscribers() {
        
        // Updates all coins from API or from Search Text
        $searchText
            .combineLatest(dataService.$allCoins)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterCoins)
            .sink { [weak self] returnedCoins in
                self?.allCoins = returnedCoins
            }.store(in: &cancellable)
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
