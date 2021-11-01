//
//  ShareViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/1.
//

import Foundation
import UIKit

class ShareViewController: UIViewController {

    @IBOutlet weak var halfImageTemplateContainerView: UIView!
    @IBOutlet weak var smallImageTemplateContainerView: UIView!
    @IBOutlet weak var fullImageTemplateContainerView: UIView!

    var containerViews: [UIView] {
        return [
            halfImageTemplateContainerView,
            smallImageTemplateContainerView,
            fullImageTemplateContainerView
        ]
    }
    let templateSelectionView = SelectionView()
    var content = ""
    var author = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        layoutViews()

        containerViews[0].isHidden = false
        containerViews[1].isHidden = true
        containerViews[2].isHidden = true

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissSelf(_:))
        )
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let templateVC = segue.destination as? ShareTemplateViewController else { return }

        if segue.identifier == "shareTemplate" {

            templateVC.content = content
            templateVC.author = author
        }
    }

    @objc func dismissSelf(_ sender: UIBarButtonItem) {

        self.dismiss(animated: true, completion: nil)
    }

    func layoutViews() {

        view.addSubview(templateSelectionView)
        templateSelectionView.translatesAutoresizingMaskIntoConstraints = false
        templateSelectionView.dataSource = self
        templateSelectionView.delegate = self

        NSLayoutConstraint.activate([

            templateSelectionView.topAnchor.constraint(equalTo: halfImageTemplateContainerView.bottomAnchor),
            templateSelectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            templateSelectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            templateSelectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension ShareViewController: SelectionViewDataSource, SelectionViewDelegate {
    func buttonStyle(_ view: SelectionView) -> ButtonStyle { .text }

    func numberOfButtonsAt(_ view: SelectionView) -> Int { containerViews.count }

    func buttonTitle(_ view: SelectionView, index: Int) -> String {

        let titles = ["模板一", "模板二", "模板三"]

        view.buttons[0].setTitleColor(.black, for: .normal)

        return titles[index]
    }

    func buttonColor(_ view: SelectionView) -> UIColor { .lightGray }

    func indicatorColor(_ view: SelectionView) -> UIColor { .clear }

    func indicatorWidth(_ view: SelectionView) -> CGFloat { 0 }

    func shouldSelectButtonAt(_ view: SelectionView, at index: Int) -> Bool { true }

    func didSelectButtonAt(_ view: SelectionView, at index: Int) {

        view.buttons.forEach { $0.setTitleColor(.lightGray, for: .normal) }
        view.buttons[index].setTitleColor(.black, for: .normal)

        containerViews.forEach { $0.isHidden = true }
        containerViews[index].isHidden = false
    }
}
