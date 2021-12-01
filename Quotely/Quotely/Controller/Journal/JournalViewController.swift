//
//  JournalViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/26.
//

import Foundation
import UIKit

class JournalViewController: UIViewController {

    // MARK: User Default
    private let defaults = UserDefaults.standard

    // MARK: Interface
    private let dateLabel = UILabel()
    private let dailyQuoteLabel = UILabel()
    private var selectedEmoji: SFSymbol?
    private let educationDimmingView = UIView()
    private let backgroundView = UIView()
    private let editPanel = UIView()
    private let buttonImages = [
        UIImage.sfsymbol(.smile),
        UIImage.sfsymbol(.book),
        UIImage.sfsymbol(.umbrella),
        UIImage.sfsymbol(.moon),
        UIImage.sfsymbol(.fire),
        UIImage.sfsymbol(.music)
    ]
    private let emojiTitleLabel = UILabel()
    private var emojiSelection = SelectionView()
    private var journalTextView = ContentTextView()
    private let textNumberLabel = UILabel()
    private let submitButton = UIButton()
    private let collapseButton = ImageButton(image: UIImage.sfsymbol(.collapse), color: .M1)
    private let journalListButton = RowButton(
        image: UIImage.sfsymbol(.calendar),
        imageColor: .M2,
        labelColor: .gray,
        text: "查看所有隻字")

    // MARK: Expand EditPanel Animation
    private var editPanelCollapse = NSLayoutConstraint()
    private var editPanelExpand = NSLayoutConstraint()
    private var backgroundViewCornerRadius = CGFloat()
    private var journalTextViewCollapse = NSLayoutConstraint()
    private var journalTextViewExpand = NSLayoutConstraint()
    private var isEditPanelExpand = false {
        didSet {
            expandAnimation()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchQuoteOncePerDay()
        configureGradientLayer()
        setupTitle()
        setupEditPanel()
        setupButtons()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if UIApplication.isFirstLaunch(forKey: "HasLaunchedJournalVC") {
            setupEducationView()
        }
        backgroundView.cornerRadius = isEditPanelExpand
        ? 0 : backgroundView.frame.width / 2
        collapseButton.cornerRadius = collapseButton.frame.width / 2
    }

    func fetchQuoteOncePerDay() {

        let lastJournalCall = defaults.string(forKey: "LastJournalCall")

        let currentDate = Date().getCurrentTime(format: .dd)

        if lastJournalCall != nil {

            if currentDate != lastJournalCall {

                fetchQuote()
                defaults.set(currentDate, forKey: "LastJournalCall")

            } else {

                self.dailyQuoteLabel.text = defaults.string(forKey: "LastJournalQuote")?
                    .replacingOccurrences(of: "\\n", with: "\n")
            }
        } else {

            fetchQuote()
            defaults.set(currentDate, forKey: "LastJournalCall")
        }
    }

    func fetchQuote() {

        CardManager.shared.fetchRandomCards(limitNumber: 1) { result in

            switch result {

            case .success(let cards):
                let lastJournalQuote = (cards.first?.content.replacingOccurrences(of: "\\n", with: "\n") ?? "")
                + "\n\n" +
                (cards.first?.author ?? "")
                self.defaults.set(lastJournalQuote, forKey: "LastJournalQuote")
                self.dailyQuoteLabel.text = lastJournalQuote

            case .failure(let error):
                print(error)
            }
        }
    }
}

extension JournalViewController: SelectionViewDataSource {

    func numberOfButtonsAt(_ view: SelectionView) -> Int { buttonImages.count }

    func buttonStyle(_ view: SelectionView) -> ButtonStyle { .image }

    func buttonColor(_ view: SelectionView) -> UIColor { .lightGray }

    func indicatorColor(_ view: SelectionView) -> UIColor { .M1 }

    func indicatorWidth(_ view: SelectionView) -> CGFloat { 0.8 }

    func buttonImage(_ view: SelectionView, index: Int) -> UIImage? {

        view.buttons[0].tintColor = .black
        return buttonImages[index]
    }
}

extension JournalViewController: SelectionViewDelegate {

    func didSelectButtonAt(_ view: SelectionView, at index: Int) {

        view.buttons.forEach { $0.tintColor = .lightGray }
        view.buttons[index].tintColor = .S1

        if isEditPanelExpand == false {
            isEditPanelExpand = true
        }

        switch index {

        case 0: selectedEmoji = .smile
        case 1: selectedEmoji = .book
        case 2: selectedEmoji = .umbrella
        case 3: selectedEmoji = .moon
        case 4: selectedEmoji = .fire
        case 5: selectedEmoji = .music
        default: selectedEmoji = .smile
        }
    }

    func shouldSelectButtonAt(_ view: SelectionView, at index: Int) -> Bool { true }
}

extension JournalViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {

        isEditPanelExpand = journalTextView.isFirstResponder
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        let currentText = textView.text ?? ""

        guard let stringRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

        textNumberLabel.text = "\(updatedText.count) / 140"

        return updatedText.count <= 140
    }
}

// swiftlint:disable function_body_length
extension JournalViewController {

    @objc func tapSubmitButton(_ sender: UIButton) {

        var journal = Journal(
            createdMonth: "\(Calendar.current.component(.month, from: Date()))",
            createdYear: "\(Calendar.current.component(.year, from: Date()))",
            emoji: selectedEmoji?.rawValue ?? "face.smiling",
            content: journalTextView.text
        )

        JournalManager.shared.createJournal(
            journal: &journal
        ) { result in

            switch result {

            case .success(let success):
                print(success)
                self.isEditPanelExpand = false
                self.journalTextView.text.removeAll()
                Toast.showSuccess(text: ToastText.successAdd.rawValue)

            case .failure(let error):
                print(error)
                Toast.showFailure(text: ToastText.failToAdd.rawValue)
            }
        }
    }

    @objc func tapJournalListButton(_ sender: UIButton) {

        guard let journalListVC =
                UIStoryboard.journal.instantiateViewController(
                    withIdentifier: JournalListViewController.identifier
                ) as? JournalListViewController
        else { return }

        show(journalListVC, sender: nil)
    }

    @objc func tapCollapseButton(_ sender: UIButton) {

        isEditPanelExpand = false
    }

    func expandAnimation() {

        UIView.animate(
            withDuration: 1 / 2,
            delay: 0,
            options: .curveEaseIn
        ) {
            self.editPanelCollapse.isActive = !self.isEditPanelExpand
            self.editPanelExpand.isActive = self.isEditPanelExpand
            self.backgroundView.cornerRadius = self.isEditPanelExpand
            ?
            0 : self.backgroundView.frame.width / 2
            self.journalTextViewCollapse.isActive = !self.isEditPanelExpand
            self.journalTextViewExpand.isActive = self.isEditPanelExpand
            self.textNumberLabel.isHidden = !self.isEditPanelExpand
            self.submitButton.isHidden = !self.isEditPanelExpand
            self.collapseButton.isHidden = !self.isEditPanelExpand
            self.journalListButton.isHidden = self.isEditPanelExpand

            self.view.layoutIfNeeded()
        }
    }

    func configureGradientLayer() {

        let gradient = CAGradientLayer()
        view.backgroundColor = .clear
        gradient.colors = [UIColor.M1.cgColor, UIColor.M4.cgColor]
        gradient.locations = [0, 1]
        gradient.frame = view.bounds
        view.layer.addSublayer(gradient)
    }

    func setupTitle() {

        let labels = [dateLabel, dailyQuoteLabel]
        labels.forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textColor = .white
            $0.textAlignment = .center
        }

        dateLabel.text = "\(Date().getCurrentTime(format: .MM)).\(Date().getCurrentTime(format: .dd))"
        dateLabel.font = UIFont(name: "Avenir Next Heavy", size: 68)
        dailyQuoteLabel.font = UIFont.setRegular(size: 16)
        dailyQuoteLabel.numberOfLines = 0

        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -18),
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dailyQuoteLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 12),
            dailyQuoteLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dailyQuoteLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dailyQuoteLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    func setupEditPanel() {

        let panelObjects = [editPanel, emojiTitleLabel, emojiSelection, journalTextView, textNumberLabel, submitButton]

        panelObjects.forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        editPanel.backgroundColor = .white
        editPanel.cornerRadius = CornerRadius.standard.rawValue
        emojiTitleLabel.text = "選擇一個代表心情的Emoji"
        emojiTitleLabel.textColor = .lightGray
        emojiTitleLabel.font = UIFont.setBold(size: 16)
        emojiSelection.dataSource = self
        emojiSelection.delegate = self
        journalTextView.delegate = self
        self.submitButton.isHidden = !self.isEditPanelExpand

        editPanelCollapse = editPanel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25)
        editPanelExpand = editPanel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        editPanelCollapse.isActive = !isEditPanelExpand
        editPanelExpand.isActive = isEditPanelExpand
        journalTextView.cornerRadius = CornerRadius.standard.rawValue * 0.75
        journalTextView.contentInset = .init(top: 0, left: 10, bottom: 0, right: 0)

        journalTextView.placeholder(text: "  寫點什麼，只有自己看得到...", color: .lightGray)

        submitButton.setTitle("存檔", for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.backgroundColor = .M2
        submitButton.cornerRadius = CornerRadius.standard.rawValue * 0.75
        submitButton.titleLabel?.font = UIFont.setRegular(size: 20)

        submitButton.addTarget(self, action: #selector(tapSubmitButton(_:)), for: .touchUpInside)
        journalTextViewCollapse = journalTextView.bottomAnchor.constraint(
            equalTo: editPanel.bottomAnchor,
            constant: -20
        )
        journalTextViewExpand = journalTextView.bottomAnchor.constraint(
            equalTo: self.submitButton.topAnchor,
            constant: -16
        )
        journalTextViewCollapse.isActive = !isEditPanelExpand

        NSLayoutConstraint.activate([
            editPanel.topAnchor.constraint(equalTo: dailyQuoteLabel.bottomAnchor, constant: 32),
            editPanel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            editPanel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),

            emojiTitleLabel.centerXAnchor.constraint(equalTo: editPanel.centerXAnchor),
            emojiTitleLabel.topAnchor.constraint(equalTo: editPanel.topAnchor, constant: 16),

            emojiSelection.centerXAnchor.constraint(equalTo: editPanel.centerXAnchor),
            emojiSelection.widthAnchor.constraint(equalTo: editPanel.widthAnchor, multiplier: 0.9),
            emojiSelection.topAnchor.constraint(equalTo: emojiTitleLabel.bottomAnchor, constant: 16),
            emojiSelection.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.045),

            journalTextView.topAnchor.constraint(equalTo: emojiSelection.bottomAnchor, constant: 32),
            journalTextView.widthAnchor.constraint(equalTo: editPanel.widthAnchor, multiplier: 0.9),
            journalTextView.centerXAnchor.constraint(equalTo: editPanel.centerXAnchor),

            textNumberLabel.trailingAnchor.constraint(equalTo: journalTextView.trailingAnchor, constant: -16),
            textNumberLabel.bottomAnchor.constraint(equalTo: journalTextView.bottomAnchor, constant: -8),
            textNumberLabel.widthAnchor.constraint(equalTo: journalTextView.widthAnchor, multiplier: 0.3),

            submitButton.leadingAnchor.constraint(equalTo: editPanel.leadingAnchor, constant: 24),
            submitButton.trailingAnchor.constraint(equalTo: journalTextView.trailingAnchor),
            submitButton.heightAnchor.constraint(equalTo: editPanel.heightAnchor, multiplier: 0.12),
            submitButton.bottomAnchor.constraint(equalTo: editPanel.bottomAnchor, constant: -24)
        ])
    }

    func setupButtons() {

        view.addSubview(journalListButton)
        view.addSubview(collapseButton)
        journalListButton.translatesAutoresizingMaskIntoConstraints = false
        collapseButton.translatesAutoresizingMaskIntoConstraints = false

        collapseButton.isHidden = !isEditPanelExpand
        collapseButton.backgroundColor = .clear
        collapseButton.addTarget(self, action: #selector(tapCollapseButton(_:)), for: .touchUpInside)

        textNumberLabel.text = "\(journalTextView.text.count) / 140"
        textNumberLabel.textColor = .black
        textNumberLabel.font = UIFont.setRegular(size: 14)
        textNumberLabel.textAlignment = .right
        textNumberLabel.isHidden = !isEditPanelExpand

        journalListButton.cornerRadius = CornerRadius.standard.rawValue
        journalListButton.backgroundColor = .white
        journalListButton.addTarget(self, action: #selector(tapJournalListButton(_:)), for: .touchUpInside)

        NSLayoutConstraint.activate([
            collapseButton.centerXAnchor.constraint(equalTo: editPanel.centerXAnchor),
            collapseButton.topAnchor.constraint(equalTo: editPanel.bottomAnchor, constant: 16),
            collapseButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15),
            collapseButton.heightAnchor.constraint(equalTo: collapseButton.widthAnchor),
            journalListButton.leadingAnchor.constraint(equalTo: editPanel.leadingAnchor),
            journalListButton.topAnchor.constraint(equalTo: editPanel.bottomAnchor, constant: 24),
            journalListButton.trailingAnchor.constraint(equalTo: editPanel.trailingAnchor),
            journalListButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1)
        ])
    }

    func setupEducationView() {

        let topTitleLabel = UILabel()
        let bottomTitleLabel = UILabel()
        let topArrow = LottieAnimationView(animationName: "arrow")
        let bottomArrow = LottieAnimationView(animationName: "arrow")
        let okButton = UIButton()
        bottomArrow.transform = CGAffineTransform(rotationAngle: .pi)

        let views = [topTitleLabel, bottomTitleLabel, topArrow, bottomArrow, okButton]

        view.addSubview(educationDimmingView)
        view.bringSubviewToFront(educationDimmingView)
        educationDimmingView.translatesAutoresizingMaskIntoConstraints = false
        educationDimmingView.backgroundColor = .black.withAlphaComponent(0.8)

        views.forEach {
            educationDimmingView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let labels = [topTitleLabel, bottomTitleLabel]
        topTitleLabel.text = "點擊emoji或輸入文字，\n紀錄隻字隨筆"
        bottomTitleLabel.text = "點擊查看紀錄過的隻字隨筆"

        labels.forEach {
            $0.textColor = .white
            $0.font = UIFont.setBold(size: 18)
            $0.numberOfLines = 0
        }

        okButton.setTitle("好喔", for: .normal)
        okButton.setTitleColor(.black, for: .normal)
        okButton.backgroundColor = .white.withAlphaComponent(0.7)
        okButton.titleLabel?.font = UIFont.setBold(size: 18)
        okButton.cornerRadius = CornerRadius.standard.rawValue
        okButton.addTarget(self, action: #selector(dismissEducationAnimation(_:)), for: .touchUpInside)

        NSLayoutConstraint.activate([
            educationDimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            educationDimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            educationDimmingView.widthAnchor.constraint(equalTo: view.widthAnchor),
            educationDimmingView.heightAnchor.constraint(equalTo: view.heightAnchor),

            topArrow.bottomAnchor.constraint(equalTo: editPanel.topAnchor),
            topArrow.leadingAnchor.constraint(equalTo: editPanel.leadingAnchor),
            topArrow.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.25),
            topArrow.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),

            topTitleLabel.leadingAnchor.constraint(equalTo: topArrow.trailingAnchor),
            topTitleLabel.centerYAnchor.constraint(equalTo: topArrow.centerYAnchor),
            topTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            bottomArrow.topAnchor.constraint(equalTo: journalListButton.bottomAnchor),
            bottomArrow.leadingAnchor.constraint(equalTo: topArrow.leadingAnchor),
            bottomArrow.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.25),
            bottomArrow.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.25),

            bottomTitleLabel.leadingAnchor.constraint(equalTo: bottomArrow.trailingAnchor),
            bottomTitleLabel.centerYAnchor.constraint(equalTo: bottomArrow.centerYAnchor),
            bottomTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            okButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            okButton.centerXAnchor.constraint(equalTo: educationDimmingView.centerXAnchor),
            okButton.widthAnchor.constraint(equalTo: educationDimmingView.widthAnchor, multiplier: 0.3),
            okButton.heightAnchor.constraint(equalTo: educationDimmingView.heightAnchor, multiplier: 0.05)
        ])
    }

    @objc func dismissEducationAnimation(_ sender: UIButton) {
        educationDimmingView.removeFromSuperview()
    }
}
