//
//  FavoriteCardViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/28.
//

import Foundation
import UIKit
import AVFoundation

class FavoriteCardViewController: UIViewController {

    let visitorUid = SignInManager.shared.visitorUid ?? ""

    var likeCardList = [Card]() {
        didSet {
            tableView.reloadData()
        }
    }

    var isFromWriteVC = false {
        didSet {
            navigationTitle = isFromWriteVC ? "點選引用片語" : "收藏清單"
        }
    }

    var navigationTitle = "收藏清單"

    var passedContentText = ""

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.registerCellWithNib(
                identifier: FavoriteCardTableViewCell.identifier,
                bundle: nil
            )
            tableView.backgroundColor = .clear
            tableView.separatorStyle = .none
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchUserInfo()

        view.backgroundColor = .M3

        navigationController?.setupBackButton(color: .white)
    }

    override func viewWillAppear(_ animated: Bool) {

        tabBarController?.tabBar.isHidden = true

        navigationItem.title = navigationTitle
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        tabBarController?.tabBar.isHidden = false
    }

    func fetchUserInfo() {

        UserManager.shared.fetchUserInfo(uid: visitorUid) { result in

            switch result {

            case .success(let userInfo):
                userInfo.likeCardList?.forEach({
                    self.fetchFavoriteCard(cardID: $0)
                })

            case .failure(let error):
                print(error)
            }
        }
    }

    func fetchFavoriteCard(cardID: String) {
        CardManager.shared.fetchSpecificCard(cardID: cardID) { result in

            switch result {

            case .success(let card):
                self.likeCardList.append(card)

            case .failure(let error):
                print(error)
            }
        }
    }

    func disLikeCard(index: Int) {

        let card = likeCardList[index]

        UserManager.shared.updateFavoriteCard(
            uid: visitorUid,
            cardID: card.cardID ?? "",
            likeAction: .dislike
        ) { result in

                switch result {

                case .success(let success):
                    print(success)
                    self.updateCard(cardID: card.cardID ?? "")
                    self.likeCardList.remove(at: index)

                case .failure(let error):
                    print(error)
                }
            }
    }

    func updateCard(cardID: String) {

        CardManager.shared.updateCards(
            cardID: cardID,
            likeAction: .dislike,
            uid: visitorUid) { result in

                switch result {

                case .success(let success):
                    print(success)

                case .failure(let error):
                    print(error)
                }
            }
    }

    func goToCardWritePage(index: Int) {

        guard let writeVC =
                UIStoryboard.write
                .instantiateViewController(
                    withIdentifier: String(describing: CardWriteViewController.self)
                ) as? CardWriteViewController else {

                    return
                }

        let card = likeCardList[index]
        let navVC = BaseNavigationController(rootViewController: writeVC)

        writeVC.card = card
        writeVC.contentFromFavCard = passedContentText

        navVC.modalPresentationStyle = .fullScreen

        present(navVC, animated: true)
    }

    func goToCardTopicPage(index: Int) {

        guard let cardTopicVC =
                UIStoryboard.card
                .instantiateViewController(
                    withIdentifier: String(describing: CardTopicViewController.self)
                ) as? CardTopicViewController else {

                    return
                }

        let card = likeCardList[index]

        cardTopicVC.card = card

        navigationController?.pushViewController(cardTopicVC, animated: true)
    }

    func goToSharePage(content: String, author: String) {

        guard let shareVC =
                UIStoryboard.share
                .instantiateViewController(
                    withIdentifier: String(describing: ShareViewController.self)
                ) as? ShareViewController else {

            return
        }

        let nav = BaseNavigationController(rootViewController: shareVC)

        shareVC.templateContent = [
            content.replacingOccurrences(of: "\\n", with: "\n"),
            author
        ]

        nav.modalPresentationStyle = .fullScreen

        present(nav, animated: true)
    }
}

extension FavoriteCardViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        likeCardList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FavoriteCardTableViewCell.identifier,
            for: indexPath
        ) as? FavoriteCardTableViewCell else {

            fatalError("Cannot crate cell")
        }

        cell.layoutCell(
            content: likeCardList[indexPath.row].content.replacingOccurrences(of: "\\n", with: "\n"),
            author: likeCardList[indexPath.row].author
        )

        cell.hideSelectionStyle()

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch isFromWriteVC {

        case true:

            goToCardWritePage(index: indexPath.row)

        case false:

            goToCardTopicPage(index: indexPath.row)
        }
    }

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        let comment = UIAction(title: "查看討論",
                               image: UIImage.sfsymbol(.comment)) { _ in

            self.goToCardTopicPage(index: indexPath.row)
        }

        let share = UIAction(title: "分享至社群",
                             image: UIImage.sfsymbol(.shareNormal)) { _ in

            self.goToSharePage(
                content: self.likeCardList[indexPath.row].content,
                author: self.likeCardList[indexPath.row].author
            )
        }

        let delete = UIAction(title: "不喜歡",
                              image: UIImage.sfsymbol(.dislike),
                              attributes: .destructive) { _ in

            self.disLikeCard(index: indexPath.row)
        }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in

            UIMenu(title: "", children: [comment, share, delete])

        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        let animation = AnimationFactory.takeTurnsFadingIn(duration: 0.5, delayFactor: 0.1)
        let animator = Animator(animation: animation)
            animator.animate(cell: cell, at: indexPath, in: tableView)
    }
}
