//
//  ExploreViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import Foundation
import UIKit

class ExploreViewController: UIViewController {

    let filters: [PostManager.FilterType] = [.latest, .popular, .following]
    var currentFilter: PostManager.FilterType = .latest {
        didSet {
            addPostListener(type: currentFilter)
        }
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.registerCellWithNib(
                identifier: ExploreTableViewCell.identifier,
                bundle: nil)
            tableView.separatorStyle = .none
        }
    }

    let filterView = SelectionView()

    var postList: [Post] = [] {
        didSet {
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
            color: .M1!
        )

        setupFilterView()

        fetchPost(type: .latest)
    }

    // MARK: Data
    func addPostListener(type: PostManager.FilterType) {

        PostManager.shared.listenToPostUpdate(type: type, uid: nil) { result in

            switch result {

            case .success(let posts):

                self.postList = posts

            case .failure(let error):

                print(error)
            }
        }
    }

    func fetchPost(type: PostManager.FilterType) {

        PostManager.shared.fetchPost(type: type, uid: nil) { result in

            switch result {

            case .success(let posts):

                self.postList = posts

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

    func buttonTitle(_ view: SelectionView, index: Int) -> String {
        filters[index].rawValue
    }

    func buttonColor(_ view: SelectionView) -> UIColor { .gray }

    func indicatorColor(_ view: SelectionView) -> UIColor { .lightGray }

    func indicatorWidth(_ view: SelectionView) -> CGFloat { 0.4 }

    func didSelectButtonAt(_ view: SelectionView, at index: Int) {

        switch index {

        case 0: return currentFilter = .latest
        case 1: return currentFilter = .popular
        case 2: return currentFilter = .following
        default: return currentFilter = .latest
        }
    }

    func shouldSelectButtonAt(_ view: SelectionView, at index: Int) -> Bool { true }
}

// MARK: TableView
extension ExploreViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        postList.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        UITableView.automaticDimension
    }

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

        UserManager.shared.fetchUserInfo(uid: post.uid) { result in

            switch result {

            case .success(let user):
                cell.layoutCell(
                    userImageUrl: user.profileImageUrl ?? "",
                    userName: user.name ?? "",
                    post: post,
                    hasLiked: self.isLikePost
                )

            case .failure(let error):
                print(error)
            }
        }

        if let likeUserList = post.likeUser {

            isLikePost = likeUserList.contains("test123456") ?
            true : false

        } else {

            isLikePost = false
        }

        cell.hideSelectionStyle()

        cell.likeHandler = {

            // When tapping on the like button, check if the user has likedPost

            if let likeUserList = post.likeUser {

                self.isLikePost = likeUserList.contains("test123456") ?
                true : false

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
                    self.fetchPost(type: self.currentFilter)

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
        let post = postList[indexPath.row]

        detailVC.postID = post.postID ?? ""
        detailVC.postAuthorUid = post.uid
        detailVC.userImage = UIImage.asset(.testProfile)
        detailVC.userName = "Morgan Yu"
        detailVC.time = post.createdTime
        detailVC.content = post.content
        detailVC.imageUrl = post.imageUrl
        detailVC.postAuthorUid = post.uid

        if let likeUserList = postList[row].likeUser {

            detailVC.hasLiked = likeUserList.contains("test123456")
        }

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
