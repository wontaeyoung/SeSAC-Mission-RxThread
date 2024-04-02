//
//  RxBaseTableCell.swift
//  SeSACRxThreads
//
//  Created by 원태영 on 4/2/24.
//

import UIKit
import RxSwift

internal class RxBaseTableCell: UITableViewCell {
  
  internal class var identifier: String {
    return self.description()
  }
  
  // MARK: - Property
  internal var disposeBag = DisposeBag()
  
  // MARK: - Initializer
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    backgroundColor = .clear
    contentView.backgroundColor = .clear
    
    setHierarchy()
    setConstraint()
    setAttribute()
    bind()
  }
  
  @available(*, unavailable)
  internal required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle
  internal func setHierarchy() { }
  internal func setConstraint() { }
  internal func setAttribute() { }
  internal func bind() { }
}
