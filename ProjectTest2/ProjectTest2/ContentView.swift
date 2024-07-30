import SwiftUI

struct ContentView: View {
    @State private var showFullScreenMap = false
    @State private var isLoggedIn = false

    var body: some View {
        if isLoggedIn {
            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }

                FullScreenMapView()
                    .tabItem {
                        Image(systemName: "map.fill")
                        Text("Map")
                    }

                AccountView(isLoggedIn: $isLoggedIn)
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("My Account")
                    }
            }
        } else {
            LoginView(isLoggedIn: $isLoggedIn)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
