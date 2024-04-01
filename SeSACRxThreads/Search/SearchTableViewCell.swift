//
//  SearchTableViewCell.swift
//  SeSACRxThreads
//
//  Created by jack on 2024/04/01.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SearchTableViewCell: UITableViewCell {
  
  static let identifier = "SearchTableViewCell"
  
  private let appNameLabel = UILabel().configured {
    $0.font = .systemFont(ofSize: 18, weight: .bold)
    $0.textColor = .black
  }
  
  private let appIconImageView = UIImageView().configured {
    $0.contentMode = .scaleAspectFit
    $0.clipsToBounds = true
    $0.backgroundColor = .systemMint
    $0.layer.cornerRadius = 8
  }
  
  private let downloadButton = UIButton().configured {
    $0.setTitle("받기", for: .normal)
    $0.setTitleColor(.systemBlue, for: .normal)
    $0.isUserInteractionEnabled = true
    $0.backgroundColor = .lightGray
    $0.layer.cornerRadius = 16
  }
  
  private var disposeBag = DisposeBag()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    self.selectionStyle = .none
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()
  }
  
  private func configure() {
    contentView.addSubview(appNameLabel)
    contentView.addSubview(appIconImageView)
    contentView.addSubview(downloadButton)
    
    appIconImageView.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalTo(20)
      $0.size.equalTo(60)
    }
    
    appNameLabel.snp.makeConstraints {
      $0.centerY.equalTo(appIconImageView)
      $0.leading.equalTo(appIconImageView.snp.trailing).offset(8)
      $0.trailing.equalTo(downloadButton.snp.leading).offset(-8)
    }
    
    downloadButton.snp.makeConstraints {
      $0.centerY.equalTo(appIconImageView)
      $0.trailing.equalToSuperview().inset(20)
      $0.height.equalTo(32)
      $0.width.equalTo(72)
    }
  }
  
  func updateUI(data: String) {
    appNameLabel.text = data
    appIconImageView.backgroundColor = .systemBlue
  }
  
  func tapEvent(observer: PublishSubject<Void>) {
    downloadButton.rx.tap
      .bind(to: observer)
      .disposed(by: disposeBag)
  }
}
