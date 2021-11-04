//
//  PostDetailViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/19.
//

import Foundation
import UIKit

class PostDetailViewController: BaseDetailViewController {

    var isAuthor = false

    let visitorUid = SignInManager.shared.uid ?? ""

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchComments()

        navigationItem.title = "摘語"
    }

    // MARK: LiftCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: Action

    @objc func goToProfileFromHeader(_ gestureRecognizer: UITapGestureRecognizer) {

        guard let profileVC = UIStoryboard
                .profile
                .instantiateViewController(withIdentifier: String(describing: ProfileViewController.self)
        ) as? ProfileViewController else {

            return
        }

        profileVC.visitedUid = postAuthorUid

        self.show(profileVC, sender: nil)
    }

    @objc func goToProfileFromCell(_ gestureRecognizer: UITapGestureRecognizer) {

        guard let profileVC = UIStoryboard
                .profile
                .instantiateViewController(withIdentifier: String(describing: ProfileViewController.self)
        ) as? ProfileViewController else {

            return
        }

        guard let currentRow = gestureRecognizer.view?.tag else { return }

        profileVC.visitedUid = comments[currentRow].uid

        self.show(profileVC, sender: nil)
    }

    override func addComment(_ sender: UIButton) {
        super.addComment(sender)

        if let message = commentTextField.text {

            guard let visitorUid = SignInManager.shared.uid else { return }

            var comment = Comment(
                uid: visitorUid,
                content: message,
                createdTime: Date().millisecondsSince1970,
                editTime: nil,
                cardID: nil,
                postID: postID
            )

            PostCommentManager.shared.addComment(
                comment: &comment
            ) { _ in

                self.commentTextField.text = ""

                self.fetchComments()
            }

        } else {

            self.present(
                UIAlertController(
                    title: "請輸入內容", message: nil, preferredStyle: .alert
                ), animated: true
            )
        }
    }

    // MARK: TableView
    // Header: post content
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: BaseDetailTableViewHeader.identifier
        ) as? BaseDetailTableViewHeader else {

            fatalError("Cannot load header view.")
        }

        isAuthor = postAuthorUid == visitorUid
        ? true : false

        UserManager.shared.fetchUserInfo(uid: postAuthorUid) { result in

            switch result {

            case .success(let user):
                header.layoutHeader(
                    userImageUrl: user.profileImageUrl,
                    userName: user.name,
                    time: self.time,
                    content: self.content,
                    imageUrl: self.imageUrl,
                    isAuthor: self.isAuthor
                )

            case .failure(let error):
                print(error)
            }
        }
        // Pass data from Post Detail page to Write page
        header.editHandler = {

            guard let writeVC = UIStoryboard.write.instantiateViewController(
                withIdentifier: String(describing: WriteViewController.self)
            ) as? WriteViewController else { return }

            let nav = UINavigationController(rootViewController: writeVC)

            nav.modalPresentationStyle = .automatic

            self.navigationController?.present(nav, animated: true) {

                writeVC.contentTextView.text = self.content

                writeVC.postID = self.postID

                if let imageUrl = self.imageUrl {

                    writeVC.imageUrl = imageUrl

                    writeVC.hasImage = true
                }

                writeVC.contentHandler = { content in

                    self.content = content

                    tableView.reloadData()
                }
            }
        }

        header.deleteHandler = {

            let alert = UIAlertController(title: "確定要刪除嗎？", message: nil, preferredStyle: .alert)

            let okAction = UIAlertAction(title: "刪除", style: .default) { _ in

                PostManager.shared.deletePost(postID: self.postID) { result in

                    switch result {

                    case .success(let success):

                        print(success)

                        self.navigationController?.popViewController(animated: true)

                    case .failure(let error):

                        print(error)

                        self.present(UIAlertController(
                            title: "刪除失敗",
                            message: nil,
                            preferredStyle: .alert), animated: true, completion: nil
                        )
                    }
                }
            }

            let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)

            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }

        // go to user's profile when tapping image, name, and time

        let tapGoToProfileGesture = UITapGestureRecognizer(target: self, action: #selector(goToProfileFromHeader(_:)))
        let tapGoToProfileGesture2 = UITapGestureRecognizer(target: self, action: #selector(goToProfileFromHeader(_:)))

        header.userImageView.addGestureRecognizer(tapGoToProfileGesture)
        header.userImageView.isUserInteractionEnabled = true
        header.userInfoStackView.addGestureRecognizer(tapGoToProfileGesture2)
        header.userInfoStackView.isUserInteractionEnabled = true

        return header
    }

    // Cells: comments
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: BaseDetailCommentCell.identifier, for: indexPath
        ) as? BaseDetailCommentCell else {
            fatalError("Cannot create cell.")
        }

        let comment = comments[indexPath.row]

        isAuthor = postAuthorUid == visitorUid ? true : false

        UserManager.shared.fetchUserInfo(uid: comment.uid) { result in

            switch result {

            case .success(let user):
                cell.layoutCell(
                    comment: comment,
                    userImageUrl: user.profileImageUrl ?? "",
                    userName: user.name ?? "",
                    isAuthor: self.isAuthor
                )

            case .failure(let error):
                print(error)
            }
        }

        cell.hideSelectionStyle()

        cell.editHandler = { text in

            guard let postCommentID = comment.postCommentID else { return }

            PostCommentManager.shared.updateComment( postCommentID: postCommentID, newContent: text) { result in

                    switch result {

                    case .success(let success):

                        print(success)

                        self.comments[indexPath.row].content = text

                    case .failure(let error):

                        print(error)
                    }
                }
        }

        cell.deleteHandler = {

            guard let postCommentID = comment.postCommentID else { return }

            let alert = UIAlertController(title: "確定要刪除嗎？", message: nil, preferredStyle: .alert)

            let okAction = UIAlertAction(title: "刪除", style: .default) { _ in

                PostCommentManager.shared.deleteComment(
                    postCommentID: postCommentID) { result in

                        switch result {

                        case .success(let success):

                            print(success)

                            self.fetchComments()

                        case .failure(let error):

                            print(error)
                        }
                    }
            }

            let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)

            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }

        // go to user's profile when tapping image, name, and time

        let tapGoToProfileGesture3 = UITapGestureRecognizer(
            target: self,
            action: #selector(self.goToProfileFromCell(_:))
        )
        let tapGoToProfileGesture4 = UITapGestureRecognizer(
            target: self,
            action: #selector(self.goToProfileFromCell(_:))
        )

        cell.userImageView.addGestureRecognizer(tapGoToProfileGesture3)
        cell.userImageView.isUserInteractionEnabled = true
        cell.nameLabel  .addGestureRecognizer(tapGoToProfileGesture4)
        cell.nameLabel.isUserInteractionEnabled = true

        cell.userImageView.tag = indexPath.row
        cell.nameLabel.tag = indexPath.row

        return cell
    }

    // MARK: Data
    func fetchComments() {

        PostCommentManager.shared.fetchComment(postID: postID) { result in

            switch result {

            case .success(let comments):

                self.comments = comments

            case .failure(let error):

                print("fetchData.failure: \(error)")
            }
        }
    }
}
