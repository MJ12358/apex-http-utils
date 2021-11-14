/**
 * Created on Tue Feb 9 2021
 *
 * Copyright (c) 2021 Matt T. Jants
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *    are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *    this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *    this list of conditions and the following disclaimer in the documentation 
 *    and/or other materials provided with the distribution.
 * - Neither the name of the company, software or the names of its contributors 
 *    may be used to endorse or promote products derived from this software without 
 *    specific prior written permission.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 *  TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, TORT (INCLUDING NEGLIGENCE) OR OTHERWISE, 
 *  ARISING FROM, OUT OF OR IN CONNECTION WITH THE USE OF THIS SOFTWARE OR OTHER DEALINGS IN THE SOFTWARE, 
 *  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 **/

public without sharing class HttpStatus {

	public static final Map<Integer, Map<String, String>> statusByCode {
		get {
			if (statusByCode == null) {
				statusByCode = new Map<Integer, Map<String, String>>{
					// informational responses
					100 => new Map<String, String>{
						'name' => 'CONTINUE',
						'message' => 'Everything so far is OK and the client should continue the request, or ignore the response if the request is already finished.'
					},
					101 => new Map<String, String>{
						'name' => 'SWITCHING PROTOCOL',
						'message' => 'This code is sent in response to an Upgrade request header from the client, and indicates the protocol the server is switching to.'
					},
					102 => new Map<String, String>{
						'name' => 'PROCESSING',
						'message' => 'The server has received and is processing the request, but no response is available yet.'
					},
					103 => new Map<String, String>{
						'name' => 'EARLY HINTS',
						'message' => 'The user agent should start preloading resources while the server prepares a response.'
					},

					// successful responses
					200 => new Map<String, String>{
						'name' => 'OK',
						'message' => 'The request has succeeded'
					},
					201 => new Map<String, String>{
						'name' => 'CREATED',
						'message' => 'The request has been fulfilled and resulted in a new resource being created.'
					},
					202 => new Map<String, String>{
						'name' => 'ACCEPTED',
						'message' => 'The request has been accepted for processing, but the processing has not been completed.'
					},
					203 => new Map<String, String>{
						'name' => 'NON-AUTHORITATIVE INFORMATION',
						'message' => 'The returned metainformation in the entity-header is not the definitive set as available from the origin server, but is gathered from a local or a third-party copy.'
					},
					204 => new Map<String, String>{
						'name' => 'NO CONTENT',
						'message' => 'The server has fulfilled the request but does not need to return an entity-body.'
					},
					205 => new Map<String, String>{
						'name' => 'RESET CONTENT',
						'message' => 'The server has fulfilled the request and the user agent should reset the document view which caused the request to be sent.'
					},
					206 => new Map<String, String>{
						'name' => 'PARTIAL CONTENT',
						'message' => 'The server has fulfilled the partial request for the resource.'
					},
					207 => new Map<String, String>{
						'name' => 'MULTI-STATUS',
						'message' => 'Provides multiple independent operations'
					},
					208 => new Map<String, String>{
						'name' => 'ALREADY REPORTED',
						'message' => 'Bindings have already been enumerated in a previous reply to this request, and are not being included again.'
					},
					226 => new Map<String, String>{
						'name' => 'IM USED',
						'message' => 'The server has fulfilled a request for the resource, and the response is a representation of the result of one or more instance-manipulations applied to the current instance.'
					},

					// redirection messages
					300 => new Map<String, String>{
						'name' => 'MULTIPLE CHOICE',
						'message' => 'There are multiple options for the resource that the client may follow.'
					},
					301 => new Map<String, String>{
						'name' => 'MOVED PERMANENTLY',
						'message' => 'This and all future requests should be directed to the given URI.'
					},
					302 => new Map<String, String>{
						'name' => 'FOUND',
						'message' => 'The response to the request can be found under another URI using a GET method.'
					},
					303 => new Map<String, String>{
						'name' => 'SEE OTHER',
						'message' => 'The response to the request can be found under another URI using a GET method.'
					},
					304 => new Map<String, String>{
						'name' => 'NOT MODIFIED',
						'message' => 'The resource has not been modified since last requested.'
					},
					307 => new Map<String, String>{
						'name' => 'TEMPORARY REDIRECT',
						'message' => 'The requested resource resides temporarily under a different URI.'
					},
					308 => new Map<String, String>{
						'name' => 'PERMANENT REDIRECT',
						'message' => 'The request, and all future requests should be repeated using another URI'
					},

					// client error responses
					400 => new Map<String, String>{
						'name' => 'BAD REQUEST',
						'message' => 'The request could not be understood by the server due to malformed syntax.'
					},
					401 => new Map<String, String>{
						'name' => 'UNAUTHORIZED',
						'message' => 'This request requires user authentication or authorization has been refused.'
					},
					402 => new Map<String, String>{
						'name' => 'PAYMENT REQUIRED',
						'message' => 'The client may retry the request with a suitable ChargeTo header.'
					},
					403 => new Map<String, String>{
						'name' => 'FORBIDDEN',
						'message' => 'The server understood the request, but is refusing to fulfill it.'
					},
					404 => new Map<String, String>{
						'name' => 'NOT FOUND',
						'message' => 'The requested resource could not be found but may be available again in the future.'
					},
					405 => new Map<String, String>{
						'name' => 'METHOD NOT ALLOWED',
						'message' => 'A request was made of a resource using a request method not supported by that resource.'
					},
					406 => new Map<String, String>{
						'name' => 'NOT ACCEPTABLE',
						'message' => 'The requested resource is only capable of generating content not acceptable according to the Accept headers sent in the request.'
					},
					407 => new Map<String, String>{
						'name' => 'PROXY AUTHENTICATION REQUIRED',
						'message' => 'The client must first authenticate itself with the proxy.'
					},
					408 => new Map<String, String>{
						'name' => 'REQUEST TIMEOUT',
						'message' => 'The server timed out waiting for the request.'
					},
					409 => new Map<String, String>{
						'name' => 'CONFLICT',
						'message' => 'The request could not be processed because of conflict in the request.'
					},
					410 => new Map<String, String>{
						'name' => 'GONE',
						'message' => 'The resource requested is no longer available and will not be available again.'
					},
					411 => new Map<String, String>{
						'name' => 'LENGTH REQUIRED',
						'message' => 'The request did not specify the length of its content, which is required by the requested resource.'
					},
					412 => new Map<String, String>{
						'name' => 'PRECONDITION FAILED',
						'message' => 'The server does not meet one of the preconditions that the requester put on the request.'
					},
					413 => new Map<String, String>{
						'name' => 'PAYLOAD TOO LARGE',
						'message' => 'The request is larger than the server is willing or able to process.'
					},
					414 => new Map<String, String>{
						'name' => 'URI TOO LONG',
						'message' => 'The URI provided was too long for the server to process.'
					},
					415 => new Map<String, String>{
						'name' => 'UNSUPPORTED MEDIA TYPE',
						'message' => 'The request entity has a media type which the server or resource does not support.'
					},
					416 => new Map<String, String>{
						'name' => 'RANGE NOT SATISFIABLE',
						'message' => 'The client has asked for a portion of the file, but the server cannot supply that portion.'
					},
					417 => new Map<String, String>{
						'name' => 'EXPECTATION FAILED',
						'message' => 'The server cannot meet the requirements of the Expect request-header field.'
					},
					425 => new Map<String, String>{
						'name' => 'TOO EARLY',
						'message' => 'The server is unwilling to risk processing a request that might be replayed.'
					},
					426 => new Map<String, String>{
						'name' => 'UPGRADE REQUIRED',
						'message' => 'The client should switch to a different protocol.'
					},
					428 => new Map<String, String>{
						'name' => 'PRECONDITION REQUIRED',
						'message' => 'The origin server requires the request to be conditional.'
					},
					429 => new Map<String, String>{
						'name' => 'TOO MANY REQUESTS',
						'message' => 'The client has sent too many requests in a given amount of time.'
					},
					431 => new Map<String, String>{
						'name' => 'REQUEST HEADER FIELDS TOO LARGE',
						'message' => 'The server is unwilling to process the request because the header fields are too large.'
					},
					451 => new Map<String, String>{
						'name' => 'UNAVAILABLE FOR LEGAL REASONS',
						'message' => 'Resource access is denied for legal reasons.'
					},
					
					// server error responses
					500 => new Map<String, String>{
						'name' => 'INTERNAL SERVER ERROR',
						'message' => 'The server encountered an unexpected condition which prevented it from fulfilling the request.'
					},
					501 => new Map<String, String>{
						'name' => 'NOT IMPLEMENTED',
						'message' => 'The server either does not recognize the request method, or it lacks the ability to fulfill the request.'
					},
					502 => new Map<String, String>{
						'name' => 'BAD GATEWAY',
						'message' => 'The server was acting as a gateway or proxy and received an invalid response from the upstream server.'
					},
					503 => new Map<String, String>{
						'name' => 'SERVICE UNAVAILABLE',
						'message' => 'The server is currently unable to handle the request due to a temporary overloading or maintenance of the server.'
					},
					504 => new Map<String, String>{
						'name' => 'GATEWAY TIMEOUT',
						'message' => 'The server was acting as a gateway or proxy and did not receive a timely response from the upstream server.'
					},
					505 => new Map<String, String>{
						'name' => 'HTTP VERSION NOT SUPPORTED',
						'message' => 'The server does not support the HTTP protocol version used in the request.'
					},
					511 => new Map<String, String>{
						'name' => 'NETWORK AUTHENTICATION REQUIRED',
						'message' => 'The client needs to authenticate to gain network access.'
					},
					598 => new Map<String, String>{
						'name' => 'NETWORK READ TIMEOUT ERROR',
						'message' => 'A network read timeout occurred behind the proxy to a client in front of the proxy.'
					}
				};
			}
			return statusByCode;
		}
		private set;
	}

	//* Public methods

	public static Integer getCode(String name) {
		name = name.toUpperCase().replaceAll('[^A-Z]', '');
		for (Integer code : statusByCode.keySet()) {
			String status = statusByCode.get(code).get('name').replaceAll('[^A-Z]', '');
			// TODO: use equals here... or something better
			if (status.containsIgnoreCase(name)) {
				return code;
			}
		}
		return 0;
	}

	public static String getMessage(Integer code) {
		Map<String, String> result = statusByCode.get(code);
		if (result != null) {
			return result.get('message');
		}
		return getUnknownStatus(code).get('message');
	}

	public static String getName(Integer code) {
		Map<String, String> result = statusByCode.get(code);
		if (result != null) {
			return result.get('name');
		}
		return getUnknownStatus(code).get('name');
	}

	//* Private methods

	private static Map<String, String> getUnknownStatus(Integer value) {
		return new Map<String, String>{
			'name' => 'UNKNOWN STATUS: ' + String.valueOf(value),
			'message' => 'This is a non-standard response, possibly custom to the server\'s software.'
		};
	}

}
