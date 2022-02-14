/**
 * Created on Sep 30 2019
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

public class UriBuilder {

	//* [scheme:]//[userinfo@][host][:port]/[path][?query][#fragment]

	private String baseUri;
	private String scheme;
	private String userinfo;
	private String host;
	private Integer port;
	private List<Object> paths;
	private Map<String, Object> queries;
	private String fragment;
	private String charset;
	private Boolean encode = false;

	public UriBuilder() {
		this.paths = new List<String>();
		this.queries = new Map<String, Object>();
	}

	public UriBuilder(String baseUri) {
		this();
		base(baseUri);
	}

	//* Public methods

	public UriBuilder base(String baseUri) {
		this.baseUri = baseUri;
		return this;
	}

	public UriBuilder scheme(String scheme) {
		this.scheme = scheme;
		return this;
	}

	public UriBuilder userinfo(String userinfo) {
		this.userinfo = userinfo;
		return this;
	}

	public UriBuilder host(String host) {
		this.host = host;
		return this;
	}

	public UriBuilder port(Integer port) {
		if (port != null) {
			if (port < 1 || port > 65535) {
				throw new UriBuilderException(System.Label.UriPortInvalid);
			}
			this.port = port;
		}
		return this;
	}

	public UriBuilder path(Object value) {
		if (value != null && String.isNotBlank(String.valueOf(value))) {
			this.paths.add(value);
		}
		return this;
	}

	public UriBuilder path(List<Object> values) {
		if (values != null) {
			for (Object value : values) {
				path(value);
			}
		}
		return this;
	}

	public UriBuilder query(String key, Object value) {
		if (String.isNotBlank(key)) {
			if (value != null && String.isNotBlank(String.valueOf(value))) {
				this.queries.put(key, value);
			} else {
				this.queries.remove(key);
			}
		}
		return this;
	}

	public UriBuilder query(Map<String, Object> values) {
		if (values != null) {
			for (String key : values.keySet()) {
				query(key, values.get(key));
			}
		}
		return this;
	}

	public UriBuilder fragment(String value) {
		this.fragment = value;
		return this;
	}

	public UriBuilder encode() {
		return encode('UTF-8');
	}

	public UriBuilder encode(String charset) {
		if (String.isBlank(charset)) {
			throw new UriBuilderException(System.Label.UriCharsetInvalid);
		}
		this.encode = true;
		this.charset = charset;
		return this;
	}

	//* Build the uri

	public String build() {
		Integer count = 0;
		String result = '';

		if (String.isNotBlank(this.baseUri)) {
			result = this.baseUri;
		} else {
			if (String.isNotBlank(this.scheme)) {
				result += this.scheme + ':';
			}
			if (String.isNotBlank(this.host)) {
				result += '//';
				if (String.isNotBlank(this.userinfo)) {
					result += this.userinfo + '@';
				}
				result += this.host;
				if (this.port != null) {
					result += ':' + String.valueOf(this.port);
				}
			}
		}

		// build paths
		for (Object path : this.paths) {
			result += '/' + String.valueOf(path);
		}

		// build queries eg. ?key=value or &key=value
		for (String key : this.queries.keySet()) {
			String value = String.valueOf(this.queries.get(key));
			result += String.format('{0}{1}={2}',
				new List<String>{
					getDelimiter(count),
					key,
					this.encode ? urlEncode(value) : value
				}
			);
			count++;
		}

		// add fragment
		if (String.isNotBlank(this.fragment)) {
			result += '#' + this.fragment;
		}

		// Most web servers limit to 8192
		//	Internet Explorer cap is 2083
		//	the spec [RFC7230] "recommends" support for a minimum of 8000
		if (result.length() > 8192) {
			throw new UriBuilderException(System.Label.UriLengthExceeded);
		}

		return result;
	}

	//* Private methods

	private String getDelimiter(Integer count) {
		return count == 0 ? '?' : '&';
	}

	// TODO: verify these are correct
	private String urlEncode(String value) {
		return System.EncodingUtil.urlEncode(value, this.charset)
			.replaceAll('\\+', '%20')
			.replaceAll('\\*', '%2A')
			.replaceAll('\\%7E', '~');
	}
}
