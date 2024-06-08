//
//  ContentView.swift
//  PurchaseModelDemo
//
//  Created by Moksh on 07/06/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var model = ContentViewModel()
    
    var body: some View {
        ZStack{
            VStack {
                Image(systemName: "banknote.fill")
                    .imageScale(.large)
                    .padding(.bottom)
                
                
                Button(action: model.yealryPurchaseAction, label: {
                    Text("Purchase yearly with \(model.yearlyPurchaseID.getPriceString())")
                })
                
                
                Button(action: model.weeklyPurchaseAction, label: {
                    Text("Purchase weekly with \(model.weeklyPurchaseID.getPriceString())")
                })
                
                Button(action: model.restorePurchase, label: {
                    Text("Restore purchase")
                })
                .padding(.top)
                
                
               
            }
            .buttonStyle(.bordered)
            .padding()
            
            if model.isLoading {
                ZStack{
                    ProgressView()
                }
                .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 0, idealHeight: 100, maxHeight: .infinity, alignment: .center)
                .background(.ultraThinMaterial)
            }
        }
        .ignoresSafeArea()
        .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 0, idealHeight: 100, maxHeight: .infinity, alignment: .center)
       
    }
}

#Preview {
    ContentView()
}
