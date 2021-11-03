//
//  ProfileViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/1.
//

import Foundation
import Lottie
import UIKit

class ProfileViewController: UIViewController {

    let profileImageView = UIImageView()
    var tableView = UITableView()

    let uid = SignInManager.shared.uid
    var userInfo: User? {
        didSet {
            setupView()
        }
    }
    var userPostList = [Post]() {
        didSet {
            tableView.reloadData()
        }
    }

    private var animationView: AnimationView?

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchUserInfo()
        fetchUserPost()

        tableView.dataSource = self
        tableView.delegate = self

        navigationItem.title = "個人資訊"
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        profileImageView.cornerRadius = profileImageView.frame.width / 2
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.registerCellWithNib(identifier: ProfileTableViewCell.identifier, bundle: nil)
    }

    func fetchUserInfo() {

        guard let uid = uid else { return }

        UserManager.shared.fetchUserInfo(uid: uid) { result in

                switch result {

                case .success(let userInfo):
                    self.userInfo = userInfo

                case.failure(let error):
                    print(error)
                }
            }
    }

    func fetchUserPost() {

        guard let uid = uid else { return }

        PostManager.shared.fetchPost(type: .user, uid: uid) { result in

            switch result {

            case .success(let posts):
                self.userPostList = posts

            case .failure(let error):
                print(error)
            }
        }
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        userPostList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath
        ) as? ProfileTableViewCell else {

            fatalError("Cannot create cell")
        }

        let post = userPostList[indexPath.row]

        cell.layoutCell(post: post)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        UITableView.automaticDimension
    }
}

extension ProfileViewController {

    func setupView() {

        guard let userInfo = userInfo else { return }

        let userNameLabel = UILabel()
        let postNumberLabel = UILabel()
        let followerNumberLabel = UILabel()
        let followingNumberLabel = UILabel()
        let numberLabelStackView = UIStackView()
        let blockButton = UIButton()
        let followButton = UIButton()
        let buttonStackView = UIStackView()

        let profileViews = [profileImageView, userNameLabel, numberLabelStackView, buttonStackView, tableView]
        let numberLabels = [postNumberLabel, followerNumberLabel, followingNumberLabel]
        let buttons = [blockButton, followButton]

        profileViews.forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        profileImageView.image = UIImage.asset(.testProfile)
        profileImageView.clipsToBounds = true
        userNameLabel.text = userInfo.name
        userNameLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)

        numberLabels.forEach {
            numberLabelStackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textColor = .gray
            $0.font = UIFont.systemFont(ofSize: 14)
        }

        numberLabelStackView.spacing = 8

        postNumberLabel.text = "\(userInfo.postNumber)則貼文"
        followerNumberLabel.text = "\(userInfo.followerNumber)被追蹤"
        followingNumberLabel.text = "\(userInfo.followingNumber)追蹤中"

        buttons.forEach {

            buttonStackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setTitleColor(.M1, for: .normal)
            $0.borderWidth = 1
            $0.borderColor = .gray
            $0.cornerRadius = CornerRadius.standard.rawValue / 3
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            $0.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.25).isActive = true
        }

        buttonStackView.spacing = 12
        blockButton.setTitle("封鎖他", for: .normal)
        followButton.setTitle("追蹤他", for: .normal)

        NSLayoutConstraint.activate([

            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
            profileImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),

            userNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 32),

            numberLabelStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            numberLabelStackView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 12),

            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.topAnchor.constraint(equalTo: numberLabelStackView.bottomAnchor, constant: 32),

            tableView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 32),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func lottie() {

        animationView = .init(name: "ball")

        animationView!.frame = view.bounds

        animationView!.contentMode = .scaleAspectFit

        animationView!.loopMode = .loop

        animationView!.animationSpeed = 1

        view.addSubview(animationView!)

        animationView!.play()
    }
}
