//
//  Onboarding.swift
//  garage
//
//  Created by Apple on 6.02.24.
//

import SwiftUI

struct ContentView: View {
    
    var dismissAction: (() -> Void)
    
    var body: some View {
        OnboardingScreen(dismissAction: dismissAction)
    }
}
//MARK: - Home Screen
struct Home: View {
    
    var body: some View {
        VStack {
            Text("Добро пожаловать!")
                .font(.title)
            .fontWeight(.medium)
            Text("Пройдите регистрацию, если Вы у нас впервые")
                .font(.body)
                .fontWeight(.thin)
        }
    }
}


var totalPages = 3
var currentPage = 1

//MARK: - OnboardingScreens

struct OnboardingScreen: View {
    
    var dismissAction: (() -> Void)
    
    @AppStorage(wrappedValue: 1, "currentPage") var currentPage
    
    var body: some View {
       
        ZStack{
        
            if currentPage == 1  {
                ScreenView(dismissAction: dismissAction, image: "добавление ТО", title: "Регистрация", details: "Добавляете Ваши авто и планируете их обслуживание")
            }
            
            else if currentPage == 2  {
               ScreenView(dismissAction: dismissAction, image: "уведомление", title: "Напоминание", details: "Получаете напоминание и фиксируете выполнение ТО")
            } else //currentPage == 3
            {
               ScreenView(dismissAction: dismissAction, image: "история", title: "История", details: "Всегда имеете доступ к истории обслуживания Ваших авто")
            }
        }
    }
}


struct ScreenView: View {
    
    var dismissAction: (() -> Void)
    
    @AppStorage(wrappedValue: 1, "currentPage") var currentPage
    
    var image: String
    var title: String
    var details: String
    
    var body: some View {
        ZStack{
            Color(uiColor: Theme.currentTheme.backgroundColor)
                .ignoresSafeArea(.all)
            VStack {
                HStack{

                    if currentPage != 1 {
                        Button {
                            currentPage -= 1
                        } label: {
                            Text("<Назад")
                                .fontWeight(.semibold)
                                .kerning(1.2)
                        }
                    }
                    Spacer()
                    
                    Button(action: {
                        currentPage = 4
                        dismissAction()
                    }) {
                        Text("Пропустить")
                            .fontWeight(.semibold)
                            .kerning(1.2)
                    }
                }.padding()
                    .foregroundColor(.black)
                
                Spacer(minLength: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/)
                
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 16)
                    .frame(height: 300)
                
                Spacer(minLength: 80)
                
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .kerning(1.2)
                    .padding(.top)
                    .padding(.bottom, 5)
                    .foregroundColor(.black)
                
                Text (details)
                    .font(.body)
                    .fontWeight(.regular)
                    .kerning(1.2)
                    .foregroundColor(.secondary)
                    .padding([.leading, .trailing])
                    .multilineTextAlignment(.center)
                
                Spacer(minLength: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/)
                
                HStack{
                    
                    if currentPage == 1 {
                        Color(Theme.currentTheme.buttonColor).frame(height: 8 /
                                           UIScreen.main.scale)
                        Color.gray.frame(height: 8 /
                                           UIScreen.main.scale)
                        Color.gray.frame(height: 8 /
                                           UIScreen.main.scale)
                    }
                    else if currentPage == 2 {
                        Color.gray.frame(height: 8 /
                                           UIScreen.main.scale)
                        Color(Theme.currentTheme.buttonColor).frame(height: 8 /
                                           UIScreen.main.scale)
                        Color.gray.frame(height: 8 /
                                           UIScreen.main.scale)
                    }
            
                    else if currentPage == 3 {
                        Color.gray.frame(height: 8 /
                                           UIScreen.main.scale)
                        Color.gray.frame(height: 8 /
                                           UIScreen.main.scale)
                        Color(Theme.currentTheme.buttonColor).frame(height: 8 /
                                           UIScreen.main.scale)
                    }
                }
                
                .padding(.horizontal, 35)
                
                Button(action: {
                    if currentPage <= totalPages {
                        currentPage += 1
                    }
                    else {
                        currentPage = 1
                    }
                    if currentPage > 3 {
                        dismissAction()
                    }
                    
                }, label: {
                    Text("Далее")
                        .fontWeight(.semibold)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color(.button))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                })
            }
        }
    }
}

//#Preview {
//    ContentView(dismissAction: <#() -> Void#>)
//}

extension View {
    
    func injectIn(controller vc: UIViewController) {
        let controller = UIHostingController(rootView: self)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.backgroundColor = .clear
        vc.view.addSubview(controller.view)
        
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            controller.view.topAnchor.constraint(equalTo: vc.view.topAnchor),
            controller.view.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            controller.view.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor)
        ])
    }
}

class OnbordingHost: UIViewController {
    
    var myView: ContentView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myView = ContentView(dismissAction: { [weak self] in
            self?.dismiss(animated: true)
        })
        myView?.injectIn(controller: self)
    }
}
