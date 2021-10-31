//
//  BaseDetailViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/19.
//

import Foundation
import UIKit

class BaseDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    // MARK: ViewControls
    let commentPanel = UIView()
    let userImageView = UIImageView()
    let commentTextField = CommentTextField()
    let submitButton = ImageButton(image: UIImage.sfsymbol(.send)!, color: .M2!)

    @IBOutlet weak var tableView: UITableView!

    // MARK: DetailDataProperty
    var userImage: UIImage?
    var userName: String?
    var time: Int64?
    var likeNumber: Int?
    var cardID: String?
    var postID: String = ""
    var postCommentID: String?
    var uid = ""

    var comments: [Comment] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var content: String = ""
    var imageUrl: String?

    var hasTabBar = false
    var hasLiked = false

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableVIew()

        layoutCommentPanel()

        if #available(iOS 15.0, *) {

          tableView.sectionHeaderTopPadding = 0
        }

        navigationController?.setupBackButton(color: .gray)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        userImageView.cornerRadius = userImageView.frame.width / 2
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.tabBar.isHidden = !hasTabBar

        tableView.registerHeaderWithNib(
            identifier: BaseDetailTableViewHeader.identifier,
            bundle: nil
        )

        tableView.registerCellWithNib(
            identifier: BaseDetailCommentCell.identifier, bundle: nil
        )
    }

    override func viewWillDisappear(_ animated: Bool) {

        tabBarController?.tabBar.isHidden = hasTabBar
    }

    // MARK: Action
    // Should be properly overridden by subclasses
    @objc func like(_ sender: UIButton) {}

    @objc func addComment(_ sender: UIButton) {

        commentTextField.resignFirstResponder()
    }

    // MARK: SetupViews

    func setupTableVIew() {

        if tableView == nil {

            let tableView = UITableView(frame: .zero, style: .grouped)

            view.stickSubView(tableView)

            self.tableView = tableView
        }

        tableView.dataSource = self

        tableView.delegate = self

        tableView.backgroundColor = .white
    }

    func layoutCommentPanel() {

        let commentPanelObject = [
            commentPanel, userImageView, commentTextField, submitButton
        ]

        commentPanelObject.forEach {

            self.view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        self.view.sendSubviewToBack(tableView)

        NSLayoutConstraint.activate([

            commentPanel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            commentPanel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            commentPanel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            commentPanel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.1),

            userImageView.leadingAnchor.constraint(equalTo: commentPanel.leadingAnchor, constant: 10),
            userImageView.topAnchor.constraint(equalTo: commentPanel.topAnchor, constant: 10),
            userImageView.widthAnchor.constraint(equalTo: commentPanel.widthAnchor, multiplier: 0.1),
            userImageView.heightAnchor.constraint(equalTo: userImageView.widthAnchor),

            commentTextField.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 10),
            commentTextField.heightAnchor.constraint(equalTo: userImageView.heightAnchor),
            commentTextField.trailingAnchor.constraint(equalTo: submitButton.leadingAnchor, constant: -10),
            commentTextField.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),

            submitButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            submitButton.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
            submitButton.widthAnchor.constraint(equalTo: commentPanel.widthAnchor, multiplier: 0.1),
            submitButton.heightAnchor.constraint(equalTo: commentPanel.widthAnchor, multiplier: 0.1)
        ])

        commentPanel.backgroundColor = .white

        userImageView.backgroundColor = .gray
        userImageView.image = userImage
        commentTextField.delegate = self

        submitButton.addTarget(
            self, action: #selector(addComment(_:)),
            for: .touchUpInside
        )
    }

    // MARK: TableView
    // Should be properly edited by subclasses
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {

        view.tintColor = UIColor.white
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        return UITableViewCell(style: .default, reuseIdentifier: String(describing: BaseDetailViewController.self))
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        let animation = AnimationFactory.takeTurnsFadingIn(duration: 0.5, delayFactor: 0.1)
        let animator = Animator(animation: animation)
            animator.animate(cell: cell, at: indexPath, in: tableView)
    }
}
