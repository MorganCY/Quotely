//
//  ExploreViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import Foundation
import UIKit

class ExploreViewController: UIViewController {

    var postList: [Post] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    var likedPost = false

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addPostButton: UIButton!

    // MARK: LiftCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerCellWithNib(
            identifier: ExploreTableViewCell.identifier,
            bundle: nil)

        tableView.dataSource = self

        tableView.delegate = self

        tableView.separatorStyle = .none

        navigationItem.title = "探索"
    }

    override func viewDidLayoutSubviews() {

        setupAddPostButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchPost()
    }

    // MARK: Data
    func fetchPost() {

        PostManager.shared.fetchPost { result in

            switch result {

            case .success(let posts):

                self.postList = posts

            case .failure(let error):

                print("fetchData.failure: \(error)")
            }
        }
    }
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

        let likeUser = postList[row].likeUser

        // When displaying the reusable cell, check if the user has likedPost
        likedPost = likeUser.contains("test123456") ?
        true : false

        cell.layoutCell(
            userImage: UIImage.asset(.testProfile),
            userName: "Morgan Yu",
            time: Date.dateFormatter.string(from: Date.init(milliseconds: postList[row].createdTime)),
            content: postList[row].content,
            postImageUrl: postList[row].imageUrl,
            likeNumber: nil,
            commentNumber: nil,
            hasLiked: likedPost
        )

        cell.selectionStyle = .none

        cell.likeHandler = {

            // When tapping on the like button, check if the user has likedPost
            self.likedPost = likeUser.contains("test123456") ?
            true : false

            guard let postID = self.postList[row].postID else { return }

            let likeAction: LikeAction = self.likedPost
            ? .dislike : .like

            PostManager.shared.updateLikes(
                postID: postID, likeAction: likeAction
            ) { result in

                switch result {

                case .success(let action):

                    print(action)

                    self.fetchPost()

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

        let likeUserList = postList[row].likeUser

        detailVC.hasLiked = likeUserList.contains("test123456") ? true : false

        navigationController?.pushViewController(detailVC, animated: true)
    }

    // MARK: SetupViews
    func setupAddPostButton() {

        addPostButton.layer.cornerRadius = addPostButton.frame.width / 2

        addPostButton.layer.shadowColor = UIColor.gray.cgColor

        addPostButton.layer.shadowOpacity = 0.7

        addPostButton.layer.shadowOffset = CGSize(width: 3, height: 3)

        addPostButton.addTarget(self, action: #selector(addArticle(_:)), for: .touchUpInside)
    }

    @objc func addArticle(_ sender: UIButton) {

        guard let writeVC = UIStoryboard.write.instantiateViewController(
            withIdentifier: String(describing: WriteViewController.self)
        ) as? WriteViewController else { return }

        let nav = UINavigationController(rootViewController: writeVC)

        nav.modalPresentationStyle = .automatic

        self.navigationController?.present(nav, animated: true)
    }
}
