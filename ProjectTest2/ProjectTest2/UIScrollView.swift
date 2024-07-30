//
//  UIScrollView.swift
//  ProjectTest2
//
//  Created by Arthur Foo Che Jit on 25/07/2024.
//

import SwiftUI

struct AlwaysVisibleScrollView<Content: View>: UIViewRepresentable {
    var content: () -> Content

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.indicatorStyle = .black
        scrollView.delegate = context.coordinator

        let hostingController = UIHostingController(rootView: content())
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        let hostingController = UIHostingController(rootView: content())
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        uiView.subviews.forEach { $0.removeFromSuperview() }
        uiView.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: uiView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: uiView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: uiView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: uiView.bottomAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: uiView.widthAnchor)
        ])
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            scrollView.flashScrollIndicators()
        }
    }
}
