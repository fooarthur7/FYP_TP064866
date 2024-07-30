//
//  ViewModifier.swift
//  ProjectTest2
//
//  Created by Arthur Foo Che Jit on 29/07/2024.
//

import SwiftUI

struct BannerModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let backgroundColor: Color

    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                VStack {
                    BannerView(message: message, backgroundColor: backgroundColor)
                        .transition(.move(edge: .top))
                    Spacer()
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            isPresented = false
                        }
                    }
                }
            }
        }
    }
}

extension View {
    func banner(isPresented: Binding<Bool>, message: String, backgroundColor: Color = Color.green) -> some View {
        self.modifier(BannerModifier(isPresented: isPresented, message: message, backgroundColor: backgroundColor))
    }
}
