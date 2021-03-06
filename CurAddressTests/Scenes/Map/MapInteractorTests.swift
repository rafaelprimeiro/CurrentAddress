//
//  MapInteractorTests.swift
//  CurrentAddress
//
//  Created by Raymond Law on 8/1/17.
//  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import CurAddress
import XCTest
import MapKit

// MARK: - Test doubles

class MapLocationManagerSpy: CLLocationManager
{
  var requestWhenInUseAuthorizationCalled = false
  
  override func requestWhenInUseAuthorization()
  {
    requestWhenInUseAuthorizationCalled = true
  }
}

class MapGeocoderSpy: CLGeocoder
{
  var reverseGeocodeLocationCalled = false
  var reverseGeocodeLocationSuccess: Bool!
  var placemark: CLPlacemark!
  
  override func reverseGeocodeLocation(_ location: CLLocation, completionHandler: @escaping CLGeocodeCompletionHandler)
  {
    reverseGeocodeLocationCalled = true
    if reverseGeocodeLocationSuccess {
      completionHandler([placemark], nil)
    } else {
      let error = NSError(domain: kCLErrorDomain, code: CLError.geocodeFoundNoResult.rawValue, userInfo: nil)
      completionHandler(nil, error)
    }
  }
}

class MapPresentationLogicSpy: MapPresentationLogic
{
  var presentRequestForCurrentLocationCalled = false
  var presentGetCurrentLocationCalled = false
  var presentCenterMapCalled = false
  var presentGetCurrentAddressCalled = false
  
  var requestForCurrentLocationResponse: Map.RequestForCurrentLocation.Response!
  var getCurrentLocationResponse: Map.GetCurrentLocation.Response!
  var centerMapResponse: Map.CenterMap.Response!
  var getCurrentAddressResponse: Map.GetCurrentAddress.Response!
  
  func presentRequestForCurrentLocation(response: Map.RequestForCurrentLocation.Response)
  {
    presentRequestForCurrentLocationCalled = true
    requestForCurrentLocationResponse = response
  }
  
  func presentGetCurrentLocation(response: Map.GetCurrentLocation.Response)
  {
    presentGetCurrentLocationCalled = true
    getCurrentLocationResponse = response
  }
  
  func presentCenterMap(response: Map.CenterMap.Response)
  {
    presentCenterMapCalled = true
    centerMapResponse = response
  }
  
  func presentGetCurrentAddress(response: Map.GetCurrentAddress.Response)
  {
    presentGetCurrentAddressCalled = true
    getCurrentAddressResponse = response
  }
}

class MapInteractorTests: XCTestCase
{
  // MARK: - Subject under test
  
  var sut: MapInteractor!
  
  // MARK: - Test lifecycle
  
  override func setUp()
  {
    super.setUp()
    setupMapInteractor()
  }
  
  override func tearDown()
  {
    super.tearDown()
  }
  
  // MARK: - Test setup
  
  func setupMapInteractor()
  {
    sut = MapInteractor()
  }
  
  // MARK: - Tests
  
  // MARK: Request for current location
  
  func testRequestForCurrentLocation()
  {
    // Given
    let mapLocationManagerSpy = MapLocationManagerSpy()
    sut.locationManager = mapLocationManagerSpy
    let request = Map.RequestForCurrentLocation.Request()
    
    // When
    sut.requestForCurrentLocation(request: request)
    
    // Then
    XCTAssert(mapLocationManagerSpy.delegate === sut, "requestForCurrentLocation() should set locationManager's delegate to the interactor")
    XCTAssertTrue(mapLocationManagerSpy.requestWhenInUseAuthorizationCalled, "requestForCurrentLocation() should ask the location manager to request for GPS (when in use)")
  }
  
  func testLocationManagerDidChangeAuthorizationSuccess()
  {
    // Given
    let mapPresentationLogicSpy = MapPresentationLogicSpy()
    sut.presenter = mapPresentationLogicSpy
    
    // When
    sut.locationManager(sut.locationManager, didChangeAuthorization: .authorizedWhenInUse)
    
    // Then
    XCTAssertTrue(mapPresentationLogicSpy.presentRequestForCurrentLocationCalled, "locationManager(_:didChangeAuthorization:), given success, should ask the presenter to format the result")
    XCTAssertTrue(mapPresentationLogicSpy.requestForCurrentLocationResponse.success, "locationManager(_:didChangeAuthorization:), given success, should pass success to the presenter")
  }
  
  func testLocationManagerDidChangeAuthorizationFailureRestricted()
  {
    // Given
    let mapPresentationLogicSpy = MapPresentationLogicSpy()
    sut.presenter = mapPresentationLogicSpy
    
    // When
    sut.locationManager(sut.locationManager, didChangeAuthorization: .restricted)
    
    // Then
    XCTAssertTrue(mapPresentationLogicSpy.presentRequestForCurrentLocationCalled, "locationManager(_:didChangeAuthorization:), given failure (restricted), should ask the presenter to format the result")
    XCTAssertFalse(mapPresentationLogicSpy.requestForCurrentLocationResponse.success, "locationManager(_:didChangeAuthorization:), given failure (restricted), should pass failure to the presenter")
  }
  
  func testLocationManagerDidChangeAuthorizationFailureDenied()
  {
    // Given
    let mapPresentationLogicSpy = MapPresentationLogicSpy()
    sut.presenter = mapPresentationLogicSpy
    
    // When
    sut.locationManager(sut.locationManager, didChangeAuthorization: .denied)
    
    // Then
    XCTAssertTrue(mapPresentationLogicSpy.presentRequestForCurrentLocationCalled, "locationManager(_:didChangeAuthorization:), given failure (denied) should ask the presenter to format the result")
    XCTAssertFalse(mapPresentationLogicSpy.requestForCurrentLocationResponse.success, "locationManager(_:didChangeAuthorization:), given failure (denied), should pass failure to the presenter")
  }
  
  func testLocationManagerDidChangeAuthorizationUndefined()
  {
    // Given
    let mapPresentationLogicSpy = MapPresentationLogicSpy()
    sut.presenter = mapPresentationLogicSpy
    
    // When
    sut.locationManager(sut.locationManager, didChangeAuthorization: .notDetermined)
    
    // Then
    XCTAssertFalse(mapPresentationLogicSpy.presentRequestForCurrentLocationCalled, "locationManager(_:didChangeAuthorization:), given failure (undefined), should not ask the presenter to format the result")
  }
  
  // MARK: Get current location
  
  func testGetCurrentLocation()
  {
    // Given
    let mapView = MKMapView()
    let request = Map.GetCurrentLocation.Request(mapView: mapView)
    
    // When
    sut.getCurrentLocation(request: request)
    
    // Then
    XCTAssert(request.mapView.delegate === sut, "getCurrentLocation() should set mapView's delegate to the interactor")
  }
  
  func testMapViewDidUpdate()
  {
    // Given
    let mapPresentationLogicSpy = MapPresentationLogicSpy()
    sut.presenter = mapPresentationLogicSpy
    let mapView = MKMapView()
    let userLocation = MKUserLocation()
    
    // When
    sut.mapView(mapView, didUpdate: userLocation)
    
    // Then
    XCTAssertTrue(mapPresentationLogicSpy.presentGetCurrentLocationCalled, "mapView(_:didUpdate:) should ask the presenter to format the result")
    XCTAssertTrue(mapPresentationLogicSpy.getCurrentLocationResponse.success, "mapView(_:didUpdate:) should pass success to the presenter")
  }
  
  func testMapViewDidFailToLocateUserWithError()
  {
    // Given
    let mapPresentationLogicSpy = MapPresentationLogicSpy()
    sut.presenter = mapPresentationLogicSpy
    let mapView = MKMapView()
    let error = NSError(domain: MKErrorDomain, code: Int(MKError.unknown.rawValue), userInfo: nil)
    
    // When
    sut.mapView(mapView, didFailToLocateUserWithError: error)
    
    // Then
    XCTAssertTrue(mapPresentationLogicSpy.presentGetCurrentLocationCalled, "mapView(_:didFailToLocateUserWithError:) should ask the presenter to format the result")
    XCTAssertFalse(mapPresentationLogicSpy.getCurrentLocationResponse.success, "mapView(_:didFailToLocateUserWithError:) should pass failure to the presenter")
    XCTAssertEqual(mapPresentationLogicSpy.getCurrentLocationResponse.error, error, "mapView(_:didFailToLocateUserWithError:) should pass error to the presenter")
  }
  
  // MARK: Center map
  
  func testCenterMapFirstTime()
  {
    // Given
    let mapPresentationLogicSpy = MapPresentationLogicSpy()
    sut.presenter = mapPresentationLogicSpy
    sut.currentLocation = CLLocation(latitude: 37.92, longitude: -78.02)
    sut.centerMapFirstTime = false
    let request = Map.CenterMap.Request()
    
    // When
    sut.centerMap(request: request)
    
    // Then
    XCTAssertTrue(mapPresentationLogicSpy.presentCenterMapCalled, "centerMap(), for the first time, should ask the presenter to format the result")
    XCTAssertEqual(mapPresentationLogicSpy.centerMapResponse.coordinate.latitude, sut.currentLocation?.coordinate.latitude, "centerMap(), for the first time, should pass latitude to the presenter")
    XCTAssertEqual(mapPresentationLogicSpy.centerMapResponse.coordinate.longitude, sut.currentLocation?.coordinate.longitude, "centerMap(), for the first time, should pass longitude to the presenter")
  }
  
  func testCenterMapAfterFirstTime()
  {
    // Given
    let mapPresentationLogicSpy = MapPresentationLogicSpy()
    sut.presenter = mapPresentationLogicSpy
    sut.currentLocation = CLLocation(latitude: 37.92, longitude: -78.02)
    sut.centerMapFirstTime = true
    let request = Map.CenterMap.Request()
    
    // When
    sut.centerMap(request: request)
    
    // Then
    XCTAssertFalse(mapPresentationLogicSpy.presentCenterMapCalled, "centerMap(), after the first time, should not ask the presenter to format the result")
  }
  
  // MARK: Get current address
  
  func testGetCurrentAddressGivenNoLocation()
  {
    // Given
    let mapPresentationLogicSpy = MapPresentationLogicSpy()
    sut.presenter = mapPresentationLogicSpy
    let mapGeocoderSpy = MapGeocoderSpy()
    mapGeocoderSpy.reverseGeocodeLocationSuccess = false
    sut.geocoder = mapGeocoderSpy
    sut.currentLocation = nil
    let request = Map.GetCurrentAddress.Request()
    
    // When
    sut.getCurrentAddress(request: request)
    
    // Then
    XCTAssertFalse(mapPresentationLogicSpy.presentGetCurrentAddressCalled, "getCurrentAddress(), given no location, should not ask the presenter to format the result")
  }
  
  func testGetCurrentAddressGivenLocationButNoAddress()
  {
    // Given
    let mapPresentationLogicSpy = MapPresentationLogicSpy()
    sut.presenter = mapPresentationLogicSpy
    let mapGeocoderSpy = MapGeocoderSpy()
    mapGeocoderSpy.reverseGeocodeLocationSuccess = false
    sut.geocoder = mapGeocoderSpy
    sut.currentLocation = CLLocation(latitude: 37.92, longitude: -78.02)
    let request = Map.GetCurrentAddress.Request()
    
    // When
    sut.getCurrentAddress(request: request)
    
    // Then
    XCTAssertTrue(mapPresentationLogicSpy.presentGetCurrentAddressCalled, "getCurrentAddress(), given location but no address, should ask the presenter to format the result")
    XCTAssertFalse(mapPresentationLogicSpy.getCurrentAddressResponse.success, "getCurrentAddress(), given location but no address, should pass failure to the presenter")
  }
  
  func testGetCurrentAddressGivenLocationAndAddress()
  {
    // Given
    let mapPresentationLogicSpy = MapPresentationLogicSpy()
    sut.presenter = mapPresentationLogicSpy
    sut.currentLocation = CurAddressTestHelpers.location
    let mapGeocoderSpy = MapGeocoderSpy()
    mapGeocoderSpy.reverseGeocodeLocationSuccess = true
    mapGeocoderSpy.placemark = CurAddressTestHelpers.placemark
    sut.geocoder = mapGeocoderSpy
    let request = Map.GetCurrentAddress.Request()
    
    // When
    sut.getCurrentAddress(request: request)
    
    // Then
    XCTAssertTrue(mapPresentationLogicSpy.presentGetCurrentAddressCalled, "getCurrentAddress(), given both location and address, should ask the presenter to format the result")
    XCTAssertTrue(mapPresentationLogicSpy.getCurrentAddressResponse.success, "getCurrentAddress(), given both location and address, should pass success to the presenter")
  }
}
