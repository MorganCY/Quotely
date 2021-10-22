//
//  PostDetailViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/19.
//

import Foundation
import UIKit

class PostDetailViewController: BaseDetailViewController {

    var hasLiked = false

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "摘語"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchComments()

        setupLikeButtonState()
    }

    override func like(_ sender: UIButton) {

        let likeAction: LikeAction = hasLiked ? .dislike : .like

        let buttonImage: UIImage = hasLiked
        ?
        UIImage.sfsymbol(.heartNormal)! :
        UIImage.sfsymbol(.heartSelected)!

        let buttonColor: UIColor = hasLiked
        ? .gray : .red

        hasLiked.toggle()

        guard let postID = postID else { return }

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

    func setupLikeButtonState() {

        let buttonImage: UIImage = hasLiked ? UIImage.sfsymbol(.heartSelected)! : UIImage.sfsymbol(.heartNormal)!
        let buttonColor: UIColor = hasLiked ?  .red : .gray

        likeButton.setBackgroundImage(buttonImage, for: .normal)
        likeButton.tintColor = buttonColor
    }

    override func addComment(_ sender: UIButton) {
        super.addComment(sender)

        if let message = commentTextField.text {

            let comment = Comment(
                uid: "test123456",
                content: message,
                createdTime: Date().millisecondsSince1970,
                editTime: nil,
                articleID: nil,
                postID: postID
            )

            CommentManager.shared.addComment(
                comment: comment
            ) { _ in

                ProgressHUD.showSuccess(text: "已發布")

                self.commentTextField.text = ""
            }

        } else {

            self.present(
                UIAlertController(
                    title: "請輸入內容", message: nil, preferredStyle: .alert
                ), animated: true
            )
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: BaseDetailCommentCell.identifier, for: indexPath
        ) as? BaseDetailCommentCell else {

            fatalError("Cannot create cell.")
        }

        let row = indexPath.row

        cell.layoutCell(
            userImage: UIImage.asset(.testProfile),
            userName: "Morgan Yu",
            time: Date.dateFormatter.string(from: Date.init(milliseconds: comments[row].createdTime)),
            content: comments[row].content
        )

        cell.noSelectionStyle()

        return cell
    }

    func fetchComments() {

        guard let postID = postID else { return }

        CommentManager.shared.fetchComment(postID: postID) { result in

            switch result {

            case .success(let comments):

                self.comments = comments

            case .failure(let error):

                print("fetchData.failure: \(error)")
            }
        }
    }
}
