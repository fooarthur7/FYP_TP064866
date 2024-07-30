//
//  UserData.swift
//  ProjectTest2
//
//  Created by Arthur Foo Che Jit on 24/07/2024.
//

import SwiftUI
import Combine

class UserData: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoggedIn: Bool = false
}

