//
//  ThemeChangeView.swift
//  Expense Tracker
//
//  Created by Виктор Евграфов on 25.04.2024.
//

import SwiftUI

struct ThemeChangeView: View {
    var scheme: ColorScheme
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    //For Sliding Effect
    @Namespace private var animation
    //View Properties
    @State private var circleOffet: CGSize
    init(scheme: ColorScheme) {
        self.scheme = scheme
        let isDark = scheme == .dark
        self._circleOffet = .init(initialValue: CGSize(width: isDark ? 30 : 150, height: isDark ? -25 : -150))
    }
    var body: some View {
        VStack(spacing: 15){
            Circle()
                .fill(userTheme.color(scheme).gradient)
                .frame(width: 150, height: 150)
                .mask {
                    //Inverted mask
                    Rectangle()
                        .overlay{
                            Circle()
                                .offset(circleOffet)
                                .blendMode(.destinationOut)
                        }
                }
            
            Text("Выберите тему")
                .font(.title2.bold())
                .padding(.top, 25)
            Text("День или ночь \nНастройте свой интерфейс")
                .multilineTextAlignment(.center)
            
            //Custom Segmented Picker
            HStack(spacing: 0){
                ForEach(Theme.allCases, id: \.rawValue){ theme in
                    Text(theme.rawValue)
                        .padding(.vertical, 10)
                        .frame(width: 100)
                        .background{
                            ZStack{
                                if userTheme == theme{
                                    Capsule()
                                        .fill(.themeBG)
                                        .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                                }
                            }
                            .animation(.snappy, value: userTheme)
                        }
                        .contentShape(.rect)
                        .onTapGesture {
                            userTheme = theme
                        }
                }
            }
            .padding(3)
            .background(.primary.opacity(0.06), in: .capsule)
            .padding(.top, 20)
        }
        // Max Height = 410
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: 410)
        .background(.themeBG)
        .clipShape(.rect(cornerRadius: 30))
        .padding(.horizontal, 15)
        .environment(\.colorScheme, scheme)
        .onChange(of: scheme, initial: false){_, newValue in
            let isDark =  newValue == .dark
            withAnimation(.bouncy){
                circleOffet = CGSize(width: isDark ? 30 : 150, height: isDark ? -25 : -150)
            }
        }
    }
}

#Preview {
    Settings()
}


//Theme
enum Theme: String, CaseIterable {
    case systemDefault = "Системная"
    case light = "Светлая"
    case dark = "Темная"
    
    func color(_ scheme: ColorScheme) -> Color {
        switch self {
        case .systemDefault:
            return scheme == .dark ? .moon : .sun
        case .light:
            return .sun
        case .dark:
            return .moon
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .systemDefault:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
