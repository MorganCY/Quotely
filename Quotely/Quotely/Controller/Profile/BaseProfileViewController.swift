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

    var visitedUid: String?

    var visitedUserInfo: User? {
        didSet {
            tableView.reloadData()
        }
    }

    var visitedUserPostList: [Post]? {
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchVisitedUserInfo(uid: visitedUid ?? "")
        listenToVisitedUserPost(uid: visitedUid ?? "")
    }

    func setupTableView() {

        if tableView == nil {

            let tableView = UITableView(frame: .zero, style: .insetGrouped)
            view.stickSubView(tableView)
            self.tableView = tableView
        }
        tableView.delegate = self
        tableView.backgroundColor = .M3
        tableView.registerHeaderWithNib(identifier: ProfileTableViewHeaderView.identifier, bundle: nil)
        tableView.registerCellWithNib(identifier: ProfileTableViewCell.identifier, bundle: nil)

        if #available(iOS 15.0, *) {

          tableView.sectionHeaderTopPadding = 0
        }
    }

    func fetchVisitedUserInfo(uid: String) {

        UserManager.shared.fetchUserInfo(uid: uid) { result in

            switch result {

            case .success(let userInfo):
                self.tableView.dataSource = self
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
}

extension BaseProfileViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard let visitedUserPostList = visitedUserPostList else {

            return 0
        }

        return visitedUserPostList.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        return UITableViewHeaderFooterView()
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {

        return 400.0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let detailVC =
                UIStoryboard.explore.instantiateViewController(
                    withIdentifier: PostDetailViewController.identifier
                ) as? PostDetailViewController
        else { return }

        let row = indexPath.row

        detailVC.post = visitedUserPostList?[row]
        detailVC.postAuthor = visitedUserInfo

        if let likeUserList = visitedUserPostList?[row].likeUser {

            detailVC.isLikePost = likeUserList.contains(UserManager.shared.visitorUserInfo?.uid ?? "")
        }

        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        UITableView.automaticDimension
    }
}

extension BaseProfileViewController {

    @objc func tapFollowNumberLabel(_ gestureRecognizer: UITapGestureRecognizer) {

        guard let followVC =
                UIStoryboard.profile.instantiateViewController(
                    withIdentifier: FollowListViewController.identifier
                ) as? FollowListViewController
        else { return }

        followVC.visitedUid = visitedUid

        navigationController?.pushViewController(followVC, animated: true)
    }

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
