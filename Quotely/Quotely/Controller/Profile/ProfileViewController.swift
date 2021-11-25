//
//  ProfileViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/20.
//

import Foundation
import UIKit

class ProfileViewController: BaseProfileViewController {

    // the user who is visiting other's profile
    var visitorUid: String?

    var visitorBlockList: [String]? {
        didSet {
            if let visitedUid = visitedUid,
               let visitorBlockList = visitorBlockList {
                self.isBlock = visitorBlockList.contains(visitedUid)
            }
        }
    }

    var visitorFollowingList: [String]? {
        didSet {
            if let visitedUid = visitedUid,
               let visitorFollowingList = visitorFollowingList {
                self.isFollow = visitorFollowingList.contains(visitedUid)
            }
        }
    }

    var isBlock = false

    var isFollow = false

    override func viewDidLoad() {
        super.viewDidLoad()

        visitorUid = UserManager.shared.visitorUserInfo?.uid
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        visitorBlockList = UserManager.shared.visitorUserInfo?.blockList
        visitorFollowingList = UserManager.shared.visitorUserInfo?.followingList
    }

    func updateUserBlock(blockAction: FirebaseAction) {

        guard let visitedUid = visitedUid else { return }

        UserManager.shared.updateUserList(
            userAction: .block,
            visitedUid: visitedUid,
            action: blockAction
        ) { result in

            switch result {

            case .success(let success):

                print(success)

                self.isBlock = blockAction == .positive

                self.fetchVisitedUserInfo(uid: visitedUid)

            case .failure(let error):

                print(error)

                DispatchQueue.main.async {
                    Toast.showFailure(text: "資料更新失敗")
                }
            }
        }
    }

    func updateUserFollow(followAction: FirebaseAction) {

        guard let visitedUid = visitedUid else { return }

        UserManager.shared.updateUserList(
            userAction: .follow,
            visitedUid: visitedUid,
            action: followAction
        ) { result in

            switch result {

            case .success(let success):

                print(success)

                self.isFollow = followAction == .positive

                self.fetchVisitedUserInfo(uid: visitedUid)

            case .failure(let error):

                print(error)

                DispatchQueue.main.async {
                    Toast.showFailure(text: "資料更新失敗")
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: ProfileTableViewHeaderView.identifier
        ) as? ProfileTableViewHeaderView else {

            fatalError("Cannot create header view")
        }

        guard let userInfo = visitedUserInfo else {

            return UITableViewHeaderFooterView()
        }

        let goToFollowListGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(goToFollowList(_:))
        )

        header.layoutProfileHeader(userInfo: userInfo, isBlock: isBlock, isFollow: isFollow)
        header.blockButton.isEnabled = !isFollow
        header.followButton.isEnabled = !isBlock
        header.followStackView.addGestureRecognizer(goToFollowListGesture)
        header.followStackView.isUserInteractionEnabled = true

        header.blockHanlder = {

            var blockAction: FirebaseAction = .positive

            blockAction = self.isBlock ? .negative : .positive

            self.updateUserBlock(blockAction: blockAction)
        }

        header.followHandler = {

            var followAction: FirebaseAction = .positive

            followAction = self.isFollow ? .negative : .positive

            self.updateUserFollow(followAction: followAction)
        }

        return header
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ProfileTableViewCell.identifier,
            for: indexPath
        ) as? ProfileTableViewCell else {

            fatalError("Cannot create cell")
        }

        guard let visitedUserPostList = visitedUserPostList else {

            return UITableViewCell()
        }

        let post = visitedUserPostList[indexPath.row]

        cell.layoutCell(post: post)
        cell.hideSelectionStyle()

        return cell
    }
}
