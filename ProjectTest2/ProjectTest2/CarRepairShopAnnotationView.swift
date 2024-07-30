import SwiftUI
import CoreLocation
import MapKit

struct CarRepairShopAnnotationView: View {
    let shop: CarRepairShop
    @State private var showingDetails = false

    var body: some View {
        VStack {
            Button(action: {
                showingDetails.toggle()
            }) {
                Image(systemName: "location.circle.fill")
                    .foregroundColor(.red)
                    .padding(5)
                    .background(Color.white)
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showingDetails) {
                ShopDetailView(shop: shop, isPresented: $showingDetails)
                    .presentationDetents([.fraction(0.5)])
            }
        }
    }
}
