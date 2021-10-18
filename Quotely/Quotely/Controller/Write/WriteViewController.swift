//
//  WriteViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import Foundation
import UIKit

class WriteViewController: UIViewController {

    private let contentTextView = UITextView()

    private let hashtagLabel = UILabel()

    private let editOptionView = EditOptionView()

    let postProvider = PostProvider()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "撰寫摘語"

        contentTextView.delegate = self

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "分享", style: .plain, target: self, action: #selector(post(_:)))
    }

    override func viewDidLayoutSubviews() {

        layoutViews()
    }

    @objc func post(_ sender: UIBarButtonItem) {

        if !contentTextView.text.isEmpty {

            let post = Post(
                uid: "test123456",
                createdTime: Date().millisecondsSince1970,
                editTime: nil,
                content: contentTextView.text,
                photoUrl: nil,
                hashtag: nil,
                likeNumber: nil,
                likeUser: nil,
                commentNumber: nil)

            postProvider.publishPost(post: post) { _ in

                self.dismiss(animated: true, completion: nil)
            }

        } else {

            let alert = UIAlertController(
                title: "請輸入內容", message: "請輸入內容", preferredStyle: .alert)

            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)

            alert.addAction(alertAction)

            present(alert, animated: true)
        }
    }

    private func layoutViews() {

        self.view.addSubview(contentTextView)
        self.view.addSubview(hashtagLabel)
        self.view.addSubview(editOptionView)

        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        hashtagLabel.translatesAutoresizingMaskIntoConstraints = false
        editOptionView.translatesAutoresizingMaskIntoConstraints = false

        hashtagLabel.text = "新增標籤"
        contentTextView.text = "有什麼感觸...?"
        contentTextView.textColor = .gray
        hashtagLabel.textColor = .black
        contentTextView.font = UIFont.systemFont(ofSize: 18)
        hashtagLabel.font = UIFont.systemFont(ofSize: 18)

        NSLayoutConstraint.activate([

            contentTextView.topAnchor.constraint(equalTo: self.view.topAnchor),
            contentTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            contentTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            contentTextView.heightAnchor.constraint(equalToConstant: self.view.frame.height / 3),

            hashtagLabel.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 16),
            hashtagLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),

            editOptionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            editOptionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            editOptionView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.2),
            editOptionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
}

extension WriteViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {

        contentTextView.text = ""

        contentTextView.textColor = UIColor.black

        if !contentTextView.text!.isEmpty && contentTextView.text! == "有什麼感觸...?" {

            contentTextView.text = ""

            contentTextView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {

        if contentTextView.text.isEmpty {

            contentTextView.text = "有什麼感觸...?"

            contentTextView.textColor = UIColor.lightGray
        }
    }
}
