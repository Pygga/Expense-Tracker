//
//  Settings.swift
//  Expense Tracker
//
//  Created by Виктор Евграфов on 04.01.2024.
//

import SwiftUI

struct Settings: View {
    //View Properties
    @State private var changeTheme: Bool = false
    @Environment(\.colorScheme) private var scheme
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    //User Properties
    @AppStorage("userName") private var userName: String = ""
    // App Lock Properties
    @AppStorage("isAppLockEnabled") private var isAppLockEnabled: Bool = false
    @AppStorage("lockWhenAppGoesBackground") private var lockWhenAppGoesBackground: Bool = false
    var body: some View {
        NavigationStack{
            List{
                Section("Имя Пользователя"){
                    TextField("Ваше Имя", text: $userName)
                }
                
                Section("Блокировка"){
                    Toggle("Включить блокировку приложения", isOn: $isAppLockEnabled)
                    
                    if isAppLockEnabled {
                        Toggle("Блокировка, когда приложение переходит в фоновый режим", isOn: $lockWhenAppGoesBackground)
                    }
                }
                
                Section("Внешний вид"){
                    Button("Сменить тему"){
                        changeTheme.toggle()
                    }
                }
                
            }
            .navigationTitle("Настройки")
        }
        .preferredColorScheme(userTheme.colorScheme)
        .sheet(isPresented: $changeTheme, content: {
            ThemeChangeView(scheme: scheme)
                .presentationDetents([.height(410)])
                .presentationBackground(.clear)
        })
    }
}

#Preview {
    ContentView()
}
