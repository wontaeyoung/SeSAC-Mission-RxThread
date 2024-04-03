//
//  SignUpViewModel.swift
//  SeSACRxThreads
//
//  Created by 원태영 on 4/3/24.
//

import RxSwift
import RxCocoa

final class SignUpViewModel: ViewModel {
  
  // MARK: - I / O
  struct Input {
    let email: PublishRelay<String>
  }
  
  struct Output {
    let validation: Driver<Bool>
  }
  
  // MARK: - Property
  let disposeBag = DisposeBag()
  
  // MARK: - Initializer
  init() {
    
  }
  
  // MARK: - Method
  func transform(input: Input) -> Output {
    
    let atMarkValidation = input.email
      .map { $0.filter { $0 == "@" }.count }
      .map { $0 == 1 }
    
    let dotValidation = input.email
      .map { $0.filter { $0 == "." }.count }
      .map { $0 == 1 }
    
    let validation = Observable.zip(atMarkValidation, dotValidation)
      .map { $0 && $1 }
      .asDriver(onErrorJustReturn: false)
    
    return Output(validation: validation)
  }
}
