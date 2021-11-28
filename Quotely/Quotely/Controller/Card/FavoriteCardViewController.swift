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

    private var visitorUid: String?

    private var likeCardList = [Card]() {
        didSet {
            tableView.reloadData()
        }
    }

    var isFromWriteVC = false {
        didSet {
            navigationTitle = isFromWriteVC ? "點選引用片語" : "收藏清單"
        }
    }

    private var navigationTitle = "收藏清單"
    var passedContentText = ""

    private let loadingAnimationView = LottieAnimationView(animationName: "whiteLoading")
    private let emptyReminderView = LottieAnimationView(animationName: "empty")

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            setupTableView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        visitorUid = UserManager.shared.visitorUserInfo?.uid ?? ""
        setupLoadingAnimation()
        fetchFavoriteCardList()
        view.backgroundColor = .M3
        navigationController?.setupBackButton(color: .white)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = navigationTitle
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    func fetchFavoriteCardList() {

        let group = DispatchGroup()

        DispatchQueue.global().async {

            UserManager.shared.visitorUserInfo?.likeCardList?.forEach {

                group.enter()

                CardManager.shared.fetchSpecificCard(cardID: $0
                ) { result in

                    switch result {

                    case .success(let card):
                        self.likeCardList.append(card)
                        group.leave()

                    case .failure(let error):
                        print(error)
                        Toast.showFailure(text: ToastText.failToDownload.rawValue)
                        group.leave()
                    }
                }
            }

            group.notify(queue: DispatchQueue.main) {

                if self.likeCardList.count == 0 {

                    self.setupEmptyReminder()
                }

                self.loadingAnimationView.removeFromSuperview()
                self.tableView.reloadData()
            }
        }
    }

    func disLikeCard(index: Int) {

        guard let cardID = likeCardList[index].cardID else { return }

        UserManager.shared.updateFavoriteCard(
            cardID: cardID,
            likeAction: .negative
        ) { result in

                switch result {

                case .success(let success):
                    print(success)
                    self.updateCard(cardID: cardID, likeAction: .negative)
                    self.likeCardList.remove(at: index)

                case .failure(let error):
                    print(error)
                    Toast.showFailure(text: ToastText.failToDownload.rawValue)
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

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint
    ) -> UIContextMenuConfiguration? {

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

extension FavoriteCardViewController {

    func goToCardWritePage(index: Int) {

        guard let writeVC =
                UIStoryboard.write.instantiateViewController(
                    withIdentifier: AddCardPostViewController.identifier
                ) as? AddCardPostViewController
        else { return }

        let card = likeCardList[index]
        let navVC = BaseNavigationController(rootViewController: writeVC)

        writeVC.card = card
        writeVC.contentFromFavCard = passedContentText

        navVC.modalPresentationStyle = .fullScreen

        present(navVC, animated: true)
    }

    func goToCardTopicPage(index: Int) {

        guard let cardTopicVC =
                UIStoryboard.card.instantiateViewController(
                    withIdentifier: CardTopicViewController.identifier
                ) as? CardTopicViewController
        else { return }

        let card = likeCardList[index]

        cardTopicVC.card = card

        navigationController?.pushViewController(cardTopicVC, animated: true)
    }

    func goToSharePage(content: String, author: String) {

        guard let shareVC =
                UIStoryboard.share.instantiateViewController(
                    withIdentifier: ShareViewController.identifier
                ) as? ShareViewController
        else { return }

        let nav = BaseNavigationController(rootViewController: shareVC)

        shareVC.templateContent = [
            content.replacingOccurrences(of: "\\n", with: "\n"),
            author
        ]

        nav.modalPresentationStyle = .fullScreen

        present(nav, animated: true)
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

    func setupEmptyReminder() {

        let titleLabel = UILabel()

        emptyReminderView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(emptyReminderView)
        emptyReminderView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = "還沒有收藏卡片，快去滑幾張吧！"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.setBold(size: 22)

        NSLayoutConstraint.activate([
            emptyReminderView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            emptyReminderView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            emptyReminderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyReminderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            titleLabel.topAnchor.constraint(equalTo: emptyReminderView.bottomAnchor, constant: -24),
            titleLabel.centerXAnchor.constraint(equalTo: emptyReminderView.centerXAnchor)
        ])
    }

    func setupTableView() {

        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerCellWithNib(
            identifier: FavoriteCardTableViewCell.identifier,
            bundle: nil)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
}
