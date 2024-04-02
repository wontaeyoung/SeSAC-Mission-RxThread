//
//  ViewModel.swift
//  SeSACRxThreads
//
//  Created by 원태영 on 4/2/24.
//

import RxSwift

protocol ViewModel: AnyObject {
  
  associatedtype Input
  associatedtype Output
  
  // MARK: - Property
  var disposeBag: DisposeBag { get }
  
  // MARK: - Method
  func transform(input: Input) -> Output
}
