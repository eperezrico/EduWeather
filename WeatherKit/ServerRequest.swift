//
//  ServerRequest.swift
//  EduWeather
//
//  Created by Eduardo on 1/17/15.
//
//

import Foundation

typealias JSONObject = AnyObject

class ServerRequest : NSObject, NSURLConnectionDataDelegate {
    typealias CompletionClosure = (JSONObject?)->()
    
    let queue: dispatch_queue_t
    let urlConnection: NSURLConnection!
    let completion: CompletionClosure
    private var data: NSMutableData = NSMutableData()
    
    init?(urlPath: String, queue: dispatch_queue_t, completion: CompletionClosure) {
        self.queue = queue
        self.completion = completion
        
        super.init()
        
        
        let url = NSURL(string: urlPath)
        
        if url == nil {
            return nil
        }
        let urlRequest = NSURLRequest(URL: url!)
        
        urlConnection = NSURLConnection(request: urlRequest, delegate: self, startImmediately: true)
        
        if urlConnection == nil {
            return nil
        }
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        self.completion(nil)
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.data.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        
        // Using GCD here may be an overkill but it ilustrates a technique to keep the main thread free while processing data
        dispatch_async(queue) {
            let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(self.data, options: NSJSONReadingOptions.allZeros, error: nil)
            
            self.completion(json)
        }
    }
}

extension String {
    func stringByAddingUrlEncoding() -> String {
        let characterSet = NSMutableCharacterSet.alphanumericCharacterSet()
        characterSet.addCharactersInString("-._* ")
        
        return stringByAddingPercentEncodingWithAllowedCharacters(characterSet)?.stringByReplacingOccurrencesOfString(" ", withString: "+") ?? self
    }
}