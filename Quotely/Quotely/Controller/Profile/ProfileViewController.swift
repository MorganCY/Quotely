//
//  ProfileViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/1.
//

import Foundation
import Lottie
import UIKit
import PhotosUI

class ProfileViewController: BaseImagePickerViewController {

    enum UserType {

        case visited

        case visitor
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.registerHeaderWithNib(identifier: ProfileTableViewHeaderView.identifier, bundle: nil)
            tableView.registerCellWithNib(identifier: ProfileTableViewCell.identifier, bundle: nil)
            tableView.backgroundColor = .C3?.withAlphaComponent(0.5)
        }
    }

    // the user who is visiting other's profile

    let visitorUid = SignInManager.shared.uid

    // the user who is visited by others

    var visitedUid = SignInManager.shared.uid {
        didSet {
            isVisitorProfile = visitorUid == visitedUid
        }
    }

    // if the profile visitor is the profile owener. set true by default.

    var isVisitorProfile = true

    var isFollow = false {
        didSet {
            tableView.reloadData()
        }
    }

    var visitedUserInfo: User? {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.reloadData()
        }
    }

    var userPostList = [Post]() {
        didSet {
            tableView.reloadData()
        }
    }

    private var animationView: AnimationView?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "個人資訊"

        if isVisitorProfile {

            navigationItem.setupRightBarButton(
                image: UIImage.sfsymbol(.settings),
                text: nil,
                target: self,
                action: #selector(goToSettingsPage(_:)),
                color: .M1!
            )
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchUserInfo(userType: .visited)
        fetchUserInfo(userType: .visitor)
        listenToVisitedUserPost()
    }

    func fetchUserInfo(userType: UserType) {

        let uid: String = {
            switch userType {
            case .visited: return visitedUid ?? ""
            case .visitor: return visitorUid ?? ""
            }
        }()

        UserManager.shared.listenToUserUpdate(uid: uid) { result in

            switch result {

            case .success(let userInfo):

                if userType == .visited {

                    self.visitedUserInfo = userInfo

                } else if userType == .visitor {

                    guard let followingList = userInfo.following else { return }

                    self.isFollow = followingList.contains(self.visitedUid ?? "")
                }

            case .failure(let error):

                print(error)
            }
        }
    }

    func listenToVisitedUserPost() {

        guard let uid = visitedUid else { return }

        _ = PostManager.shared.listenToPostUpdate(type: .user, uid: uid, followingList: nil) { result in

            switch result {

            case .success(let posts):
                self.userPostList = posts

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

        let nav = BaseNavigationController(rootViewController: settingsVC)

        nav.modalPresentationStyle = .automatic

        present(nav, animated: true)
    }

    override func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {

        picker.dismiss(animated: true)

        Toast.showLoading(text: "載入中")

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

                                    case .failure(let error):

                                        print(error)
                                    }
                                }

                        case .failure(let error):

                            Toast.shared.hud.dismiss()

                            print(error)

                            self.present(
                                UIAlertController(
                                    title: "上傳失敗",
                                    message: nil,
                                    preferredStyle: .alert
                                ), animated: true, completion: nil
                            )

                            picker.dismiss(animated: true)
                        }
                    }
                }
            }
    }

    @available(iOS 14, *)
    override func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        picker.dismiss(animated: true)

        Toast.showLoading(text: "載入中")

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

                                            case .failure(let error):

                                                print(error)
                                            }
                                        }

                                case .failure(let error):

                                    Toast.shared.hud.dismiss()

                                    print(error)

                                    self.present(
                                        UIAlertController(
                                            title: "上傳失敗",
                                            message: nil,
                                            preferredStyle: .alert
                                        ), animated: true, completion: nil
                                    )

                                    picker.dismiss(animated: true)
                                }
                            }
                        }
                    }
            })
        }
    }

    func tapFollowButton(followAction: UserManager.FollowAction) {

        UserManager.shared.updateUserFollow(
            visitorUid: visitorUid ?? "",
            visitedUid: visitedUid ?? "",
            followAction: followAction) { result in

                switch result {

                case .success(let success): print(success)

                    if followAction == .follow {
                        self.isFollow = true
                    } else if followAction == .unfollow {
                        self.isFollow = false
                    }

                case .failure(let error): print(error)
                }
            }
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        userPostList.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: ProfileTableViewHeaderView.identifier
        ) as? ProfileTableViewHeaderView else {

            fatalError("Cannot create header view")
        }

        guard let userInfo = visitedUserInfo else {

            fatalError("Cannot fetch user info")
        }

        header.isVisitorProfile = isVisitorProfile

        header.layoutHeader(userInfo: userInfo, isFollow: isFollow)

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

        header.followHandler = {

            var followAction: UserManager.FollowAction = .follow

            followAction = self.isFollow ? .unfollow : .follow

            self.tapFollowButton(followAction: followAction)
        }

        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ProfileTableViewCell.identifier,
            for: indexPath
        ) as? ProfileTableViewCell else {

            fatalError("Cannot create cell")
        }

        let post = userPostList[indexPath.row]

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

        detailVC.post = userPostList[row]
        detailVC.postAuthor = visitedUserInfo

        if let likeUserList = userPostList[row].likeUser {

            detailVC.isLike = likeUserList.contains(visitorUid ?? "")
        }

        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        UITableView.automaticDimension
    }
}

extension ProfileViewController {

    func lottie() {

        animationView = .init(name: "ball")

        animationView!.frame = view.bounds

        animationView!.contentMode = .scaleAspectFit

        animationView!.loopMode = .loop

        animationView!.animationSpeed = 1

        view.addSubview(animationView!)

        animationView!.play()
    }
}
