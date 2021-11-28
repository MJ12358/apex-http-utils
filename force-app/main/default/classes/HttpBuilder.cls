/**
 * Created on Thur Nov 14 2019
 *
 * Copyright (c) 2019 Matt Jants
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

public with sharing class HttpBuilder {

	private System.HttpRequest request;
	private System.HttpResponse response;
	private Map<String, String> cookieByKey;
	private Map<String, String> headerByKey;
	private Boolean cachex = false;
	private String cachePrefix = 'local.httpbuilder';
	private Integer cacheTTL = 7200; // seconds
	private Boolean debug = false;
	private Integer maxRetries = 3;
	private Boolean retry = false;
	private Integer retryCounter = 0;
	private Integer retryDelay = 1000; // milliseconds
	private Integer timeout = 10000; // milliseconds

	public HttpBuilder() {
		this(new System.HttpRequest());
	}

	public HttpBuilder(System.HttpRequest request) {
		if (System.getApplicationReadWriteMode() == ApplicationReadWriteMode.READ_ONLY) {
			throw new HttpBuilderException(System.Label.http_ReadOnly);
		}
		this.request = request;
		this.cookieByKey = new Map<String, String>();
		this.headerByKey = new Map<String, String>();
	}

/**
 *	Http methods as defined by RFC 5789 (2010)
 */

	//* delete

	public HttpBuilder deletex() {
		return method('DELETE');
	}

	//* get

	public HttpBuilder get() {
		return method(HttpMethod.GET);
	}

	//* patch

	public HttpBuilder patch() {
		return method(HttpMethod.PATCH);
	}

	public HttpBuilder patch(Blob body) {
		if (body.size() > 0) {
			this.request.setBodyAsBlob(body);
		}
		return patch();
	}

	public HttpBuilder patch(Dom.Document body) {
		if (body.toXmlString().length() > 0) {
			this.request.setBodyDocument(body);
		}
		return patch();
	}

	public HttpBuilder patch(String body) {
		if (String.isNotBlank(body)) {
			this.request.setBody(body);
		}
		return patch();
	}

	public HttpBuilder patch(Map<String, Object> body) {
		return patch(System.JSON.serialize(body));
	}

	//* post

	public HttpBuilder post() {
		return method(HttpMethod.POST);
	}

	public HttpBuilder post(Blob body) {
		if (body.size() > 0) {
			this.request.setBodyAsBlob(body);
		}
		return post();
	}

	public HttpBuilder post(Dom.Document body) {
		if (body.toXmlString().length() > 0) {
			this.request.setBodyDocument(body);
		}
		return post();
	}

	public HttpBuilder post(String body) {
		if (String.isNotBlank(body)) {
			this.request.setBody(body);
		}
		return post();
	}

	public HttpBuilder post(Map<String, Object> body) {
		return post(System.JSON.serialize(body));
	}

	//* put

	public HttpBuilder put() {
		return method(HttpMethod.PUT);
	}

	public HttpBuilder put(Blob body) {
		if (body.size() > 0) {
			this.request.setBodyAsBlob(body);
		}
		return put();
	}

	public HttpBuilder put(Dom.Document body) {
		if (body.toXmlString().length() > 0) {
			this.request.setBodyDocument(body);
		}
		return put();
	}

	public HttpBuilder put(String body) {
		if (String.isNotBlank(body)) {
			this.request.setBody(body);
		}
		return put();
	}

	public HttpBuilder put(Map<String, Object> body) {
		return put(System.JSON.serialize(body));
	}

	//* generic

	public HttpBuilder method(HttpMethod method) {
		if (method == null) {
			throw new HttpBuilderException(System.Label.http_MethodNull);
		}
		return method(method.name());
	}

	public HttpBuilder method(String method) {
		if (String.isBlank(method)) {
			throw new HttpBuilderException(System.Label.http_MethodInvalid);
		}
		this.request.setMethod(method);
		return this;
	}

	//* Request methods

	public HttpBuilder body(Blob body) {
		if (body.size() > 0) {
			this.request.setBodyAsBlob(body);
		}
		return this;
	}

	public HttpBuilder body(Map<String, Object> body) {
		return body(System.JSON.serialize(body));
	}

	public HttpBuilder body(String body) {
		if (String.isNotBlank(body)) {
			this.request.setBody(body);
		}
		return this;
	}

	public HttpBuilder body(Dom.Document body) {
		if (body.toXmlString().length() > 0) {
			this.request.setBodyDocument(body);
		}
		return this;
	}

	public HttpBuilder body(Object body) {
		if (body != null) {
			if (body instanceof String) {
				body((String)body);
			} else if (body instanceof Blob) {
				body((Blob)body);
			} else if (body instanceof Map<String, Object>) {
				body((Map<String, Object>)body);
			} else if (body instanceof Dom.Document) {
				body((Dom.Document)body);
			}
		}
		return this;
	}

	//* cache

	public HttpBuilder cache() {
		this.cachex = true;
		return this;
	}

	public HttpBuilder cache(Object value) {
		if (value == null) {
			throw new HttpBuilderException(System.Label.http_CacheInvalid);
		}
		Integer ttl = Integer.valueOf(value);
		if (ttl < 300 || ttl > 172800) {
			throw new HttpBuilderException(System.Label.http_CacheInvalid);
		}
		this.cacheTTL = ttl;
		cache();
		return this;
	}

	//* cert

	public HttpBuilder cert(String certDevName) {
		if (String.isNotBlank(certDevName)) {
			this.request.setClientCertificateName(certDevName);
		}
		return this;
	}

	//* compress

	public HttpBuilder compress() {
		return compress(true);
	}

	public HttpBuilder compress(Boolean value) {
		if (value != null) {
			this.request.setCompressed(value);
			if (value) {
				header('Accept-Encoding', 'gzip');
				header('Content-Encoding', 'gzip');
			}
		}
		return this;
	}

	//* debug

	public HttpBuilder debug() {
		return debug(true);
	}

	public HttpBuilder debug(Boolean value) {
		if (value != null) {
			this.debug = value;
		}
		return this;
	}

	//* endpoint

	public HttpBuilder endpoint(String endpoint) {
		if (String.isBlank(endpoint)) {
			throw new HttpBuilderException(System.Label.http_EndpointInvalid);
		}
		this.request.setEndpoint(endpoint);
		return this;
	}

	public HttpBuilder endpoint(String namedCredential, String endpoint) {
		if (String.isBlank(namedCredential) || String.isBlank(endpoint)) {
			throw new HttpBuilderException(System.Label.http_EndpointInvalid);
		}
		return endpoint('callout:' + namedCredential + '/' + endpoint);
	}

	//* header

	public HttpBuilder header(String key, Object value) {
		if (String.isBlank(key)) {
			throw new HttpBuilderException(System.Label.http_HeaderKeyInvalid);
		}
		// TODO: remove a header when value is set to null
		if (value != null) {
			this.request.setHeader(key, String.valueOf(value));
			// because of limitations of the System.HttpRequest class we need to store these ourselves
			this.headerByKey.put(key, String.valueOf(value));
		}
		return this;
	}

	public HttpBuilder header(Map<String, Object> values) {
		if (values != null) {
			for (String key : values.keySet()) {
				header(key, values.get(key));
			}
		}
		return this;
	}

	//* cookie

	public HttpBuilder cookie(String key, Object value) {
		if (String.isBlank(key)) {
			throw new HttpBuilderException(System.Label.http_CookieKeyInvalid);
		}
		// TODO: remove a cookie when value is set to null
		if (value != null) {
			List<String> results = new List<String>();
			this.cookieByKey.put(key, String.valueOf(value));
			for (String cookieKey : this.cookieByKey.keySet()) {
				// cookies are formatted as "key=value"
				String cookie = String.format('{0}={1}',
					new List<Object>{
						cookieKey,
						cookieByKey.get(cookieKey)
					}
				);
				results.add(cookie);
			}
			// each cookie (when multiple exist) should be separated by "; "
			header('Cookie', String.join(results, '; '));
		}
		return this;
	}

	public HttpBuilder cookie(Map<String, Object> values) {
		if (values != null) {
			for (String key : values.keySet()) {
				cookie(key, values.get(key));
			}
		}
		return this;
	}

	//* timeout

	public HttpBuilder timeout(Object value) {
		if (value == null) {
			throw new HttpBuilderException(System.Label.http_TimeoutInvalid);
		}
		Integer timeout = Integer.valueOf(value);
		if (timeout < 1 || timeout > 120000) {
			throw new HttpBuilderException(System.Label.http_TimeoutInvalid);
		}
		this.timeout = timeout;
		this.request.setTimeout(timeout);
		return this;
	}

	//* delay

	public HttpBuilder delay(Object value) {
		if (value == null) {
			throw new HttpBuilderException(System.Label.http_DelayInvalid);
		}
		Integer interval = Integer.valueOf(value);
		if (interval < 1 || interval > 5000) {
			throw new HttpBuilderException(System.Label.http_DelayInvalid);
		}
		this.retryDelay = interval;
		return this;
	}

	//* retry

	public HttpBuilder retry() {
		this.retry = true;
		return this;
	}

	public HttpBuilder retry(Object value) {
		if (value == null) {
			throw new HttpBuilderException(System.Label.http_RetryCountInvalid);
		}
		Integer count = Integer.valueOf(value);
		if (count < 1 || count > 10) {
			throw new HttpBuilderException(System.Label.http_RetryCountInvalid);
		}
		this.maxRetries = count;
		retry();
		return this;
	}

	//* Request returns

	public Map<String, String> getRequestHeaders() {
		return this.headerByKey;
	}

	public System.HttpRequest getRequest() {
		return this.request;
	}

	//* Response returns

	public String getHeader(String header) {
		checkResponse();
		for (String key : this.response.getHeaderKeys()) {
			if (key == header) {
				return this.response.getHeader(key);
			}
		}
		return null;
	}

	public Map<String, String> getHeaders() {
		checkResponse();
		Map<String, String> results = new Map<String, String>();
		for (String key : this.response.getHeaderKeys()) {
			results.put(key, this.response.getHeader(key));
		}
		return results;
	}

	public String getBase64() {
		checkResponse();
		return System.EncodingUtil.base64Encode(this.response.getBodyAsBlob());
	}

	public String getBody() {
		checkResponse();
		return this.response.getBody();
	}

	public Blob getBlob() {
		checkResponse();
		return this.response.getBodyAsBlob();
	}

	public Dom.Document getDom() {
		checkResponse();
		return this.response.getBodyDocument();
	}

	public String getStatus() {
		checkResponse();
		return this.response.getStatus();
	}

	public Integer getStatusCode() {
		checkResponse();
		return this.response.getStatusCode();
	}

	public System.XmlStreamReader getXml() {
		checkResponse();
		return this.response.getXmlStreamReader();
	}

	public System.HttpResponse getResponse() {
		return this.response;
	}

	//* Build and/or send

	public System.HttpRequest build() {
		return this.request;
	}

	public HttpBuilder send() {

		if (this.cachex && hasCache()) {
			Object value = Cache.Org.get(getCacheString());
			if (value != null) {
				this.response = new System.HttpResponse();
				this.response.setBody((String)value);
				debugThis();
				return this;
			}
		}

		System.Http http = new System.Http();

		// salesforce throws a callout exception
		try {
			this.response = http.send(this.request);
		} catch (System.CalloutException e) {
			throw new HttpBuilderException(e.getMessage());
		}

		// validate response also throws a callout exception
		try {
			validateResponse();
		} catch (System.CalloutException e) {
			if (String.isNotBlank(e.getMessage()) && e.getMessage().containsIgnoreCase('timeout')) {
				retryCallout();
			} else {
				throw e;
			}
		} finally {
			debugThis();
		}

		if (this.cachex && hasCache()) {
			Cache.Org.put(getCacheString(), getBody(), this.cacheTTL);
		}

		return this;
	}

/**
 *	Validate status codes as defined by RFC 2616 (1999) and RFC 7231 (2014)
 */
	private void validateResponse() {
		Integer statusCode = this.response.getStatusCode();

		// anything that is not a 1xx or 2xx
		if (!Pattern.matches('[1-2]\\d{2}', String.valueOf(statusCode))) {
			String message = HttpStatus.getMessage(statusCode);

			// 300 status codes are redirect codes
			if (Pattern.matches('3\\d{2}', String.valueOf(statusCode))) {
				switch on statusCode {
					when 301, 302, 303, 307 {
						redirectCallout();
						return;
					}
					when 304 { // this one includes many more headers....
						String header = getHeader('Date');
						message += header != null ? ' Date: ' + header : '';
					}
				}

			// 400 status codes are client errors
			} else if (Pattern.matches('4\\d{2}', String.valueOf(statusCode))) {
				switch on statusCode {
					when 401 {
						String header = getHeader('WWW-Authenticate');
						message += header != null ? ' Challenge: ' + header : '';
					}
					when 405 {
						message += ' Method: ' + this.request.getMethod();
					}
					when 406 {
						String header = getHeader('Accept');
						message += header != null ? ' Accept: ' + header : '';
					}
					when 407 {
						String header = getHeader('Proxy-Authenticate');
						message += header != null ? ' Challenge: ' + header : '';
					}
					when 408, 409, 425 {
						retryCallout();
						return;
					}
					when 416 {
						String header = getHeader('Content-Range');
						message += header != null ? ' Range: ' + header : '';
					}
					when 429 {
						// TODO: gather backoff interval
					}
				}

			// 500 status codes are server errors
			} else if (Pattern.matches('5\\d{2}', String.valueOf(statusCode))) {
				switch on statusCode {
					when 502, 503, 504, 598, 599 {
						retryCallout();
						return;
					}
				}
			}

			if (String.isBlank(this.response.getStatus())) {
				this.response.setStatus(message);
			}

			throw new System.CalloutException(formatMessage(message));
		}
	}

	//* Retries

	private void redirectCallout() {
		// BUG: this does not work with named credentials...
		checkLimits();
		String newEndpoint = getHeader('Location');
		if (String.isBlank(newEndpoint)) {
			throw new HttpBuilderException(System.Label.http_RedirectionInvalid);
		}
		endpoint(newEndpoint);
		send();
	}

	private void retryCallout() {
		checkLimits();
		if (this.retry && this.retryCounter < this.maxRetries) {
			sleep(this.retryDelay * ++this.retryCounter);
			timeout(this.timeout + 1000);
			send();
		} else {
			throw new HttpBuilderException(System.Label.http_RetryLimitReached);
		}
	}

	//* Utility methods

	private Boolean hasCache() {
		try {
			// use a fake key to determine if the org has platform cache enabled
			Cache.Org.get(this.cachePrefix + '.0');
		} catch (Cache.Org.OrgCacheException e) {
			// TODO: determine whether logging or throwing is good
			//	when throwing, tests must be able to handle this
			// throw new HttpBuilderException(System.Label.http_CacheUnavailable);
			System.debug(System.LoggingLevel.WARN, System.Label.http_CacheUnavailable);
			return false;
		}
		return true;
	}

	private void checkLimits() {
		if (System.Limits.getCallouts() >= System.Limits.getLimitCallouts()) {
			throw new HttpBuilderException(System.Label.http_CalloutLimitReached);
		}
		if (System.Limits.getCpuTime() >= System.Limits.getLimitCpuTime()) {
			throw new HttpBuilderException(System.Label.http_CpuLimitReached);
		}
	}

	private void checkResponse() {
		if (this.response == null) {
			throw new HttpBuilderException(System.Label.http_CheckResponse);
		}
	}

	private void debugThis() {
		if (this.debug) {
			// TODO: implement an HttpLog object
			// Log.viaEvent(this.request, this.response);
		}
	}

	private String getCacheString() {
		// this is an easy way to get all query parameters
		PageReference pageRef = new PageReference(this.request.getEndpoint());
		// now sanitize them (exclude things like apikey and password)
		System.Pattern pattern = System.Pattern.compile(System.Label.http_SanitizeCachedUrl);
		for (String key : pageRef.getParameters().keySet()) {
			System.Matcher matcher = pattern.matcher(key);
			if (matcher.find()) {
				pageRef.getParameters().remove(key);
			}
		}
		// cache keys can only contain alphanumeric chars
		return String.format('{0}.{1}',
			new List<String>{
				this.cachePrefix,
				pageRef.getUrl().replaceAll('[^a-zA-Z0-9]', '').right(50)
			}
		);
	}

	private String formatMessage(String msg) {
		return String.format(System.Label.http_Message,
			new List<Object>{
				this.response.getStatusCode(),
				this.response.getStatus(),
				msg
			}
		);
	}

	private void sleep(Integer milliseconds) {
		Long startTime = Datetime.now().getTime();
		Long endTime = Datetime.now().getTime();
		while ((endTime - startTime) < milliseconds) {
			endTime = Datetime.now().getTime();
		}
	}
}
