//
//  Search.swift
//  Expense Tracker
//
//  Created by Виктор Евграфов on 04.01.2024.
//

import SwiftUI
import Combine

struct Search: View {
    //View Properties
    @State private var searchText: String = ""
    @State private var filterText: String = ""
    @State private var selectedCategory: Category? = nil
    let searchPublisher = PassthroughSubject<String, Never>()
    var body: some View {
        NavigationStack{
            ScrollView(.vertical){
                LazyVStack(spacing: 12){
                    FilterTransactionsView(category: selectedCategory, searchText: filterText){ transactions in
                        ForEach(transactions) { transaction in
                            NavigationLink{
                                TransactionView(editTransaction: transaction)
                            } label: {
                                TransactionCardView(transaction: transaction, showsCategory: true)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(15)
            }
            .overlay(content:{
                ContentUnavailableView("Поиск операций", systemImage: "magnifyingglass")
                    .opacity(filterText.isEmpty ? 1 : 0)
            })
            .onChange(of: searchText, { oldValue, newValue in
                if newValue.isEmpty{
                    filterText = ""
                }
                searchPublisher.send(newValue)
            })
            .onReceive(searchPublisher.debounce(for: .seconds(0.3), scheduler: DispatchQueue.main), perform: { text in
                filterText = text
            })
            .searchable(text: $searchText)
            .navigationTitle("Поиск")
            .background(.gray.opacity(0.15))
            .toolbar{
                ToolbarItem(placement: .topBarTrailing){
                    ToolBarContent()
                }
            }
        }
    }
    
    @ViewBuilder
    func ToolBarContent() -> some View{
        Menu {
            Button{
                selectedCategory = nil
            } label: {
                HStack{
                    Text("Все")
                    
                    if selectedCategory == nil{
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            ForEach(Category.allCases, id: \.rawValue){ category in
                Button{
                    selectedCategory = category
                } label: {
                    HStack{
                        Text(category.rawValue)
                        
                        if selectedCategory == category{
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "slider.vertical.3")
        }
    }
}

#Preview {
    Search()
}
