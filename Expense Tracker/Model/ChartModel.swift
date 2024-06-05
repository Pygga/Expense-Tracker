//
//  ChartModel.swift
//  Expense Tracker
//
//  Created by Виктор Евграфов on 04.04.2024.
//

import SwiftUI

struct ChartGroup: Identifiable { //This model is used to represent a graph that will show each month's total transactions based on categories.
    let id: UUID = .init()
    var date: Date
    var categories: [ChartCategories]
    var totalExpense: Double
    var totalIncome: Double
}

struct ChartCategories: Identifiable{
    let id: UUID = .init()
    var totalValue: Double
    var category: Category
}
