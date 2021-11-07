//
//  ExploreViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import Foundation
import UIKit
import FirebaseFirestore

class ExploreViewController: UIViewController {

    let visitorUid = SignInManager.shared.uid

    var listener: ListenerRegistration?

    var visitorFollowingList: [String] = []

    let filters: [PostManager.FilterType] = [.latest, .popular, .following]
    var currentFilter: PostManager.FilterType = .latest {
        didSet {
            if currentFilter == .following {
                listener = addPostListener(type: currentFilter, uid: visitorUid, followingList: visitorFollowingList)
            } else {
                listener = addPostListener(type: currentFilter, uid: nil, followingList: nil)
            }
        }
    }

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

    // MARK: LiftCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "探索"

        filterView.delegate = self
        filterView.dataSource = self

        navigationItem.setupRightBarButton(
            image: UIImage.sfsymbol(.addPost)!,
            text: nil,
            target: self,
            action: #selector(addPost(_:)),
            color: .white
        )

        setupFilterView()

        fetchVisitorFollowingList()

        view.backgroundColor = .M1
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        listener = addPostListener(type: currentFilter, uid: visitorUid, followingList: visitorFollowingList)
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

    func fetchVisitorFollowingList() {

        UserManager.shared.fetchUserInfo(
            uid: visitorUid ?? "") { result in
                switch result {

                case .success(let user):

                    self.visitorFollowingList = user.following ?? [""]

                case .failure(let error):
                    print(error)
                }
            }
    }

    @objc func addPost(_ sender: UIBarButtonItem) {

        guard let writeVC =
                UIStoryboard.write
                .instantiateViewController(
                    withIdentifier: String(describing: WriteViewController.self)
                ) as? WriteViewController else {

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

        self.show(profileVC, sender: nil)
    }
}

extension ExploreViewController: SelectionViewDataSource, SelectionViewDelegate {

    func numberOfButtonsAt(_ view: SelectionView) -> Int { filters.count }

    func buttonStyle(_ view: SelectionView) -> ButtonStyle { .text }

    func buttonTitle(_ view: SelectionView, index: Int) -> String { filters[index].rawValue }

    func buttonColor(_ view: SelectionView) -> UIColor { .white }

    func indicatorColor(_ view: SelectionView) -> UIColor { .M3! }

    func indicatorWidth(_ view: SelectionView) -> CGFloat { 0.4 }

    func didSelectButtonAt(_ view: SelectionView, at index: Int) {

        switch index {

        case 0:
            listener?.remove()
            currentFilter = .latest
        case 1:
            listener?.remove()
            currentFilter = .popular
        case 2:
            listener?.remove()
            currentFilter = .following
        default:
            listener?.remove()
            currentFilter = .latest
        }
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

            isLikePost = likeUserList.contains(visitorUid ?? "")

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

                self.isLikePost = likeUserList.contains(SignInManager.shared.uid ?? "")

            } else {

                self.isLikePost = false
            }

            guard let postID = post.postID else { return }

            let likeAction: LikeAction = self.isLikePost
            ? .dislike : .like

            PostManager.shared.updateLikes(
                postID: postID, likeAction: likeAction
            ) { result in

                switch result {

                case .success(let action):

                    print(action)

                case .failure(let error):

                    print(error)
                }
            }
        }

        // go to user's profile when tapping image, name, and time

        let tapGoToProfileGesture = UITapGestureRecognizer(target: self, action: #selector(goToProfile(_:)))
        let tapGoToProfileGesture2 = UITapGestureRecognizer(target: self, action: #selector(goToProfile(_:)))
        let tapGoToProfileGesture3 = UITapGestureRecognizer(target: self, action: #selector(goToProfile(_:)))

        cell.userImageView.addGestureRecognizer(tapGoToProfileGesture)
        cell.userImageView.isUserInteractionEnabled = true
        cell.userNameLabel.addGestureRecognizer(tapGoToProfileGesture2)
        cell.userNameLabel.isUserInteractionEnabled = true
        cell.timeLabel.addGestureRecognizer(tapGoToProfileGesture3)
        cell.timeLabel.isUserInteractionEnabled = true

        cell.userImageView.tag = indexPath.row
        cell.userNameLabel.tag = indexPath.row
        cell.timeLabel.tag = indexPath.row

        return cell
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

        if let likeUserList = postList[row].likeUser {

            isLikePost = likeUserList.contains(visitorUid ?? "")

        } else {

            isLikePost = false
        }

        detailVC.post = postList[row]
        detailVC.postAuthor = userList[row]
        detailVC.isLike = isLikePost

        navigationController?.pushViewController(detailVC, animated: true)
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
}
