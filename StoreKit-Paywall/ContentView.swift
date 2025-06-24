//
//  ContentView.swift
//  StoreKit-Paywall
//
//  Created by Nonprawich I. on 24/6/25.
//

import StoreKit
import SwiftUI

/// IAP View Images
enum IAPImage: String, CaseIterable {
    case one = "Profile 0"
    case two = "Profile 1"
    case three = "Profile 2"
    case four = "Profile 3"
    case five = "Profile 4"
    case six = "Profile 5"
    case seven = "Profile 6"
    case eight = "Profile 7"
    case nine = "Profile 8"
    case ten = "Profile 9"
}

struct ContentView: View {
    @State private var isLoadingCompleted: Bool = false
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        //        SubscriptionStoreView(groupID: "0532D82C")
        //        SubscriptionStoreView(productIDs: Self.productIDs)
        ZStack {
            BackdropView()
            VStack(spacing: 0) {
                SubscriptionStoreView(productIDs: Self.productIDs, marketingContent: {
                    CustomMarketingView()
                })
                .subscriptionStoreControlStyle(.pagedProminentPicker, placement: .bottomBar)
                .subscriptionStorePickerItemBackground(.ultraThinMaterial)
                .storeButton(.visible, for: .restorePurchases)
                .storeButton(.hidden, for: .policies)
                
                // OnlnAppPurchaseStart: This event will notify us when the user initiates a purchase by pressing the subscribe button.
                
                .onInAppPurchaseStart { product in
                    print("Show Loading Screen")
                    print("Purchasing \(product.displayName)")
                }
                
                // OnlnAppPurchaseCompletion: This event will be triggered when the purchase is canceled, closed, failed, or successful. You can use switch cases to determine the actual outcome of the purchase.
                
                .onInAppPurchaseCompletion { product, result in
                    switch result {
                    case .success(let result):
                        switch result {
                        case .success(_): print("Success and verify purchase using verification result")
                        case .pending: print("Pending Action")
                        case .userCancelled: print("User Cancelled")
                        @unknown default:
                            fatalError()
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                    print("Hide Loading Screen")
                }
                
                //  SubscriptionStatusTask: This modifier will monitor any changes in the specified group, indicating whether the user is subscribed, expired, revoked, or otherwise. This information can be used to determine the user's subscription status.
                
                .subscriptionStatusTask(for: "0532D82C") { status in
                    if let result = status.value {
                        let premiumUser = !result.filter({ $0.state == .subscribed }).isEmpty
                        print("User Subscribed = \(premiumUser)")
                    }
                }
                
                HStack(spacing: 3) {
                    Link("Terms of Service", destination: URL(string:"https://apple.com")!)
                    Text("and")
                    Link("Privacy Policy", destination: URL(string: "https://apple.com")!)
                }
                .font(.caption)
                .padding(.bottom, 10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(isLoadingCompleted ? 1 : 0) // will appear at the same time
            .overlay {
                if !isLoadingCompleted {
                    ProgressView()
                        .controlSize(.extraLarge)
                        .ignoresSafeArea()
                }
            }
            .animation(.easeInOut(duration: 0.35), value: isLoadingCompleted)
            .storeProductsTask(for: Self.productIDs) { @MainActor collection in
                if let products = collection.products, products.count == Self.productIDs.count {
                    try? await Task.sleep(for: .seconds(0.1))
                    isLoadingCompleted = true
                }
            }
            .environment(\.colorScheme, .dark)
        }
    }
    
    static var productIDs: [String] {
        return ["pro_weekly", "pro_monthly", "pro_yearly"]
    }
    
    @ViewBuilder
    func BackdropView() -> some View {
        GeometryReader { geometry in
            Image("apple_park_background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .scaleEffect(1.2)
                .blur(radius: 25)
                .overlay {
                    LinearGradient(
                        colors: [
                            .black.opacity(0.5),
                            .black.opacity(0.2),
                            .black.opacity(0.7)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    func CustomMarketingView() -> some View {
        ScrollView {
            VStack(spacing: 4) {
                Image("real_apple_fruit")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                Text("AppleHolic")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Text("Premium Apple")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
        }
        .scrollDisabled(true)
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
    }
}


#Preview {
    ContentView()
}
