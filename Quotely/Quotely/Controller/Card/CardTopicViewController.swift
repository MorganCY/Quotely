//
//  CardTopicViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/9.
//

import Foundation
import UIKit

class CardTopicViewController: UIViewController {

    var card: Card?

    var postList: [Post]?

    var userList: [User]? {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.reloadData()
        }
    }

    var isLikePost = false

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.registerCellWithNib(identifier: CardTopicTableViewCell.identifier, bundle: nil)
            tableView.registerHeaderWithNib(identifier: CardTopicTableViewHeader.identifier, bundle: nil)
            tableView.setSpecificCorner(corners: [.topLeft, .topRight])
            tableView.backgroundColor = .M3
        }
    }

    @IBOutlet weak var backgroundImageView: UIImageView!

    override func viewDidLoad() {

        setupBackgroundImage()

        setupBackButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchCardData()
    }

    func setupBackgroundImage() {

        let images = [UIImage.asset(.bg1), UIImage.asset(.bg2), UIImage.asset(.bg3), UIImage.asset(.bg4)]

        backgroundImageView.image = images[Int.random(in: 0...3)]
    }

    func fetchCardData() {

        CardManager.shared.fetchSpecificCard(cardID: card?.cardID ?? "") { result in

            switch result {

            case . success(let card):

                self.card = card

                self.fetchPostList(card: card)

            case .failure(let error):

                print(error)

                Toast.showFailure(text: "載入資料失敗")
            }
        }
    }

    func fetchPostList(card: Card) {

        PostManager.shared.fetchCardPost(cardID: card.cardID ?? "") { result in

            switch result {

            case .success(let postList):

                self.postList = postList

                self.fetchUserList(postList: postList)

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

    func goToCardPostPage(index: Int) {

        guard let cardPostVC =
                UIStoryboard.explore
                .instantiateViewController(
                    withIdentifier: String(describing: PostDetailViewController.self)
                ) as? PostDetailViewController else {

                    return
                }

        let post = postList?[index]
        let user = userList?[index]

        cardPostVC.post = post
        cardPostVC.postAuthor = user
        cardPostVC.isLike = isLikePost

        navigationController?.pushViewController(cardPostVC, animated: true)
    }

    func setupBackButton() {

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage.asset(.back)?.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(backToPreviousVC(_:))
        )
    }

    @objc func backToPreviousVC(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension CardTopicViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { card?.postList?.count ?? 0 }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CardTopicTableViewHeader.identifier
        ) as? CardTopicTableViewHeader else {

            fatalError("Cannot create header")
        }

        guard let card = card else {

            fatalError("Cannot create header")
        }

        header.layoutHeader(card: card)

        return header
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: CardTopicTableViewCell.identifier, for: indexPath
        ) as? CardTopicTableViewCell else {

            fatalError("Cannot create cell")
        }

        guard let userList = userList,
              let postList = postList else {

                  fatalError("Cannot create cell")
              }

        cell.layoutCell(user: userList[indexPath.row], post: postList[indexPath.row])

        cell.hideSelectionStyle()

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let post = postList?[indexPath.row]

        if let likeUserList = post?.likeUser {

            isLikePost = likeUserList.contains(SignInManager.shared.uid ?? "")

        } else {

            isLikePost = false
        }

        goToCardPostPage(index: indexPath.row)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat { 250 }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }

//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { 200 }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
