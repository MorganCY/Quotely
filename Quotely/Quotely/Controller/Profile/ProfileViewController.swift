//
//  ProfileViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/20.
//

import Foundation
import UIKit

class ProfileViewController: BaseProfileViewController {

    override var visitorBlockList: [String]? {
        didSet {
            if let visitedUid = visitedUid,
               let visitorBlockList = visitorBlockList {
                isBlock = visitorBlockList.contains(visitedUid)
            }
        }
    }

    override var visitorFollowingList: [String]? {
        didSet {
            if let visitedUid = visitedUid,
               let visitorFollowingList = visitorFollowingList {
                isFollow = visitorFollowingList.contains(visitedUid)
            }
        }
    }

    override var isBlock: Bool {
        didSet {
            tableView.reloadData()
        }
    }

    override var isFollow: Bool {
        didSet {
            fetchVisitedUserInfo(uid: visitedUid ?? "")
        }
    }

    func updateUserBlock(blockAction: UserManager.BlockAction) {

        guard let visitorUid = visitorUid,
              let visitedUid = visitedUid else { return }

        UserManager.shared.updateUserBlockList(
            visitorUid: visitorUid,
            visitedUid: visitedUid,
            blockAction: blockAction
        ) { result in

            switch result {

            case .success(let success):

                print(success)

                self.isBlock = blockAction == .block

                self.fetchVisitedUserInfo(uid: visitedUid)

            case .failure(let error):

                print(error)
            }
        }
    }

    func updateUserFollow(followAction: UserManager.FollowAction) {

        guard let visitorUid = visitorUid,
              let visitedUid = visitedUid else { return }

        UserManager.shared.updateUserFollow(
            visitorUid: visitorUid,
            visitedUid: visitedUid,
            followAction: followAction
        ) { result in

            switch result {

            case .success(let success):

                print(success)

                self.isFollow = followAction == .follow

            case .failure(let error):

                print(error)
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

            fatalError("Cannot fetch user info")
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

            var blockAction: UserManager.BlockAction = .block

            blockAction = self.isBlock ? .unblock : .block

            self.updateUserBlock(blockAction: blockAction)
        }

        header.followHandler = {

            var followAction: UserManager.FollowAction = .follow

            followAction = self.isFollow ? .unfollow : .follow

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

        let post = visitedUserPostList[indexPath.row]

        cell.layoutCell(post: post)
        cell.hideSelectionStyle()

        return cell
    }
}
