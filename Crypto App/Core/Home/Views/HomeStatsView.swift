//
//  HomeStatsView.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-01-24.
//

import SwiftUI

struct HomeStatsView: View {
    
    @EnvironmentObject var vm: HomeViewModel
    @Binding var showPorfolio: Bool
    
    var body: some View {
        HStack {
            ForEach(vm.statistics) { stat in
                StatisticView(stat: stat)
                    .frame(width: UIScreen.main.bounds.width / 3)
            }
        }
        .frame(width: UIScreen.main.bounds.width, alignment: showPorfolio ? .trailing : .leading)
    }
}

struct HomeStatsView_Previews: PreviewProvider {
    static var previews: some View {
        HomeStatsView(showPorfolio: .constant(false))
            .environmentObject(dev.homeVM)
    }
}
