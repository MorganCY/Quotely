//
//  ProfileViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/1.
//

import Foundation
import Lottie

class ProfileViewController: UIViewController {

    private var animationView: AnimationView?

    override func viewDidLoad() {
        super.viewDidLoad()

        animationView = .init(name: "ball")

        animationView!.frame = view.bounds

        animationView!.contentMode = .scaleAspectFit

        animationView!.loopMode = .loop

        animationView!.animationSpeed = 1

        view.addSubview(animationView!)

        animationView!.play()
    }
}
