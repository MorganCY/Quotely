//
//  ProfileViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/1.
//

import Foundation
import UIKit
import PhotosUI

class ProfileViewController: BaseImagePickerViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.registerHeaderWithNib(identifier: ProfileTableViewHeaderView.identifier, bundle: nil)
            tableView.registerCellWithNib(identifier: ProfileTableViewCell.identifier, bundle: nil)
            tableView.backgroundColor = .M3
        }
    }

    // the user who is visiting other's profile

    var visitorUid: String? {
        didSet {
            isVisitorProfile = visitorUid == visitedUid
        }
    }

    // the user who is visited by others

    var visitedUid = SignInManager.shared.visitorUid
    var visitorBlockList: [String]? {
        didSet {
            if let visitedUid = visitedUid,
               let visitorBlockList = visitorBlockList {
                isBlock = visitorBlockList.contains(visitedUid)
            }
        }
    }
    var visitorFollowingList: [String]? {
        didSet {
            if let visitedUid = visitedUid,
               let visitorFollowingList = visitorFollowingList {
                isFollow = visitorFollowingList.contains(visitedUid)
            }
        }
    }

    // if the profile visitor is the profile owener. set true by default.

    var isVisitorProfile = true

    var isBlock = false {
        didSet {
            if tableView != nil { tableView.reloadData() }
        }
    }

    var isFollow = false {
        didSet {
            fetchVisitedUserInfo(uid: visitedUid ?? "")
        }
    }

    var visitedUserInfo: User? {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.reloadData()
        }
    }

    var visitedUserPostList = [Post]() {
        didSet {
            tableView.reloadData()
        }
    }

    let loadingAnimationView = LottieAnimationView(animationName: "whiteLoading")

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLoadingAnimation()

        navigationItem.title = "個人資訊"

        if isVisitorProfile {

            navigationItem.setupRightBarButton(
                image: UIImage.sfsymbol(.settings),
                text: nil,
                target: self,
                action: #selector(goToSettingsPage(_:)),
                color: .M1
            )
        }

        visitorUid = UserManager.shared.visitorUserInfo?.uid
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchVisitedUserInfo(uid: visitedUid ?? "")
        listenToVisitedUserPost(uid: visitedUid ?? "")
        visitorBlockList = UserManager.shared.visitorUserInfo?.blockList
        visitorFollowingList = UserManager.shared.visitorUserInfo?.followingList
    }

    func fetchVisitedUserInfo(uid: String) {

        UserManager.shared.fetchUserInfo(uid: uid) { result in

            switch result {

            case .success(let userInfo):

                self.visitedUserInfo = userInfo

                self.loadingAnimationView.removeFromSuperview()

            case .failure(let error):

                print(error)

                self.loadingAnimationView.removeFromSuperview()

                DispatchQueue.main.async {
                    Toast.showFailure(text: "資料載入異常")
                }
            }
        }
    }

    func listenToVisitedUserPost(uid: String) {

        _ = PostManager.shared.listenToPostUpdate(type: .user, uid: uid, followingList: nil) { result in

            switch result {

            case .success(let posts):

                self.visitedUserPostList = posts

            case .failure(let error):

                print(error)
            }
        }
    }

    @objc func goToSettingsPage(_ sender: UIBarButtonItem) {

        guard let settingsVC =
                UIStoryboard.profile
                .instantiateViewController(
                    withIdentifier: String(describing: SettingsViewController.self)
                ) as? SettingsViewController else {

                    return
                }

        let navigationVC = BaseNavigationController(rootViewController: settingsVC)

        navigationVC.modalPresentationStyle = .fullScreen

        present(navigationVC, animated: true)
    }

    override func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {

        picker.dismiss(animated: true)

        Toast.showLoading(text: "上傳中")

        guard let selectedImage = info[.editedImage] as? UIImage else {

            return
        }

        // remove original image from firebase storage

        ImageManager.shared.deleteImage(
            imageUrl: self.visitedUserInfo?.profileImageUrl ?? "") { result in

                switch result {

                case .failure(let error): print(error)

                case .success(let success):

                    print(success)

                    // upload new image to firebase storage

                    ImageManager.shared.uploadImage(image: selectedImage) { result in

                        switch result {

                        case .success(let url):

                            Toast.shared.hud.dismiss()

                            // update user profile image in firestore

                            UserManager.shared.updateUserInfo(
                                uid: self.visitedUserInfo?.uid ?? "",
                                profileImageUrl: url,
                                userName: nil
                            ) { result in

                                    switch result {

                                    case .success(let success):

                                        print(success)

                                        self.fetchVisitedUserInfo(uid: self.visitedUserInfo?.uid ?? "")

                                        Toast.shared.hud.dismiss()

                                    case .failure(let error):

                                        print(error)

                                        Toast.showFailure(text: "上傳失敗")
                                    }
                                }

                        case .failure(let error):

                            print(error)

                            Toast.showFailure(text: "上傳失敗")

                            picker.dismiss(animated: true)
                        }
                    }
                }
            }
    }

    @available(iOS 14, *)
    override func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        picker.dismiss(animated: true)

        Toast.showLoading(text: "上傳中")

        guard !results.isEmpty else { return }

        for result in results {

            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (image, error) in

                guard let selectedImage = image as? UIImage else {

                    DispatchQueue.main.async {

                        picker.dismiss(animated: true)
                    }

                    return
                }

                // remove original image from firebase storage

                ImageManager.shared.deleteImage(
                    imageUrl: self.visitedUserInfo?.profileImageUrl ?? "") { result in

                        switch result {

                        case .failure(let error): print(error)

                        case .success(let success):

                            print(success)

                            // upload new image to firebase storage

                            ImageManager.shared.uploadImage(image: selectedImage) { result in

                                switch result {

                                case .success(let url):

                                    Toast.shared.hud.dismiss()

                                    // update profile image in firestore

                                    UserManager.shared.updateUserInfo(
                                        uid: self.visitedUserInfo?.uid ?? "",
                                        profileImageUrl: url,
                                        userName: nil
                                    ) { result in

                                            switch result {

                                            case .success(let success):

                                                print(success)

                                                self.fetchVisitedUserInfo(uid: self.visitedUserInfo?.uid ?? "")

                                                Toast.shared.hud.dismiss()

                                            case .failure(let error):

                                                print(error)

                                                Toast.showFailure(text: "上傳失敗")
                                            }
                                        }

                                case .failure(let error):

                                    print(error)

                                    Toast.showFailure(text: "上傳失敗")

                                    picker.dismiss(animated: true)
                                }
                            }
                        }
                    }
            })
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

    @objc func goToFollowList(_ gestureRecognizer: UITapGestureRecognizer) {

        guard let followVC =
                UIStoryboard.profile
                .instantiateViewController(
                    withIdentifier: String(describing: FollowListViewController.self)
                ) as? FollowListViewController else {

                    return
                }

        followVC.visitedUid = visitedUid

        navigationController?.pushViewController(followVC, animated: true)
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { visitedUserPostList.count }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

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

        header.isVisitorProfile = isVisitorProfile

        header.layoutHeader(userInfo: userInfo, isBlock: isBlock, isFollow: isFollow)

        header.blockButton.isEnabled = !isFollow

        header.followButton.isEnabled = !isBlock

        header.followStackView.addGestureRecognizer(goToFollowListGesture)
        header.followStackView.isUserInteractionEnabled = true

        header.editImageHandler = {

            self.openImagePicker()
        }

        header.editNameHandler = { userName in

            UserManager.shared.updateUserInfo(
                uid: userInfo.uid,
                profileImageUrl: nil,
                userName: userName
            ) { result in

                switch result {

                case .success(let success):
                    print(success)

                case .failure(let error):
                    print(error)
                }
            }
        }

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

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { UITableView.automaticDimension }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let detailVC =
                UIStoryboard.explore
                .instantiateViewController(
                    withIdentifier: String(describing: PostDetailViewController.self)
                ) as? PostDetailViewController else {

                    return
                }

        let row = indexPath.row

        detailVC.post = visitedUserPostList[row]
        detailVC.postAuthor = visitedUserInfo

        if let likeUserList = visitedUserPostList[row].likeUser {

            detailVC.isLike = likeUserList.contains(visitorUid ?? "")
        }

        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        UITableView.automaticDimension
    }
}

extension ProfileViewController {

    func setupLoadingAnimation() {

        view.addSubview(loadingAnimationView)
        loadingAnimationView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            loadingAnimationView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            loadingAnimationView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            loadingAnimationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingAnimationView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
