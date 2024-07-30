//
//  AccountRow.swift
//  ProjectTest2
//
//  Created by Arthur Foo Che Jit on 25/07/2024.
//

import SwiftUI

struct AccountRow: View {
    var icon: String
    var iconColor: Color
    var title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)
                .background(iconColor.opacity(0.1))
                .cornerRadius(6)
            
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.vertical, 10)
    }
}

struct AccountRow_Previews: PreviewProvider {
    static var previews: some View {
        AccountRow(icon: "person.crop.circle", iconColor: .blue, title: "My Profile")
            .previewLayout(.sizeThatFits)
    }
}
