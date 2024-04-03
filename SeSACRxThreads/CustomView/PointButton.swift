//
//  PointButton.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit

class PointButton: UIButton {
  
  init(title: String) {
    super.init(frame: .zero)
    
    configuration = .filled().configured {
      $0.title = title
      $0.baseBackgroundColor = .black
      $0.cornerStyle = .large
      $0.buttonSize = .large
    }
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
