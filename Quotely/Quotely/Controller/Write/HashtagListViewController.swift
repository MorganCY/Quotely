//
//  HashtagListViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/30.
//

import Foundation
import UIKit

class HashtagListViewController: UIViewController {

    let searchController = UISearchController(searchResultsController: nil)
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }

    var hashtagList = [Hashtag]() {
        didSet {
            filteredHashtagList = hashtagList
        }
    }
    var filteredHashtagList = [Hashtag]() {
        didSet {
            tableView.reloadData()
        }
    }
    var hashtagHandler: ((String) -> Void) = {_ in}

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.registerCellWithNib(identifier: HashtagListTableViewCell.identifier, bundle: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "主題列表"
        setupSearchBar()
        filteredHashtagList = hashtagList

        fetchHashtags()
    }

    @IBAction func addHashtag(_ sender: UIBarButtonItem) {

        let alert = UIAlertController(title: "新增主題", message: nil, preferredStyle: .alert)
        alert.addTextField()

        let submitAction = UIAlertAction(title: "提交", style: .default
        ) { [unowned alert] _ in

            guard let textField = alert.textFields?[0] else {

                return
            }

            guard let newHashtag = textField.text else { return }

            self.dismiss(animated: true) {

                self.hashtagHandler("#" + newHashtag)
            }
        }

        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        alert.textFields?[0].delegate = self

        alert.addAction(submitAction)

        alert.addAction(cancel)

        present(alert, animated: true)
    }

    func fetchHashtags() {

        HashtagManager.shared.fetchHashtag(
            postID: nil) { result in

                switch result {

                case .success(let hashtagList):
                    self.hashtagList = hashtagList

                case .failure(let error):
                    print(error)
                }
            }
    }

    func setupSearchBar() {

        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    func search(_ searchText: String) {
        if searchText.isEmpty {
            filteredHashtagList = hashtagList
        } else {
            filteredHashtagList = hashtagList.filter {
                $0.title.contains(searchText)
            }
        }
        tableView.reloadData()
    }
}

extension HashtagListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        let searchText = searchBar.text ?? ""
        search(searchText)
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) { filteredHashtagList = hashtagList }
}

extension HashtagListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { filteredHashtagList.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: HashtagListTableViewCell.identifier,
            for: indexPath
        ) as? HashtagListTableViewCell else {

            fatalError("Cannot create cell")
        }

        cell.layoutCell(hashtag: filteredHashtagList[indexPath.row])
        cell.hideSelectionStyle()

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        dismiss(animated: true) {

            self.hashtagHandler(self.filteredHashtagList[indexPath.row].title)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        let animation = AnimationFactory.takeTurnsFadingIn(duration: 0.3, delayFactor: 0.1)
        let animator = Animator(animation: animation)
            animator.animate(cell: cell, at: indexPath, in: tableView)
    }
}

extension HashtagListViewController: UITextFieldDelegate {

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {

        let currentText = textField.text ?? ""

        guard let stringRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        return updatedText.count <= 12 && !updatedText.contains("#")
    }
}
