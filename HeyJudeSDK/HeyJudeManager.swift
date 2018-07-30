//
//  HeyJudeManager.swift
//  Hey Jude SDK
//
//  Created by Byron Tudhope on 2018/07/15.
//  Copyright © 2018 TCT Digital. All rights reserved.
//

import MobileCoreServices
import CoreLocation
import CoreTelephony
import SocketIO

public enum HeyJudeEnvironment {
    case LIVE
    case STAGING
    case DEVELOPMENT

    var intValue: Int {
        switch self {
        case .LIVE: return 0
        case .STAGING: return 1
        case .DEVELOPMENT: return 2
        }
    }
}

public class HeyJudeManager: NSObject, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation!
    private var environment: Int
    private var program: String
    private var apiKey: String
    private var token: String = ""
    private var userId: Int = 0
    private var socket: SocketIOClient?

    public init(environment: HeyJudeEnvironment, program: String, apiKey: String) {

        self.environment = environment.intValue;
        self.program = program;
        self.apiKey = apiKey;

        super.init()

        if #available(iOS 9.0, *) {
            locationManager.delegate = self
            locationManager.requestLocation()
        }

    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            //print("Found user's location: \(location)")
            self.currentLocation = location
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //print("Failed to find user's location: \(error.localizedDescription)")
    }


    // MARK: SocketIO

    private func initSocket() {

        self.socket = SocketIOClient(socketURL: URL(string: self.socketHost())!, config: [.log(true),
                                                                                       .connectParams(["user_id": self.userId, "token": self.token]),
                                                                                       .path("/chat")

            ])

        self.socket?.reconnects = true
        self.socket?.forceNew = true
        self.addHandlers()
    }

    private func connectSocket() {
        if self.socket != nil {
            self.socket!.connect()
        }
    }

    private func configureSocket() {

        if self.socket == nil {
            self.initSocket()
        }

        
//
//        self.manager!.setConfigs([.log(true),
//                                  .connectParams(["user_id": self.userId, "token": self.token]),
//                                  .path("/chat")
//                                ])
//
//        self.manager!.reconnect()

    }

    private func disconnectSocket() {
        if self.socket != nil {
            self.socket!.disconnect()
        }
    }

    private func clearSocket() {
        self.socket = nil
    }

    private func addHandlers() {

        self.socket?.onAny { (data) in
//            if data.event == "reconnectAttempt" {
//                self.manager!.disconnect()
//                self.socket!.connect()
//            }
        }
    }


    // MARK: - Bind to Chat Status
    public func BindToChatStatus(completion: @escaping (_ status: String) -> ()) {

        self.socket?.on(clientEvent: .connect) {data, ack in
            completion("connected")
        }

        self.socket?.on(clientEvent: .disconnect) {data, ack in
            completion("disconnected")
        }

        self.socket?.on(clientEvent: .reconnectAttempt) {data, ack in
            completion("reconnecting")
        }

        self.socket?.on(clientEvent: .reconnect) {data, ack in
            completion("reconnecting")
        }

    }


    // MARK: - Bind to Chat
    public func BindToChat(completion: @escaping (_ message: Message) -> ()) {

        self.socket!.on("chat-channel:" + String(self.userId)) {data, ack in

            print("Message Received!")
            let messageJson = data[0] as! String

            let messageData = messageJson.data(using: .utf8)

            guard let message = try? JSONDecoder().decode(Message.self, from: messageData!) else {
                print("Error: Couldn't decode data into Response")
                return
            }
            completion(message)
        }

    }

    private func userAuthenticated(user: User) {
        self.userId = user.id!
        self.configureSocket()
        self.connectSocket()
        self.Analytics() { (success, error) in }
        self.ResetBadgeCount() { (success, error) in }
    }

    private func userSignedOut() {
        self.userId = 0
        self.token = ""
        self.disconnectSocket()
        self.clearSocket()
    }

    // MARK: Auth

    // MARK: - Pause Session
    public func PauseSession() -> String {
        let token = self.token
        self.userSignedOut()
        return token
    }

    // MARK: - Resume Session
    public func ResumeSession(token: String, completion: @escaping (_ success: Bool, _ error: HeyJudeError?) -> ()){

        let jwtClaims = self.decodeToken(jwtToken: token)
        if let userId = jwtClaims["sub"] as? Int {
            self.userId = userId
            self.token = token
            self.Profile() { (success, user, error) in
                if (success) {
                    if let user = user {
                        self.userAuthenticated(user: user)
                    }
                }
                completion(success, error)
            }
            return
        }

        let error = HeyJudeError(httpResponseCode: 401, apiErrors: ["Invalid Token"], requestError: nil, response: nil)

        completion(false, error)

    }
    // MARK: - Sign In
    public func SignIn(username: String, password: String, completion: @escaping (_ success: Bool, _ object: User?, _ error: HeyJudeError?) -> ()) {
        let params = ["email": username, "password": password, "program": self.program]
        post(request: createPostRequest(path: "auth/sign-in", params: params as Dictionary<String, AnyObject>?)) { (success, data, error) in
            if let user = data?.user {
                self.userAuthenticated(user: user)
                completion(success, user, error)

            } else {
                completion(false, nil, error)
            }
        }
    }

    // MARK: - Verify Phone
    public func VerifyPhone(mobile: String, type: String, completion: @escaping (_ success: Bool, _ error: HeyJudeError?) -> ()) {
        let params = ["mobile": mobile, "type": type, "program": self.program]
        post(request: createPostRequest(path: "auth/verify", params: params as Dictionary<String, AnyObject>?)) { (success, data, error) in
            completion(success, error)
        }
    }

    // MARK: - Sign Up
    public func SignUp(params: Dictionary<String, AnyObject>, completion: @escaping (_ success: Bool, _ object: User?, _ error: HeyJudeError?) -> ()) {
        var user = params
        user["program"] = self.program as AnyObject
        user["platform"] = "ios" as AnyObject

        post(request: createPostRequest(path: "auth/sign-up", params: user as Dictionary<String, AnyObject>?)) { (success, data, error) in
            if let user = data?.user {
                self.userAuthenticated(user: user)
                completion(success, user, error)

            } else {
                completion(false, nil, error)
            }
        }
    }

    // MARK: - Forgot Password
    public func ForgotPassword(mobile: String, type: String, completion: @escaping (_ success: Bool, _ error: HeyJudeError?) -> ()) {
        let params = ["mobile": mobile, "type": type, "program": self.program]
        post(request: createPostRequest(path: "auth/forgot", params: params as Dictionary<String, AnyObject>?)) { (success, data, error) in
            completion(success, error)
        }
    }

    // MARK: - Reset Password
    public func ResetPassword(params: Dictionary<String, AnyObject>, completion: @escaping (_ success: Bool, _ object: User?, _ error: HeyJudeError?) -> ()) {
        var resetParams = params
        resetParams["program"] = self.program as AnyObject
        post(request: createPostRequest(path: "auth/reset", params: resetParams as Dictionary<String, AnyObject>?)) { (success, data, error) in
            if let user = data?.user {
                completion(success, user, error)
            } else {
                completion(false, nil, error)
            }
        }
    }

    // MARK: - Refresh
    public func Refresh(completion: @escaping (_ success: Bool, _ error: HeyJudeError?) -> ()) {
        get(request: createPostRequest(path: "auth/refresh")) { (success, data, error) in
            completion(success, error)
        }
    }

    // MARK: - Sign Out
    public func SignOut(completion: @escaping (_ success: Bool) -> ()) {
        get(request: createPostRequest(path: "auth/sign-out")) { (success, data, error) in
            self.userSignedOut()
            completion(success)
        }
    }

    // MARK: - Verify Phone
    public func VerifyPhone(mobile: String, completion: @escaping (_ success: Bool, _ error: HeyJudeError?) -> ()) {
        let params = ["mobile": mobile, "program": self.program]
        post(request: createPostRequest(path: "auth/verify", params: params as Dictionary<String, AnyObject>?)) { (success, data, error) in
            completion(success, error)
        }
    }

    // MARK: - Forgot
    public func Forgot(mobile: String, completion: @escaping (_ success: Bool, _ error: HeyJudeError?) -> ()) {
        let params = ["mobile": mobile, "program": self.program]
        post(request: createPostRequest(path: "auth/forgot", params: params as Dictionary<String, AnyObject>?)) { (success, data, error) in
            completion(success, error)
        }
    }

    // MARK: - Reset
    public func Reset(mobile: String, completion: @escaping (_ success: Bool, _ error: HeyJudeError?) -> ()) {
        let params = ["mobile": mobile, "program": self.program]
        post(request: createPostRequest(path: "auth/reset", params: params as Dictionary<String, AnyObject>?)) { (success, data, error) in
            completion(success, error)
        }
    }

    // MARK: User
    // MARK: Profile
    public func Profile(completion: @escaping (_ success: Bool, _ object: User?, _ error: HeyJudeError?) -> ()) {
        get(request: createGetRequest(path: "users/profile")) { (success, data, error) in
            if let user = data?.user {
                completion(success, user, error)
            } else {
                completion(false, nil, error)
            }
        }
    }
    // MARK: Update Profile
    public func UpdateProfile(params: Dictionary<String, AnyObject>, completion: @escaping (_ success: Bool, _ object: User?, _ error: HeyJudeError?) -> ()) {
        post(request: createPostRequest(path: "users/profile", params: params as Dictionary<String, AnyObject>?)) { (success, data, error) in
            if let user = data?.user {
                completion(success, user, error)
            } else {
                completion(false, nil, error)
            }
        }
    }
    // MARK: Skip Roadblock
    public func SkipRoadblock(roadblock: String, completion: @escaping (_ success: Bool, _ object: User?, _ error: HeyJudeError?) -> ()) {
        let params = ["roadblock": roadblock]
        post(request: createPostRequest(path: "users/skip-roadblock", params: params as Dictionary<String, AnyObject>?)) { (success, data, error) in
            if let user = data?.user {
                completion(success, user, error)
            } else {
                completion(false, nil, error)
            }
        }
    }

    // MARK: Tasks
    // MARK: - Open
    public func OpenTasks(completion: @escaping (_ success: Bool, _ object: [Task]?, _ error: HeyJudeError?) -> ()) {
        get(request: createGetRequest(path: "tasks/open")) { (success, data, error) in
            if let tasks = data?.tasks {
                completion(success, tasks, error)
            } else {
                completion(false, [], error)
            }
        }
    }

    // MARK: - Closed
    public func ClosedTasks(completion: @escaping (_ success: Bool, _ object: [Task]?, _ error: HeyJudeError?) -> ()) {
        get(request: createGetRequest(path: "tasks/closed")) { (success, data, error) in

            if let tasks = data?.tasks {
                completion(success, tasks, error)
            } else {
                completion(false, [], error)
            }
        }
    }

    // MARK: - Get Task
    public func GetTask(id: Int, completion: @escaping (_ success: Bool, _ object: Task?, _ error: HeyJudeError?) -> ()) {
        get(request: createGetRequest(path: "tasks/" + String(id))) { (success, data, error) in

            if (success) {
                completion(success, data?.task, error)
            } else {
                completion(success, nil, error)
            }
        }
    }

    // MARK: - Cancel Task
    public func CancelTask(id: Int, completion: @escaping (_ success: Bool, _ error: HeyJudeError?) -> ()) {
        post(request: createPostRequest(path: "tasks/" + String(id) + "/cancel")) { (success, data, error) in

            if (success) {
                completion(success, error)
            } else {
                completion(success, error)
            }
        }
    }

    // MARK: - Reopen Task
    public func ReopenTask(id: Int, completion: @escaping (_ success: Bool, _ error: HeyJudeError?) -> ()) {
        post(request: createPostRequest(path: "tasks/" + String(id) + "/reopen")) { (success, data, error) in

            if (success) {
                completion(success, error)
            } else {
                completion(success, error)
            }
        }
    }

    // MARK: - Delete Task
    public func DeleteTask(id: Int, completion: @escaping (_ success: Bool, _ error: HeyJudeError?) -> ()) {
        post(request: createPostRequest(path: "tasks/" + String(id) + "/delete")) { (success, data, error) in

            if (success) {
                completion(success, error)
            } else {
                completion(success, error)
            }
        }
    }
    // MARK: - Create Task
    public func CreateTask(title: String, createDefaultMessage: Bool, completion: @escaping (_ success: Bool, _ object: Task?, _ error: HeyJudeError?) -> ()) {
        let lat = self.currentLocation?.coordinate.latitude
        let lon = self.currentLocation?.coordinate.longitude
        var latString = ""
        var lonString = ""

        if lat != nil {
            latString = "\(lat ?? 0)"
        }
        if lon != nil {
            lonString = "\(lon ?? 0)"
        }

        let params = ["title": title, "create_default_message": createDefaultMessage, "latitude": latString, "longitude": lonString] as [String : Any]
        post(request: createPostRequest(path: "tasks/create", params: params as Dictionary<String, AnyObject>?)) { (success, data, error) in
            if (success) {
                completion(success, data?.task, error)
            } else {
                completion(success, nil, error)
            }
        }
    }
    // MARK: - Message Task
    public func MessageTask(id: Int, params: Dictionary<String, AnyObject>, completion: @escaping (_ success: Bool, _ error: HeyJudeError?) -> ()) {
        post(request: createPostRequest(path: "tasks/" + String(id) + "/message", params: params as Dictionary<String, AnyObject>?)) { (success, data, error) in
            if (success) {
                completion(success, error)
            } else {
                completion(success, error)
            }
        }
    }
    // MARK: - Rate Task
    public func RateTask(id: Int, params: Dictionary<String, AnyObject>, completion: @escaping (_ success: Bool, _ error: HeyJudeError?) -> ()) {
        post(request: createPostRequest(path: "tasks/" + String(id) + "/rate", params: params as Dictionary<String, AnyObject>?)) { (success, data, error) in
            if (success) {
                completion(success, error)
            } else {
                completion(success, error)
            }
        }
    }
    // MARK: - Get Task Rating
    public func TaskRating(id: Int, unixTimeStamp: String, completion: @escaping (_ success: Bool, _ rating: Int?, _ error: HeyJudeError?) -> ()) {
        let params = ["unix_timestamp": unixTimeStamp]
        post(request: createPostRequest(path: "tasks/" + String(id) + "/rating", params: params as Dictionary<String, AnyObject>?)) { (success, data, error) in
            if (success) {
                completion(success, data?.taskRating, error)
            } else {
                completion(success, nil, error)
            }
        }
    }

    // MARK: Attachments
    // MARK: - Upload
    public func UploadAttachment(path: String, completion: @escaping (_ success: Bool, _ object: Attachment?, _ error: HeyJudeError?) -> ()) {
        post(request: createMultiPartRequest(path: "attachments/upload", filePath: path)) { (success, data, error) in
            if (success) {
                completion(success, data?.attachment, error)
            } else {
                completion(success, nil, error)
            }
        }
    }
    // MARK: - Download
    public func DownloadAttachment(id: Int, completion: @escaping (_ success: Bool, _ object: AnyObject?, _ error: HeyJudeError?) -> ()) {
        download(request: createDownloadRequest(path: "attachments/download/" + String(id))) { (success, data, error) in
            if (success) {
                completion(success, data, error)
            } else {
                completion(success, nil, error)
            }
        }
    }
    // MARK: - Detail
    public func AttachmentDetail(id: Int, completion: @escaping (_ success: Bool, _ object: Attachment?, _ error: HeyJudeError?) -> ()) {
        get(request: createGetRequest(path: "attachments/detail/" + String(id))) { (success, data, error) in

            if (success) {
                completion(success, data?.attachment, error)
            } else {
                completion(success, nil, error)
            }
        }
    }

    // MARK: Payments
    // MARK: - Methods
    public func PaymentMethods(completion: @escaping (_ success: Bool, _ object: [PaymentMethod]?, _ error: HeyJudeError?) -> ()) {
        get(request: createGetRequest(path: "payments/methods")) { (success, data, error) in
            if (success) {
                completion(success, data?.paymentMethods, error)
            } else {
                completion(success, nil, error)
            }
        }
    }
    
    // MARK: - Add Method
    public func AddPaymentMethod(params: Dictionary<String, AnyObject>, completion: @escaping (_ success: Bool, _ object: [PaymentMethod]?, _ error: HeyJudeError?) -> ()) {
        post(request: createPostRequest(path: "payments/methods", params: params as Dictionary<String, AnyObject>?)) { (success, data, error) in
            if (success) {
                completion(success, data?.paymentMethods, error)
            } else {
                completion(success, nil, error)
            }
        }
    }

    // MARK: - Update Method
    public func UpdatePaymentMethod(id: Int, params: Dictionary<String, AnyObject>, completion: @escaping (_ success: Bool, _ object: [PaymentMethod]?, _ error: HeyJudeError?) -> ()) {
        post(request: createPostRequest(path: "payments/methods/" + String(id), params: params as Dictionary<String, AnyObject>?)) { (success, data, error) in
            if (success) {
                completion(success, data?.paymentMethods, error)
            } else {
                completion(success, nil, error)
            }
        }
    }

    // MARK: - Delete Method
    public func DeletePaymentMethod(id: Int, completion: @escaping (_ success: Bool, _ object: [PaymentMethod]?, _ error: HeyJudeError?) -> ()) {
        post(request: createPostRequest(path: "payments/methods/" + String(id) + "/delete")) { (success, data, error) in
            if (success) {
                completion(success, data?.paymentMethods, error)
            } else {
                completion(success, nil, error)
            }
        }
    }

    // MARK: - Request
    public func PaymentRequest(id: Int, completion: @escaping (_ success: Bool, _ object: PaymentRequest?, _ error: HeyJudeError?) -> ()) {
        get(request: createGetRequest(path: "payments/requests/" + String(id))) { (success, data, error) in
            if (success) {
                completion(success, data?.paymentRequest, error)
            } else {
                completion(success, nil, error)
            }
        }
    }

    // MARK: - Pay
    public func Pay(paymentRequestId: Int, paymentMethodId: Int, completion: @escaping (_ success: Bool, _ object: PaymentRequest?, _ error: HeyJudeError?) -> ()) {
        let params = ["payment_request_id": paymentRequestId, "payment_method_id": paymentMethodId] as [String : Any]
        post(request: createPostRequest(path: "payments/pay", params: params as Dictionary<String, AnyObject>?)) { (success, data, error) in
            if (success) {
                completion(success, data?.paymentRequest, error)
            } else {
                completion(success, nil, error)
            }
        }
    }


    // MARK: - History
    public func PaymentHistory(completion: @escaping (_ success: Bool, _ object: [Payment]?, _ error: HeyJudeError?) -> ()) {
        get(request: createGetRequest(path: "payments/history")) { (success, data, error) in
            if (success) {
                completion(success, data?.payments, error)
            } else {
                completion(success, nil, error)
            }
        }
    }

    // MARK: - Invoice
    public func Invoice(id: Int, completion: @escaping (_ success: Bool, _ error: HeyJudeError?) -> ()) {
        let params = ["payment_id": id] as [String : Any]
        post(request: createPostRequest(path: "payments/invoice", params: params as Dictionary<String, AnyObject>?)) { (success, data, error) in
            if (success) {
                completion(success, error)
            } else {
                completion(success, error)
            }
        }
    }


    // MARK: Subscription
    // MARK: - Options
    public func SubscriptionOptions(completion: @escaping (_ success: Bool, _ object: [SubscriptionOption]?, _ error: HeyJudeError?) -> ()) {
        get(request: createGetRequest(path: "subscriptions/options")) { (success, data, error) in
            if (success) {
                completion(success, data?.subscriptionOptions, error)
            } else {
                completion(success, nil, error)
            }
        }
    }

    // MARK: - Status
    public func SubscriptionStatus(completion: @escaping (_ success: Bool, _ object: SubscriptionStatus?, _ error: HeyJudeError?) -> ()) {
        get(request: createGetRequest(path: "subscriptions/status")) { (success, data, error) in
            if (success) {
                completion(success, data?.subscriptionStatus, error)
            } else {
                completion(success, nil, error)
            }
        }
    }

    // MARK: - Select
    public func SubscriptionSelect(id: Int, completion: @escaping (_ success: Bool, _ object: SubscriptionStatus?, _ error: HeyJudeError?) -> ()) {
        let params = ["subscription_option_id": id] as [String : Any]
        post(request: createPostRequest(path: "subscriptions/select", params: params as Dictionary<String, AnyObject>?)) { (success, data, error) in
            if (success) {
                completion(success, data?.subscriptionStatus, error)
            } else {
                completion(success, nil, error)
            }
        }
    }

    // MARK: - Auto Renew
    public func SubscriptionAutoRenew(autoRenew: Bool, completion: @escaping (_ success: Bool, _ object: SubscriptionStatus?, _ error: HeyJudeError?) -> ()) {
        let params = ["auto_renew": autoRenew] as [String : Any]
        post(request: createPostRequest(path: "subscriptions/auto-renew", params: params as Dictionary<String, AnyObject>?)) { (success, data, error) in
            if (success) {
                completion(success, data?.subscriptionStatus, error)
            } else {
                completion(success, nil, error)
            }
        }
    }

    // MARK: Analytics
    public func Analytics(completion: @escaping (_ success: Bool, _ error: HeyJudeError?) -> ()) {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height

        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider

        // Get carrier name
        let carrierName = carrier?.carrierName ?? ""

        //self.locationManager.requestWhenInUseAuthorization()

        let lat = self.currentLocation?.coordinate.latitude
        let lon = self.currentLocation?.coordinate.longitude
        var latString = ""
        var lonString = ""

        if lat != nil {
            latString = "\(lat ?? 0)"
        }
        if lon != nil {
            lonString = "\(lon ?? 0)"
        }

        var locationEnabled = false
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            locationEnabled = true
            break
        case .authorizedAlways:
            locationEnabled = true
            break
        default:
            locationEnabled = false
            break
        }

        let params = [
              "device_identifier": UIDevice.current.name,
              "device_manufacturer": "Apple",
              "device_model": identifier,
              "device_os": "iOS",
              "device_os_version": UIDevice.current.systemVersion,
              "device_carrier": carrierName,
              "device_screen_size": "\(screenWidth)x\(screenHeight)",
              "app_version": "3.0.0",
              "app_push_enabled": UIApplication.shared.isRegisteredForRemoteNotifications,
              "app_location_enabled": locationEnabled,
              "latitude": latString,
              "longitude": lonString,
              "device_token": "TEST"
            ] as [String : Any]
        post(request: createPostRequest(path: "analytics", params: params as Dictionary<String, AnyObject>?)) { (success, data, error) in
            if (success) {
                completion(success, error)
            } else {
                completion(success, error)
            }
        }
    }

    // MARK: - Map
    public func Map(url: String, completion: @escaping (_ success: Bool, _ object: AnyObject?, _ error: HeyJudeError?) -> ()) {
        download(request: createMapRequest(url: url)) { (success, data, error) in
            if (success) {
                completion(success, data, error)
            } else {
                completion(success, nil, error)
            }
        }
    }

    // MARK: - Badge Count
    public func ResetBadgeCount(completion: @escaping (_ success: Bool, _ error: HeyJudeError?) -> ()) {
        get(request: createGetRequest(path: "badge")) { (success, data, error) in
            completion(success, error)
        }
    }

    // MARK: - FeaturedImage
    public func FeaturedImage(completion: @escaping (_ success: Bool, _ object: FeaturedImage?, _ error: HeyJudeError?) -> ()) {
        get(request: createGetRequest(path: "featured-image")) { (success, data, error) in
            if (success) {
                completion(success, data?.featuredImage, error)
            } else {
                completion(success, nil, error)
            }
        }
    }

    // MARK: - Countries
    public func Countries(completion: @escaping (_ success: Bool, _ object: [Country]?, _ error: HeyJudeError?) -> ()) {
        get(request: createGetRequest(path: "countries")) { (success, data, error) in
            if (success) {
                completion(success, data?.countries, error)
            } else {
                completion(success, nil, error)
            }
        }
    }

    //MARK: Convenience Methods


    private func host() -> String! {
        switch self.environment {
        case 0: return "https://agent.heyjudeapp.com/api/v1/"
        case 1: return "https://staging.heyjudeapp.com/api/v1/"
        case 2: return "http://heyjudeapp.com.tctdigital.xyz/api/v1/"
        default: return ""
        }
    }

    private func socketHost() -> String! {
        switch self.environment {
        case 0: return "https://agent.heyjudeapp.com/"
        case 1: return "https://staging.heyjudeapp.com/"
        case 2: return "http://heyjudeapp.com.tctdigital.xyz/"
        default: return ""
        }
    }

    private func post(request: NSMutableURLRequest, completion: @escaping (_ success: Bool, _ data: Data?, _ error: HeyJudeError?) -> ()) {
        dataTask(request: request, method: "POST", completion: completion)
    }

    private func get(request: NSMutableURLRequest, completion: @escaping (_ success: Bool, _ data: Data?, _ error: HeyJudeError?) -> ()) {
        dataTask(request: request, method: "GET", completion: completion)
    }

    private func download(request: NSMutableURLRequest, completion: @escaping (_ success: Bool, _ data: AnyObject?, _ error: HeyJudeError?) -> ()) {
        fileTask(request: request, method: "GET", completion: completion)
    }

    private func createPostRequest(path: String, params: Dictionary<String, AnyObject>? = nil) -> NSMutableURLRequest {

        if (params != nil) {
            let urlString = self.host() + path
            let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params!, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
            }

            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue(self.apiKey, forHTTPHeaderField: "x-api-key")
            if (self.token != "") {
                request.addValue("Bearer " + self.token, forHTTPHeaderField: "Authorization")
            }
            return request
        } else {
            let urlString = self.host() + path
            let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue(self.apiKey, forHTTPHeaderField: "x-api-key")
            if (self.token != "") {
                request.addValue("Bearer " + self.token, forHTTPHeaderField: "Authorization")
            }
            return request
        }

    }

    private func createGetRequest(path: String, params: Dictionary<String, AnyObject>? = nil) -> NSMutableURLRequest {

        if (params != nil) {
            let urlString = self.host() + path
            let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params!, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
            }

            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue(self.apiKey, forHTTPHeaderField: "x-api-key")
            if (self.token != "") {
                request.addValue("Bearer " + self.token, forHTTPHeaderField: "Authorization")
            }
            return request
        } else {
            let urlString = self.host() + path
            let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue(self.apiKey, forHTTPHeaderField: "x-api-key")
            if (self.token != "") {
                request.addValue("Bearer " + self.token, forHTTPHeaderField: "Authorization")
            }
            return request
        }

    }

    private func createDownloadRequest(path: String, params: Dictionary<String, AnyObject>? = nil) -> NSMutableURLRequest {

        if (params != nil) {
            let urlString = self.host() + path
            let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params!, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
            }

            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(self.apiKey, forHTTPHeaderField: "x-api-key")
            if (self.token != "") {
                request.addValue("Bearer " + self.token, forHTTPHeaderField: "Authorization")
            }
            return request
        } else {
            let urlString = self.host() + path
            let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(self.apiKey, forHTTPHeaderField: "x-api-key")
            if (self.token != "") {
                request.addValue("Bearer " + self.token, forHTTPHeaderField: "Authorization")
            }
            return request
        }

    }

    private func createMapRequest(url: String) -> NSMutableURLRequest {
        if url.hasPrefix("https://agent.heyjudeapp.com/") {
            var path = url.replacingOccurrences(of: "https://agent.heyjudeapp.com/map?", with: "")
            path = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!

            let urlString = "https://agent.heyjudeapp.com/map?" + path
            
            let request = NSMutableURLRequest(url: URL(string: urlString)!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(self.apiKey, forHTTPHeaderField: "x-api-key")
            if (self.token != "") {
                request.addValue("Bearer " + self.token, forHTTPHeaderField: "Authorization")
            }
            return request
        }

        let request = NSMutableURLRequest(url: NSURL(string: self.host())! as URL)
        return request

    }

    private func createMultiPartRequest(path: String, filePath: String, params: Dictionary<String, AnyObject>? = nil) -> NSMutableURLRequest {

        var body = Foundation.Data()
        let boundary = self.generateBoundaryString()
        let urlString = self.host() + path
        let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.addValue(self.apiKey, forHTTPHeaderField: "x-api-key")
        if (self.token != "") {
            request.addValue("Bearer " + self.token, forHTTPHeaderField: "Authorization")
        }

        let url = URL(fileURLWithPath: filePath)
        let filename = url.lastPathComponent
        let data = try! Foundation.Data(contentsOf: url)
        let mimetype = mimeType(for: path)

        if params != nil {
            for (key, value) in params! {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append("\(value)\r\n")
            }
        }

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"attachment\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: \(mimetype)\r\n\r\n")
        body.append(data)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
        request.httpBody = body
        return request
    }

    private func mimeType(for path: String) -> String {
        let url = NSURL(fileURLWithPath: path)
        let pathExtension = url.pathExtension

        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue()
        {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue()
            {
                return mimetype as String
            }
        }
        return "application/octet-stream";
    }

    private func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }


    private func dataTask(request: NSMutableURLRequest, method: String, completion: @escaping (_ success: Bool, _ data: Data?, _ error: HeyJudeError?) -> ()) {
        request.httpMethod = method

        let session = URLSession(configuration: URLSessionConfiguration.default);

        session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in

            var httpResponseCode = 0

            if let response = response as? HTTPURLResponse {
                httpResponseCode = response.statusCode
            }

            if let data = data {

                guard let responseObj = try? JSONDecoder().decode(Response.self, from: data) else {
                    let error = HeyJudeError(httpResponseCode: httpResponseCode, apiErrors: nil, requestError: error, response: response)
                    completion(false, nil, error)
                    return
                }

                if let token = responseObj.token {
                    self.token = token
                }

                guard let responseData = try? JSONDecoder().decode(ResponseData.self, from: data) else {
                    let error = HeyJudeError(httpResponseCode: httpResponseCode, apiErrors: responseObj.errors, requestError: error, response: response)
                    completion(responseObj.success!, nil, error)
                    return
                }

                if 200...299 ~= httpResponseCode {
                    completion(responseObj.success!, responseData.data, nil)
                } else {
                    let error = HeyJudeError(httpResponseCode: httpResponseCode, apiErrors: responseObj.errors, requestError: error, response: response)
                    completion(responseObj.success!, responseData.data, error)
                }

            } else {
                let error = HeyJudeError(httpResponseCode: httpResponseCode, apiErrors: nil, requestError: error, response: response)
                completion(false, nil, error)
            }
        }.resume();
    }


    private func fileTask(request: NSMutableURLRequest, method: String, completion: @escaping (_ success: Bool, _ data: AnyObject?, _ error: HeyJudeError?) -> ()) {
        request.httpMethod = method

        let session = URLSession(configuration: URLSessionConfiguration.default);

        session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in

            var httpResponseCode = 0

            if let response = response as? HTTPURLResponse {
                httpResponseCode = response.statusCode
            }

            if let data = data {

                if 200...299 ~= httpResponseCode {
                    completion(true, data as AnyObject, nil)
                } else {

                    guard let responseObj = try? JSONDecoder().decode(Response.self, from: data) else {
                        let error = HeyJudeError(httpResponseCode: httpResponseCode, apiErrors: nil, requestError: error, response: response)
                        completion(false, nil, error)
                        return
                    }

                    if let token = responseObj.token {
                        self.token = token
                    }

                    let error = HeyJudeError(httpResponseCode: httpResponseCode, apiErrors: responseObj.errors, requestError: error, response: response)

                    completion(responseObj.success!, nil, error)
                }

            } else {
                let error = HeyJudeError(httpResponseCode: httpResponseCode, apiErrors: nil, requestError: error, response: response)
                completion(false, nil, error)
            }

            }.resume();
    }

    private func decodeToken(jwtToken jwt: String) -> [String: Any] {
        if jwt == "" {
            return [:]
        }
        let segments = jwt.components(separatedBy: ".")
        return self.decodeJWTPart(segments[1]) ?? [:]
    }

    private func base64UrlDecode(_ value: String) -> Foundation.Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 = base64 + padding
        }
        return Foundation.Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }

    private func decodeJWTPart(_ value: String) -> [String: Any]? {
        guard let bodyData = self.base64UrlDecode(value),
            let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
                return nil
        }
        return payload
    }

}

extension Foundation.Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
