//
//  LockView.swift
//  Expense Tracker
//
//  Created by Виктор Евграфов on 11.01.2024.
//

import SwiftUI
import LocalAuthentication

struct LockView<Content: View>: View {
    //Lock Properties
    var lockType: LockType
    var lockPin: String
    var isEnabled: Bool
    var lockWhenAppGoesBackground: Bool = false
    @ViewBuilder var content: Content
    var forgotPin: () -> () = {  }
    //View Properties
    @State private var pin: String = ""
    @State private var animateField: Bool = false
    @State private var isUnlocked: Bool = true
    @State private var noBiometricAccess: Bool = false
    let context = LAContext()
    // Scene Phase
    @Environment(\.scenePhase) private var phase
    var body: some View {
        GeometryReader{
            let size = $0.size
            
            content
                .frame(width: size.width, height: size.height)
            
            if isEnabled && !isUnlocked{
                ZStack{
                    Rectangle()
                        .fill(.black)
                        .ignoresSafeArea()
                    if(lockType == .both && !noBiometricAccess) || lockType == .biometric{
                        Group{
                            if noBiometricAccess{
                                Text("Включите биометрическую аутентификацию в настройках, чтобы разблокировать.")
                                    .font(.callout)
                                    .multilineTextAlignment(.center)
                                    .padding(50)
                            }else{
                                //Bio || Pin unlock
                                VStack(spacing: 12){
                                    VStack(spacing: 6){
                                        Image(systemName: "faceid")
                                            .font(.largeTitle)
                                        Text("Tap to Unlock")
                                            .font(.caption2)
                                            .foregroundStyle(.gray)
                                    }
                                    .frame(width: 100, height: 100)
                                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 10))
                                    .contentShape(.rect)
                                    .onTapGesture {
                                        unlockView()
                                    }
                                    
                                    if lockType == .both{
                                        Text("Введите Pin")
                                            .frame(width: 100, height: 100)
                                            .background(.ultraThinMaterial, in: .rect(cornerRadius: 10))
                                            .contentShape(.rect)
                                            .onTapGesture {
                                                noBiometricAccess = true
                                            }
                                    }
                                }
                            }
                        }
                    } else {
                        //Custom Number Pud to type View Lock Pin
                        NumberPadPinView()
                    }
                }
                .environment(\.colorScheme, .dark)
                .transition(.offset(y: size.height + 100))
            }
        }
        .onChange(of: isEnabled, initial: true){ oldValue, newValue in
            if newValue{
                unlockView()
            }
        } // Locking When App goes back
        .onChange(of: phase){ oldValue, newValue in
            if newValue != .active && lockWhenAppGoesBackground{
                isUnlocked = false
                pin = ""
            }
            
            if newValue == .active && !isUnlocked && isEnabled{
                unlockView()
            }
        }
    }
    
    private func unlockView(){
        //Checking and Unlocking View
        Task{
            //Lock Context
            let context = LAContext()
            
            if isBiometricAvailable && lockType != .number{
                //Requesting Biometric Unlock
                if let result = try? await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock the View"), result{
                    print("Unlocked")
                    withAnimation(.snappy, completionCriteria: .logicallyComplete){
                        isUnlocked = true
                    } completion: {
                        pin = ""
                    }
                }
            }
            
            //No Bio Metrick Permission || Lock Type Must be Set as KeyPad
            //Updating Biometrick status
            noBiometricAccess = !isBiometricAvailable
        }
    }
    
    private var isBiometricAvailable: Bool{
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    //NumberPad Pin View
    @ViewBuilder
    private func NumberPadPinView() -> some View{
        VStack(spacing: 15){
            Text("Введите Pin")
                .font(.title.bold())
                .frame(minWidth: .infinity)
                .overlay(alignment: .leading){
                    // Back Button only for both lock type
                    if lockType == .both && isBiometricAvailable{
                        Button(action: {
                            pin = ""
                            noBiometricAccess = false
                        }, label: {
                            Image(systemName: "arrow.left")
                                .font(.title3)
                                .contentShape(.rect)
                        })
                        .tint(.white)
                        .padding(.leading)
                    }
                }
            //Adding Wiggling Animation for Wrong Pin
            HStack(spacing: 10){
                ForEach(0..<4, id: \.self){ index in
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 50, height: 55)
                        //Showing Pin at each box
                        .overlay{
                            //Save Check
                            if pin.count > index{
                                let index = pin.index(pin.startIndex, offsetBy: index)
                                let string = String(pin[index])
                                
                                Text(string)
                                    .font(.title.bold())
                                    .foregroundStyle(.black)
                            }
                        }
                }
            }
            .keyframeAnimator(initialValue: CGFloat.zero, trigger: animateField, content: { content, value in
                content
                    .offset(x: value)
            }, keyframes: { _ in
                KeyframeTrack{
                    CubicKeyframe(30,duration: 0.07)
                    CubicKeyframe(-30,duration: 0.07)
                    CubicKeyframe(20,duration: 0.07)
                    CubicKeyframe(-20,duration: 0.07)
                    CubicKeyframe(0,duration: 0.07)
                }
            })
            .padding(.top, 15)
            .overlay(alignment: .bottomTrailing, content: {
                Button("Забыли Pin ?",action: forgotPin)
                    .foregroundStyle(.white)
                    .offset(y: 40)
            })
            .frame(maxHeight: .infinity)
            
            //Custom NumberPad
            GeometryReader{ _ in
                LazyVGrid(columns: Array(repeating: GridItem(), count: 3), content: {
                    ForEach(1...9, id: \.self){ number in
                        Button(action: {
                            //Adding Number to Pin
                            //Max limit = 4
                            if pin.count < 4{
                                pin.append("\(number)")
                            }
                        }, label: {
                            Text("\(number)")
                                .font(.title)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .contentShape(.rect)
                        })
                        .tint(.white)
                    }
                    //0 and back button
                    Button(action: {
                        if pin.isEmpty{
                            pin.removeLast()
                        }
                    }, label: {
                        Image(systemName: "delete.backward")
                            .font(.title)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .contentShape(.rect)
                    })
                    .tint(.white)
                    
                    Button(action: {
                        if pin.count < 4{
                            pin.append("0")
                        }
                    }, label: {
                        Text("0")
                            .font(.title)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .contentShape(.rect)
                    })
                    .tint(.white)
                })
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .onChange(of: pin) { oldValue, newValue in
                if newValue.count == 4{
                    //Validate Pin
                    if lockPin == pin{
                        //print("Unlocked")
                        withAnimation {
                            isUnlocked = true
                        } completion: {
                            //Clearing Pin
                            pin = ""
                            noBiometricAccess = !isBiometricAvailable
                        }

                    } else {
                        print("Wrong Pin")
                        pin = ""
                        animateField.toggle()
                    }
                }
            }
        }
        .padding()
        .environment(\.colorScheme, .dark)
    }
    
    //Lock Type
    enum LockType: String{
        case biometric = "Bio Metric Auth"
        case number = "Custom Number Lock"
        case both = "First preference will be biometric, and if it's not available, it will go for number lock."
    }
}

#Preview {
    ContentView()
}
