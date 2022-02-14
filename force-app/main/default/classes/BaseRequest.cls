/**
 * Created on Apr 27 2020
 *
 * Copyright (c) 2020 Matt Jants
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

public virtual class BaseRequest {

	private Object cacheTtl; // seconds
	private Boolean debug;
	private Map<String, Object> headers;
	private Object timeout; // milliseconds
	private UriBuilder uriBuilder;

	public BaseRequest(String requestUrl) {
		this.headers = new Map<String, Object>();
		this.uriBuilder = new UriBuilder(requestUrl);
	}

	//* Validation

	protected virtual void validateRequest() {}

	protected virtual void validateResponse(System.HttpResponse response) {}

	//* Request methods

	@TestVisible
	protected virtual System.HttpResponse send(String method) {
		return send(method, null);
	}

	@TestVisible
	protected virtual System.HttpResponse send(HttpMethod method) {
		return send(method.name(), null);
	}

	@TestVisible
	protected virtual System.HttpResponse send(HttpMethod method, Object objectx) {
		return send(method.name(), objectx);
	}

	@TestVisible
	protected virtual System.HttpResponse send(String method, Object objectx) {
		validateRequest();
		HttpBuilder builder = new HttpBuilder();
		try {
			builder.endpoint(buildRequestUrl())
				.body(objectx)
				.cache(getCacheTtl())
				.debug(getDebug())
				.header(getHeaders())
				.method(method)
				.timeout(getTimeout())
				.send();
		} catch (HttpBuilderException e) {
			throw new HttpException(e.getMessage());
		} catch (System.CalloutException e) {
			throw new HttpException(builder.getRequest(), builder.getResponse());
		} finally {
			validateResponse(builder.getResponse());
		}
		return builder.getResponse();
	}

	//* Request Url get/build

	@TestVisible
	protected String getRequestUrl() {
		return this.uriBuilder.build();
	}

	@TestVisible
	protected String getRequestUrl(String urlPath) {
		addPath(urlPath);
		return getRequestUrl();
	}

	@TestVisible
	protected void setRequestUrl(String requestUrl) {
		if (String.isNotBlank(requestUrl)) {
			this.requestUrl = requestUrl;
		}
	}

	//* Getters/Setters

	// cache

	@TestVisible
	protected virtual Object getCacheTtl() {
		return this.cacheTtl;
	}

	@TestVisible
	protected void setCacheTTL(Object value) {
		this.cacheTtl = value;
	}

	// debug

	@TestVisible
	protected virtual Boolean getDebug() {
		return this.debug;
	}

	@TestVisible
	protected void setDebug(Boolean value) {
		if (value != null) {
			this.debug = value;
		}
	}

	// timeout

	@TestVisible
	protected virtual Object getTimeout() {
		return this.timeout;
	}

	@TestVisible
	protected void setTimeout(Object value) {
		this.timeout = value;
	}

	//* Utility methods

	@TestVisible
	protected virtual void addHeader(String key, Object value) {
		if (String.isNotBlank(key)) {
			if (value != null && String.isNotBlank(String.valueOf(value))) {
				this.headers.put(key, value);
			} else {
				this.headers.remove(key);
			}
		}
	}

	@TestVisible
	protected virtual void addPath(Object value) {
		this.uriBuilder.path(value);
	}

	@TestVisible
	protected virtual void addQuery(String key, Object value) {
		this.uriBuilder.query(key, value);
	}

	@TestVisible
	protected virtual Map<String, Object> getHeaders() {
		return this.headers;
	}

	@TestVisible
	protected virtual String serialize(Object objectx) {
		return System.JSON.serialize(objectx, true);
	}

}
