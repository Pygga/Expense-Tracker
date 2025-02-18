//
//  DateFilterView.swift
//  Expense Tracker
//
//  Created by Виктор Евграфов on 05.01.2024.
//

import SwiftUI

struct DateFilterView: View {
    @State var start: Date
    @State var end: Date
    var onSubmit: (Date, Date) -> ()
    var onClose: () -> ()
    var body: some View {
        VStack(spacing: 15){
            DatePicker("Начальная Дата",selection: $start, displayedComponents: [.date])
            
            DatePicker("Конечная Дата",selection: $end, displayedComponents: [.date])
            
            HStack(spacing: 15){
                Button("Закрыть"){
                    onClose()
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 5))
                .tint(.red)
                
                Button("Применить"){
                    onSubmit(start, end)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 5))
                .tint(appTint)
            }
            .padding(.top, 10)
        }
        .padding(15)
        .background(.bar, in: .rect(cornerRadius: 10))
        .padding(.horizontal, 30)
    }
}

