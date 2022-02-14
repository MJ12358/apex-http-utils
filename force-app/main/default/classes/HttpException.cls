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

public virtual class HttpException extends Exception {

	private System.HttpRequest request;
	private System.HttpResponse response;

	public HttpException(System.HttpRequest request, System.HttpResponse response) {
		System.debug(String.format('REQUEST:\n{0}\nRESPONSE:\n{1}',
			new List<Object>{
				request,
				response
			}
		));
		this.request = request;
		this.response = response;
	}

	public virtual String getContext() {
		return this.getTypeName();
	}

	public virtual String getErrorMessage() {
		return System.Label.HttpException;
	}

	public override String getMessage() {
		if (this.response == null) {
			return String.format('{0}: {1}',
				new List<Object>{
					getContext(),
					super.getMessage()
				}
			);
		}
		return String.format('{0}{1} : {2}({3}) : {4}',
			new List<Object>{
				getContext(),
				this.request != null ? '/' + this.request.getEndpoint().substringAfterLast('/').substringBefore('?') : '',
				this.response.getStatus(),
				this.response.getStatusCode(),
				getErrorMessage()
			}
		);
	}

	public System.HttpRequest getRequest() {
		return this.request;
	}

	public System.HttpResponse getResponse() {
		return this.response;
	}

	public virtual String getDebugMessage() {
		return String.format('CONTEXT: {0}\nMESSAGE: {1}\nENDPOINT: {2}\nREQUEST BODY: {3}\nRESPONSE BODY: {4}\nSTATUS: {5}\nSTATUS CODE: {6}',
			new List<Object>{
				getContext(),
				getErrorMessage(),
				this.request != null ? this.request.getEndpoint() : '',
				this.request != null ? this.request.getBody().abbreviate(8192) : '',
				this.response != null ? this.response.getBody().abbreviate(8192) : '',
				this.response != null ? this.response.getStatus() : '',
				this.response != null ? this.response.getStatusCode() : 0
			}
		);
	}

}
