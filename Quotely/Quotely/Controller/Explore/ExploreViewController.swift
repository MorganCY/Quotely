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

        fetchPost()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)

        fetchPost()
    }

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

        if let likeUserList = postList[row].likeUser {

            likedPost = likeUserList.contains("test123456") ? true : false
        }

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

//        cell.clickLike = {
//
//            guard let postID = self.postList[self.tappedCell].postID else { return }
//
//            PostManager.shared.updateLikes(
//                postID: postID
//            ) { result in
//
//                switch result {
//
//                case .success():
//
//                    cell.likeButton.setImage(UIImage.sfsymbol(.heartSelected), for: .normal)
//                    cell.likeButton.tintColor = .red
//
//                case .failure(let error):
//
//                    print(error)
//                }
//            }
//        }

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

        detailVC.postID = postList[row].postID
        detailVC.userImage = UIImage.asset(.testProfile)
        detailVC.userName = "Morgan Yu"
        detailVC.time = postList[row].createdTime
        detailVC.content = postList[row].content
        detailVC.imageUrl = postList[row].imageUrl
        detailVC.likeNumber = nil

        if let likeUserList = postList[row].likeUser {

            detailVC.hasLiked = likeUserList.contains("test123456") ? true : false
        }

        navigationController?.pushViewController(detailVC, animated: true)
    }
}
