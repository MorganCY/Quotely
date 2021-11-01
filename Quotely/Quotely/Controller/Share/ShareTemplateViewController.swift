//
//  ShareTemplateViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/1.
//

import Foundation
import UIKit

class ShareTemplateViewController: BaseImagePickerViewController {

    @IBOutlet weak var halfImageTemplateView: UIView!
    @IBOutlet weak var smallImageTemplateView: UIView!
    @IBOutlet weak var fullImageTemplateView: UIView!

    @IBOutlet weak var halfImageView: UIImageView!
    @IBOutlet weak var smallImageView: UIImageView!
    @IBOutlet weak var fullImageView: UIImageView!

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!

    var content = ""
    var author = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .lightGray.withAlphaComponent(0.3)

        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let templateViews = [
            halfImageTemplateView,
            smallImageTemplateView,
            fullImageTemplateView
        ]

        templateViews.forEach {
            $0?.dropShadow(opacity: 0.3)
        }
    }

    func setupView() {

        let templateViews = [
            halfImageTemplateView,
            smallImageTemplateView,
            fullImageTemplateView
        ]

        let imageViews = [halfImageView, smallImageView, fullImageView]

        templateViews.forEach {
            $0?.cornerRadius = CornerRadius.standard.rawValue
            $0?.clipsToBounds = true
            $0?.dropShadow(opacity: 0.3)
        }

        imageViews.forEach {

            $0?.contentMode = .scaleAspectFill
            $0?.image = UIImage.asset(.bg3)
        }

        contentLabel.text = content.replacingOccurrences(of: "\\n", with: "\n")
        authorLabel.text = author.replacingOccurrences(of: "\\n", with: "\n")
    }
}
