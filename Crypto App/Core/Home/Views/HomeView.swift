//
//  HomeView.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-01-10.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject private var vm: HomeViewModel
    @State private var showPortfolio: Bool = false
    
    var body: some View {
        ZStack {
            // background layer
            Color.theme.background.ignoresSafeArea()
            
            // content layer
            VStack {
                homeHeader
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
    }
}


// MARK: - UI Views
extension HomeView {
    
    private var homeHeader: some View {
        HStack {
            CircleButtonView(iconName: showPortfolio ? "plus" : "info")
                .animation(.none, value: 0)
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
            }
        }.listStyle(.plain)
    }
    
    private var porfolioCoinsList: some View {
        List {
            ForEach(vm.portfolioCoins) { coin in
                CoinRowView(coin: coin, showHoldingsColumn: true)
            }
        }.listStyle(.plain)
    }
    
    private var columnTitles: some View {
        HStack {
            Text("Coin")
            Spacer()
            
            if showPortfolio { Text("Holdings") }
            
            Text("Price")
                .frame(width: UIScreen.main.bounds.width/3, alignment: .trailing)
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
