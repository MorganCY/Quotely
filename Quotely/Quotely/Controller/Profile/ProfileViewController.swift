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

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.registerHeaderWithNib(identifier: ProfileTableViewHeaderView.identifier, bundle: nil)
            tableView.registerCellWithNib(identifier: ProfileTableViewCell.identifier, bundle: nil)
            tableView.backgroundColor = .C3?.withAlphaComponent(0.3)
        }
    }

    let uid = SignInManager.shared.uid
    var userInfo: User? {
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

        fetchUserInfo()
        fetchUserPost()

        navigationItem.title = "個人資訊"

        navigationItem.setupRightBarButton(
            image: UIImage.sfsymbol(.settings),
            text: nil,
            target: self,
            action: #selector(goToSettingsPage(_:)),
            color: .M1!
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if #available(iOS 15.0, *) {

            tableView.sectionHeaderTopPadding = 0
        }
    }

    func fetchUserInfo() {

        guard let uid = uid else { return }

        UserManager.shared.listenToUserUpdate(uid: uid) { result in

            switch result {

            case .success(let userInfo):
                self.userInfo = userInfo

            case .failure(let error):
                print(error)
            }
        }
    }

    func fetchUserPost() {

        guard let uid = uid else { return }

        PostManager.shared.listenToPostUpdate(type: .user, uid: uid) { result in

            switch result {

            case .success(let posts):
                self.userPostList = posts

            case .failure(let error):
                print(error)
            }
        }
    }

    @objc func goToSettingsPage(_ sender: UIBarButtonItem) {}

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
            imageUrl: self.userInfo?.profileImageUrl ?? "") { result in

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

                            UserManager.shared.updateProfileImage(
                                uid: self.userInfo?.uid ?? "",
                                profileImageUrl: url) { result in

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
                    imageUrl: self.userInfo?.profileImageUrl ?? "") { result in

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

                                    UserManager.shared.updateProfileImage(
                                        uid: self.userInfo?.uid ?? "",
                                        profileImageUrl: url) { result in

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

        guard let userInfo = userInfo else {

            fatalError("Cannot fetch user info")
        }

        header.layoutHeader(userInfo: userInfo)

        header.editImageHandler = {

            self.openImagePicker()
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
