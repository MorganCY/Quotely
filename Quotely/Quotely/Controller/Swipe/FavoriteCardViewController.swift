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

    var likeCardList = [Card]() {
        didSet {
            tableView.reloadData()
        }
    }

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

        self.view.backgroundColor = .M1

        navigationController?.setupBackButton(color: .white)
    }

    override func viewWillAppear(_ animated: Bool) {

        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        tabBarController?.tabBar.isHidden = false
    }

    func fetchUserInfo() {

        UserManager.shared.fetchUserInfo(uid: "test123456") { result in

            switch result {

            case .success(let userInfo):
                userInfo.likeCardID?.forEach({
                    self.fetchFavoriteCard(cardID: $0)
                })

            case .failure(let error):
                print(error)
            }
        }
    }

    func fetchFavoriteCard(cardID: String) {
        CardManager.shared.fetchFavoriteCard(cardID: cardID) { result in

            switch result {

            case .success(let card):
                self.likeCardList.append(card)

            case .failure(let error):
                print(error)
            }
        }
    }

    func goToDetailPage(index: Int) {

        guard let detailVC =
                UIStoryboard.swipe
                .instantiateViewController(
                    withIdentifier: String(describing: CardDetailViewController.self)
                ) as? CardDetailViewController else {

                    return
                }

        let card = likeCardList[index]

        detailVC.cardID = card.cardID
        detailVC.hasLiked = card.likeUser.contains("test123456") ? true : false
        detailVC.uid = "test123456"
        detailVC.content = "\(card.content)\n\n\n\(card.author)"

        navigationController?.pushViewController(detailVC, animated: true)
    }

    func disLikeCard(index: Int) {

        let card = likeCardList[index]

        UserManager.shared.updateFavoriteCard(
            uid: "test123456",
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
            uid: "test123456") { result in

                switch result {

                case .success(let success):
                    print(success)

                case .failure(let error):
                    print(error)
                }
            }
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
            imageUrl: likeCardList[indexPath.row].imageUrl ?? "",
            content: likeCardList[indexPath.row].content.replacingOccurrences(of: "\\n", with: "\n"),
            author: likeCardList[indexPath.row].author
        )

        cell.hideSelectionStyle()

        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        let animation = AnimationFactory.takeTurnsFadingIn(duration: 0.5, delayFactor: 0.1)
        let animator = Animator(animation: animation)
            animator.animate(cell: cell, at: indexPath, in: tableView)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "查看討論", style: .default, handler: { _ in

            self.goToDetailPage(index: indexPath.row)
        }))

        alert.addAction(UIAlertAction(title: "分享至社群", style: .default, handler: { _ in

            Toast.showFailure(text: "建置中")
        }))

        alert.addAction(UIAlertAction(title: "刪除", style: .destructive, handler: { _ in

            self.disLikeCard(index: indexPath.row)
        }))

        alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
}
