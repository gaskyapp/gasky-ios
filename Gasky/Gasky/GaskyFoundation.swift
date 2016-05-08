//
//  GaskyAPI.swift
//  Gasky
//
//  Created by Eric Lorentz on 1/22/16.
//  Copyright © 2016 Gasky, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreData
import Alamofire

// API endpoint url definitions
struct APIEndpoints {
    static let base = "https://preview.ericlorentz.com/gasky/api/public"
    // Service areas endpoint
    static let serviceAreas = base + "/info/serviceAreas"
    // Service pricing endpoint
    static let pricing = base + "/info/pricing"
    // User login endpoint (email/password)
    static let login = base + "/account/login"
    // User logout endpoint
    static let logout = base + "/account/logout"
    // User creation endpoint (email/password)
    static let create = base + "/account/create"
    // User password reset endpoint (email)
    static let reset = base + "/account/reset"
    // User info update (name/phone)
    static let infoUpdate = base + "/account/updateInfo"
    // User info photo update (name/phone)
    static let infoPhotoUpdate = base + "/account/updateInfoPhoto"
    // User info retrieval
    static let currentInfo = base + "/account/getInfo"
    // User vehicle update (plate/make and model/color)
    static let vehicleUpdate = base + "/account/updateVehicle"
    // User vehicle photo update
    static let vehiclePhotoUpdate = base + "/account/updateVehiclePhoto"
    // User vehicle retrieval
    static let currentVehicle = base + "/account/getVehicle"
    // Get client token for payment methods
    static let clientToken = base + "/payments/token"
    // User payment method update
    static let paymentMethodUpdate = base + "/account/updatePaymentMethod"
    // User payment method retrieval
    static let currentPaymentMethod = base + "/account/getPaymentMethod"
    // User payment method deletion
    static let deletePaymentMethod = base + "/account/deletePaymentMethod"
    // User default payment method change
    static let defaultPaymentMethod = base + "/account/defaultPaymentMethod"
    // Submit order
    static let submitOrder = base + "/order/submit"
    // Order status
    static let orderStatus = base + "/order/status"
    // Order cancellation
    static let orderCancel = base + "/order/cancel"
    // Order summary
    static let orderSummary = base + "/order/summary"
    // Feedback
    static let orderFeedback = base + "/order/feedback"
    // Get promo
    static let getPromo = base + "/account/getPromo"
    // Set promo
    static let setPromo = base + "/account/setPromo"
    // Check promo
    static let checkPromo = base + "/account/checkPromo"
    // Clear promo
    static let clearPromo = base + "/account/clearPromo"
}

// API error message definitions
struct APIMessages {
    static let serviceUnavailable = "Service is currently unavailable"
}

// User data structure
class User: NSManagedObject {
    @NSManaged var authKey: String?
}

// Data validation functions
class Validation {
    // Validate email address (true if valid)
    class func validateEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluateWithObject(email)
        return result
    }
    
    // Get number of words in a string
    class func wordCount(s: String) -> Int {
        let words = s.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        return words.count
    }
}

// Data interaction class for fetching, storing and returning data as well as the home for app-wide utility functions
class GaskyFoundation {
    // Define as singleton
    static let sharedInstance:GaskyFoundation = GaskyFoundation()





    /***********************
    *     API AND DATA     *
    ***********************/

    // Boolean flag for application data state. True is application has no stored data on device.
    private var freshData = true
    // Storage for fetched data from device storage. Deivce stores data as an array, but app only uses the first entry.
    private var dataRelation: Array<AnyObject> = []
    private var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    private var managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    // Current authKey for the application
    private var authKey: String? = nil
    // Logged in state
    private var loggedIn: Bool = false
    // Current data states for the application
    private var serviceAreas: [[[Double]]] = []
    private var pricing: [String:Float?] = [
        "delivery": nil,
        "cancellation": nil,
        "regular": nil,
        "diesel": nil
    ]
    private var hasPersonalInfo: Bool = false
    private var personalInfoOverride: Int = 0
    private var personalInfo: [String:String?] = [
        "name": nil,
        "email": nil,
        "phone": nil,
        "photo": nil
    ]
    private var hasPromoCode: Bool = false
    private var promoCode: [String:AnyObject?] = [
        "code": nil,
        "percentOff": nil,
        "dollarAmountOff": nil
    ]
    private var vehicleInfoOverride: Int = 0
    private var vehicleInfoStep: Int = 2
    private var hasVehicleInfo: Bool = false
    private var vehicleInfo: [String:String?] = [
        "license": nil,
        "make": nil,
        "model": nil,
        "year": nil,
        "color": nil,
        "photo": nil
    ]
    private var paymentMethodOverride: Int = 0
    private var paymentMethodStep: Int = 3
    private var hasPaymentMethod: Bool = false
    private var paymentMethodInfo: NSArray = []
    private var makeRequestCoords: CLLocationCoordinate2D? = nil
    private var makeRequestLocation: String? = nil
    private var makeRequestDetails: String = ""
    private var makeRequestTime: Int? = nil
    private var makeRequestDate: Int? = nil
    private var orderStatus: [String:String?] = [
        "id": nil,
        "scheduled": nil,
        "deliveryDay": nil,
        "latitude": nil,
        "longitude": nil,
        "received": nil,
        "delivering": nil,
        "delivered": nil,
        "status": nil
    ]
    private var orderSummary: [String:String?] = [
        "id": nil,
        "completed": nil,
        "total": nil,
        "pricePerGallon": nil,
        "gallons": nil,
        "gasTotal": nil,
        "deliveryFee": nil,
        "discount": nil,
        "meterPhoto": nil
    ]
    // Headers used for data only (no media) calls to the API
    private var headers = [
        "Accept": "application/json",
        "Content-Type": "application/json"
    ]
    
    // Set current authKey in application state
    func setAuthKey(key: String) {
        self.authKey = key
        self.loggedIn = true
    }
    
    func invalidateAuthKey() {
        self.authKey = nil
        self.loggedIn = false
    }
    
    // Return the current authKey
    func getAuthKey() -> String? {
        return self.authKey
    }
    
    // Get current log in state
    func isLoggedIn() -> Bool {
        return self.loggedIn
    }
    
    // Set current request form state
    func setRequestFormState(coords: CLLocationCoordinate2D?, location: String?, details: String, time: Int?, date: Int?) {
        self.makeRequestCoords = coords
        self.makeRequestLocation = location
        self.makeRequestDetails = details
        self.makeRequestTime = time
        self.makeRequestDate = date
    }
    
    func resetRequestFormState() {
        self.makeRequestCoords = nil
        self.makeRequestLocation = nil
        self.makeRequestDetails = ""
        self.makeRequestTime = nil
        self.makeRequestDate = nil
    }
    
    // Get request form state components
    func getRequestFormStateCoords() -> CLLocationCoordinate2D? {
        return self.makeRequestCoords
    }
    
    func getRequestFormStateLocation() -> String? {
        return self.makeRequestLocation
    }
    
    func getRequestFormStateDetails() -> String {
        return self.makeRequestDetails
    }
    
    func getRequestFormStateTime() -> Int? {
        return self.makeRequestTime
    }
    
    func getRequestFormStateDate() -> Int? {
        return self.makeRequestDate
    }
    
    // Get service areas and digest
    func getServiceAreas() {
        Alamofire.request(.GET, APIEndpoints.serviceAreas, encoding: .JSON, headers: self.authorizedHeaders()).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                let response = JSON as! NSDictionary
                let status = response.objectForKey("status_code") as? NSInteger
                
                if (status == 401 && GaskyFoundation.sharedInstance.isLoggedIn() == true) {
                    self.authInvalid()
                }
                
                if (status == 200) {
                    if response.objectForKey("areas") is NSArray {
                        let areas = response.objectForKey("areas") as! NSArray
                        var convertedAreas: [[[Double]]] = []
                        
                        for area in areas {
                            let pointArray = area["bounds"].componentsSeparatedByString(",")
                            var thisArea: [[Double]] = []
                            
                            for var index = 0; index < pointArray.count / 2; ++index {
                                thisArea.append([Double(pointArray[index*2])!, Double(pointArray[index*2 + 1])!])
                            }
                            
                            convertedAreas.append(thisArea)
                        }
                        GaskyFoundation.sharedInstance.setServiceAreas(convertedAreas)
                    }
                }
                break
            case .Failure(_):
                // Silence for now
                break
            }
        }
    }
    
    // Store service areas for session
    func setServiceAreas(areas: [[[Double]]]) {
        self.serviceAreas = areas
        NSNotificationCenter.defaultCenter().postNotificationName("serviceAreasReceived", object: nil)
    }
    
    func returnServiceAreas() -> [[[Double]]] {
        return self.serviceAreas
    }
    
    // Get pricing and digest
    func getPricing() {
        Alamofire.request(.GET, APIEndpoints.pricing, encoding: .JSON, headers: self.authorizedHeaders()).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                let response = JSON as! NSDictionary
                let status = response.objectForKey("status_code") as? NSInteger
                
                if (status == 401 && GaskyFoundation.sharedInstance.isLoggedIn() == true) {
                    self.authInvalid()
                }
                
                if (status == 200) {
                    if response.objectForKey("pricing") is NSDictionary {
                        let pricing = response.objectForKey("pricing") as! NSDictionary
                        
                        var delivery: Float? = nil
                        if pricing.objectForKey("delivery") is String {
                            delivery = pricing.objectForKey("delivery")!.floatValue
                        }
                        
                        var cancellation: Float? = nil
                        if pricing.objectForKey("cancellation") is String {
                            cancellation = pricing.objectForKey("cancellation")!.floatValue
                        }
                        
                        var regular: Float? = nil
                        if pricing.objectForKey("regular") is String {
                            regular = pricing.objectForKey("regular")!.floatValue
                        }
                        
                        var diesel: Float? = nil
                        if pricing.objectForKey("diesel") is String {
                            diesel = pricing.objectForKey("diesel")!.floatValue
                        }
                        
                        GaskyFoundation.sharedInstance.setPricing(delivery, cancellation: cancellation, regular: regular, diesel: diesel)
                    }
                }
                break
            case .Failure(_):
                // Silence for now
                break
            }
        }
    }
    
    // Store service areas for session
    func setPricing(delivery: Float?, cancellation: Float?, regular: Float?, diesel: Float?) {
        self.pricing["delivery"] = delivery
        self.pricing["cancellation"] = cancellation
        self.pricing["regular"] = regular
        self.pricing["diesel"] = diesel
        NSNotificationCenter.defaultCenter().postNotificationName("pricingReceived", object: nil)
    }
    
    func returnPricing() -> [String:Float?] {
        return self.pricing
    }
    
    // Set state of personal info
    func setPersonalInfo(name: String?, email: String?, phone: String?, photo: String?) {
        if (name != nil) {
            self.personalInfo["name"] = name
        }
        
        if (email != nil) {
            self.personalInfo["email"] = email
        }
        
        if (phone != nil) {
            self.personalInfo["phone"] = phone
        }
        
        if (photo != nil) {
            self.personalInfo["photo"] = photo
        }
        
        if (self.personalInfo["name"]! != nil && self.personalInfo["email"]! != nil && self.personalInfo["phone"]! != nil) {
            self.hasPersonalInfo = true
            NSNotificationCenter.defaultCenter().postNotificationName("userDataReceived", object: nil)
        }
    }
    
    // Reset personal info
    func resetPersonalInfo() {
        self.hasPersonalInfo = false
        self.personalInfoOverride = 0
        self.personalInfo = [
            "name": nil,
            "email": nil,
            "phone": nil,
            "photo": nil
        ]
    }
    
    // Get current personal info
    func getPersonalInfo() -> [String: String?] {
        return self.personalInfo
    }
    
    // Get state of personal info
    func doesHavePersonalInfo() -> Bool {
        return self.hasPersonalInfo
    }
    
    func setPersonalInfoViewOverride(type: Int) {
        self.personalInfoOverride = type
    }
    
    func getPersonalInfoViewOverride() -> Int {
        return self.personalInfoOverride
    }
    
    // Get current perosonal information from server
    func getCurrentPersonalInfo() {
        let parameters = [String: AnyObject]()
        
        Alamofire.request(.POST, APIEndpoints.currentInfo, parameters: parameters, encoding: .JSON, headers: self.authorizedHeaders()).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                let response = JSON as! NSDictionary
                let status = response.objectForKey("status_code") as? NSInteger
                
                if (status == 401 && GaskyFoundation.sharedInstance.isLoggedIn() == true) {
                    self.authInvalid()
                }
                
                if (status == 200) {
                    var name: String? = nil
                    if response.objectForKey("name") is String {
                        name = response.objectForKey("name") as? String
                    }
                    
                    var phone: String? = nil
                    if response.objectForKey("phone") is String {
                        phone = response.objectForKey("phone") as? String
                    }
                    
                    var email: String? = nil
                    if response.objectForKey("email") is String {
                        email = response.objectForKey("email") as? String
                    }
                    
                    var photo: String? = nil
                    if response.objectForKey("photo") is String {
                        photo = response.objectForKey("photo") as? String
                    }
                    
                    GaskyFoundation.sharedInstance.setPersonalInfo(name, email: email, phone: phone, photo: photo)
                }
                break
            case .Failure(_):
                // Silence for now
                break
            }
        }
    }
    
    // Set state of promo info
    func setPromoInfo(code: String?, percentOff: String?, dollarAmountOff: String?) {
        if (code != nil) {
            self.promoCode["code"] = code
        }
        
        if (percentOff != nil && percentOff != "0") {
            self.promoCode["percentOff"] = percentOff
        }
        
        if (dollarAmountOff != nil && dollarAmountOff != "0") {
            self.promoCode["dollarAmountOff"] = dollarAmountOff
        }
        
        if (self.promoCode["code"]! != nil) {
            self.hasPromoCode = true
            NSNotificationCenter.defaultCenter().postNotificationName("userDataReceived", object: nil)
        }
    }
    
    // Reset promo info
    func resetPromoInfo() {
        self.hasPromoCode = false
        self.promoCode = [
            "code": nil,
            "percentOff": nil,
            "dollarAmountOff": nil
        ]
    }
    
    // Get current promo info
    func getPromoInfo() -> [String: AnyObject?] {
        return self.promoCode
    }
    
    // Get state of promo info
    func doesHavePromoInfo() -> Bool {
        return self.hasPromoCode
    }
    
    // Get current promo information from server
    func getCurrentPromoInfo() {
        let parameters = [String: AnyObject]()
        
        Alamofire.request(.POST, APIEndpoints.getPromo, parameters: parameters, encoding: .JSON, headers: self.authorizedHeaders()).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                let response = JSON as! NSDictionary
                let status = response.objectForKey("status_code") as? NSInteger
                
                if (status == 401 && GaskyFoundation.sharedInstance.isLoggedIn() == true) {
                    self.authInvalid()
                }

                if (status == 200) {
                    var code: String? = nil
                    if response.objectForKey("promo_code") is String {
                        code = response.objectForKey("promo_code") as? String
                    }
                    
                    var percentOff: String? = nil
                    if response.objectForKey("percent_off") is String {
                        percentOff = response.objectForKey("percent_off") as? String
                    }
                    
                    var dollarAmountOff: String? = nil
                    if response.objectForKey("dollar_amount_off") is String {
                        dollarAmountOff = response.objectForKey("dollar_amount_off") as? String
                    }
                    
                    GaskyFoundation.sharedInstance.setPromoInfo(code, percentOff: percentOff, dollarAmountOff: dollarAmountOff)
                }
                break
            case .Failure(_):
                // Silence for now
                break
            }
        }
    }
    
    // Check if current promo is still valid
    func checkPromoValidity(completion: (valid: Bool) -> Void) {
        let parameters = [String: AnyObject]()
        
        Alamofire.request(.POST, APIEndpoints.checkPromo, parameters: parameters, encoding: .JSON, headers: self.authorizedHeaders()).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                let response = JSON as! NSDictionary
                let status = response.objectForKey("status_code") as? NSInteger
                
                if (status == 401 && GaskyFoundation.sharedInstance.isLoggedIn() == true) {
                    self.authInvalid()
                }
                
                if (status == 200) {
                    completion(valid: true)
                }
                
                if (status == 400) {
                    completion(valid: false)
                    self.resetPromoInfo()
                }
            case .Failure(_):
                completion(valid: false)
            }
        }
    }
    
    // Remove current promo
    func removePromo() {
        let parameters = [String: AnyObject]()
        
        Alamofire.request(.POST, APIEndpoints.clearPromo, parameters: parameters, encoding: .JSON, headers: self.authorizedHeaders()).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                let response = JSON as! NSDictionary
                let status = response.objectForKey("status_code") as? NSInteger
                
                if (status == 401 && GaskyFoundation.sharedInstance.isLoggedIn() == true) {
                    self.authInvalid()
                }
                
                self.resetPromoInfo()
            case .Failure(_):
                // Silence for now
                break
            }
        }
    }
    
    func setVehicleViewOverride(type: Int) {
        self.vehicleInfoOverride = type
    }
    
    func getVehicleViewOverride() -> Int {
        return self.vehicleInfoOverride
    }
    
    func setVehicleInfoStep(step: Int) {
        self.vehicleInfoStep = step
    }
    
    func getVehicleInfoStep() -> Int {
        return self.vehicleInfoStep
    }
    
    // Set current vehicle information
    func setVehicleInfo(license: String?, make: String?, model: String?, year: String?, color: String?, photo: String?) {
        if (license != nil) {
            self.vehicleInfo["license"] = license
        }
        
        if (make != nil) {
            self.vehicleInfo["make"] = make
        }
        
        if (model != nil) {
            self.vehicleInfo["model"] = model
        }
        
        if (year != nil) {
            self.vehicleInfo["year"] = year
        }
        
        if (color != nil) {
            self.vehicleInfo["color"] = color
        }
        
        if (photo != nil) {
            self.vehicleInfo["photo"] = photo
        }
        
        if (self.vehicleInfo["license"]! != nil && self.vehicleInfo["make"]! != nil && self.vehicleInfo["model"]! != nil && self.vehicleInfo["year"]! != nil && self.vehicleInfo["color"]! != nil && self.vehicleInfo["photo"]! != nil) {
            self.hasVehicleInfo = true
            NSNotificationCenter.defaultCenter().postNotificationName("userDataReceived", object: nil)
        }
    }
    
    func resetVehicleInfo() {
        self.vehicleInfoOverride = 0
        self.vehicleInfoStep = 2
        self.hasVehicleInfo = false
        self.vehicleInfo = [
            "license": nil,
            "make": nil,
            "model": nil,
            "year": nil,
            "color": nil,
            "photo": nil
        ]
    }
    
    // Get current personal info
    func getVehicleInfo() -> [String: String?] {
        return self.vehicleInfo
    }
    
    // Get state of vehicle info
    func doesHaveVehicleInfo() -> Bool {
        return self.hasVehicleInfo
    }
    
    // Get current vehicle information from server
    func getCurrentVehicleInfo() {
        let parameters = [String: AnyObject]()
        
        Alamofire.request(.POST, APIEndpoints.currentVehicle, parameters: parameters, encoding: .JSON, headers: self.authorizedHeaders()).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                
                let response = JSON as! NSDictionary
                let status = response.objectForKey("status_code") as? NSInteger
                
                if (status == 401 && GaskyFoundation.sharedInstance.isLoggedIn() == true) {
                    self.authInvalid()
                }
                
                if (status == 200) {
                    var license: String? = nil
                    if response.objectForKey("plates") is String {
                        license = response.objectForKey("plates") as? String
                    }
                    
                    var make: String? = nil
                    if response.objectForKey("make") is String {
                        make = response.objectForKey("make") as? String
                    }
                    
                    var model: String? = nil
                    if response.objectForKey("model") is String {
                        model = response.objectForKey("model") as? String
                    }
                    
                    var year: String? = nil
                    if response.objectForKey("year") is String {
                        year = response.objectForKey("year") as? String
                    }
                    
                    var color: String? = nil
                    if response.objectForKey("color") is String {
                        color = response.objectForKey("color") as? String
                    }
                    
                    var photo: String? = nil
                    if response.objectForKey("photo") is String {
                        photo = response.objectForKey("photo") as? String
                    }
                    
                    GaskyFoundation.sharedInstance.setVehicleInfo(license, make: make, model: model, year: year, color: color, photo: photo)
                }
                break
            case .Failure(_):
                // Silence for now
                break
            }
        }
    }
    
    func setPaymentViewOverride(type: Int) {
        self.paymentMethodOverride = type
    }
    
    func getPaymentViewOverride() -> Int {
        return self.paymentMethodOverride
    }
    
    func setPaymentMethodStep(step: Int) {
        self.paymentMethodStep = step
    }
    
    func getPaymentMethodStep() -> Int {
        return self.paymentMethodStep
    }
    
    // Set current payment method information
    func setPaymentMethodInfo(data: NSArray) {
        self.paymentMethodInfo = data
        
        if (self.paymentMethodInfo.count > 0) {
            self.hasPaymentMethod = true
        } else {
            self.hasPaymentMethod = false
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("userDataReceived", object: nil)
    }
    
    func resetPaymentMethodInfo() {
        self.paymentMethodOverride = 0
        self.paymentMethodStep = 3
        self.hasPaymentMethod = false
        self.paymentMethodInfo = []
    }
    
    // Get current payment method info
    func getPaymentMethodInfo() -> NSArray {
        return self.paymentMethodInfo
    }
    
    // Get state of payment method info
    func doesHavePaymentMethodInfo() -> Bool {
        return self.hasPaymentMethod
    }
    
    // Get current payment method information from server
    func getCurrentPaymentMethodInfo() {
        let parameters = [String: AnyObject]()
        
        Alamofire.request(.POST, APIEndpoints.currentPaymentMethod, parameters: parameters, encoding: .JSON, headers: self.authorizedHeaders()).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                let response = JSON as! NSDictionary
                let status = response.objectForKey("status_code") as? NSInteger
                
                if (status == 401 && GaskyFoundation.sharedInstance.isLoggedIn() == true) {
                    self.authInvalid()
                }
                
                if (status == 200) {
                    let data = response.objectForKey("data") as! NSArray
                    GaskyFoundation.sharedInstance.setPaymentMethodInfo(data)
                }
                break
            case .Failure(_):
                // Silence for now
                break
            }
        }
    }
    
    // Store authKey data to application storage
    func storeData() {
        // Store new data is no application data exists
        if (self.freshData == true) {
            let entityDescription = NSEntityDescription.entityForName("User", inManagedObjectContext: managedObjectContext)
            let user = User(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
            user.authKey = self.authKey!
            try! managedObjectContext.save()
        }
        // Update existing data if application data exists
        else {
            let managedObject = self.dataRelation[0]
            managedObject.setValue(self.authKey, forKey: "authKey")
            self.appDelegate.saveContext()
        }
    }
    
    // Retrieve authKey data from application storage
    func retrieveData() {
        let fetchRequest = NSFetchRequest(entityName: "User")
        do {
            let results = try managedObjectContext.executeFetchRequest(fetchRequest)
            self.dataRelation = results
            
            // If data was fetched, assign it to the current application state
            if (results.count > 0) {
                self.freshData = false
                let userData = results[0] as? NSManagedObject
                
                var retrievedAuthKey: String? = nil
                if userData!.valueForKey("authKey") is String {
                    retrievedAuthKey = userData!.valueForKey("authKey") as? String
                    GaskyFoundation.sharedInstance.setAuthKey(retrievedAuthKey!)
                }
            } else {
                // no logged in user data available
            }
        } catch let error as NSError {
            //print(error)
        }
    }
    
    func authorizedHeaders() -> [String: String] {
        var authHeaders = self.headers
        authHeaders["Authorization"] = self.authKey
        return authHeaders
    }
    
    // Account login, connect to API to verify credentials and retrieve authKey
    func login(email: String, password: String, completion: (result: Bool) -> Void) {
        let parameters = [
            "email": email,
            "password": password
        ]
        
        Alamofire.request(.POST, APIEndpoints.login, parameters: parameters, encoding: .JSON, headers: self.headers).responseJSON { response in
            switch response.result {
                case .Success(let JSON):
                    let response = JSON as! NSDictionary
                    let retrievedAuthKey = response.objectForKey("auth") as? String
                    
                    if (retrievedAuthKey != nil) {
                        GaskyFoundation.sharedInstance.setAuthKey(retrievedAuthKey!)
                        GaskyFoundation.sharedInstance.storeData()
                        GaskyFoundation.sharedInstance.setPersonalInfo(nil, email: email, phone: nil, photo: nil)
                        GaskyFoundation.sharedInstance.getOpenOrder()
                        GaskyFoundation.sharedInstance.getServiceAreas()
                        GaskyFoundation.sharedInstance.getPricing()
                        GaskyFoundation.sharedInstance.getCurrentPersonalInfo()
                        GaskyFoundation.sharedInstance.getCurrentVehicleInfo()
                        GaskyFoundation.sharedInstance.getCurrentPaymentMethodInfo()
                        GaskyFoundation.sharedInstance.getCurrentPromoInfo()
                        completion(result: true)
                    } else {
                        completion(result: false)
                    }
                case .Failure(_):
                    completion(result: false)
            }
        }
    }
    
    // Log user out and clear data
    func logout() {
        Alamofire.request(.GET, APIEndpoints.logout, encoding: .JSON, headers: self.authorizedHeaders()).responseJSON { response in
            GaskyFoundation.sharedInstance.invalidateAuthKey()
            GaskyFoundation.sharedInstance.storeData()
            
            // Clear all local variable data
            self.resetPersonalInfo()
            self.resetVehicleInfo()
            self.resetPaymentMethodInfo()
            self.resetRequestFormState()
            self.resetOrderStatus()
            self.resetOrderSummary()
            self.resetPromoInfo()

            NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedIntro"])
        }
    }
    
    // Account create, connect to API to create an account and retrieve authKey
    func create(email: String, password: String, completion: (result: NSInteger) -> Void) {
        let parameters = [
            "email": email,
            "password": password
        ]
        
        Alamofire.request(.POST, APIEndpoints.create, parameters: parameters, encoding: .JSON, headers: self.headers).responseJSON { response in
            switch response.result {
                case .Success(let JSON):
                    let response = JSON as! NSDictionary
                    let status = response.objectForKey("status_code") as? NSInteger
                    
                    if (status == 200) {
                        let retrievedAuthKey = response.objectForKey("auth") as? String
                        GaskyFoundation.sharedInstance.setAuthKey(retrievedAuthKey!)
                        GaskyFoundation.sharedInstance.storeData()
                        GaskyFoundation.sharedInstance.setPersonalInfo(nil, email: email, phone: nil, photo: nil)
                        GaskyFoundation.sharedInstance.getOpenOrder()
                        GaskyFoundation.sharedInstance.getServiceAreas()
                        GaskyFoundation.sharedInstance.getPricing()
                        GaskyFoundation.sharedInstance.getCurrentPersonalInfo()
                        GaskyFoundation.sharedInstance.getCurrentVehicleInfo()
                        GaskyFoundation.sharedInstance.getCurrentPaymentMethodInfo()
                        GaskyFoundation.sharedInstance.getCurrentPromoInfo()
                    }
                    
                    // 200: Account created and session set, move to next step
                    // 400: Invalid email address or password
                    // 409: Account already exists
                    completion(result: status!)
                case .Failure(_):
                    // 0: Unreachable (Server outage most likely)
                    completion(result: 0)
            }
        }
    }
    
    func forgotPassword(email: String, completion: (result: Bool) -> Void) {
        let parameters = [
            "email": email
        ]
        
        Alamofire.request(.POST, APIEndpoints.reset, parameters: parameters, encoding: .JSON, headers: self.headers).responseJSON { response in
            switch response.result {
                case .Success(_):
                    completion(result: true)
                case .Failure(_):
                    completion(result: false)
            }
        }
    }
    
    func updateInfo(name: String, mobile: String, email: String?, completion: (result: Int) -> Void) {
        var parameters = [
            "name": name,
            "phone": mobile
        ]
        
        if (email != nil) {
            parameters["email"] = email
        }
        
        Alamofire.request(.POST, APIEndpoints.infoUpdate, parameters: parameters, encoding: .JSON, headers: self.authorizedHeaders()).responseJSON { response in
            switch response.result {
                case .Success(let JSON):
                    let response = JSON as! NSDictionary
                    let status = response.objectForKey("status_code") as? NSInteger
                    
                    if (status == 401 && GaskyFoundation.sharedInstance.isLoggedIn() == true) {
                        self.authInvalid()
                    }
                                        
                    if (status == 200) {
                        GaskyFoundation.sharedInstance.setPersonalInfo(name, email: email, phone: mobile, photo: nil)
                    }
                    
                    if (status == nil) {
                        // Likely encountered a server error within the API
                        completion(result: 0)
                    } else {
                        // 200: Account data updated
                        // 409: Account email change conflicts with existing email
                        completion(result: status!)
                    }
                case .Failure(_):
                    // 0: Unreachable (Server outage most likely)
                    completion(result: 0)
            }
        }
    }
    
    func updateInfoPhoto(photo: UIImage, completion: (result: Int) -> Void) {
        let resizedImage = GaskyFoundation.resizeImage(photo, toWidth: 600)
        let photoData = UIImageJPEGRepresentation(resizedImage, 0.75)
        let base64encoded = photoData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        
        let parameters = [
            "photo": base64encoded
        ]
        
        Alamofire.request(.POST, APIEndpoints.infoPhotoUpdate, parameters: parameters, encoding: .JSON, headers: self.authorizedHeaders()).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                // Only response is 1, throwing data to update on server, no heavy checks here
                let response = JSON as! NSDictionary
                let status = response.objectForKey("status_code") as? NSInteger
                
                if (status == 401 && GaskyFoundation.sharedInstance.isLoggedIn() == true) {
                    self.authInvalid()
                }
                
                if (status == 200) {
                    let photoUrl = response.objectForKey("photo_url") as? String
                    GaskyFoundation.sharedInstance.setPersonalInfo(nil, email: nil, phone: nil, photo: photoUrl)
                }
                
                completion(result: status!)
            case .Failure(_):
                // 0: Unreachable
                completion(result: 0)
            }
        }
    }
    
    func updatePromo(code: String, completion: (result: Int) -> Void) {
        let parameters = [
            "code": code
        ]
        
        Alamofire.request(.POST, APIEndpoints.setPromo, parameters: parameters, encoding: .JSON, headers: self.authorizedHeaders()).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                let response = JSON as! NSDictionary
                let status = response.objectForKey("status_code") as? NSInteger
                
                if (status == 401 && GaskyFoundation.sharedInstance.isLoggedIn() == true) {
                    self.authInvalid()
                }
                
                if (status == 200) {
                    var code: String? = nil
                    if response.objectForKey("promo_code") is String {
                        code = response.objectForKey("promo_code") as? String
                    }
                    
                    var percentOff: String? = nil
                    if response.objectForKey("percent_off") is String {
                        percentOff = response.objectForKey("percent_off") as? String
                    }
                    
                    var dollarAmountOff: String? = nil
                    if response.objectForKey("dollar_amount_off") is String {
                        dollarAmountOff = response.objectForKey("dollar_amount_off") as? String
                    }
                    
                    GaskyFoundation.sharedInstance.setPromoInfo(code, percentOff: percentOff, dollarAmountOff: dollarAmountOff)
                }
                
                if (status == nil) {
                    // Likely encountered a server error within the API
                    completion(result: 0)
                } else {
                    // 200: Promo added
                    // 400: Invalid promo
                    completion(result: status!)
                }
            case .Failure(_):
                // 0: Unreachable (Server outage most likely)
                completion(result: 0)
            }
        }
    }

    func updateVehicle(plates: String, make: String, model: String, year: String, color: String, completion: (result: Int) -> Void) {
        let parameters = [
            "plates": plates,
            "make": make,
            "model": model,
            "year": year,
            "color": color
        ]
        
        Alamofire.request(.POST, APIEndpoints.vehicleUpdate, parameters: parameters, encoding: .JSON, headers: self.authorizedHeaders()).responseJSON { response in
            switch response.result {
                case .Success(let JSON):
                    // Only response is 1, throwing data to update on server, no heavy checks here
                    let response = JSON as! NSDictionary
                    let status = response.objectForKey("status_code") as? NSInteger
                    
                    if (status == 401 && GaskyFoundation.sharedInstance.isLoggedIn() == true) {
                        self.authInvalid()
                    }
                    
                    if (status == 200) {
                        GaskyFoundation.sharedInstance.setVehicleInfo(plates, make: make, model: model, year: year, color: color, photo: nil)
                    }
                    
                    completion(result: status!)
                case .Failure(_):
                    // 0: Unreachable
                    completion(result: 0)
            }
        }
    }
    
    func updateVehiclePhoto(photo: UIImage, completion: (result: Int) -> Void) {
        let resizedImage = GaskyFoundation.resizeImage(photo, toWidth: 600)
        let photoData = UIImageJPEGRepresentation(resizedImage, 0.75)
        let base64encoded = photoData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        
        let parameters = [
            "photo": base64encoded
        ]
        
        Alamofire.request(.POST, APIEndpoints.vehiclePhotoUpdate, parameters: parameters, encoding: .JSON, headers: self.authorizedHeaders()).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                // Only response is 1, throwing data to update on server, no heavy checks here
                let response = JSON as! NSDictionary
                let status = response.objectForKey("status_code") as? NSInteger
                
                if (status == 401 && GaskyFoundation.sharedInstance.isLoggedIn() == true) {
                    self.authInvalid()
                }
                
                if (status == 200) {
                    let photoUrl = response.objectForKey("photo_url") as? String
                    GaskyFoundation.sharedInstance.setVehicleInfo(nil, make: nil, model: nil, year: nil, color: nil, photo: photoUrl)
                }
                
                completion(result: status!)
            case .Failure(_):
                // 0: Unreachable
                completion(result: 0)
            }
        }
    }
    
    func getClientToken(completion: (result: String) -> Void) {
        let parameters = [String: AnyObject]()
        
        Alamofire.request(.POST, APIEndpoints.clientToken, parameters: parameters, encoding: .JSON, headers: self.authorizedHeaders()).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                let response = JSON as! NSDictionary
                
                let status = response.objectForKey("status_code") as? NSInteger
                
                if (status == 401 && GaskyFoundation.sharedInstance.isLoggedIn() == true) {
                    self.authInvalid()
                    completion(result: "0")
                } else {
                    let token = response.objectForKey("client_token") as? String
                    completion(result: token!)
                }
            case .Failure(_):
                // 0: Unreachable
                completion(result: "0")
            }
        }
    }
    
    func updatePaymentMethod(nonce: String, zip: String, id: Int, makeDefault: Bool, completion: (status: Int, error: String) -> Void) {
        let parameters: [String: AnyObject] = [
            "nonce": nonce,
            "zip": zip,
            "id": id,
            "default": makeDefault
        ]
        
        Alamofire.request(.POST, APIEndpoints.paymentMethodUpdate, parameters: parameters, encoding: .JSON, headers: self.authorizedHeaders()).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                let response = JSON as! NSDictionary
                let responseStatus = response.objectForKey("status_code") as? NSInteger
                var error: String = ""
                
                if (responseStatus == 401 && GaskyFoundation.sharedInstance.isLoggedIn() == true) {
                    self.authInvalid()
                }
                
                if (responseStatus == 409) {
                    error = (response.objectForKey("status_description") as? String)!
                }
                
                if (responseStatus == 200) {
                    let data = response.objectForKey("data") as! NSArray
                    GaskyFoundation.sharedInstance.setPaymentMethodInfo(data)
                }
                
                completion(status: responseStatus!, error: error)
            case .Failure(_):
                // 0: Unreachable
                completion(status: 0, error: APIMessages.serviceUnavailable)
            }
        }
    }
    
    func deletePaymentMethod(id: Int, completion: (status: Int) -> Void) {
        let parameters: [String: AnyObject] = [
            "id": id
        ]
        
        Alamofire.request(.POST, APIEndpoints.deletePaymentMethod, parameters: parameters, encoding: .JSON, headers: self.authorizedHeaders()).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                let response = JSON as! NSDictionary
                let responseStatus = response.objectForKey("status_code") as? NSInteger
                
                if (responseStatus == 401 && GaskyFoundation.sharedInstance.isLoggedIn() == true) {
                    self.authInvalid()
                }
                
                if (responseStatus == 200) {
                    let data = response.objectForKey("data") as! NSArray
                    GaskyFoundation.sharedInstance.setPaymentMethodInfo(data)
                }
                
                completion(status: responseStatus!)
            case .Failure(_):
                // 0: Unreachable
                completion(status: 0)
            }
        }
    }
    
    func defaultPaymentMethod(id: Int, completion: (status: Int) -> Void) {
        let parameters: [String: AnyObject] = [
            "id": id
        ]
        
        Alamofire.request(.POST, APIEndpoints.defaultPaymentMethod, parameters: parameters, encoding: .JSON, headers: self.authorizedHeaders()).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                let response = JSON as! NSDictionary
                let responseStatus = response.objectForKey("status_code") as? NSInteger
                
                if (responseStatus == 401 && GaskyFoundation.sharedInstance.isLoggedIn() == true) {
                    self.authInvalid()
                }
                
                if (responseStatus == 200) {
                    let data = response.objectForKey("data") as! NSArray
                    GaskyFoundation.sharedInstance.setPaymentMethodInfo(data)
                }
                
                completion(status: responseStatus!)
            case .Failure(_):
                // 0: Unreachable
                completion(status: 0)
            }
        }
    }
    
    func submitNewOrder(grade: String, location: String, latitude: Double, longitude: Double, details: String, day: Int, time: Int, completion: (status: Int, error: String) -> Void) {
        let parameters: [String: AnyObject] = [
            "grade": grade,
            "location": location,
            "latitude": latitude,
            "longitude": longitude,
            "details": details,
            "day": day,
            "time": time
        ]
        
        Alamofire.request(.POST, APIEndpoints.submitOrder, parameters: parameters, encoding: .JSON, headers: self.authorizedHeaders()).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                let response = JSON as! NSDictionary
                let responseStatus = response.objectForKey("status_code") as? NSInteger
                var error: String = ""
                
                if (responseStatus == 401 && GaskyFoundation.sharedInstance.isLoggedIn() == true) {
                    self.authInvalid()
                }
                
                if (responseStatus == 400) {
                    error = (response.objectForKey("status_description") as? String)!
                }
                
                if (responseStatus == 200) {
                    let orderId = response.objectForKey("order_id") as? String
                    let deliveryDay = response.objectForKey("delivery_day") as? String
                    let latitude = response.objectForKey("latitude") as? String
                    let longitude = response.objectForKey("longitude") as? String
                    let scheduled = response.objectForKey("scheduled") as? String
                    let orderTime = response.objectForKey("received_time") as? String
                    let orderStatus = response.objectForKey("order_status") as? String
                    GaskyFoundation.sharedInstance.setOrderStatus(orderId, scheduled: scheduled, deliveryDay: deliveryDay, latitude: latitude, longitude: longitude, received: orderTime, delivering: nil, delivered: nil, status: orderStatus)
                }
                
                completion(status: responseStatus!, error: error)
            case .Failure(_):
                // 0: Unreachable
                completion(status: 0, error: APIMessages.serviceUnavailable)
            }
        }
    }
    
    func getOpenOrder() {
        Alamofire.request(.GET, APIEndpoints.orderStatus, encoding: .JSON, headers: self.authorizedHeaders()).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                let response = JSON as! NSDictionary
                let responseStatus = response.objectForKey("status_code") as? NSInteger
                
                if (responseStatus == 401 && GaskyFoundation.sharedInstance.isLoggedIn() == true) {
                    self.authInvalid()
                }
                
                if (responseStatus == 200) {
                    let orderId = response.objectForKey("order_id") as? String
                    
                    if (orderId != nil) {
                        let scheduled = response.objectForKey("scheduled") as? String
                        let deliveryDay = response.objectForKey("delivery_day") as? String
                        let latitude = response.objectForKey("latitude") as? String
                        let longitude = response.objectForKey("longitude") as? String
                        let orderTime = response.objectForKey("received_time") as? String
                        let deliveringTime = response.objectForKey("delivering_time") as? String
                        let deliveredTime = response.objectForKey("delivered_time") as? String
                        let status = response.objectForKey("order_status") as? String
                        GaskyFoundation.sharedInstance.setOrderStatus(orderId, scheduled: scheduled, deliveryDay: deliveryDay, latitude: latitude, longitude: longitude, received: orderTime, delivering: deliveringTime, delivered: deliveredTime, status: status)
                    }
                }
                
                break
            case .Failure(_):
                // 0: Unreachable
                break
            }
        }
    }
    
    func cancelOpenOrder() {
        Alamofire.request(.GET, APIEndpoints.orderCancel, encoding: .JSON, headers: self.authorizedHeaders()).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                let response = JSON as! NSDictionary
                let responseStatus = response.objectForKey("status_code") as? NSInteger
                
                if (responseStatus == 401 && GaskyFoundation.sharedInstance.isLoggedIn() == true) {
                    self.authInvalid()
                }
                
                if (responseStatus == 200) {
                    self.setOrderStatus(nil, scheduled: nil, deliveryDay: nil, latitude: nil, longitude: nil, received: nil, delivering: nil, delivered: nil, status: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedOrderMap"])
                }
                
                break
            case .Failure(_):
                // 0: Unreachable
                break
            }
        }
    }
    
    // Store order data for session
    func setOrderStatus(id: String?, scheduled: String?, deliveryDay: String?, latitude: String?, longitude: String?, received: String?, delivering: String?, delivered: String?, status: String?) {
        self.orderStatus["id"] = id
        self.orderStatus["scheduled"] = scheduled
        self.orderStatus["deliveryDay"] = deliveryDay
        self.orderStatus["latitude"] = latitude
        self.orderStatus["longitude"] = longitude
        self.orderStatus["received"] = received
        self.orderStatus["delivering"] = delivering
        self.orderStatus["delivered"] = delivered
        self.orderStatus["status"] = status
        
        NSNotificationCenter.defaultCenter().postNotificationName("orderStatusUpdated", object: nil)
    }
    
    func resetOrderStatus() {
        self.orderStatus = [
            "id": nil,
            "scheduled": nil,
            "deliveryDay": nil,
            "latitude": nil,
            "longitude": nil,
            "received": nil,
            "delivering": nil,
            "delivered": nil,
            "status": nil
        ]
    }

    func returnOrderStatus() -> [String:String?] {
        return self.orderStatus
    }
    
    func getOrderSummary() {
        Alamofire.request(.GET, APIEndpoints.orderSummary, encoding: .JSON, headers: self.authorizedHeaders()).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                let response = JSON as! NSDictionary
                let responseStatus = response.objectForKey("status_code") as? NSInteger
                                
                if (responseStatus == 401 && GaskyFoundation.sharedInstance.isLoggedIn() == true) {
                    self.authInvalid()
                }
                
                if (responseStatus == 200) {
                    let orderId = response.objectForKey("order_id") as? String
                    
                    if (orderId != nil) {
                        let completed = response.objectForKey("completed_time") as? String
                        let total = response.objectForKey("total") as? String
                        let pricePerGallon = response.objectForKey("price_per_gallon") as? String
                        let gallons = response.objectForKey("gallons") as? String
                        let gasTotal = response.objectForKey("gas_total") as? String
                        let deliveryFee = response.objectForKey("delivery_fee") as? String
                        let meterPhoto = response.objectForKey("meter_photo") as? String
                        let discount = response.objectForKey("discount") as? String
                        GaskyFoundation.sharedInstance.setOrderSummary(orderId, completed: completed, total: total, pricePerGallon: pricePerGallon, gallons: gallons, gasTotal: gasTotal, deliveryFee: deliveryFee, meterPhoto: meterPhoto, discount: discount)
                    }
                }
                
                break
            case .Failure(_):
                // 0: Unreachable
                break
            }
        }
    }
    
    // Store order summary data for session
    func setOrderSummary(id: String?, completed: String?, total: String?, pricePerGallon: String?, gallons: String?, gasTotal: String?, deliveryFee: String?, meterPhoto: String?, discount: String?) {
        self.orderSummary["id"] = id
        self.orderSummary["completed"] = completed
        self.orderSummary["total"] = total
        self.orderSummary["pricePerGallon"] = pricePerGallon
        self.orderSummary["gallons"] = gallons
        self.orderSummary["gasTotal"] = gasTotal
        self.orderSummary["deliveryFee"] = deliveryFee
        self.orderSummary["meterPhoto"] = meterPhoto
        self.orderSummary["discount"] = discount
        
        NSNotificationCenter.defaultCenter().postNotificationName("orderSummaryUpdated", object: nil)
    }
    
    func resetOrderSummary() {
        self.orderSummary = [
            "id": nil,
            "completed": nil,
            "total": nil,
            "pricePerGallon": nil,
            "gallons": nil,
            "gasTotal": nil,
            "deliveryFee": nil,
            "discount": nil,
            "meterPhoto": nil
        ]
    }
    
    func returnOrderSummary() -> [String:String?] {
        return self.orderSummary
    }
    
    func submitOrderFeedback(id: Int, rating: Int, details: String?, completion: (status: Int, error: String) -> Void) {
        var parameters: [String: AnyObject] = [
            "id": id,
            "rating": rating,
        ]
        
        if (details != nil) {
            parameters["details"] = details!
        }
        
        Alamofire.request(.POST, APIEndpoints.orderFeedback, parameters: parameters, encoding: .JSON, headers: self.authorizedHeaders()).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                let response = JSON as! NSDictionary
                let responseStatus = response.objectForKey("status_code") as? NSInteger
                var error: String = ""
                
                if (responseStatus == 401 && GaskyFoundation.sharedInstance.isLoggedIn() == true) {
                    self.authInvalid()
                }
                
                if (responseStatus == 400) {
                    error = (response.objectForKey("status_description") as? String)!
                }
                
                completion(status: responseStatus!, error: error)
            case .Failure(_):
                // 0: Unreachable
                completion(status: 0, error: APIMessages.serviceUnavailable)
            }
        }
    }
    
    func authInvalid() {
        NSNotificationCenter.defaultCenter().postNotificationName("authInvalid", object: nil)
        GaskyFoundation.sharedInstance.logout()
    }



    /***********************************
    *     REFERENCES AND UTILITIES     *
    ***********************************/

    static let neutralColor: UIColor = UIColor(red: 135.0 / 255.0, green: 135.0 / 255.0, blue: 135.0 / 255.0, alpha: 1.0)
    static let normalColor: UIColor = UIColor.whiteColor()
    static let errorColor: UIColor = UIColor(red: 255.0 / 255.0, green: 50.0 / 255.0, blue: 100.0 / 255.0, alpha: 1.0)
    static let buttonEnabled: UIColor = UIColor(red: 0.0, green: 204.0 / 255.0, blue: 251.0 / 255.0, alpha: 1.0)
    static let buttonDisabled: UIColor = UIColor(red: 26.0 / 255.0, green: 26.0 / 255.0, blue: 26.0 / 255.0, alpha: 1.0)
    static let buttonEnabledText: UIColor = UIColor.whiteColor()
    static let buttonDisabledText: UIColor = UIColor(red: 66.0 / 255.0, green: 66.0 / 255.0, blue: 66.0 / 255.0, alpha: 1.0)
    
    // Get the true font size of a UILabel
    static func labelTrueFontSize(label: UILabel) -> CGFloat {
        let comparisonContext = NSStringDrawingContext()
        comparisonContext.minimumScaleFactor = label.minimumScaleFactor
        
        let string = NSAttributedString(string: label.text!, attributes: [NSFontAttributeName: label.font!])
        string.boundingRectWithSize(label.frame.size, options: NSStringDrawingOptions.UsesFontLeading, context: comparisonContext)
        
        return label.font.pointSize * comparisonContext.actualScaleFactor
    }
    
    // Resize an image to the given width, maintaining aspect ratio
    static func resizeImage(image: UIImage, toWidth: CGFloat) -> UIImage {
        let scale = toWidth / image.size.width
        let toHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSizeMake(toWidth, toHeight))
        image.drawInRect(CGRectMake(0, 0, toWidth, toHeight))
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    // Set field text color based on state (placeholder, entering, error)
    static func setFieldColor(textField: UITextField, state: String) {
        switch state {
        case "neutral":
            textField.textColor = GaskyFoundation.neutralColor
        case "normal":
            textField.textColor = GaskyFoundation.normalColor
        case "error":
            textField.textColor = GaskyFoundation.errorColor
        default:
            textField.textColor = GaskyFoundation.normalColor
        }
    }
}