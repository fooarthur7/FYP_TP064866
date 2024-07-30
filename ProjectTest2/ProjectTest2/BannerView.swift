//
//  BannerView.swift
//  ProjectTest2
//
//  Created by Arthur Foo Che Jit on 29/07/2024.
//

import SwiftUI

struct BannerView: View {
    var message: String
    var backgroundColor: Color = Color.green

    var body: some View {
        Text(message)
            .foregroundColor(.white)
            .padding()
            .background(.green)
            .cornerRadius(8)
            .shadow(radius: 10)
            .padding()
            .frame(maxWidth: .infinity)
    }
}
