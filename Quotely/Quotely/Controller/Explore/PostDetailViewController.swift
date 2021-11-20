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

    var author: User? {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchComments(type: .post)

        navigationItem.title = "想法"
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

        profileVC.visitedUid = postAuthor?.uid

        self.show(profileVC, sender: nil)
    }

    @objc func goToProfileFromCell(_ gestureRecognizer: UITapGestureRecognizer) {

        guard let profileVC = UIStoryboard
                .profile
                .instantiateViewController(withIdentifier: String(describing: ProfileViewController.self)
        ) as? ProfileViewController else {

            return
        }

        guard let myVC = UIStoryboard
                .profile
                .instantiateViewController(withIdentifier: String(describing: MyViewController.self)
        ) as? MyViewController else {

            return
        }

        guard let currentRow = gestureRecognizer.view?.tag else { return }

        profileVC.visitedUid = comments[currentRow].uid

        if comments[currentRow].uid == UserManager.shared.visitorUserInfo?.uid {

            self.show(myVC, sender: nil)

        } else {

            self.show(profileVC, sender: nil)
        }
    }

    @objc func goToCardTopicPage(_ gestureRecognizer: UITapGestureRecognizer) {

        guard let cardTopicVC = UIStoryboard
                .card
                .instantiateViewController(withIdentifier: String(describing: CardTopicViewController.self)
        ) as? CardTopicViewController else {

            return
        }

        cardTopicVC.cardID = post?.cardID

        self.show(cardTopicVC, sender: nil)
    }

    override func addComment(_ sender: UIButton) {
        super.addComment(sender)

        guard commentTextField.text != "" else {

            DispatchQueue.main.async { Toast.showFailure(text: "請輸入內容") }

            return
        }

        submitButton.isEnabled = false

        if let message = commentTextField.text {

            guard let visitorUid = SignInManager.shared.visitorUid else { return }

            var comment = Comment(
                uid: visitorUid,
                createdTime: Date().millisecondsSince1970,
                editTime: nil,
                content: message,
                postID: post?.postID
            )

            PostCommentManager.shared.addComment(
                comment: &comment
            ) { result in

                switch result {

                case .success(let success):

                    print(success)

                    self.commentTextField.text = ""

                    PostManager.shared.updateCommentNumber(
                        postID: self.post?.postID ?? "",
                        commentAction: .add) { result in

                            switch result {

                            case .success(let success):

                                print(success)

                                self.submitButton.isEnabled = true

                            case .failure(let error):

                                print(error)

                                DispatchQueue.main.async {
                                    Toast.showFailure(text: "新增評論失敗")
                                }

                                self.submitButton.isEnabled = true
                            }
                        }

                    self.fetchComments(type: .post)

                case .failure(let error):

                    print(error)

                    DispatchQueue.main.async {
                        Toast.showFailure(text: "新增評論失敗")
                    }

                    self.submitButton.isEnabled = true
                }
            }

        } else {

            DispatchQueue.main.async {
                Toast.showFailure(text: "請輸入內容")
            }

            submitButton.isEnabled = true
        }
    }

    func deleteImage(imageUrl: String) {

        ImageManager.shared.deleteImage(imageUrl: imageUrl) { result in

            switch result {

            case .success(let success):

                print(success)

            case .failure(let error):

                print(error)

                DispatchQueue.main.async {
                    Toast.showFailure(text: "刪除圖片失敗")
                }
            }
        }
    }

    func deletePostFromCard(postID: String) {

        CardManager.shared.removePostFromCard(postID: postID) { result in

            switch result {

            case .success(let success):

                print(success)

                self.navigationController?.popViewController(animated: true)

            case .failure(let error):

                print(error)
            }
        }
    }

    func updateUserPost(postID: String, action: UserManager.PostAction) {

        UserManager.shared.updateUserPost(
            uid: self.postAuthor?.uid ?? "",
            postID: postID,
            postAction: action
        ) { result in

            switch result {

            case .success(let success):

                print(success)

                self.deletePostFromCard(postID: postID)

            case .failure(let error):

                print(error)
            }
        }
    }

    // MARK: TableView
    // Header: post content
    override func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int ) -> UIView? {

        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: BaseDetailTableViewHeader.identifier
        ) as? BaseDetailTableViewHeader else { fatalError("Cannot load header view.") }

        let tapGoToCardTopicGesture = UITapGestureRecognizer(target: self, action: #selector(goToCardTopicPage(_:)))

        header.cardStackView.addGestureRecognizer(tapGoToCardTopicGesture)
        header.cardStackView.isUserInteractionEnabled = true

        isAuthor = postAuthor?.uid == visitorUid ? true : false

        guard post != nil, postAuthor != nil else { fatalError("Cannot fetch post data") }

        header.layoutHeader(
            post: post,
            postAuthor: postAuthor,
            isAuthor: self.isAuthor,
            isLike: isLike)

        // Pass data from Post Detail page to Write page

        header.likeHandler = {

            // When tapping on the like button, check if the user has likedPost

            guard let postID = self.post?.postID else { return }

            let likeAction: LikeAction = self.isLike ? .dislike : .like

            header.likeButton.isEnabled = false

            PostManager.shared.updateLikes(postID: postID, likeAction: likeAction) { result in

                switch result {

                case .success(_):

                    if likeAction == .like {
                        self.post?.likeNumber += 1
                        self.isLike = true
                    } else if likeAction == .dislike {
                        self.post?.likeNumber -= 1
                        self.isLike = false
                    }

                    header.likeButton.isEnabled = true

                    tableView.reloadData()

                case .failure(let error):

                    print(error)

                    DispatchQueue.main.async {
                        Toast.showFailure(text: "資料載入失敗")
                    }

                    header.likeButton.isEnabled = true
                }
            }
        }

        header.editHandler = {

            var writeVC: BaseWriteViewController? {

                if self.post?.cardID != nil {

                    return UIStoryboard.write.instantiateViewController(withIdentifier: String(describing: CardWriteViewController.self)) as? CardWriteViewController

                } else {

                    return UIStoryboard.write.instantiateViewController(withIdentifier: String(describing: ExploreWriteViewController.self)) as? ExploreWriteViewController
                }
            }

            guard let writeVC = writeVC else { return }

            let navigationVC = UINavigationController(rootViewController: writeVC)

            navigationVC.modalPresentationStyle = .automatic

            writeVC.contentTextView.text = self.post?.content

            writeVC.postID = self.post?.postID

            if let imageUrl = self.post?.imageUrl { writeVC.imageUrl = imageUrl }

            writeVC.contentHandler = { content, editTime, postImage in

                self.post?.content = content

                self.post?.editTime = editTime

                if self.post?.cardID != nil {
                    header.cardImageView.image = postImage
                    header.cardImageView.layoutIfNeeded()
                } else {
                    if postImage == nil {
                        header.postImageView.isHidden = true
                    } else {
                        header.postImageView.image = postImage
                    }
                    header.postImageView.layoutIfNeeded()
                }
            }

            if let cardID = self.post?.cardID {

                writeVC.uploadedImage = header.cardImageView.image

                CardManager.shared.fetchSpecificCard(cardID: cardID) { result in

                    switch result {

                    case .success(let card):

                        writeVC.card = card

                        self.navigationController?.present(navigationVC, animated: true)

                    case .failure(let error):

                        print(error)
                    }
                }

            } else {

                self.navigationController?.present(navigationVC, animated: true)
            }
        }

        header.deleteHandler = {

            let alert = UIAlertController(title: "確定要刪除嗎？", message: nil, preferredStyle: .alert)

            let okAction = UIAlertAction(title: "刪除", style: .default) { _ in

                guard let postID = self.post?.postID else { return }

                PostManager.shared.deletePost(postID: postID) { result in

                    switch result {

                    case .success(let success):

                        print(success)

                        if let postImageUrl = self.post?.imageUrl {

                            self.deleteImage(imageUrl: postImageUrl)
                        }

                        self.updateUserPost(postID: postID, action: .delete)

                    case .failure(let error):

                        print(error)

                        DispatchQueue.main.async { Toast.showFailure(text: "刪除失敗") }
                    }
                }
            }

            let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)

            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }

            header.optionHandler = {

                self.openOptionMenu(blockedUid: self.post?.uid ?? "", index: nil) {

                    self.navigationController?.popViewController(animated: true)
                }
            }

        // go to user's profile when tapping image, name, and time

        let tapGoToProfileGesture = UITapGestureRecognizer(target: self, action: #selector(goToProfileFromHeader(_:)))
        let tapGoToProfileGesture2 = UITapGestureRecognizer(target: self, action: #selector(goToProfileFromHeader(_:)))
        let tapGoToProfileGesture3 = UITapGestureRecognizer(target: self, action: #selector(goToProfileFromHeader(_:)))

        header.userImageView.addGestureRecognizer(tapGoToProfileGesture)
        header.userImageView.isUserInteractionEnabled = true
        header.userNameLabel.addGestureRecognizer(tapGoToProfileGesture2)
        header.userNameLabel.isUserInteractionEnabled = true
        header.timeLabel.addGestureRecognizer(tapGoToProfileGesture3)
        header.timeLabel.isUserInteractionEnabled = true

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
        let commentUser = commentUser[indexPath.row]

        var isCommentAuthor = false

        isCommentAuthor = comment.uid == visitorUid

        cell.layoutCell(
            comment: comment,
            userImageUrl: commentUser.profileImageUrl,
            userName: commentUser.name,
            isAuthor: isCommentAuthor
        )

        cell.hideSelectionStyle()

        cell.editHandler = { text in

            if cell.editTextField != cell.contentLabel {

                guard let postCommentID = comment.postCommentID else { return }

                PostCommentManager.shared.updateComment( postCommentID: postCommentID, newContent: text
                ) { result in

                    switch result {

                    case .success(let success):

                        print(success)

                        self.fetchComments(type: .post)

                    case .failure(let error):

                        print(error)

                        DispatchQueue.main.async { Toast.showFailure(text: "編輯評論失敗") }
                    }
                }
            }
        }

        cell.deleteHandler = {

            guard let postCommentID = comment.postCommentID else { return }

            let alert = UIAlertController(title: "確定要刪除嗎？", message: nil, preferredStyle: .alert)

            let okAction = UIAlertAction(title: "刪除", style: .destructive
            ) { _ in

                PostCommentManager.shared.deleteComment(
                    postCommentID: postCommentID
                ) { result in

                    switch result {

                    case .success(let success):

                        print(success)

                        PostManager.shared.updateCommentNumber(
                            postID: comment.postID ?? "",
                            commentAction: .delete
                        ) { result in

                            switch result {

                            case .success(let success): print(success)

                            case .failure(let error): print(error)
                            }
                        }

                        self.fetchComments(type: .post)

                    case .failure(let error):

                        print(error)

                        DispatchQueue.main.async { Toast.showFailure(text: "刪除評論失敗") }
                    }
                }
            }

            let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)

            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }

        cell.optionHandler = {

            self.openOptionMenu(blockedUid: commentUser.uid, index: indexPath.row, completion: nil)
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
}
