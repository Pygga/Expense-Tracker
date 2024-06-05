//
//  View+Extensions.swift
//  Expense Tracker
//
//  Created by Виктор Евграфов on 04.01.2024.
//

import SwiftUI

extension View{
    @ViewBuilder
    func hSpacing(_ aligment: Alignment = .center) -> some View{
        self
        .frame(maxWidth: .infinity,alignment: aligment)
    }
    
    @ViewBuilder
    func vSpacing(_ aligment: Alignment = .center) -> some View{
        self
        .frame(maxHeight: .infinity,alignment: aligment)
    }
    @available(iOSApplicationExtension, unavailable)
    var safeArea: UIEdgeInsets {
        if let windowScene = (UIApplication.shared.connectedScenes.first as? UIWindowScene){
            return windowScene.keyWindow?.safeAreaInsets ?? .zero
        }
        return .zero
    }
    
    func format(date: Date, format: String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    func currencyString(_ value: Double, allowedDigits: Int = 2) -> String{
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = allowedDigits
        
        return formatter.string(from: .init(value: value)) ?? ""
    }
    
    var currencySymbol: String {
        let local = Locale.current
        
        return local.currencySymbol ?? ""
    }
    
    func total(_ transactions: [Transaction], category: Category) -> Double {
        return transactions.filter({$0.category == category.rawValue}).reduce(Double.zero){ partialResult, transaction in
            return partialResult + transaction.amount
        }
    }
}
