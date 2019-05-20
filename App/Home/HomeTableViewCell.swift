//
//  HomeTableViewCell.swift
//  RxSwift-Todo
//
//  Created by Ng Hui Qin on 5/19/19.
//  Copyright © 2019 huiqinlab. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()

    private lazy var checkBoxButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "check"), for: .selected)
        button.setImage(UIImage(named: "uncheck"), for: .normal)
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        checkBoxButton.isSelected = false
        titleLabel.text = nil
    }

    private func setupViews() {
        selectionStyle = .none

        contentView.addSubview(checkBoxButton)
        checkBoxButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
        }

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(checkBoxButton.snp.left).offset(-10)
        }
    }

    func setupContent(with taskItem: TaskItem) {
        titleLabel.text = taskItem.title
        checkBoxButton.isSelected = taskItem.checked
    }

}
