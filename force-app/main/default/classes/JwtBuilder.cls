/**
 * Created on Jan 10 2020
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

/**
 *	Heavily influnced by https://github.com/salesforceidentity/jwt
 */

public class JwtBuilder {

	// RFC 7519 (2015)
	// JSON Web Token is a compact, URL-safe means of transferring claims between two parties

	private Algorithm algorithm;
	private Map<String, Object> headerClaims;
	private Map<String, Object> payloadClaims;
	private Long now;
	private String certName;
	private String privateKey;

	public JwtBuilder() {
		this.headerClaims = new Map<String, Object>();
		this.payloadClaims = new Map<String, Object>();
		this.now = (Datetime.now().getTime() / 1000) + 1;
		// default claims
		issuedAt(this.now);
		notBefore(this.now);
		type('JWT');
	}

	public JwtBuilder(Algorithm algorithm) {
		this();
		sign(algorithm);
	}

	//* Header claims

	public JwtBuilder sign(Algorithm value) {
		if (value == null) {
			throw new JwtBuilderException(System.Label.JwtAlgorithmInvalid);
		}
		this.algorithm = value;
		this.headerClaims.put('alg', value.name());
		return this;
	}

	public JwtBuilder type(Object value) {
		if (value == null) {
			throw new JwtBuilderException(System.Label.JwtTypeInvalid);
		}
		this.headerClaims.put('typ', value);
		return this;
	}

	//* Payload claims

	public JwtBuilder audience(String value) {
		addClaim('aud', value);
		return this;
	}

	public JwtBuilder contentType(String value) {
		addClaim('cty', value);
		return this;
	}

	// exp must be a number
	public JwtBuilder expires(Datetime value) {
		return expires((value.getTime() / 1000) - this.now);
	}

	public JwtBuilder expires(Long value) {
		return expires((Integer)value);
	}

	public JwtBuilder expires(Integer value) {
		Long exp = this.now + value;
		if (this.now >= exp) {
			throw new JwtBuilderException(System.Label.JwtExpirationInvalid);
		}
		addClaim('exp', exp);
		return this;
	}

	public JwtBuilder id(String value) {
		addClaim('jti', value);
		return this;
	}

	// iat must be a number
	public JwtBuilder issuedAt(Datetime value) {
		return issuedAt(value.getTime() / 1000);
	}

	public JwtBuilder issuedAt(Long value) {
		return issuedAt((Integer)value);
	}

	public JwtBuilder issuedAt(Integer value) {
		addClaim('iat', value);
		return this;
	}

	public JwtBuilder issuer(String value) {
		addClaim('iss', value);
		return this;
	}

	// nbf value must be a number
	public JwtBuilder notBefore(Datetime value) {
		return notBefore(value.getTime() / 1000);
	}

	public JwtBuilder notBefore(Long value) {
		return notBefore((Integer)value);
	}

	public JwtBuilder notBefore(Integer value) {
		addClaim('nbf', value);
		return this;
	}

	public JwtBuilder subject(String value) {
		addClaim('sub', value);
		return this;
	}

	public JwtBuilder cert(String certDevName) {
		if (String.isBlank(certDevName)) {
			throw new JwtBuilderException(System.Label.JwtCertificateInvalid);
		}
		this.certName = certDevName;
		return this;
	}

	public JwtBuilder key(String keyContents) {
		if (String.isBlank(keyContents)) {
			throw new JwtBuilderException(System.Label.JwtPrivateKeyInvalid);
		}
		this.privateKey = keyContents
			.replace('-----BEGIN RSA PRIVATE KEY-----', '')
			.replace('-----END RSA PRIVATE KEY-----', '')
			.replace('\n', '');
		return this;
	}

	public JwtBuilder keyFromResource(String name) {
		if (String.isBlank(name)) {
			throw new JwtBuilderException(System.Label.JwtKeyResourceNameInvalid);
		}
		StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = :name LIMIT 1];
		return key(sr.Body.toString());
	}

	//* Generic claim methods

	public JwtBuilder claim(String name, Object value) {
		addClaim(name, value);
		return this;
	}

	public JwtBuilder claim(Map<String, Object> values) {
		if (values != null) {
			for (String key : values.keySet()) {
				addClaim(key, values.get(key));
			}
		}
		return this;
	}

	//* Build

	public String build() {
		String encodedHeader = '';
		String encodedPayload = '';
		Blob signature = null;

		// generate the jwt header
		System.JSONGenerator header = System.JSON.createGenerator(false);
		header.writeStartObject();
		for (String claim : headerClaims.keySet()) {
			header.writeObjectField(claim, headerClaims.get(claim));
		}
		header.writeEndObject();
		encodedHeader = base64URLencode(Blob.valueOf(header.getAsString()));

		// generate the jwt payload
		System.JSONGenerator payload = System.JSON.createGenerator(false);
		payload.writeStartObject();
		for (String claim : payloadClaims.keySet()) {
			payload.writeObjectField(claim, payloadClaims.get(claim));
		}
		payload.writeEndObject();
		encodedPayload = base64URLencode(Blob.valueOf(payload.getAsString()));

		// generate the jwt body
		Blob body = Blob.valueOf(String.format('{0}.{1}',
			new List<String>{
				encodedHeader,
				encodedPayload
			}
		));

		switch on this.algorithm {
			// HMAC with SHA-256
			when HS256 {
				if (String.isBlank(this.privateKey)) {
					throw new JwtBuilderException(System.Label.JwtHS256PrivateKeyInvalid);
				}
				Blob key = System.EncodingUtil.base64Decode(this.privateKey);
				signature = System.Crypto.generateMac('hmacSHA256', body, key);
			}
			// RSASSA-PKCS1-v1_5 with SHA-256
			when RS256 {
				if (String.isNotBlank(this.certName)) {
					signature = System.Crypto.signWithCertificate('rsa-sha256', body, this.certName);
				} else if (String.isNotBlank(this.privateKey)) {
					Blob key = System.EncodingUtil.base64Decode(this.privateKey);
					signature = System.Crypto.sign('rsa-sha256', body, key);
				} else {
					throw new JwtBuilderException(System.Label.JwtRS256CertOrKeyInvalid);
				}
			}
			when else {
				// no algorithm was given so nothing to do
				//	this is valid if the server does not require signing
			}
		}

		return String.format('{0}.{1}.{2}',
			new List<String>{
				encodedHeader,
				encodedPayload,
				base64URLencode(signature)
			}
		);
	}

	public String getBody() {
		return String.format('grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion={0}',
			new List<String>{
				build()
			}
		);
	}

	public String getAccessToken(String endpoint) {
		HttpBuilder builder = new HttpBuilder()
			.endpoint(endpoint)
			.body(getBody())
			.method(HttpMethod.POST)
			.header('Content-Type', 'application/x-www-form-urlencoded')
			.send();
		Response response = (Response)System.JSON.deserialize(builder.getBody(), Response.class);
		return response.access_token;
	}

	//* Private methods
	
	private void addClaim(String name, Object value) {
		if (String.isBlank(name)) {
			throw new JwtBuilderException(System.Label.JwtClaimNameInvalid);
		}
		if (value == null) {
			this.payloadClaims.remove(name);
		} else {
			this.payloadClaims.put(name, value);
		}
	}

	private String base64URLencode(Blob input) {
		if (input == null || input.size() == 0) {
			return '';
		}
		String output = System.EncodingUtil.base64Encode(input);
		output = output.replace('+', '-');
		output = output.replace('/', '_');
		while (output.endsWith('=')) {
			output = output.substring(0, output.length() - 1);
		}
		return output;
	}

/**
 *	A generic class used to parse the response from a bearer
 */
	private class Response {
		public String access_token;
	}

/**
 *	An emum to represent the algorithm used to sign the jwt
 */
	public enum Algorithm {
		HS256,
		RS256
	}
}
