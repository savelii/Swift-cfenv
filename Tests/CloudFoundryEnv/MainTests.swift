/**
* Copyright IBM Corporation 2016
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
**/

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

import XCTest
import Foundation
import SwiftyJSON

@testable import CloudFoundryEnv

/**
* Online tool for escaping JSON: http://www.freeformatter.com/javascript-escape.html
* Online tool for removing new lines: http://www.textfixer.com/tools/remove-line-breaks.php
* Online JSON editor: http://jsonviewer.stack.hu/
*/
class MainTests : XCTestCase {

  static var allTests : [(String, (MainTests) -> () throws -> Void)] {
    return [
      ("testGetApp", testGetApp),
      ("testGetServices", testGetServices),
      ("testGetService", testGetService),
      ("testGetAppEnv", testGetAppEnv),
      ("testGetServiceURL", testGetServiceURL),
      ("testGetServiceCreds", testGetServiceCreds)
    ]
  }

  let options = "{ \"vcap\": { \"application\": { \"limits\": { \"mem\": 128, \"disk\": 1024, \"fds\": 16384 }, \"application_id\": \"e582416a-9771-453f-8df1-7b467f6d78e4\", \"application_version\": \"e5e029d1-4a1a-4004-9f79-655d550183fb\", \"application_name\": \"swift-test\", \"application_uris\": [ \"swift-test.mybluemix.net\" ], \"version\": \"e5e029d1-4a1a-4004-9f79-655d550183fb\", \"name\": \"swift-test\", \"space_name\": \"dev\", \"space_id\": \"b15eb0bb-cbf3-43b6-bfbc-f76d495981e5\", \"uris\": [ \"swift-test.mybluemix.net\" ], \"users\": null, \"instance_id\": \"7d4f24cfba06462ba23d68aaf1d7354a\", \"instance_index\": 0, \"host\": \"0.0.0.0\", \"port\": 61263, \"started_at\": \"2016-03-04 02:43:07 +0000\", \"started_at_timestamp\": 1457059387, \"start\": \"2016-03-04 02:43:07 +0000\", \"state_timestamp\": 1457059387 }, \"services\": { \"cloudantNoSQLDB\": [ { \"name\": \"Cloudant NoSQL DB-kd\", \"label\": \"cloudantNoSQLDB\", \"tags\": [ \"data_management\", \"ibm_created\", \"ibm_dedicated_public\" ], \"plan\": \"Shared\", \"credentials\": { \"username\": \"09ed7c8a-fae8-48ea-affa-0b44b2224ec0-bluemix\", \"password\": \"06c19ae06b1915d8a6649df5901eca85e885182421ffa9ef89e14bbc1b76efd4\", \"host\": \"09ed7c8a-fae8-48ea-affa-0b44b2224ec0-bluemix.cloudant.com\", \"port\": 443, \"url\": \"https://09ed7c8a-fae8-48ea-affa-0b44b2224ec0-bluemix:06c19ae06b1915d8a6649df5901eca85e885182421ffa9ef89e14bbc1b76efd4@09ed7c8a-fae8-48ea-affa-0b44b2224ec0-bluemix.cloudant.com\" } } ] } } }"
  var jsonOptions: JSON = [:]

  override func setUp() {
    super.setUp()
    jsonOptions = JSONUtils.convertStringToJSON(text: options) as JSON!
  }

  override func tearDown() {
    super.tearDown()
    jsonOptions = [:]
  }

  func testGetApp() {
    do {
      let appEnv = try CloudFoundryEnv.getAppEnv(options: jsonOptions)
      if let app = appEnv.getApp() {
        XCTAssertNotNil(app)
        XCTAssertEqual(app.port, 61263, "Application port number should match.")
        XCTAssertEqual(app.id, "e582416a-9771-453f-8df1-7b467f6d78e4", "Application ID value should match.")
        XCTAssertEqual(app.version, "e5e029d1-4a1a-4004-9f79-655d550183fb", "Application version number should match.")
        XCTAssertEqual(app.name, "swift-test", "App name should match.")
        XCTAssertEqual(app.instanceId, "7d4f24cfba06462ba23d68aaf1d7354a", "Application instance ID value should match.")
        XCTAssertEqual(app.instanceIndex, 0, "Application instance index value should match.")
        XCTAssertEqual(app.spaceId, "b15eb0bb-cbf3-43b6-bfbc-f76d495981e5", "Application space ID value should match.")
        let limits = app.limits
        //print("limits: \(limits)")
        //XCTAssertNotNil(limits)
        XCTAssertEqual(limits.memory, 128, "Memory value should match.")
        XCTAssertEqual(limits.disk, 1024, "Disk value should match.")
        XCTAssertEqual(limits.fds, 16384, "FDS value should match.")
        let uris = app.uris
        //XCTAssertNotNil(uris)
        XCTAssertEqual(uris.count, 1, "There should be only 1 uri in the uris array.")
        XCTAssertEqual(uris[0], "swift-test.mybluemix.net", "URI value should match.")
        XCTAssertEqual(app.name, "swift-test", "Application name should match.")
        let startedAt: NSDate? = app.startedAt
        XCTAssertNotNil(startedAt)
        let dateUtils = DateUtils()
        let startedAtStr = dateUtils.convertDateToString(date: startedAt)
        XCTAssertEqual(startedAtStr, "2016-03-04 02:43:07 +0000", "Application startedAt date should match.")
        XCTAssertNotNil(app.startedAtTs, "Application startedAt ts should not be nil.")
        XCTAssertEqual(app.startedAtTs, 1457059387, "Application startedAt ts should match.")
      } else {
        XCTFail("Could not get App object!")
      }
    } catch let error as NSError {
      print("Error domain: \(error.domain)")
      print("Error code: \(error.code)")
      XCTFail("Could not get AppEnv object!")
    }
  }

  func testGetServices() {
    do {
      //print("json \(json)")
      let appEnv = try CloudFoundryEnv.getAppEnv(options: jsonOptions)
      //let servs = appEnv.services
      //print("servs \(servs)")
      let services = appEnv.getServices()
      //print("services \(services)")
      XCTAssertEqual(services.count, 1, "There should be only 1 service in the services dictionary.")
      let name = "Cloudant NoSQL DB-kd"
      if let service = services[name] {
        XCTAssertEqual(service.name, name, "Key in dictionary and service name should match.")
        verifyService(service: service)
      } else {
        XCTFail("A service object should have been found for '\(name)'.")
      }
    } catch let error as NSError {
      print("Error domain: \(error.domain)")
      print("Error code: \(error.code)")
      XCTFail("Could not get AppEnv object!")
    }
  }

  func testGetService() {
    do {
      let appEnv = try CloudFoundryEnv.getAppEnv(options: jsonOptions)
      let checkService = { (name: String) in
        if let service = appEnv.getService(spec: name) {
          self.verifyService(service: service)
        } else {
          XCTFail("A service object should have been found for '\(name)'.")
        }
      }

      // Case #1
      let name = "Cloudant NoSQL DB-kd"
      checkService(name)

      // Case #2
      let regex = "Cloudant NoSQL*"
      checkService(regex)
    } catch let error as NSError {
      print("Error domain: \(error.domain)")
      print("Error code: \(error.code)")
      XCTFail("Could not get AppEnv object!")
    }
  }

  func testGetAppEnv() {
    do {
      // Case #1 - Running locally, no options
      var appEnv = try CloudFoundryEnv.getAppEnv()
      XCTAssertEqual(appEnv.isLocal, true, "AppEnv's isLocal should be true.")
      XCTAssertEqual(appEnv.port, 8090, "AppEnv's port should be 8090.")
      XCTAssertNil(appEnv.name, "AppEnv's name should be nil.")
      XCTAssertEqual(appEnv.bind, "0.0.0.0", "AppEnv's bind should be '0.0.0.0'.")
      var urls: [String] = appEnv.urls
      XCTAssertEqual(urls.count, 1, "AppEnv's urls array should contain only 1 element.")
      XCTAssertEqual(urls[0], "http://localhost:8090", "AppEnv's urls[0] should be 'http://localhost:8090'.")
      XCTAssertEqual(appEnv.services.count, 0, "AppEnv's services array should contain 0 elements.")

      // Case #2 - Running locally with options
      appEnv = try CloudFoundryEnv.getAppEnv(options: jsonOptions)
      XCTAssertEqual(appEnv.isLocal, true, "AppEnv's isLocal should be true.")
      XCTAssertEqual(appEnv.port, 8090, "AppEnv's port should be 8090.")
      XCTAssertEqual(appEnv.name, "swift-test")
      XCTAssertEqual(appEnv.bind, "0.0.0.0", "AppEnv's bind should be 0.0.0.0.")
      urls = appEnv.urls
      XCTAssertEqual(urls.count, 1, "AppEnv's urls array should contain only 1 element.")
      XCTAssertEqual(urls[0], "http://localhost:8090", "AppEnv's urls[0] should be 'http://localhost:8090'.")
      XCTAssertEqual(appEnv.services.count, 1, "AppEnv's services array should contain 1 element.")
    } catch let error as NSError {
      print("Error domain: \(error.domain)")
      print("Error code: \(error.code)")
      XCTFail("Could not get AppEnv object!")
    }
  }

  func testGetServiceURL() {
    do {
      // Service name
      let name = "Cloudant NoSQL DB-kd"

      // Case #1 - Running locally, no options
      let appEnv = try CloudFoundryEnv.getAppEnv()
      let serviceURL = appEnv.getServiceURL(spec: name, replacements: nil)
      XCTAssertNil(serviceURL, "The serviceURL should be nil.")

      // Case #2 - Running locally with options and no replacements
      try verifyServiceURLWithOptions(name: name, replacements: nil, expectedServiceURL: "https://09ed7c8a-fae8-48ea-affa-0b44b2224ec0-bluemix:06c19ae06b1915d8a6649df5901eca85e885182421ffa9ef89e14bbc1b76efd4@09ed7c8a-fae8-48ea-affa-0b44b2224ec0-bluemix.cloudant.com")

      // Case #3 - Running locally with options and replacements
      var replacements = "{ \"user\": \"username01\", \"password\": \"passw0rd\", \"port\": 9080, \"host\": \"bluemix.ibm.com\", \"scheme\": \"https\", \"queryItems\": [ { \"name\": \"name2\", \"value\": \"value2\" }, { \"name\": \"name3\", \"value\": \"value3\" } ] }"
      try verifyServiceURLWithOptions(name: name, replacements: replacements, expectedServiceURL: "https://username01:passw0rd@bluemix.ibm.com:9080?name2=value2&name3=value3")

      // Case #4
      replacements = "{ \"user\": \"username01\", \"password\": \"passw0rd\", \"port\": 9080, \"host\": \"bluemix.ibm.com\", \"scheme\": \"https\", \"query\": \"name0=value0&name1=value1\" }"
      try verifyServiceURLWithOptions(name: name, replacements: replacements, expectedServiceURL: "https://username01:passw0rd@bluemix.ibm.com:9080?name0=value0&name1=value1")

      // Case #5
      replacements = "{ \"user\": \"username01\", \"password\": \"passw0rd\", \"port\": 9080, \"host\": \"bluemix.ibm.com\", \"scheme\": \"https\", \"query\": \"name0=value0&name1=value1\", \"queryItems\": [ { \"name\": \"name2\", \"value\": \"value2\" }, { \"name\": \"name3\", \"value\": \"value3\" } ] }"
      try verifyServiceURLWithOptions(name: name, replacements: replacements, expectedServiceURL: "https://username01:passw0rd@bluemix.ibm.com:9080?name2=value2&name3=value3")
    } catch let error as NSError {
      print("Error domain: \(error.domain)")
      print("Error code: \(error.code)")
      XCTFail("Could not get AppEnv object!")
    }
  }

  func testGetServiceCreds() {
    do {
      let appEnv = try CloudFoundryEnv.getAppEnv(options: jsonOptions)
      let checkServiceCreds = { (name: String) in
        if let serviceCreds = appEnv.getServiceCreds(spec: name) {
          self.verifyServiceCreds(serviceCreds: serviceCreds)
        } else {
          XCTFail("Service credentials should have been found for '\(name)'.")
        }
      }

      // Case #1
      let name = "Cloudant NoSQL DB-kd"
      checkServiceCreds(name)

      // Case #2
      let regex = "Cloudant NoSQL*"
      checkServiceCreds(regex)

      // Case #3
      let badName = "Unknown Service"
      if appEnv.getServiceCreds(spec: badName) != nil {
        XCTFail("Service credentials should not have been found for '\(badName)'.")
      }
    } catch let error as NSError {
      print("Error domain: \(error.domain)")
      print("Error code: \(error.code)")
      XCTFail("Could not get AppEnv object!")
    }
  }

  private func verifyServiceURLWithOptions(name: String, replacements: String?, expectedServiceURL: String) throws {
    let appEnv = try CloudFoundryEnv.getAppEnv(options: jsonOptions)
    let substitutions = JSONUtils.convertStringToJSON(text: replacements)
    if let serviceURL = appEnv.getServiceURL(spec: name, replacements: substitutions) {
        XCTAssertEqual(serviceURL, expectedServiceURL, "ServiceURL should match '\(expectedServiceURL)'.")
    } else {
      XCTFail("A serviceURL should have been returned!")
    }
  }

  private func verifyService(service: Service) {
    XCTAssertEqual(service.name, "Cloudant NoSQL DB-kd", "Service name should match.")
    XCTAssertEqual(service.label, "cloudantNoSQLDB", "Service label should match.")
    XCTAssertEqual(service.plan, "Shared", "Service plan should match.")
    let tags = service.tags
    XCTAssertEqual(tags.count, 3, "There should be 3 tags in the tags array.")
    XCTAssertEqual(tags[0], "data_management", "Service tag #0 should match.")
    XCTAssertEqual(tags[1], "ibm_created", "Serivce tag #1 should match.")
    XCTAssertEqual(tags[2], "ibm_dedicated_public", "Serivce tag #2 should match.")
    let credentials: JSON? = service.credentials
    XCTAssertNotNil(credentials)
    verifyServiceCreds(serviceCreds: credentials!)
  }

  private func verifyServiceCreds(serviceCreds: JSON) {
    XCTAssertEqual(serviceCreds.count, 5, "There should be 5 elements in the credentials object.")
    for (key, value) in serviceCreds {
      switch key {
        case "password":
          XCTAssertEqual(value, "06c19ae06b1915d8a6649df5901eca85e885182421ffa9ef89e14bbc1b76efd4", "Password in credentials object should match.")
        case "url":
          XCTAssertEqual(value, "https://09ed7c8a-fae8-48ea-affa-0b44b2224ec0-bluemix:06c19ae06b1915d8a6649df5901eca85e885182421ffa9ef89e14bbc1b76efd4@09ed7c8a-fae8-48ea-affa-0b44b2224ec0-bluemix.cloudant.com", "URL in credentials object should match.")
        case "port" :
          XCTAssertEqual(value, 443, "Port in credentials object should match.")
        case "host":
          XCTAssertEqual(value, "09ed7c8a-fae8-48ea-affa-0b44b2224ec0-bluemix.cloudant.com", "Host in credentials object should match.")
        case "username":
          XCTAssertEqual(value, "09ed7c8a-fae8-48ea-affa-0b44b2224ec0-bluemix", "Username in credentials object should match.")
        default:
          XCTFail("Unexpected key in credentials: \(key)")
      }
    }
  }

 }
