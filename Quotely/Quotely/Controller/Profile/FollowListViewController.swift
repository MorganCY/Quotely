//
//  FollowListViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/14.
//

import Foundation
import UIKit

class FollowListViewController: UIViewController {

    enum ListType {

        case following, follower
    }

    var visitedUid: String? {
        didSet {
            guard let visitedUid = visitedUid else { return }
            fetchVisitedUserInfo(visitedUid: visitedUid)
        }
    }
    private var followerList: [User]? {
        didSet {
            toDisplayList = followerList
        }
    }
    private var followingList: [User]?
    var toDisplayList: [User]? {
        didSet {
            tableView.reloadData()
        }
    }
    var currentFilterType: ListType = .following {
        didSet {
            toDisplayList = currentFilterType == .following
            ? followingList : followerList
        }
    }

    let listTypeSelectionView = SelectionView()
    let listTypeTitle = ["被追蹤", "追蹤中"]
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.registerCellWithNib(identifier: BlockListTableViewCell.identifier, bundle: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutListFilter()
        setupNavigation()
        listTypeSelectionView.dataSource = self
        listTypeSelectionView.delegate = self
    }

    func fetchVisitedUserInfo(visitedUid: String) {

        UserManager.shared.fetchUserInfo(
            uid: visitedUid
        ) { result in

            switch result {

            case .success(let user):
                self.fetchListContent(uid: user.followerList ?? [""], listType: .follower)
                self.fetchListContent(uid: user.followingList ?? [""], listType: .following)

            case .failure(let error):
                print(error)
                Toast.shared.showFailure(text: .failToUpdate)
            }
        }
    }

    func fetchListContent(uid: [String], listType: ListType) {

        var userList: [User] = Array(repeating: User.default, count: uid.count)

        let group = DispatchGroup()

        for (index, uid) in uid.enumerated() {

            group.enter()

            UserManager.shared.fetchUserInfo(uid: uid) { result in

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

            switch listType {
            case .follower: self.followerList = userList
            case .following: self.followingList = userList
            }
        }
    }
}

extension FollowListViewController: SelectionViewDataSource, SelectionViewDelegate {

    func buttonStyle(_ view: SelectionView) -> ButtonStyle { .text }

    func buttonTitle(_ view: SelectionView, index: Int) -> String? { listTypeTitle[index] }

    func numberOfButtonsAt(_ view: SelectionView) -> Int { listTypeTitle.count }

    func buttonColor(_ view: SelectionView) -> UIColor { .gray }

    func indicatorColor(_ view: SelectionView) -> UIColor { .M1 }

    func indicatorWidth(_ view: SelectionView) -> CGFloat { 0.8 }

    func didSelectButtonAt(_ view: SelectionView, at index: Int) {
        currentFilterType = index == 0 ? .follower : .following
    }

    func shouldSelectButtonAt(_ view: SelectionView, at index: Int) -> Bool { true }
}

extension FollowListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { toDisplayList?.count ?? 0 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: BlockListTableViewCell.identifier, for: indexPath
        ) as? BlockListTableViewCell else {

            fatalError("Cannot create cell")
        }

        guard let toDisplayList = toDisplayList else {

            return UITableViewCell()
        }

        cell.layoutCell(user: toDisplayList[indexPath.row])
        cell.unblockButton.isHidden = true
        cell.hideSelectionStyle()

        return cell
    }
}

extension FollowListViewController {

    func setupNavigation() {
        navigationItem.title = "追蹤名單"
        navigationController?.setupBackButton(color: .gray)
    }

    func layoutListFilter() {
        view.addSubview(listTypeSelectionView)
        listTypeSelectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            listTypeSelectionView.widthAnchor.constraint(equalTo: view.widthAnchor),
            listTypeSelectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            listTypeSelectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            listTypeSelectionView.bottomAnchor.constraint(equalTo: tableView.topAnchor)
        ])
    }
}
