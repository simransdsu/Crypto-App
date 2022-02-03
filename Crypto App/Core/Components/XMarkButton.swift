//
//  XMarkButton.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-01-26.
//

import SwiftUI

struct XMarkButton: View {
    
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            Image(systemName: "xmark")
                .font(.headline)
        })
    }
}

struct XMarkButton_Previews: PreviewProvider {
    static var previews: some View {
        XMarkButton(action: {
            
        })
    }
}
