//
//  ExploreViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import Foundation
import UIKit
import PhotosUI
import Vision

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

        goToWritePage()
    }

    func goToWritePage() {

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
}

extension ExploreViewController: SelectionViewDataSource, SelectionViewDelegate {

    func numberOfButtonsAt(_ view: SelectionView) -> Int { filters.count }

    // swiftlint:disable identifier_name
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ExploreTableViewCell.identifier,
            for: indexPath) as? ExploreTableViewCell else {

                fatalError("Cannot create cell.")
            }

        let row = indexPath.row
        let post = postList[row]

        if let likeUserList = postList[row].likeUser {

            isLikePost = likeUserList.contains("test123456") ?
            true : false

        } else {

            isLikePost = false
        }

        cell.hideSelectionStyle()

        cell.layoutCell(
            userImage: UIImage.asset(.testProfile),
            userName: "Morgan Yu",
            post: post,
            hasLiked: isLikePost
        )

        cell.likeHandler = {

            // When tapping on the like button, check if the user has likedPost
            if let likeUserList = self.postList[row].likeUser {

                self.isLikePost = likeUserList.contains("test123456") ?
                true : false

            } else {

                self.isLikePost = false
            }

            guard let postID = self.postList[row].postID else { return }

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

        detailVC.postID = postList[row].postID ?? ""
        detailVC.userImage = UIImage.asset(.testProfile)
        detailVC.userName = "Morgan Yu"
        detailVC.time = postList[row].createdTime
        detailVC.content = postList[row].content
        detailVC.imageUrl = postList[row].imageUrl
        detailVC.uid = postList[row].uid

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
