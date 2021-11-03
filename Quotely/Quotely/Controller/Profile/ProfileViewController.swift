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

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.registerHeaderWithNib(identifier: ProfileTableViewHeaderView.identifier, bundle: nil)
            tableView.registerCellWithNib(identifier: ProfileTableViewCell.identifier, bundle: nil)
        }
    }

    let uid = SignInManager.shared.uid
    var userInfo: User? {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.reloadData()
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

        navigationItem.title = "個人資訊"

        if #available(iOS 15.0, *) {

          tableView.sectionHeaderTopPadding = 0
        }
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

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: ProfileTableViewHeaderView.identifier
        ) as? ProfileTableViewHeaderView else {

            fatalError("Cannot create header view")
        }

        guard let userInfo = userInfo else {

            fatalError("Cannot fetch user info")
        }

        header.layoutHeader(userInfo: userInfo)

        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ProfileTableViewCell.identifier,
            for: indexPath
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
