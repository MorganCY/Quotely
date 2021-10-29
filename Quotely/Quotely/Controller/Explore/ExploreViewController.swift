//
//  ExploreViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import Foundation
import UIKit
import PhotosUI

class ExploreViewController: UIViewController {

    var postList: [Post] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    var likedPost = false

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addPostButton: UIButton!
    @IBOutlet weak var textRecognitionButton: UIButton!

    var imagePicker = UIImagePickerController()
    var recognizedImage = UIImage() {
        didSet {
            self.goToWritePage()
        }
    }

    // MARK: LiftCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerCellWithNib(
            identifier: ExploreTableViewCell.identifier,
            bundle: nil)

        tableView.dataSource = self

        tableView.delegate = self

        tableView.separatorStyle = .none

        navigationItem.title = "探索"

        listenToPostUpdate()

        imagePicker.delegate = self
    }

    override func viewDidLayoutSubviews() {

        setupAddPostButton()
    }

    // MARK: Data
    func listenToPostUpdate() {

        PostManager.shared.listenToPostUpdate { result in

            switch result {

            case .success(let posts):

                self.postList = posts

            case .failure(let error):

                print("listenData.failure: \(error)")
            }
        }
    }

    // MARK: Actions
    @IBAction func recognize(_ sender: UIButton) {

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in

            self.openCamera()
        }))

        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in

            self.openGallary()
        }))

        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    func goToWritePage() {

        guard let writeVC =
                UIStoryboard.write
                .instantiateViewController(
                    withIdentifier: String(describing: WriteViewController.self)
                ) as? WriteViewController else {

                    return
                }

        let nav = UINavigationController(rootViewController: writeVC)

        nav.modalPresentationStyle = .automatic

        self.navigationController?.present(nav, animated: true) {

            writeVC.recognizedImage = self.recognizedImage
        }
    }

    func setupAddPostButton() {

        addPostButton.layer.cornerRadius = addPostButton.frame.width / 2

        addPostButton.dropShadow(width: 0, height: 10)

        addPostButton.addTarget(self, action: #selector(addArticle(_:)), for: .touchUpInside)
    }

    @objc func addArticle(_ sender: UIButton) {

        guard let writeVC = UIStoryboard.write.instantiateViewController(
            withIdentifier: String(describing: WriteViewController.self)
        ) as? WriteViewController else { return }

        let nav = UINavigationController(rootViewController: writeVC)

        nav.modalPresentationStyle = .automatic

        self.navigationController?.present(nav, animated: true)
    }
}

// MARK: TableView
extension ExploreViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        let animation = AnimationFactory.takeTurnsFadingIn(duration: 0.5, delayFactor: 0.1)
        let animator = Animator(animation: animation)
            animator.animate(cell: cell, at: indexPath, in: tableView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        postList.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ExploreTableViewCell.identifier,
            for: indexPath) as? ExploreTableViewCell else {

                fatalError("Cannot create cell.")
            }

        let row = indexPath.row

        if let likeUserList = postList[row].likeUser {

            likedPost = likeUserList.contains("test123456") ?
            true : false

        } else {

            likedPost = false
        }

        cell.layoutCell(
            userImage: UIImage.asset(.testProfile),
            userName: "Morgan Yu",
            time: Date.fullDateFormatter.string(from: Date.init(milliseconds: postList[row].createdTime)),
            content: postList[row].content,
            postImageUrl: postList[row].imageUrl,
            likeNumber: nil,
            commentNumber: nil,
            hasLiked: likedPost
        )

        cell.likeHandler = {

            // When tapping on the like button, check if the user has likedPost
            if let likeUserList = self.postList[row].likeUser {

                self.likedPost = likeUserList.contains("test123456") ?
                true : false

            } else {

                self.likedPost = false
            }

            guard let postID = self.postList[row].postID else { return }

            let likeAction: LikeAction = self.likedPost
            ? .dislike : .like

            PostManager.shared.updateLikes(
                postID: postID, likeAction: likeAction
            ) { result in

                switch result {

                case .success(let action):

                    print(action)

                case .failure(let error):

                    print(error)
                }
            }
        }

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

        detailVC.postID = postList[row].postID ?? ""
        detailVC.userImage = UIImage.asset(.testProfile)
        detailVC.userName = "Morgan Yu"
        detailVC.time = postList[row].createdTime
        detailVC.content = postList[row].content
        detailVC.imageUrl = postList[row].imageUrl
        detailVC.uid = postList[row].uid

        if let likeUserList = postList[row].likeUser {

            detailVC.hasLiked = likeUserList.contains("test123456") ? true : false
        }
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: Image
extension ExploreViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {

        guard let selectedImage = info[.editedImage] as? UIImage else {

            return
        }

        recognizedImage = selectedImage

        dismiss(animated: true) {

            self.goToWritePage()
        }
    }

    // MARK: ImagePickerActions
    func openCamera() {

        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {

            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)

        } else {

            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func openGallary() {

        if #available(iOS 14, *) {

            var imageConfiguration = PHPickerConfiguration()
            imageConfiguration.filter = PHPickerFilter.images

            let picker = PHPickerViewController(configuration: imageConfiguration)
            picker.delegate = self

            self.present(picker, animated: true, completion: nil)

        } else {

            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {

                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)

            } else {

                let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

@available(iOS 14, *)
extension ExploreViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        picker.dismiss(animated: true)

        guard !results.isEmpty else { return }

        for result in results {

            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (image, error) in

                guard let image = image as? UIImage else { return picker.dismiss(animated: true) }

                DispatchQueue.main.async {

                    self.recognizedImage = image
                }
            })
        }
    }
}
