//
//  BlockListViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/11.
//

import Foundation
import UIKit

class BlockListViewController: UIViewController {

    var visitorUserInfo = UserManager.shared.visitorUserInfo

    var blockUidList = UserManager.shared.visitorUserInfo?.blockList

    var blockUserList: [User]? {
        didSet {
            tableView.dataSource = self
            tableView.reloadData()
        }
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.registerCellWithNib(identifier: BlockListTableViewCell.identifier, bundle: nil)
            tableView.backgroundColor = .white
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "封鎖名單"

        fetchBlockListContent()
    }

    func fetchBlockListContent() {

        guard let blockUidList = blockUidList else { return }

        var userList: [User] = Array(repeating: User.default, count: blockUidList.count)

        let group = DispatchGroup()

        blockUidList.forEach {_ in

            for (index, uid) in blockUidList.enumerated() {

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

                self.blockUserList = userList
            }
        }
    }

    func updateUserBlock(visitedUid: String) {

        guard let visitorUid = visitorUserInfo?.uid else { return }

        UserManager.shared.updateUserBlockList(
            visitorUid: visitorUid,
            visitedUid: visitedUid,
            blockAction: .unblock
        ) { result in

            switch result {

            case .success(let success): print(success)

            case .failure(let error): print(error)
            }
        }
    }
}

extension BlockListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        blockUidList?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: BlockListTableViewCell.identifier, for: indexPath
        ) as? BlockListTableViewCell else {

            fatalError("Cannot create cell")
        }

        guard let blockUidList = blockUidList,
              let blockUserList = blockUserList else {

                  fatalError("Cannot create cell")
              }

        cell.layoutCell(user: blockUserList[indexPath.row])

        cell.unblockHandler = {

            self.updateUserBlock(visitedUid: blockUidList[indexPath.row])
            self.blockUidList?.remove(at: indexPath.row)
            self.blockUserList?.remove(at: indexPath.row)
        }

        cell.hideSelectionStyle()

        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { 100 }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
