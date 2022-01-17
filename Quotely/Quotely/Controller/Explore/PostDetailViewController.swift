//
//  PostDetailViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/19.
//

import Foundation
import UIKit

class PostDetailViewController: UIViewController {

    // MARK: Post Data
    private var author: User? {
        didSet {
            tableView.reloadData()
        }
    }
    var post: Post?
    var postAuthor: User?
    private var likeNumber: Int?
    private var comments: [Comment] = []
    private var commentUserList: [User] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    private var isAuthor = false
    var isLikePost = false

    // MARK: Interface
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let commentPanel = UIView()
    private let userImageView = UIImageView()
    private let commentTextField = CommentTextField()
    private let submitCommentButton = ImageButton(image: UIImage.sfsymbol(.send), color: .M2)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCommentPanel()
        setupTableView()
        setupNavigation()
        setupTableView()
        fetchComments()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userImageView.cornerRadius = userImageView.frame.width / 2
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    func fetchComments() {

        guard let postID = post?.postID else { return }

        CommentManager.shared.fetchComment(postID: postID) { result in

            switch result {

            case .success(let comments):
                self.comments = comments
                self.fetchCommentUserInfo(commentList: comments)

            case .failure(let error):
                print(error)
                Toast.shared.showFailure(text: .failToDownload)
            }
        }
    }

    func fetchCommentUserInfo(commentList: [Comment]) {

        var userList: [User] = Array(repeating: User.default, count: commentList.count)

        let group = DispatchGroup()

        for (index, comment) in commentList.enumerated() {

            group.enter()

            UserManager.shared.fetchUserInfo(uid: comment.uid) { result in

                switch result {

                case .success(let user):
                    userList[index] = user
                    group.leave()

                case .failure(let error):
                    print(error)
                    Toast.shared.showFailure(text: .failToDownload)
                    group.leave()
                }
            }
        }

        group.notify(queue: DispatchQueue.main) {

            self.commentUserList = userList
        }
    }

    func openOptionMenu(blockedUid: String,
                        index: Int?,
                        completion: (() -> Void)?) {

        let blockUserAction = UIAlertAction(
            title: "檢舉並封鎖用戶",
            style: .destructive
        ) { _ in

            if let followingList = UserManager.shared.visitorUserInfo?.followingList {

                if followingList.contains(blockedUid) {

                    self.unfollowUser(blockedUid: blockedUid)
                }
            }

            self.blockUser(blockedUid: blockedUid, index: index, completion: completion)
        }

        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        let optionAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if let popoverController = optionAlert.popoverPresentationController {

            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(
                x: self.view.bounds.midX,
                y: self.view.bounds.midY,
                width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        optionAlert.addAction(blockUserAction)
        optionAlert.addAction(cancelAction)

        present(optionAlert, animated: true)
    }

    func unfollowUser(blockedUid: String) {

        UserManager.shared.updateUserList(
            userAction: .follow,
            visitedUid: blockedUid,
            action: .negative
        ) { result in

            switch result {

            case .success(let success):
                print(success)

            case .failure(let error):
                print(error)
                Toast.shared.showFailure(text: .failToDownload)
            }
        }
    }

    func blockUser(blockedUid: String,
                   index: Int?,
                   completion: (() -> Void)?) {

        UserManager.shared.updateUserList(
            userAction: .block,
            visitedUid: blockedUid,
            action: .positive
        ) { result in

            switch result {

            case .success(let success):
                print(success)

                if let index = index {

                    self.comments.remove(at: index)
                    self.commentUserList.remove(at: index)

                } else {

                    guard let completion = completion else { return }

                    completion()
                }

            case .failure(let error):
                print(error)
                Toast.shared.showFailure(text: .failToBlock)
            }
        }
    }

    func createComment() {

        guard let text = commentTextField.text else { return }

        guard !text.isEmpty else {

            Toast.shared.showFailure(text: .remindInput)
            return
        }

        submitCommentButton.isEnabled = false

        guard let commentText = commentTextField.text else { return }

        var comment = Comment(
            content: commentText,
            postID: post?.postID)

        CommentManager.shared.createComment(
            comment: &comment
        ) { result in

            switch result {

            case .success(let success):
                print(success)
                self.commentTextField.text = ""
                self.updateCommentNumber(
                    action: .positive
                ) {
                    self.submitCommentButton.isEnabled = true
                }
                self.fetchComments()

            case .failure(let error):
                print(error)
                Toast.shared.showFailure(text: .failToAdd)
                self.submitCommentButton.isEnabled = true
            }
        }
    }

    func fetchCard(cardID: String,
                   completion: @escaping (Result<Card, Error>) -> Void
    ) {

        CardManager.shared.fetchSpecificCard(cardID: cardID) { result in

            switch result {

            case .success(let card):
                completion(.success(card))

            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }

    func updateCommentNumber(
        action: FirebaseAction, completion: (() -> Void)?
    ) {

        FirebaseManager.shared.updateFieldNumber(
            collection: .posts,
            targetID: self.post?.postID ?? "",
            action: action,
            updateType: .comment
        ) { result in

            switch result {

            case .success(let successStatus):
                print(successStatus)

                if let completion = completion {
                    completion()
                }

            case .failure(let error):
                print(error)

                if let completion = completion {
                    completion()
                }
            }
        }
    }

    func updateUserPost(postID: String, action: FirebaseAction) {

        UserManager.shared.updateUserPost(
            postID: postID, postAction: action
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

    func updateComment(postCommentID: String, text: String) {

        CommentManager.shared.updateComment(
            postCommentID: postCommentID, newContent: text
        ) { result in

            switch result {

            case .success(let success):
                print(success)
                self.fetchComments()

            case .failure(let error):
                print(error)
                Toast.shared.showFailure(text: .failToUpdate)
            }
        }
    }

    func updatePostLike(postID: String,
                        likeAction: FirebaseAction,
                        successHandler: @escaping () -> Void,
                        errorHandler: @escaping () -> Void
    ) {

        FirebaseManager.shared.updateFieldNumber(
            collection: .posts,
            targetID: postID,
            action: likeAction,
            updateType: .like
        ) { result in

            switch result {

            case .success(let successStatus):
                print(successStatus)
                successHandler()

            case .failure(let error):
                print(error)
                Toast.shared.showFailure(text: .failToDownload)
                errorHandler()
            }
        }
    }

    func deletePost(postID: String) {

        FirebaseManager.shared.deleteDocument(
            collection: .posts, targetID: postID
        ) { result in

            switch result {

            case .success(let success):
                print(success)
                if let postImageUrl = self.post?.imageUrl {
                    self.deleteImage(imageUrl: postImageUrl)
                }
                self.deleteComment(idType: .postID, targetID: postID)
                self.updateUserPost(postID: postID, action: .negative)

            case .failure(let error):
                print(error)
                Toast.shared.showFailure(text: .failToDelete)
            }
        }
    }

    func deleteComment(idType: FirebaseManager.FirebaseDataID, targetID: String) {

        FirebaseManager.shared.deleteDocument(
            collection: .postComments, targetID: targetID
        ) { result in

            switch result {

            case .success(let successStatus):
                print(successStatus)
                self.updateCommentNumber(action: .negative, completion: nil)
                self.fetchComments()

            case .failure(let error):
                print(error)
                Toast.shared.showFailure(text: .failToDelete)
            }
        }
    }

    func deleteImage(imageUrl: String) {

        ImageManager.shared.deleteImage(imageUrl: imageUrl) { result in

            switch result {

            case .success(let success):
                print(success)

            case .failure(let error):
                print(error)
                Toast.shared.showFailure(text: .failToDelete)
            }
        }
    }

    func deletePostFromCard(postID: String) {

        CardManager.shared.deletePostFromCard(postID: postID) { result in

            switch result {

            case .success(let success):
                print(success)
                self.navigationController?.popViewController(animated: true)

            case .failure(let error):
                print(error)
            }
        }
    }
}

extension PostDetailViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        let currentText = textField.text ?? ""

        guard let stringRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        return updatedText.count <= 80
    }
}

extension PostDetailViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return comments.count
    }

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int ) -> UIView? {

        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: PostDetailTableViewHeader.identifier
        ) as? PostDetailTableViewHeader else { fatalError("Cannot load header view.") }

        header.delegate = self

        let tapGoToCardTopicGesture = UITapGestureRecognizer(target: self, action: #selector(tapCardTopicView(_:)))
        let tapGoToPostImageDetailGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(self.tapPostImageView(_:)))

        header.cardStackView.addGestureRecognizer(tapGoToCardTopicGesture)
        header.cardStackView.isUserInteractionEnabled = true
        header.postImageView.addGestureRecognizer(tapGoToPostImageDetailGesture)
        header.postImageView.isUserInteractionEnabled = true

        isAuthor = postAuthor?.uid == UserManager.shared.visitorUserInfo?.uid ?? ""

        guard post != nil, postAuthor != nil else { fatalError("Cannot fetch post data") }

        header.layoutHeader(post: post, postAuthor: postAuthor, isAuthor: self.isAuthor, isLike: isLikePost)

        let tapGoToProfileGesture = UITapGestureRecognizer(
            target: self, action: #selector(goToProfileFromHeader(_:))
        )
        header.userStackView.addGestureRecognizer(tapGoToProfileGesture)
        header.userImageView.isUserInteractionEnabled = true

        return header
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PostDetailCommentCell.identifier, for: indexPath
        ) as? PostDetailCommentCell
        else { fatalError("Cannot create cell.") }

        cell.delegate = self

        let comment = comments[indexPath.row]
        let commentUser = commentUserList[indexPath.row]
        var isCommentAuthor = false

        isCommentAuthor = comment.uid == UserManager.shared.visitorUserInfo?.uid ?? ""

        cell.layoutCell(comment: comment,
                        userImageUrl: commentUser.profileImageUrl,
                        userName: commentUser.name,
                        isAuthor: isCommentAuthor)

        cell.hideSelectionStyle()

        cell.editHandler = { [weak self] text in

            guard let self = self else { return }

            if cell.editTextField != cell.contentLabel {

                guard let postCommentID = comment.postCommentID else { return }

                self.updateComment(postCommentID: postCommentID, text: text)
            }
        }

        let tapGoToProfileGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(self.goToProfileFromCell(_:)))
        let tapGoToProfileGesture2 = UITapGestureRecognizer(
            target: self,
            action: #selector(self.goToProfileFromCell(_:)))

        cell.userImageView.addGestureRecognizer(tapGoToProfileGesture)
        cell.userImageView.isUserInteractionEnabled = true
        cell.nameLabel.addGestureRecognizer(tapGoToProfileGesture2)
        cell.nameLabel.isUserInteractionEnabled = true
        cell.userImageView.tag = indexPath.row
        cell.nameLabel.tag = indexPath.row

        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat { 200 }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {

        view.tintColor = UIColor.white
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        UITableView.automaticDimension
    }
}

extension PostDetailViewController: PostDetailTableViewHeaderDelegate {

    func likePostHeader(_ header: PostDetailTableViewHeader) {

        guard let postID = self.post?.postID else { return }

        let likeAction: FirebaseAction = self.isLikePost ? .negative : .positive

        header.likeButton.isEnabled = false

        self.updatePostLike(
            postID: postID,
            likeAction: likeAction
        ) {
            if likeAction == .positive {
                self.post?.likeNumber += 1
                self.isLikePost = true
            } else if likeAction == .negative {
                self.post?.likeNumber -= 1
                self.isLikePost = false
            }
            header.likeButton.isEnabled = true
            self.tableView.reloadData()

        } errorHandler: {

            header.likeButton.isEnabled = true
        }
    }

    func editPostHeader(_ header: PostDetailTableViewHeader) {

        var writeVC: BaseAddPostViewController?

        writeVC = self.post?.cardID == nil
        ?
        UIStoryboard.write.instantiateViewController(
            withIdentifier: AddPostViewController.identifier
        ) as? AddPostViewController :
        UIStoryboard.write.instantiateViewController(
            withIdentifier: AddCardPostViewController.identifier
        ) as? AddCardPostViewController

        guard let writeVC = writeVC else { return }

        let navigationVC = UINavigationController(rootViewController: writeVC)

        navigationVC.modalPresentationStyle = .fullScreen

        writeVC.contentTextView.text = self.post?.content

        writeVC.postID = self.post?.postID

        if let imageUrl = self.post?.imageUrl {
            writeVC.imageUrl = imageUrl
            writeVC.uploadedImage = header.postImageView.image
            writeVC.hasPostImage = true
        }

        writeVC.editContentHandler = { content, editTime, postImage in

            self.post?.content = content
            self.post?.editTime = editTime

            if self.post?.cardID != nil {
                header.cardImageView.image = postImage
                header.cardImageView.layoutIfNeeded()
            } else {
                if postImage == nil {
                    header.postImageView.isHidden = true
                } else { header.postImageView.image = postImage }
                header.postImageView.layoutIfNeeded()
            }
            self.tableView.reloadData()
        }

        if let cardID = self.post?.cardID {

            writeVC.uploadedImage = header.cardImageView.image

            self.fetchCard(cardID: cardID) { result in

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

    func deletePost(_ header: PostDetailTableViewHeader) {

        let alert = UIAlertController(title: "確定要刪除嗎？", message: nil, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "刪除", style: .default) { _ in

            guard let postID = self.post?.postID else { return }

            self.deletePost(postID: postID)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)

        if let popoverController = alert.popoverPresentationController {

            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(
                x: self.view.bounds.midX,
                y: self.view.bounds.midY,
                width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

    func optionMenuOfPost(_ header: PostDetailTableViewHeader) {

        self.openOptionMenu(blockedUid: self.post?.uid ?? "", index: nil) {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension PostDetailViewController: PostDetailCommentCellDelegate {

    func deleteCommentCell(_ cell: PostDetailCommentCell) {

        guard let row = tableView.indexPath(for: cell)?.row else { return }

        let comment = comments[row]

        guard let postCommentID = comment.postCommentID else { return }

        let alert = UIAlertController(title: "確定要刪除嗎？", message: nil, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "刪除", style: .destructive
        ) { _ in

            self.deleteComment(idType: .postCommentID, targetID: postCommentID)
        }

        let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)

        if let popoverController = alert.popoverPresentationController {

            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(
                x: self.view.bounds.midX,
                y: self.view.bounds.midY,
                width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

    func openOptionMenu(_ cell: PostDetailCommentCell) {

        guard let row = tableView.indexPath(for: cell)?.row else { return }

        let commentUser = commentUserList[row]

        openOptionMenu(blockedUid: commentUser.uid, index: row, completion: nil)
    }
}

extension PostDetailViewController {

    func setupNavigation() {

        navigationController?.setupBackButton(color: .gray)
        navigationItem.title = "想法"
    }

    @objc func tapSubmitCommentButton(_ sender: UIButton) {

        commentTextField.resignFirstResponder()
        createComment()
    }

    @objc func tapPostImageView(_ sender: UIImageView) {

        guard let postImageUrl = post?.imageUrl else { return }
        let imageDetailVC = ImageDetailViewController(imageUrl: postImageUrl)
        navigationController?.pushViewController(imageDetailVC, animated: true)
    }

    func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerHeaderWithNib(
            identifier: PostDetailTableViewHeader.identifier,
            bundle: nil)
        tableView.registerCellWithNib(
            identifier: PostDetailCommentCell.identifier, bundle: nil)
        tableView.backgroundColor = .white
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: commentPanel.topAnchor)
        ])
    }

    func setupCommentPanel() {

        let commentPanelObject = [
            commentPanel, userImageView, commentTextField, submitCommentButton
        ]

        commentPanelObject.forEach {

            self.view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        self.view.sendSubviewToBack(tableView)

        NSLayoutConstraint.activate([

            commentPanel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            commentPanel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            commentPanel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            commentPanel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.1),

            userImageView.leadingAnchor.constraint(equalTo: commentPanel.leadingAnchor, constant: 10),
            userImageView.topAnchor.constraint(equalTo: commentPanel.topAnchor, constant: 10),
            userImageView.widthAnchor.constraint(equalTo: commentPanel.widthAnchor, multiplier: 0.1),
            userImageView.heightAnchor.constraint(equalTo: userImageView.widthAnchor),

            commentTextField.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 10),
            commentTextField.heightAnchor.constraint(equalTo: userImageView.heightAnchor),
            commentTextField.trailingAnchor.constraint(equalTo: submitCommentButton.leadingAnchor, constant: -10),
            commentTextField.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),

            submitCommentButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            submitCommentButton.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
            submitCommentButton.widthAnchor.constraint(equalTo: commentPanel.widthAnchor, multiplier: 0.1),
            submitCommentButton.heightAnchor.constraint(equalTo: commentPanel.widthAnchor, multiplier: 0.1)
        ])

        commentPanel.backgroundColor = .white
        userImageView.backgroundColor = .gray
        userImageView.clipsToBounds = true
        commentTextField.delegate = self
        commentTextField.setLeftPaddingPoints(amount: 10)

        if let visitorUserImageUrl = UserManager.shared.visitorUserInfo?.profileImageUrl {

            userImageView.loadImage(visitorUserImageUrl, placeHolder: nil)

        } else {

            userImageView.image = UIImage.asset(.logo)
        }

        submitCommentButton.addTarget(
            self, action: #selector(tapSubmitCommentButton(_:)),
            for: .touchUpInside
        )
    }

    @objc func goToProfileFromHeader(_ gestureRecognizer: UITapGestureRecognizer) {

        guard let profileVC = UIStoryboard.profile
                .instantiateViewController(withIdentifier: ProfileViewController.identifier
                ) as? ProfileViewController
        else { return }

        guard let myVC = UIStoryboard.profile
                .instantiateViewController(withIdentifier: MyViewController.identifier
                ) as? MyViewController
        else { return }

        profileVC.visitedUid = postAuthor?.uid

        if postAuthor?.uid == UserManager.shared.visitorUserInfo?.uid {

            navigationController?.pushViewController(myVC, animated: true)

        } else {

            navigationController?.pushViewController(profileVC, animated: true)
        }
    }

    @objc func goToProfileFromCell(_ gestureRecognizer: UITapGestureRecognizer) {

        guard let profileVC = UIStoryboard.profile
                .instantiateViewController(withIdentifier: ProfileViewController.identifier
                ) as? ProfileViewController
        else { return }

        guard let myVC = UIStoryboard.profile
                .instantiateViewController(withIdentifier: MyViewController.identifier
                ) as? MyViewController
        else { return }

        guard let currentRow = gestureRecognizer.view?.tag else { return }

        profileVC.visitedUid = comments[currentRow].uid

        if comments[currentRow].uid == UserManager.shared.visitorUserInfo?.uid {

            self.show(myVC, sender: nil)

        } else {

            self.show(profileVC, sender: nil)
        }
    }

    @objc func tapCardTopicView(_ gestureRecognizer: UITapGestureRecognizer) {

        guard let cardTopicVC = UIStoryboard
                .card.instantiateViewController(withIdentifier: CardTopicViewController.identifier
                ) as? CardTopicViewController
        else { return }

        cardTopicVC.cardID = post?.cardID

        self.show(cardTopicVC, sender: nil)
    }
}
