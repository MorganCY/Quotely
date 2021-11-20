//
//  JournalListViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/27.
//

import Foundation
import UIKit
import SwiftUI
import MapKit

class JournalListViewController: UIViewController {

    let visitorUid = SignInManager.shared.visitorUid ?? ""

    var journals = [Journal]() {
        didSet {
            if journals.count == 0 { setupEmptyReminder() }
            tableView.reloadData()
        }
    }
    var selectedMonth = Date().getCurrentTime(format: .MM) {
        didSet {
            fetchJournals(visitorUid: visitorUid)
        }
    }
    var selectedYear = Date().getCurrentTime(format: .yyyy)
    var userRegisterDate: Date? {
        didSet {
            collectionView.reloadData()
            collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .left)
            collectionView(collectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
        }
    }

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.backgroundColor = .clear
            collectionView.registerCellWithNib(identifier: JournalListCollectionViewCell.identifier, bundle: nil)
            collectionView.showsHorizontalScrollIndicator = false
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.registerCellWithNib(
                identifier: JournalListTableViewCell.identifier,
                bundle: nil
            )
            tableView.backgroundColor = .M3
            tableView.separatorStyle = .none
            tableView.setSpecificCorner(corners: [.topLeft, .topRight])
        }
    }

    let emptyReminderView = LottieAnimationView(animationName: "empty")
    let loadingAnimationView = LottieAnimationView(animationName: "whiteLoading")

    override func viewDidLoad() {
        super.viewDidLoad()

        userRegisterDate = Date.init(milliseconds: UserManager.shared.visitorUserInfo?.registerTime ?? 0)

        navigationController?.setupBackButton(color: .white)
        tabBarController?.tabBar.isHidden = true
        backgroundImageView.image = UIImage.asset(.bg4)
        backgroundImageView.alpha = 0.8
        setupLoadingAnimation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchJournals(visitorUid: visitorUid)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        tabBarController?.tabBar.isHidden = false
    }

    func fetchJournals(visitorUid: String) {

        JournalManager.shared.fetchJournal(
            uid: visitorUid,
            month: self.selectedMonth,
            year: self.selectedYear
        ) { result in

            switch result {

            case .success(let journals):

                self.journals = journals

                self.loadingAnimationView.removeFromSuperview()

            case .failure(let error):

                print(error)

                self.loadingAnimationView.removeFromSuperview()

                DispatchQueue.main.async {
                    Toast.showFailure(text: "資料載入異常")
                }
            }
        }
    }

    func deleteJournal(journalID: String) {

        JournalManager.shared.deleteJournal(
            journalID: journalID) { result in

                switch result {

                case .success(let success):
                    print(success)

                case .failure(let error):
                    print(error)
                }
            }
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

extension JournalListViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        guard let userRegisterDate = userRegisterDate else { return 0 }

        let monthlist = Date.getMonthAndYearBetween(
            from: userRegisterDate,
            to: Date().addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT()))
        ).reversed() as [String]

        return monthlist.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let userRegisterDate = userRegisterDate else { fatalError("Cannot create item")
        }

        let monthlist = Date.getMonthAndYearBetween(
            from: userRegisterDate,
            to: Date().addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT()))
        ).reversed() as [String]

        guard let item = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: JournalListCollectionViewCell.self),
            for: indexPath
        ) as? JournalListCollectionViewCell else {

            fatalError("Cannot create item")
        }

        item.layoutItem(month: monthlist[indexPath.item])

        return item
    }
}

extension JournalListViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let item = collectionView.cellForItem(at: indexPath) as? JournalListCollectionViewCell else { return }

        item.setSelectedStyle()

        guard let userRegisterDate = userRegisterDate else { return }

        let monthlist = Date.getMonthAndYearBetween(from: userRegisterDate, to: Date()).reversed() as [String]

        self.selectedMonth = monthlist[indexPath.item]
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        guard let item = collectionView.cellForItem(at: indexPath) as? JournalListCollectionViewCell else { return }

        item.setSelectedStyle()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {

        cell.alpha = 0

        UIView.animate(
            withDuration: 0.5,
            delay: 0.1 * Double(indexPath.row),
            animations: {
                cell.alpha = 1
        })
    }

}

extension JournalListViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        return CGSize(width: view.frame.width * 0.22, height: view.frame.height * 0.12)
    }

}

extension JournalListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        let animation = AnimationFactory.takeTurnsFadingIn(duration: 0.3, delayFactor: 0.1)
        let animator = Animator(animation: animation)
            animator.animate(cell: cell, at: indexPath, in: tableView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        journals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: JournalListTableViewCell.identifier,
            for: indexPath
        ) as? JournalListTableViewCell else {
            fatalError("Cannot create cell")
        }

        let row = indexPath.row

        cell.layoutCell(journal: journals[row], month: selectedMonth)

        cell.hideSelectionStyle()

        if row == 0 {

            cell.isDateDuplicate = false

        } else if row >= 1 {

            cell.checkIfHideLabel(row: journals[row], previousRow: journals[row-1])
        }

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {

        let share = UIAction(title: "分享至社群",
                             image: UIImage.sfsymbol(.shareNormal)) { _ in

            self.goToSharePage(content: self.journals[indexPath.row].content, author: "Morgan Yu")
        }

        let delete = UIAction(title: "刪除",
                              image: UIImage.sfsymbol(.delete),
                              attributes: .destructive) { _ in

            let alert = UIAlertController(title: "要刪除嗎？", message: nil, preferredStyle: .alert)

            let alertAction = UIAlertAction(title: "刪除", style: .destructive) { _ in

                self.deleteJournal(journalID: self.journals[indexPath.row].journalID ?? "")
                self.journals.remove(at: indexPath.row)
            }

            alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))

            alert.addAction(alertAction)

            self.present(alert, animated: true, completion: nil)
        }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in

            UIMenu(title: "", children: [share, delete])
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        UITableView.automaticDimension
    }
}

extension JournalListViewController {

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

        titleLabel.text = "還沒有任何隻字，快回首頁新增一則吧！"
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "Pingfang TC Bold", size: 22)

        NSLayoutConstraint.activate([
            emptyReminderView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            emptyReminderView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            emptyReminderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyReminderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            titleLabel.topAnchor.constraint(equalTo: emptyReminderView.bottomAnchor, constant: -24),
            titleLabel.centerXAnchor.constraint(equalTo: emptyReminderView.centerXAnchor)
        ])
    }
}
