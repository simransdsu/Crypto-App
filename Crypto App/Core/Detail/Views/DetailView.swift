//
//  DetailView.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-02-11.
//

import SwiftUI

struct DetailLoadingView: View {
    
    @Binding var coin: CoinModel?
    
    var body: some View {
        ZStack {
            if let coin = coin {
                DetailView(coin: coin)
            }
        }
    }
}

struct DetailView: View {
    
    @StateObject var vm: DetailViewModel
    @State private var showFullDescription = false
    
    let coin: CoinModel
    
    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    private let spacing: CGFloat = 30
    
    init(coin: CoinModel) {
        self.coin = coin
        self._vm = StateObject(wrappedValue: DetailViewModel(withCoin: coin))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("")
                    .frame(height: 150)
                
                // Overview
                overviewTitle
                Divider()
                
                expandableDescription
                
                overviewGrid
                
                // Additional
                additionTitle
                Divider()
                additionalGrid
                
                websiteSection
                
            }.padding()
        }.navigationTitle(coin.name)
    }
}

extension DetailView {
    private var overviewTitle: some View {
        Text("Overview")
            .font(.title)
            .bold()
            .foregroundColor(Color.theme.accent)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var expandableDescription: some View {
        ZStack {
            if let coinDescription = vm.coinDescription,
               !coinDescription.isEmpty {
                VStack(alignment: .leading) {
                    Text(coinDescription)
                        .lineLimit(showFullDescription ? nil : 3)
                        .font(.callout)
                        .foregroundColor(Color.theme.secondaryText)
                    
                    Button {
                        withAnimation {
                            showFullDescription.toggle()
                        }
                    } label: {
                        Text(showFullDescription ? "less" : "Read more...")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.vertical, 4)
                    }.tint(.blue)

                }.frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var overviewGrid: some View {
        LazyVGrid(columns: columns,
                  alignment: .leading,
                  spacing: spacing,
                  pinnedViews: []) {
            ForEach(vm.overviewStatistics) { stat in
                StatisticView(stat: stat)
            }
        }
    }
    
    private var additionTitle: some View {
        Text("Additional Details")
            .font(.title)
            .bold()
            .foregroundColor(Color.theme.accent)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var additionalGrid: some View {
        LazyVGrid(columns: columns,
                  alignment: .leading,
                  spacing: spacing,
                  pinnedViews: []) {
            ForEach(vm.additionalStatistics) { stat in
                StatisticView(stat: stat)
            }
        }
    }
    
    private var websiteSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let websiteString = vm.websiteURL,
               let url = URL(string: websiteString) {
                Link("Website", destination: url)
            }
            
            if let redditString = vm.redditURL,
               let url = URL(string: redditString) {
                Link("Reddit", destination: url)
            }
        }.tint(.blue)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.headline)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailView(coin: dev.coin)
        }
    }
}
