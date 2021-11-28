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

    var postListener: ListenerRegistration?
    var visitorFollowingList: [String] = []
    let filters: [PostManager.PilterType] = [.latest, .following]
    var currentFilter: PostManager.PilterType = .latest {
        didSet {
            setupFilterResult()
        }
    }

    let loadingAnimationView = LottieAnimationView(animationName: "greenLoading")
    let emptyReminderView = LottieAnimationView(animationName: "empty")

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            setupTableView()
        }
    }

    let filterView = SelectionView()

    var postList: [Post] = []

    var userList: [User]? {
        didSet {
            tableView.reloadData()
        }
    }

    var isLikePost = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupFilterView()
        currentFilter = .latest
        setupLoadingAnimation()
        view.backgroundColor = .M1
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        visitorFollowingList = UserManager.shared.visitorUserInfo?.followingList ?? [""]
        addPostListenerAccordingToFollowingList()
    }

    func addPostListener(
        type: PostManager.PilterType,
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
                self.loadingAnimationView.removeFromSuperview()
                Toast.showFailure(text: ToastText.failToDownload.rawValue)
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
                        Toast.showFailure(text: ToastText.failToDownload.rawValue)
                        group.leave()
                    }
                }
            }

            group.notify(queue: DispatchQueue.main) {

                self.userList = userList

                self.loadingAnimationView.removeFromSuperview()
            }
        }
    }

    func setupFilterResult() {

        if currentFilter == .following,
           visitorFollowingList.count > 0 {
            postListener = addPostListener(type: currentFilter,
                                       uid: SignInManager.shared.visitorUid,
                                       followingList: visitorFollowingList)
        } else {
            postListener = addPostListener(type: currentFilter, uid: nil,
                                       followingList: nil)
        }

        if currentFilter == .following,
           visitorFollowingList.count == 0 {

            setupEmptyReminderView()

        } else {

            emptyReminderView.removeFromSuperview()
        }
    }

    func addPostListenerAccordingToFollowingList() {

        if visitorFollowingList.count > 0 {
            postListener = addPostListener(
                type: currentFilter,
                uid: SignInManager.shared.visitorUid,
                followingList: visitorFollowingList
            )
        } else if visitorFollowingList.count == 0 {
            postListener = addPostListener(
                type: currentFilter,
                uid: nil,
                followingList: nil
            )
        }
    }

    func goToPostDetail(index: Int) {

        guard let detailVC =
                UIStoryboard.explore.instantiateViewController(
                    withIdentifier: PostDetailViewController.identifier
                ) as? PostDetailViewController
        else { return }

        if let likeUserList = postList[index].likeUser {

            isLikePost = likeUserList.contains(SignInManager.shared.visitorUid ?? "")

        } else {

            isLikePost = false
        }

        guard let userList = userList else {
            return
        }

        detailVC.post = postList[index]
        detailVC.postAuthor = userList[index]
        detailVC.isLikePost = isLikePost

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

            UserManager.shared.updateUserList(
                userAction: .block,
                visitedUid: self.userList?[index].uid ?? "",
                action: .positive
            ) { result in

                switch result {

                case .success(let success):

                    print(success)

                    self.postListener = self.addPostListener(type: self.currentFilter, uid: nil, followingList: nil)

                case .failure(let error):
                    print(error)
                    Toast.showFailure(text: ToastText.failToBlock.rawValue)
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

        UserManager.shared.updateUserList(
            userAction: .follow,
            visitedUid: self.userList?[index].uid ?? "",
            action: .negative
        ) { result in

            switch result {

            case . success(let success): print(success)

            case .failure(let error): print(error)
            }
        }
    }

    func updatePostLike(postID: String, likeAction: FirebaseAction, completion: @escaping () -> Void) {

        FirebaseManager.shared.updateFieldNumber(
            collection: .posts,
            targetID: postID,
            action: likeAction,
            updateType: .like
        ) { result in

            switch result {

            case .success(let successStatus):
                print(successStatus)
                completion()

            case .failure(let error):
                print(error)
                completion()
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
            postListener?.remove()
            currentFilter = .latest
        case 1:
            postListener?.remove()
            currentFilter = .following
        default:
            postListener?.remove()
            currentFilter = .latest        }
    }

    func shouldSelectButtonAt(_ view: SelectionView, at index: Int) -> Bool { true }
}

// MARK: TableView
extension ExploreViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { postList.count }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { 200 }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

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

        guard let userList = userList else {
            return UITableViewCell()
        }

        cell.layoutCell(
            userInfo: userList[indexPath.row],
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

            let likeAction: FirebaseAction = self.isLikePost
            ? .negative : .positive

            cell.likeButton.isEnabled = false

            self.updatePostLike(postID: postID, likeAction: likeAction) {
                cell.likeButton.isEnabled = true
            }
        }

        cell.commentHandler = { self.goToPostDetail(index: indexPath.row) }

        cell.optionHandler = {
            self.openOptionMenu(index: indexPath.row)
        }

        let goToProfileGesture = UITapGestureRecognizer(target: self, action: #selector(tapUserProfile(_:)))
        let goToCardTopicGesture = UITapGestureRecognizer(target: self, action: #selector(tapCardTopicView(_:)))

        cell.userStackView.addGestureRecognizer(goToProfileGesture)
        cell.userStackView.isUserInteractionEnabled = true
        cell.cardStackView.addGestureRecognizer(goToCardTopicGesture)
        cell.cardStackView.isUserInteractionEnabled = true

        cell.userStackView.tag = indexPath.row
        cell.cardStackView.tag = indexPath.row

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        goToPostDetail(index: indexPath.row)
    }
}

extension ExploreViewController {

    @objc func tapAddPostButton(_ sender: UIBarButtonItem) {

        guard let writeVC =
                UIStoryboard.write.instantiateViewController(
                    withIdentifier: AddPostViewController.identifier
                ) as? AddPostViewController
        else { return }

        let nav = BaseNavigationController(rootViewController: writeVC)

        nav.modalPresentationStyle = .fullScreen

        present(nav, animated: true)
    }

    @objc func tapUserProfile(_ gestureRecognizer: UITapGestureRecognizer) {

        guard let profileVC = UIStoryboard
                .profile
                .instantiateViewController(withIdentifier: String(describing: ProfileViewController.self)
        ) as? ProfileViewController else {

            return
        }

        guard let myVC = UIStoryboard
                .profile
                .instantiateViewController(withIdentifier: String(describing: MyViewController.self)
        ) as? MyViewController else {

            return
        }

        guard let currentRow = gestureRecognizer.view?.tag else { return }

        profileVC.visitedUid = postList[currentRow].uid

        if postList[currentRow].uid == UserManager.shared.visitorUserInfo?.uid {

            navigationController?.pushViewController(myVC, animated: true)

        } else {

            navigationController?.pushViewController(profileVC, animated: true)
        }
    }

    @objc func tapCardTopicView(_ gestureRecognizer: UITapGestureRecognizer) {

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

    func setupNavigation() {

        navigationItem.title = "想法"

        navigationItem.setupRightBarButton(
            image: UIImage.sfsymbol(.addPost),
            text: nil,
            target: self,
            action: #selector(tapAddPostButton(_:)),
            color: .white)
    }

    func setupTableView() {

            tableView.dataSource = self
            tableView.delegate = self
            tableView.registerCellWithNib(
                identifier: ExploreTableViewCell.identifier,
                bundle: nil)
            tableView.separatorStyle = .none
            tableView.setSpecificCorner(corners: [.topLeft, .topRight])
    }

    func setupFilterView() {

        view.addSubview(filterView)
        filterView.translatesAutoresizingMaskIntoConstraints = false

        filterView.delegate = self
        filterView.dataSource = self

        NSLayoutConstraint.activate([
            filterView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            filterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterView.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -16)
        ])
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

    func setupEmptyReminderView() {

        let reminderLabel = UILabel()

        view.addSubview(emptyReminderView)
        view.bringSubviewToFront(emptyReminderView)
        emptyReminderView.translatesAutoresizingMaskIntoConstraints = false
        emptyReminderView.addSubview(reminderLabel)
        reminderLabel.translatesAutoresizingMaskIntoConstraints = false

        reminderLabel.text = "還沒有追蹤的用戶...QQ"
        reminderLabel.textColor = .gray
        reminderLabel.font = UIFont.setBold(size: 20)

        NSLayoutConstraint.activate([
            emptyReminderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyReminderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyReminderView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            emptyReminderView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),

            reminderLabel.topAnchor.constraint(equalTo: emptyReminderView.bottomAnchor),
            reminderLabel.centerXAnchor.constraint(equalTo: emptyReminderView.centerXAnchor)
        ])
    }
}
