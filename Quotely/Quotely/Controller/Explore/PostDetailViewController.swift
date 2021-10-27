//
//  PostDetailViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/19.
//

import Foundation
import UIKit

class PostDetailViewController: BaseDetailViewController {

    var post: Post?

    var isAuthor = false

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "摘語"
    }

    // MARK: LiftCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchComments()
    }

    // MARK: Action
    override func like(_ sender: UIButton) {

        let likeAction: LikeAction = hasLiked ? .dislike : .like

        let buttonImage: UIImage = hasLiked
        ?
        UIImage.sfsymbol(.heartNormal)! :
        UIImage.sfsymbol(.heartSelected)!

        let buttonColor: UIColor = hasLiked
        ? .gray : .red

        hasLiked.toggle()

        PostManager.shared.updateLikes(postID: postID, likeAction: likeAction) { result in

            switch result {

            case .success(let action):

                print(action)

                UIView.animate(
                    withDuration: 1 / 3, delay: 0,
                    options: .curveEaseIn) { [weak self] in

                        self?.likeButton.setBackgroundImage(buttonImage, for: .normal)
                        self?.likeButton.tintColor = buttonColor
                    }

            case .failure(let error):

                print("updateData.failure: \(error)")
            }
        }
    }

    override func addComment(_ sender: UIButton) {
        super.addComment(sender)

        if let message = commentTextField.text {

            var comment = Comment(
                uid: "test123456",
                content: message,
                createdTime: Date().millisecondsSince1970,
                editTime: nil,
                cardID: nil,
                postID: postID
            )

            PostCommentManager.shared.addComment(
                comment: &comment
            ) { _ in

                Toast.showSuccess(text: "已發布")

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

        isAuthor = uid == "test123456"
        ? true : false

        header.layoutHeader(
            userImage: userImage,
            userName: userName,
            time: time,
            content: content,
            imageUrl: imageUrl,
            isAuthor: isAuthor
        )

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

        return header
    }

    // Cells: comments
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: BaseDetailCommentCell.identifier, for: indexPath
        ) as? BaseDetailCommentCell else {
            fatalError("Cannot create cell.")
        }

        let row = indexPath.row

        isAuthor = uid == "test123456" ? true : false

        cell.layoutCell(
            userImage: UIImage.asset(.testProfile)!,
            userName: "Morgan Yu",
            createdTime: comments[row].createdTime,
            content: comments[row].content,
            isAuthor: isAuthor,
            editTime: comments[row].editTime)

        cell.noSelectionStyle()

        cell.editHandler = { text in

            guard let postCommentID = self.comments[row].postCommentID else { return }

            PostCommentManager.shared.updateComment( postCommentID: postCommentID, newContent: text) { result in

                    switch result {

                    case .success(let success):

                        print(success)

                        self.comments[row].content = text

                    case .failure(let error):

                        print(error)
                    }
                }
        }

        cell.deleteHandler = {

            guard let postCommentID = self.comments[row].postCommentID else { return }

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
