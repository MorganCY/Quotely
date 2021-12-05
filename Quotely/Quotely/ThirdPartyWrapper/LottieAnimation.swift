//
//  LottieAnimation.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/7.
//

import Foundation
import Lottie

class LottieAnimationView: UIView {

    let animationView: AnimationView

    init(animationName: String) {
        self.animationView = AnimationView(name: animationName)
        super.init(frame: .zero)
        layoutAnimationView()
        configureAnimationView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layoutAnimationView() {
        addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            animationView.topAnchor.constraint(equalTo: topAnchor),
            animationView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func configureAnimationView() {

        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.5
        animationView.play()
    }
}
