//
//  ExploreViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import Foundation
import UIKit
import FirebaseFirestore
import SwiftUI

class ExploreViewController: UIViewController {

    var listener: ListenerRegistration?

    var visitorFollowingList: [String] = []

    let filters: [PostManager.FilterType] = [.latest, .following]
    var currentFilter: PostManager.FilterType = .latest {
        didSet {
            if currentFilter == .following,
               visitorFollowingList.count > 0 {
                listener = addPostListener(
                    type: currentFilter,
                    uid: SignInManager.shared.visitorUid,
                    followingList: visitorFollowingList
                )
            } else {
                listener = addPostListener(type: currentFilter, uid: nil, followingList: nil)
            }

            if currentFilter == .following,
               visitorFollowingList.count == 0 {
                setupEmptyAnimation()
            } else {
                emptyReminderView.removeFromSuperview()
            }
        }
    }

    let emptyReminderView = UIView()

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.registerCellWithNib(
                identifier: ExploreTableViewCell.identifier,
                bundle: nil
            )
            tableView.separatorStyle = .none

            tableView.setSpecificCorner(corners: [.topLeft, .topRight])
        }
    }

    let filterView = SelectionView()

    var postList: [Post] = []

    var userList: [User?] = [] {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.reloadData()
        }
    }

    var isLikePost = false

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "想法"

        filterView.delegate = self
        filterView.dataSource = self

        navigationItem.setupRightBarButton(
            image: UIImage.sfsymbol(.addPost),
            text: nil,
            target: self,
            action: #selector(addPost(_:)),
            color: .white
        )

        setupFilterView()

        view.backgroundColor = .M1

        currentFilter = .latest
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        visitorFollowingList = UserManager.shared.visitorUserInfo?.followingList ?? [""]

        if visitorFollowingList.count > 0 {
            listener = addPostListener(
                type: currentFilter,
                uid: SignInManager.shared.visitorUid,
                followingList: visitorFollowingList
            )
        } else if visitorFollowingList.count == 0 {
            listener = addPostListener(
                type: currentFilter,
                uid: nil,
                followingList: nil
            )
        }
    }

    // MARK: Data
    func addPostListener(
        type: PostManager.FilterType,
        uid: String?,
        followingList: [String]?
    ) -> ListenerRegistration {

        return PostManager.shared.listenToPostUpdate(
            type: type,
            uid: uid,
            followingList: followingList
        ) { result in

            switch result {

            case .success(let posts):

                self.postList = posts

                self.fetchUserList(postList: posts)

            case .failure(let error):

                print(error)
            }
        }
    }

    func fetchUserList(postList: [Post]) {

        var userList: [User] = Array(repeating: User.default, count: postList.count)

        let group = DispatchGroup()

        DispatchQueue.main.async {

            for (index, post) in postList.enumerated() {

                group.enter()

                UserManager.shared.fetchUserInfo(uid: post.uid) { result in

                    switch result {

                    case .success(let user):

                        userList[index] = user

                        group.leave()

                    case .failure(let error):

                        print(error)

                        group.leave()
                    }
                }
            }

            group.notify(queue: DispatchQueue.main) {

                self.userList = userList
            }
        }
    }

    @objc func addPost(_ sender: UIBarButtonItem) {

        guard let writeVC =
                UIStoryboard.write
                .instantiateViewController(
                    withIdentifier: String(describing: ExploreWriteViewController.self)
                ) as? ExploreWriteViewController else {

                    return
                }

        let nav = BaseNavigationController(rootViewController: writeVC)

        nav.modalPresentationStyle = .fullScreen

        present(nav, animated: true)
    }

    @objc func goToProfile(_ gestureRecognizer: UITapGestureRecognizer) {

        guard let profileVC = UIStoryboard
                .profile
                .instantiateViewController(withIdentifier: String(describing: ProfileViewController.self)
        ) as? ProfileViewController else {

            return
        }

        guard let currentRow = gestureRecognizer.view?.tag else { return }

        profileVC.visitedUid = postList[currentRow].uid

        navigationController?.pushViewController(profileVC, animated: true)
    }

    @objc func goToCardTopicPage(_ gestureRecognizer: UITapGestureRecognizer) {

        guard let cardTopicVC = UIStoryboard
                .card
                .instantiateViewController(withIdentifier: String(describing: CardTopicViewController.self)
        ) as? CardTopicViewController else {

            return
        }

        guard let currentRow = gestureRecognizer.view?.tag else { return }

        cardTopicVC.cardID = postList[currentRow].cardID

        navigationController?.pushViewController(cardTopicVC, animated: true)
    }

    func goToPostDetail(index: Int) {

        guard let detailVC =
                UIStoryboard.explore
                .instantiateViewController(
                    withIdentifier: String(describing: PostDetailViewController.self)
                ) as? PostDetailViewController else {

                    return
                }

        if let likeUserList = postList[index].likeUser {

            isLikePost = likeUserList.contains(SignInManager.shared.visitorUid ?? "")

        } else {

            isLikePost = false
        }

        detailVC.post = postList[index]
        detailVC.postAuthor = userList[index]
        detailVC.isLike = isLikePost

        navigationController?.pushViewController(detailVC, animated: true)
    }

    func openOptionMenu(index: Int) {

        let blockUserAction = UIAlertAction(
            title: "檢舉並封鎖用戶",
            style: .destructive
        ) { _ in

            if self.currentFilter == .following {

                self.unfollowUser(index: index)
            }

            UserManager.shared.updateUserBlockList(
                visitorUid: UserManager.shared.visitorUserInfo?.uid ?? "",
                visitedUid: self.userList[index]?.uid ?? "",
                blockAction: .block
            ) { result in

                switch result {

                case .success(let success):

                    print(success)

                    self.listener = self.addPostListener(type: self.currentFilter, uid: nil, followingList: nil)

                case .failure(let error):

                    print(error)

                    Toast.showFailure(text: "封鎖失敗")
                }
            }
        }

        let cancelAction = UIAlertAction(title: "取消", style: .cancel)

        let optionAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        optionAlert.addAction(blockUserAction)
        optionAlert.addAction(cancelAction)

        present(optionAlert, animated: true)
    }

    func unfollowUser(index: Int) {
        UserManager.shared.updateUserFollow(
            visitorUid: UserManager.shared.visitorUserInfo?.uid ?? "",
            visitedUid: self.userList[index]?.uid ?? "",
            followAction: .unfollow
        ) { result in

            switch result {

            case . success(let success): print(success)

            case .failure(let error): print(error)
            }
        }
    }
}

extension ExploreViewController: SelectionViewDataSource, SelectionViewDelegate {

    func numberOfButtonsAt(_ view: SelectionView) -> Int { filters.count }

    func buttonStyle(_ view: SelectionView) -> ButtonStyle { .text }

    func buttonTitle(_ view: SelectionView, index: Int) -> String { filters[index].rawValue }

    func buttonColor(_ view: SelectionView) -> UIColor { .white }

    func indicatorColor(_ view: SelectionView) -> UIColor { .M3 }

    func indicatorWidth(_ view: SelectionView) -> CGFloat { 0.4 }

    func didSelectButtonAt(_ view: SelectionView, at index: Int) {

        switch index {

        case 0:
            listener?.remove()
            currentFilter = .latest
        case 1:
            listener?.remove()
            currentFilter = .following
        default:
            listener?.remove()
            currentFilter = .latest        }
    }

    func shouldSelectButtonAt(_ view: SelectionView, at index: Int) -> Bool { true }
}

// MARK: TableView
extension ExploreViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { postList.count }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { 200 }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { UITableView.automaticDimension }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ExploreTableViewCell.identifier,
            for: indexPath) as? ExploreTableViewCell else {

                fatalError("Cannot create cell.")
            }

        let post = postList[indexPath.row]

        if let likeUserList = post.likeUser {

            isLikePost = likeUserList.contains(SignInManager.shared.visitorUid ?? "")

        } else {

            isLikePost = false
        }

        cell.layoutCell(
            userInfo: userList[indexPath.row]!,
            post: post,
            isLikePost: self.isLikePost
        )

        cell.hideSelectionStyle()

        cell.likeHandler = {

            // When tapping on the like button, check if the user has likedPost

            if let likeUserList = post.likeUser {

                self.isLikePost = likeUserList.contains(SignInManager.shared.visitorUid ?? "")

            } else {

                self.isLikePost = false
            }

            guard let postID = post.postID else { return }

            let likeAction: LikeAction = self.isLikePost
            ? .dislike : .like

            cell.likeButton.isEnabled = false

            PostManager.shared.updateLikes(
                postID: postID, likeAction: likeAction
            ) { result in

                switch result {

                case .success(let action):

                    print(action)

                    cell.likeButton.isEnabled = true

                case .failure(let error):

                    print(error)

                    cell.likeButton.isEnabled = true
                }
            }
        }

        cell.commentHandler = { self.goToPostDetail(index: indexPath.row) }

        cell.optionHandler = {
            self.openOptionMenu(index: indexPath.row)
        }

        // go to user's profile when tapping image, name, and time

        let tapGoToProfileGesture = UITapGestureRecognizer(target: self, action: #selector(goToProfile(_:)))
        let tapGoToProfileGesture2 = UITapGestureRecognizer(target: self, action: #selector(goToProfile(_:)))
        let tapGoToProfileGesture3 = UITapGestureRecognizer(target: self, action: #selector(goToProfile(_:)))
        let tapGoToCardTopicGesture = UITapGestureRecognizer(target: self, action: #selector(goToCardTopicPage(_:)))

        cell.userImageView.addGestureRecognizer(tapGoToProfileGesture)
        cell.userImageView.isUserInteractionEnabled = true
        cell.userNameLabel.addGestureRecognizer(tapGoToProfileGesture2)
        cell.userNameLabel.isUserInteractionEnabled = true
        cell.timeLabel.addGestureRecognizer(tapGoToProfileGesture3)
        cell.timeLabel.isUserInteractionEnabled = true
        cell.cardStackView.addGestureRecognizer(tapGoToCardTopicGesture)
        cell.cardStackView.isUserInteractionEnabled = true

        cell.userImageView.tag = indexPath.row
        cell.userNameLabel.tag = indexPath.row
        cell.timeLabel.tag = indexPath.row
        cell.cardStackView.tag = indexPath.row

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        goToPostDetail(index: indexPath.row)
    }
}

extension ExploreViewController {

    func setupFilterView() {

        view.addSubview(filterView)
        filterView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            filterView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            filterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterView.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -16)
        ])
    }

    func setupEmptyAnimation() {

        let emptyAnimationView = LottieAnimationView(animationName: "empty")
        let reminderLabel = UILabel()

        view.addSubview(emptyReminderView)
        view.bringSubviewToFront(emptyReminderView)
        emptyReminderView.translatesAutoresizingMaskIntoConstraints = false
        emptyReminderView.addSubview(emptyAnimationView)
        emptyReminderView.addSubview(reminderLabel)
        emptyAnimationView.translatesAutoresizingMaskIntoConstraints = false
        reminderLabel.translatesAutoresizingMaskIntoConstraints = false

        reminderLabel.text = "還沒有追蹤的用戶...QQ"
        reminderLabel.textColor = .gray
        reminderLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)

        NSLayoutConstraint.activate([
            emptyReminderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyReminderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyReminderView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            emptyReminderView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),

            emptyAnimationView.centerXAnchor.constraint(equalTo: emptyReminderView.centerXAnchor),
            emptyAnimationView.centerYAnchor.constraint(equalTo: emptyReminderView.centerYAnchor),
            emptyAnimationView.heightAnchor.constraint(equalTo: emptyReminderView.heightAnchor, multiplier: 0.8),
            emptyAnimationView.widthAnchor.constraint(equalTo: emptyReminderView.widthAnchor),

            reminderLabel.topAnchor.constraint(equalTo: emptyAnimationView.bottomAnchor),
            reminderLabel.centerXAnchor.constraint(equalTo: emptyReminderView.centerXAnchor)
        ])
    }
}
