//
//  CardDetailViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/24.
//

import Foundation
import UIKit
import AVFoundation

class CardDetailViewController: BaseDetailViewController {

    var isAuthor = false

    let visitorUid = SignInManager.shared.uid ?? ""

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "隻字片語"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchComments()
    }


    override func addComment(_ sender: UIButton) {
        super.addComment(sender)

        if let message = commentTextField.text {

            var comment = Comment(
                uid: visitorUid,
                content: message,
                createdTime: Date().millisecondsSince1970,
                editTime: nil,
                cardID: cardID,
                postID: nil,
                postCommentID: nil)

            CardCommentManager.shared.addComment(
                comment: &comment) { _ in

                    Toast.showSuccess(text: "已發布")

                    self.commentTextField.text = ""

                    self.fetchComments()
                }

            CardCommentManager.shared.updateCommentNumber(
                cardID: self.cardID ?? "",
                commentAction: .add
            ) { result in

                switch result {

                case .success(let success):

                    print(success)

                case .failure(let error):

                    print(error)
                }
            }

        } else {

            self.present(
                UIAlertController(
                    title: "請輸入內容", message: nil, preferredStyle: .alert
                ), animated: true
            )
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: BaseDetailTableViewHeader.identifier
        ) as? BaseDetailTableViewHeader else {

            fatalError("Cannot load header view.")
        }

        header.layoutHeader(
            userImageUrl: nil,
            userName: nil,
            time: nil,
            content: content.replacingOccurrences(of: "\\n", with: "\n"),
            imageUrl: nil,
            isAuthor: false
        )

        header.userImageView.isHidden = true
        header.userNameLabel.isHidden = true
        header.timeLabel.isHidden = true

        return header
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: BaseDetailCommentCell.identifier, for: indexPath
        ) as? BaseDetailCommentCell else {
            fatalError("Cannot create cell.")
        }

        var userInfo: User?

        let comment = comments[indexPath.row]

        isAuthor = comment.uid == visitorUid ? true : false

        UserManager.shared.fetchUserInfo(uid: comment.uid) { result in

            switch result {

            case .success(let user):
                userInfo = user

            case .failure(let error):
                print(error)
            }
        }

        cell.layoutCell(
            comment: comment,
            userImageUrl: userInfo?.profileImageUrl ?? "",
            userName: userInfo?.name ?? "",
            isAuthor: isAuthor
        )

        cell.hideSelectionStyle()

        cell.editHandler = { text in

            guard let cardCommentID = comment.cardCommentID else { return }

            CardCommentManager.shared.updateComment( cardCommentID: cardCommentID, newContent: text) { result in

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

            guard let cardCommentID = self.comments[indexPath.row].cardCommentID else { return }

            let alert = UIAlertController(title: "確定要刪除嗎？", message: nil, preferredStyle: .alert)

            let okAction = UIAlertAction(title: "刪除", style: .default) { _ in

                CardCommentManager.shared.deleteComment(
                    cardCommentID: cardCommentID) { result in

                        switch result {

                        case .success(let success):

                            print(success)

                            self.fetchComments()

                        case .failure(let error):

                            print(error)
                        }
                    }

                CardCommentManager.shared.updateCommentNumber(
                    cardID: self.cardID ?? "",
                    commentAction: .delete
                ) { result in

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

        return cell
    }

    func fetchComments() {

        guard let cardID = cardID else { return }

        CardCommentManager.shared.fetchComment(cardID: cardID) { result in

            switch result {

            case .success(let comments):

                self.comments = comments

            case .failure(let error):

                print("fetchData.failure: \(error)")
            }
        }
    }
}
