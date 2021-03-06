//
//  PlacemarkInteractorTests.swift
//  CurrentAddress
//
//  Created by Raymond Law on 8/3/17.
//  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import CurAddress
import XCTest

// MARK: - Test doubles

class PlacemarkPresentationLogicSpy: PlacemarkPresentationLogic
{
  var presentShowPhysicalAddressCalled = false
  
  func presentShowPhysicalAddress(response: Placemark.ShowPhysicalAddress.Response)
  {
    presentShowPhysicalAddressCalled = true
  }
}

class PlacemarkInteractorTests: XCTestCase
{
  // MARK: - Subject under test
  
  var sut: PlacemarkInteractor!
  
  // MARK: - Test lifecycle
  
  override func setUp()
  {
    super.setUp()
    setupPlacemarkInteractor()
  }
  
  override func tearDown()
  {
    super.tearDown()
  }
  
  // MARK: - Test setup
  
  func setupPlacemarkInteractor()
  {
    sut = PlacemarkInteractor()
  }
  
  // MARK: - Tests
  
  // MARK: Show physical address
  
  func testShowPhysicalAddress()
  {
    // Given
    let placemarkPresentationLogicSpy = PlacemarkPresentationLogicSpy()
    sut.presenter = placemarkPresentationLogicSpy
    sut.placemark = CurAddressTestHelpers.placemark
    let request = Placemark.ShowPhysicalAddress.Request()
    
    // When
    sut.showPhysicalAddress(request: request)
    
    // Then
    XCTAssertTrue(placemarkPresentationLogicSpy.presentShowPhysicalAddressCalled, "showPhysicalAddress() should ask the presenter to format the result")
  }
}
