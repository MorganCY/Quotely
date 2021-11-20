//
//  ProfileViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/1.
//

import Foundation
import UIKit

class BaseProfileViewController: BaseImagePickerViewController {

    @IBOutlet weak var tableView: UITableView!

    // the user who is visiting other's profile

    var visitorUid: String?

    // the user who is visited by others

    var visitedUid = SignInManager.shared.visitorUid

    var visitorBlockList: [String]?

    var visitorFollowingList: [String]?

    var isBlock = false

    var isFollow = false

    var visitedUserInfo: User? {
        didSet {
            tableView.reloadData()
        }
    }

    var visitedUserPostList = [Post]() {
        didSet {
            tableView.reloadData()
        }
    }

    let loadingAnimationView = LottieAnimationView(animationName: "whiteLoading")

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLoadingAnimation()

        setupTableView()

        navigationItem.title = "個人資訊"

        visitorUid = UserManager.shared.visitorUserInfo?.uid
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchVisitedUserInfo(uid: visitedUid ?? "")

//        if let visitedUid = visitedUid {
//
//            fetchVisitedUserInfo(uid: visitedUid)
//
//        } else {
//
//            Toast.showFailure(text: "資料載入異常")
//        }

        listenToVisitedUserPost(uid: visitedUid ?? "")
        visitorBlockList = UserManager.shared.visitorUserInfo?.blockList
        visitorFollowingList = UserManager.shared.visitorUserInfo?.followingList
    }

    func setupTableView() {

        if tableView == nil {

            let tableView = UITableView(frame: .zero, style: .insetGrouped)

            view.stickSubView(tableView)

            self.tableView = tableView
        }

        if #available(iOS 15.0, *) {

          tableView.sectionHeaderTopPadding = 0
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .M3
        tableView.registerHeaderWithNib(identifier: ProfileTableViewHeaderView.identifier, bundle: nil)
        tableView.registerCellWithNib(identifier: ProfileTableViewCell.identifier, bundle: nil)
    }

    func fetchVisitedUserInfo(uid: String) {

        UserManager.shared.fetchUserInfo(uid: uid) { result in

            switch result {

            case .success(let userInfo):

                self.visitedUserInfo = userInfo

                self.loadingAnimationView.removeFromSuperview()

            case .failure(let error):

                print(error)

                self.loadingAnimationView.removeFromSuperview()

                DispatchQueue.main.async {
                    Toast.showFailure(text: "資料載入異常")
                }
            }
        }
    }

    func listenToVisitedUserPost(uid: String) {

        _ = PostManager.shared.listenToPostUpdate(type: .user, uid: uid, followingList: nil) { result in

            switch result {

            case .success(let posts):

                self.visitedUserPostList = posts

            case .failure(let error):

                print(error)
            }
        }
    }

    @objc func goToFollowList(_ gestureRecognizer: UITapGestureRecognizer) {

        guard let followVC =
                UIStoryboard.profile
                .instantiateViewController(
                    withIdentifier: String(describing: FollowListViewController.self)
                ) as? FollowListViewController else {

                    return
                }

        followVC.visitedUid = visitedUid

        navigationController?.pushViewController(followVC, animated: true)
    }
}

extension BaseProfileViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { visitedUserPostList.count }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        return UITableViewHeaderFooterView()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { UITableView.automaticDimension }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let detailVC =
                UIStoryboard.explore
                .instantiateViewController(
                    withIdentifier: String(describing: PostDetailViewController.self)
                ) as? PostDetailViewController else {

                    return
                }

        let row = indexPath.row

        detailVC.post = visitedUserPostList[row]
        detailVC.postAuthor = visitedUserInfo

        if let likeUserList = visitedUserPostList[row].likeUser {

            detailVC.isLike = likeUserList.contains(visitorUid ?? "")
        }

        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        UITableView.automaticDimension
    }
}

extension BaseProfileViewController {

    func setupLoadingAnimation() {

        view.addSubview(loadingAnimationView)
        loadingAnimationView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            loadingAnimationView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            loadingAnimationView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            loadingAnimationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingAnimationView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
