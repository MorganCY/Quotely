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
    let commentTextField = UITextField()
    let likeButton = UIButton()
    let likeNumberLabel = UILabel()
    let submitButton: UIButton = {
        let submitButton = UIButton()
        submitButton.isHidden = true
        return submitButton
    }()

    @IBOutlet weak var tableView: UITableView!

    // MARK: DetailDataProperty
    var userImage: UIImage?
    var userName: String?
    var time: Int64?
    var content: String = ""
    var imageUrl: String?
    var likeNumber: Int?
    var articleID: String?
    var postID: String?
    var comments: [Comment] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableVIew()

        setupCommentPanel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        userImageView.layer.cornerRadius = userImageView.frame.width / 2

        commentTextField.layer.cornerRadius = commentTextField.frame.height / 2
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.tabBar.isHidden = true

        commentPanel.addBorder(toSide: .top, withColor: UIColor.gray.cgColor, width: 10)

        tableView.registerHeaderWithNib(
            identifier: BaseDetailTableViewHeader.identifier,
            bundle: nil
        )

        tableView.registerCellWithNib(
            identifier: BaseDetailCommentCell.identifier, bundle: nil
        )
    }

    // MARK: Action
    // Should be properly overridden by subclasses
    @objc func addComment(_ sender: UIButton) {}

    func textFieldDidBeginEditing(_ textField: UITextField) {

        let textFieldOpened = commentTextField.isFirstResponder

        likeButton.isHidden = textFieldOpened
        likeNumberLabel.isHidden = textFieldOpened
        submitButton.isHidden = !textFieldOpened
    }

    func textFieldDidEndEditing(_ textField: UITextField) {

        let textFieldOpened = commentTextField.isFirstResponder

        likeButton.isHidden = textFieldOpened
        likeNumberLabel.isHidden = textFieldOpened
        submitButton.isHidden = !textFieldOpened
    }

    // MARK: SetupViews
    func setupTableVIew() {

        if tableView == nil {

            let tableView = UITableView()

            view.stickSubView(tableView)

            self.tableView = tableView
        }

        tableView.dataSource = self

        tableView.delegate = self
    }

    func setupCommentPanel() {

        let commentPanelObject = [
            commentPanel, userImageView, commentTextField, likeButton, likeNumberLabel, submitButton
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
            commentTextField.widthAnchor.constraint(equalTo: commentPanel.widthAnchor, multiplier: 0.6),
            commentTextField.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),

            likeButton.leadingAnchor.constraint(equalTo: commentTextField.trailingAnchor, constant: 10),
            likeButton.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
            likeButton.heightAnchor.constraint(equalTo: userImageView.heightAnchor),
            likeButton.widthAnchor.constraint(equalTo: likeButton.heightAnchor),

            likeNumberLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 10),
            likeNumberLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),

            submitButton.leadingAnchor.constraint(equalTo: commentTextField.trailingAnchor, constant: 10),
            submitButton.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor)
        ])

        commentPanel.backgroundColor = .white

        userImageView.backgroundColor = .gray
        userImageView.image = userImage
        commentTextField.backgroundColor = .gray
        commentTextField.delegate = self
        likeButton.setImage(UIImage.sfsymbol(.heartNormal), for: .normal)
        likeNumberLabel.textColor = .gray
        likeNumberLabel.text = String(describing: likeNumber)
        submitButton.setTitle("送出", for: .normal)
        submitButton.setTitleColor(.blue, for: .normal)

        submitButton.addTarget(
            self, action: #selector(addComment(_:)),
            for: .touchUpInside
        )
    }

    // MARK: TableView
    // Should be properly edited by subclasses

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: BaseDetailTableViewHeader.identifier
        ) as? BaseDetailTableViewHeader else {

            fatalError("Cannot load header view.")
        }

        header.layoutHeader(
            userImage: userImage,
            userName: userName,
            time: time,
            content: content,
            imageUrl: imageUrl
        )

        return header
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

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        return UITableViewCell(style: .default, reuseIdentifier: String(describing: BaseDetailViewController.self))
    }
}
