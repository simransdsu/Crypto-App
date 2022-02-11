//
//  HomeView.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-01-10.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject private var vm: HomeViewModel
    @State private var showPortfolio: Bool = false // animate right
    @State private var showPorfolioView: Bool = false // new sheet
    
    @State private var selectedCoin: CoinModel? = nil
    @State private var showDetailView: Bool = false
    
    var body: some View {
        ZStack {
            // background layer
            Color.theme.background.ignoresSafeArea()
                .sheet(isPresented: $showPorfolioView) {
                    PortfolioView()
                        .environmentObject(vm)
                }
            
            // content layer
            VStack {
                homeHeader
                HomeStatsView(showPorfolio: $showPortfolio)
                SearchBarView(searchText: $vm.searchText)
                columnTitles
                
                if showPortfolio {
                    porfolioCoinsList.transition(.move(edge: .trailing))
                }
                else {
                    allCoinsList.transition(.move(edge: .leading))
                }
                
                Spacer(minLength: 0)
            }
        }
        .background(
            NavigationLink(isActive: $showDetailView, destination: {
                DetailView(coin: $selectedCoin)
            }, label: {
                EmptyView()
            })
        )
    }
}


// MARK: - UI Views
extension HomeView {
    
    private var homeHeader: some View {
        HStack {
            CircleButtonView(iconName: showPortfolio ? "plus" : "info")
                .animation(.none, value: 0)
                .onTapGesture {
                    if showPortfolio {
                        showPorfolioView.toggle()
                    }
                }
                .background(CircleButtonAnimationView(animate: $showPortfolio))
            Spacer()
            Text(showPortfolio ? "Portfoli0" : "Live Prices")
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundColor(Color.theme.accent)
                .animation(.none, value: 0)
            Spacer()
            CircleButtonView(iconName: "chevron.right")
                .rotationEffect(Angle(degrees: showPortfolio ? 180 : 0))
                .onTapGesture {
                    withAnimation(.spring()) {
                        showPortfolio.toggle()
                    }
                }
        }.padding(.horizontal)
    }
    
    
    private var allCoinsList: some View {
        List {
            ForEach(vm.allCoins) { coin in
                CoinRowView(coin: coin, showHoldingsColumn: false)
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
                    .onTapGesture {
                        segue(coin: coin)
                    }
            }
        }.listStyle(.plain)
    }
    
    private var porfolioCoinsList: some View {
        List {
            ForEach(vm.portfolioCoins) { coin in
                CoinRowView(coin: coin, showHoldingsColumn: true)
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
                    .onTapGesture {
                        segue(coin: coin)
                    }
            }
        }.listStyle(.plain)
    }
    
    private func segue(coin: CoinModel) {
        selectedCoin = coin
        showDetailView.toggle()
    }
    
    private var columnTitles: some View {
        HStack {
            HStack {
                Text("Coin")
                Image(systemName: "chevron.down")
                    .opacity( (vm.sortOption == .rank || vm.sortOption == .rankReverse) ? 1 : 0)
                    .rotationEffect(Angle(degrees: vm.sortOption == .rank ? 0 : 180))
            }
            .onTapGesture {
                vm.sortOption = vm.sortOption == .rank ? SortOption.rankReverse : SortOption.rank
            }
            
            Spacer()
            
            if showPortfolio {
                HStack {
                    Text("Holdings")
                    Image(systemName: "chevron.down")
                        .opacity( (vm.sortOption == .holdings || vm.sortOption == .holdingsReverse) ? 1 : 0)
                        .rotationEffect(Angle(degrees: vm.sortOption == .holdings ? 0 : 180))
                }
                .onTapGesture {
                    vm.sortOption = vm.sortOption == .holdings ? SortOption.holdingsReverse : SortOption.holdings
                }
            }
            
            HStack {
                Text("Price")
                    .frame(width: UIScreen.main.bounds.width/3, alignment: .trailing)
                Image(systemName: "chevron.down")
                    .opacity( (vm.sortOption == .price || vm.sortOption == .priceReverse) ? 1 : 0)
                    .rotationEffect(Angle(degrees: vm.sortOption == .price ? 0 : 180))
            }
            .onTapGesture {
                vm.sortOption = vm.sortOption == .price ? SortOption.priceReverse : SortOption.price
            }
            
            
            Button {
                withAnimation(.linear(duration: 2)) {
                    vm.reloadData()
                }
            } label: {
                Image(systemName: "goforward")
            }.rotationEffect(Angle(degrees: vm.isLoading ? 360 : 0), anchor: .center)

        }.font(.caption)
            .foregroundColor(Color.theme.secondaryText)
            .padding(.horizontal)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
                .navigationBarHidden(true)
        }.environmentObject(dev.homeVM)
    }
}
