//
//  NutritionixAPI.swift
//  Nutrify
//
//  Created by Alex Benasutti on 4/27/20.
//  Copyright © 2020 Alex Benasutti. All rights reserved.
//

import Foundation

//
//  NetworkingClient.swift
//  AlamofireTest
//
//  Created by Alex Benasutti on 4/26/20.
//  Copyright © 2020 Alex Benasutti. All rights reserved.
//

import Foundation
import Alamofire

enum DataManagerError: Error {
    case unknown
    case failedRequest
    case invalidResponse
}

class NetworkingClient {
    
    typealias WebServiceResponse = ([[String: Any]]?, Error?) -> Void
    typealias NutritionCompletionHandler = ([Meal]?, DataManagerError?) -> ()
    
    let headers: HTTPHeaders = [
        "x-app-key": API.APPLICATION_KEY,
        "x-app-id": API.APPLICATION_ID,
        "Content-Type": "application/json"
    ]
    
    func execute(_ url: URL, query: String, completion: @escaping WebServiceResponse) {
        
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "PUT"
//
//        AF.request(urlRequest)
        
        let parameters = ["query": query, "detailed": true] as [String : Any]
        
        AF.request(url, parameters: parameters, headers: headers).validate().responseJSON { response in
//            if let error = response.error {
//                completion(nil, error)
//            } else if let jsonArray = response.result.value as? [[String: Any]] {
//                completion(jsonArray, nil)
//            } else if let jsonDict = response.result.value as? [String: Any] {
//                completion([jsonDict], nil)
//            }
            switch response.result {
            case let .success(value):
                debugPrint(value)
                if let jsonArray = value as? [[String: Any]] {
                    completion(jsonArray, nil)
                }
                else if let jsonDict = value as? [String: Any] {
                    completion([jsonDict], nil)
                }
            case let .failure(error):
                debugPrint(error)
                completion(nil, error)
            }
        }
        
    }
    
    func fetchFoodData(foodName: String, completion: @escaping NutritionCompletionHandler) {
        
        let parameters = ["query": foodName]
        
        AF.request("https://trackapi.nutritionix.com/v2/natural/nutrients/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            // debugPrint(response)
            switch response.result {
            case let .success(value):
                // ebugPrint(value)
                if let jsonArray = value as? [[String: Any]] {
                    // debugPrint(response.result)
                    completion(nil, .failedRequest)
                }
                else if let jsonDict = value as? [String: Any] {
                    // debugPrint(response.value as Any)
                    let result_dict = response.value as! NSDictionary
                    let result_array = result_dict["foods"] as! NSArray
                    let meals = self.mapToMeal(jsonDictionaries: result_array)
                    debugPrint(meals)
                    completion(meals, nil)
                }
            case let .failure(error):
                debugPrint(error)
                completion(nil, .failedRequest)
            }
        }
    }
    
    func mapToMeal(jsonDictionaries: NSArray) -> [Meal] {
        
        let mutableArray = NSMutableArray()
        
        // debugPrint(jsonDictionaries)
        
        for object in jsonDictionaries {
            
            debugPrint(object)
            // debugPrint("new item")
            
            if let dict = object as? NSDictionary {
                // debugPrint("nice time")
                debugPrint(dict["food_name"] as Any)
                // guard let fields = dict["fields"] as? NSDictionary else { return [] }
                guard let name = dict["food_name"] as? String else { return [] }
                debugPrint(name)
                debugPrint(dict["nf_calories"] as Any)
                guard let calories = dict["nf_calories"] as? NSNumber else { return [] }
                debugPrint(calories)
                guard let fat = dict["nf_total_fat"] as? NSNumber else { return [] }
                debugPrint(fat)
                guard let carbs = dict["nf_total_carbohydrate"] as? NSNumber else { return [] }
                debugPrint(carbs)
                guard let protein = dict["nf_protein"] as? NSNumber else { return [] }
                debugPrint(protein)
                
                mutableArray.add(Meal(
                    name: name,
                    calories: calories,
                    fat: fat,
                    carbs: carbs,
                    protein: protein
                ))
            }
        }
        
        guard let mealArray = mutableArray as? [Meal] else { return [] }
        
        debugPrint(mealArray)
        
        return mealArray
    }
}
