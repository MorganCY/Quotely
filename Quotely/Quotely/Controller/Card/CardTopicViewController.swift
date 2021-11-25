//
//  CardTopicViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/9.
//

import Foundation
import UIKit

class CardTopicViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.registerCellWithNib(identifier: CardTopicTableViewCell.identifier, bundle: nil)
            tableView.registerHeaderWithNib(identifier: CardTopicTableViewHeader.identifier, bundle: nil)
            tableView.setSpecificCorner(corners: [.topLeft, .topRight])
            tableView.backgroundColor = .M3
        }
    }

    @IBOutlet weak var backgroundImageView: UIImageView!

    let visitorUid = SignInManager.shared.visitorUid ?? ""

    // if user comes from explore page, get card ID

    var cardID: String? {
        didSet {
            guard let cardID = cardID else {return }
            fetchCardData(cardID: cardID)
        }
    }

    // if user comes from favorite card list, get card data

    var card: Card? {
        didSet {
            guard let cardID = card?.cardID else { return }
            fetchPostList(cardID: cardID)
        }
    }

    var postList: [Post]?

    var userList: [User]? {
        didSet {
            tableView.reloadData()
        }
    }

    var isLikePost = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundImage()
        setupNavigationBackButton()
    }

    func setupBackgroundImage() {

        let images = [UIImage.asset(.bg1), UIImage.asset(.bg2), UIImage.asset(.bg3), UIImage.asset(.bg4)]
        backgroundImageView.image = images[Int.random(in: 0...3)]
    }

    func fetchCardData(cardID: String) {

        CardManager.shared.fetchSpecificCard(cardID: cardID) { result in

            switch result {

            case .success(let card):

                self.card = card

                self.fetchPostList(cardID: card.cardID ?? "")

            case .failure(let error):

                print(error)

                DispatchQueue.main.async {
                    Toast.showFailure(text: "片語資料載入異常")
                }
            }
        }
    }

    func fetchPostList(cardID: String) {

        PostManager.shared.fetchCardPost(cardID: cardID) { result in

            switch result {

            case .success(let postList):

                guard let postList = postList else { return }

                self.postList = postList

                self.fetchUserList(postList: postList)

            case .failure(let error):

                print(error)

                DispatchQueue.main.async {
                    Toast.showFailure(text: "想法資料載入異常")
                }
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

    func updateUserLikeCardList(cardID: String, likeAction: FirebaseAction) {

        UserManager.shared.updateFavoriteCard(
            cardID: cardID,
            likeAction: likeAction
        ) { result in

            switch result {

            case .success(let success):
                print(success)

            case .failure(let error):
                print(error)
            }
        }
    }

    func updateCard(cardID: String, likeAction: FirebaseAction) {

        FirebaseManager.shared.updateFieldNumber(
            collection: .cards,
            targetID: cardID,
            action: likeAction,
            updateType: .like
        ) { result in

            switch result {

            case .success(let successStatus):
                print(successStatus)

            case .failure(let error):
                print(error)
            }
        }
    }

    func goToCardPostPage(index: Int) {

        guard let cardPostVC =
                UIStoryboard.explore.instantiateViewController(
                    withIdentifier: PostDetailViewController.identifier
                ) as? PostDetailViewController
        else { return }

        let post = postList?[index]
        let user = userList?[index]

        cardPostVC.post = post
        cardPostVC.postAuthor = user
        cardPostVC.isLike = isLikePost

        navigationController?.pushViewController(cardPostVC, animated: true)
    }

    func tapShareButton() {

        guard let shareVC =
                UIStoryboard.share.instantiateViewController(
                    withIdentifier: ShareViewController.identifier
                ) as? ShareViewController
        else { return }

        let navigationVC = BaseNavigationController(rootViewController: shareVC)

        guard let card = card else { return }

        shareVC.templateContent = [
            card.content.replacingOccurrences(of: "\\n", with: "\n"),
            card.author
        ]

        navigationVC.modalPresentationStyle = .fullScreen

        present(navigationVC, animated: true)
    }

    func tapLikeButton() {

        guard let cardID = card?.cardID else {

            DispatchQueue.main.async { Toast.showFailure(text: "收藏失敗") }

            return
        }

        updateUserLikeCardList(cardID: cardID, likeAction: .positive)
        updateCard(cardID: cardID, likeAction: .positive)
        card?.likeNumber += 1

        DispatchQueue.main.async { Toast.showSuccess(text: "已收藏") }
    }

    func tapWriteButton() {

        guard let writeVC =
                UIStoryboard.write.instantiateViewController(
                    withIdentifier: CardWriteViewController.identifier
                ) as? CardWriteViewController
        else { return }

        let nav = BaseNavigationController(rootViewController: writeVC)

        writeVC.card = card

        nav.modalPresentationStyle = .fullScreen

        present(nav, animated: true)
    }

    func setupNavigationBackButton() {

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage.asset(.back).withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(backToPreviousVC(_:))
        )
    }

    @objc func backToPreviousVC(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    func openOptionMenu(
        blockedUid: String,
        index: Int?,
        completion: (() -> Void)?
    ) {

        let blockUserAction = UIAlertAction(
            title: "檢舉並封鎖用戶",
            style: .destructive
        ) { _ in

            if let followingList = UserManager.shared.visitorUserInfo?.followingList {

                if followingList.contains(blockedUid) {

                    self.unfollowUser(blockedUid: blockedUid)
                }
            }

            UserManager.shared.updateUserList(
                userAction: .block,
                visitedUid: blockedUid,
                action: .positive
            ) { result in

                switch result {

                case .success(let success):

                    print(success)

                    if let index = index {

                        self.postList?.remove(at: index)
                        self.userList?.remove(at: index)

                    } else {

                        guard let completion = completion else { return }

                        completion()
                    }

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

    func unfollowUser(blockedUid: String) {
        UserManager.shared.updateUserList(
            userAction: .follow,
            visitedUid: blockedUid,
            action: .negative
        ) { result in

            switch result {

            case .success(let success): print(success)

            case .failure(let error): print(error)
            }
        }
    }
}

extension CardTopicViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { postList?.count ?? 0 }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CardTopicTableViewHeader.identifier
        ) as? CardTopicTableViewHeader else {

            fatalError("Cannot create header")
        }

        guard let card = card else {

            return UIView()
        }

        header.layoutHeader(card: card)

        header.shareHandler = { self.tapShareButton() }

        header.likeHandler = { self.tapLikeButton() }

        header.writeHandler = { self.tapWriteButton() }

        return header
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: CardTopicTableViewCell.identifier, for: indexPath
        ) as? CardTopicTableViewCell else {

            fatalError("Cannot create cell")
        }

        if let userList = userList,
           let postList = postList {

            cell.layoutCell(user: userList[indexPath.row], post: postList[indexPath.row])
        }

        cell.hideSelectionStyle()

        cell.optionHandler = {

            self.openOptionMenu(
                blockedUid: self.userList?[indexPath.row].uid ?? "",
                index: indexPath.row, completion: nil
            )
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let post = postList?[indexPath.row]

        if let likeUserList = post?.likeUser {

            isLikePost = likeUserList.contains(visitorUid)

        } else {

            isLikePost = false
        }

        goToCardPostPage(index: indexPath.row)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat { 250 }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
