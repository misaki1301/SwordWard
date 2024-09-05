//
//  File.swift
//  
//
//  Created by Paul Frank on 28/01/24.
//

import Foundation

public enum SwordWardError: Error {
	case badRequest
	case unauthorized
	case forbidden
	case invalidResponse
	case internalServerError
	case serviceUnavailable
	case custom(String)
	case badEncoding
	
}

public enum Method: String {
	case get = "GET"
	case post = "POST"
	case patch = "PATCH"
	case update = "UPDATE"
	case delete = "DELETE"
}

public enum ContentType: String {
	case json = "application/json"
}

let contentType = "Content-Type"

open class Core {
	
	public static let `default` = Core()
	
	private init() {}
	
	open func request<Nameless: Decodable>(_ url: URL, method: Method, type: ContentType = .json, body: Data?, authHeader: String? = nil) async throws -> Result<Nameless, Error> {
		
		var request = URLRequest(url: url)
		
		if let authHeader {
			request.setValue("auth", forHTTPHeaderField: authHeader)
		}
		
		request.httpMethod = method.rawValue
		request.setValue(type.rawValue, forHTTPHeaderField: contentType)
		
		switch method {
			case .post, .update, .patch:
				request.httpBody = body
			default:
				break
		}
		
		var (data, response) = try await URLSession.shared.data(for: request)
		if let res = response as? HTTPURLResponse, res.statusCode != 200 {
			throw SwordWardError.invalidResponse
		}
		
		do {
			let decoder = JSONDecoder()
			//decoder.keyDecodingStrategy = .convertFromSnakeCase
			let value = try decoder.decode(Nameless.self, from: data)
			return .success(value)
		} catch {
			print("F \(error)")
			throw SwordWardError.invalidResponse
		}
		
	}
	
}
