//
//  Context.swift
//  Pods
//
//  Created by David Jennes on 14/02/2017.
//
//

import Foundation

import Stencil

class AdvancedContext: Context{
	
	
	
	private func pop(_ locals: Set<String>) -> [String: Any?]?{
		let top = pop() ?? [:]
		var popped: [String: Any] = [:]
		//propagate non local preexisting variable values down the stack
		for (key, value) in top {
			if !locals.contains(key) && self[key] != nil{
				self[key] = value
			}else{
				popped[key] = value
			}
		}
		if popped.isEmpty{
			return nil
		}
		return popped
	}
	
	public func pushLocals<Result>(dictionary: [String: Any]? = nil, closure: (() throws -> Result)) rethrows -> Result {
		let dictionary = dictionary ?? [:]
		let locals = Set(dictionary.keys)
		
		push(dictionary)
		defer { _ = pop(locals) }
		return try closure()
	}
	
}

public enum StencilContext {
  public static let environmentKey = "env"
  public static let parametersKey = "param"

  /// Enriches a stencil context with parsed parameters and environment variables
  ///
  /// - Parameters:
  ///   - context: The stencil context to enrich
  ///   - parameters: List of strings, will be parsed using the `Parameters.parse(items:)` method
  ///   - environment: Environment variables, defaults to `ProcessInfo().environment`
  /// - Returns: The new Stencil context enriched with the parameters and env variables
  /// - Throws: `Parameters.Error`
  public static func enrich(context: [String: Any],
                            parameters: [String],
                            environment: [String: String] =
                            ProcessInfo.processInfo.environment) throws -> [String: Any] {
    let params = try Parameters.parse(items: parameters)
    return try enrich(context: context, parameters: params, environment: environment)
  }

  /// Enriches a stencil context with parsed parameters and environment variables
  ///
  /// - Parameters:
  ///   - context: The stencil context to enrich
  ///   - parameters: Dictionary of parameters. Can be structured in sub-dictionaries.
  ///   - environment: Environment variables, defaults to `ProcessInfo().environment`
  /// - Returns: The new Stencil context enriched with the parameters and env variables
  /// - Throws: `Parameters.Error`
  public static func enrich(context: [String: Any],
                            parameters: [String: Any],
                            environment: [String: String] =
                            ProcessInfo.processInfo.environment) throws -> [String: Any] {
    var context = context

    context[environmentKey] = merge(context[environmentKey], with: environment)
    context[parametersKey] = merge(context[parametersKey], with: parameters)

    return context
  }

  private static func merge(_ lhs: Any?, with rhs: [String: Any]) -> [String: Any] {
    var result = lhs as? [String: Any] ?? [:]

    for (key, value) in rhs {
      result[key] = value
    }

    return result
  }
}
