/**
 * Created on Fri Nov 27 2020
 *
 * Copyright (c) 2020 MJ12358
 * All rights reserved.

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

@IsTest
public class HttpMock implements System.HttpCalloutMock {

  private List<Mock> mocks;
  private Map<String, StaticResource> staticResourceByEndpoint;
  private Map<String, StaticResource> staticResourceByName;

  public HttpMock() {
    this.mocks = new List<Mock>{ new Mock() };
    this.staticResourceByEndpoint = new Map<String, StaticResource>();
    this.staticResourceByName = new Map<String, StaticResource>();
  }

  public HttpMock next() {
    this.mocks.add(new Mock());
    return this;
  }

  public HttpMock setBody(Blob body) {
    if (body != null && body.size() > 0) {
      getCurrent().setBodyAsBlob(body);
    }
    return this;
  }

  public HttpMock setBody(String body) {
    if (String.isNotBlank(body)) {
      getCurrent().setBody(body);
    }
    return this;
  }

  public HttpMock setBody(Map<String, Object> body) {
    if (body != null && !body.isEmpty()) {
      getCurrent().setBody(System.JSON.serialize(body));
    }
    return this;
  }

  public HttpMock setHeader(String key, Object value) {
    if (String.isNotBlank(key)) {
      getCurrent().setHeader(key, String.valueOf(value));
    }
    return this;
  }

  public HttpMock setHeader(Map<String, Object> values) {
    if (values != null && !values.isEmpty()) {
      for (String key : values.keySet()) {
        setHeader(key, values.get(key));
      }
    }
    return this;
  }

  public HttpMock setStatus(String value) {
    if (String.isNotBlank(value)) {
      getCurrent().setStatus(value);
      getCurrent().setStatusCode(HttpStatus.getCode(value));
    }
    return this;
  }

  public HttpMock setStatusCode(Integer value) {
    if (value != null) {
      getCurrent().setStatusCode(value);
      getCurrent().setStatus(HttpStatus.getName(value));
    }
    return this;
  }

  public HttpMock setStaticResource(String name) {
    try {
      StaticResource sr = this.staticResourceByName.get(name);
      if (sr == null) {
        sr = [SELECT Body FROM StaticResource WHERE Name = :name LIMIT 1];
        this.staticResourceByName.put(name, sr);
      }
      getCurrent().setBody(sr.Body.toString());
    } catch (System.QueryException e) {
      e.setMessage(String.format(System.Label.HttpResourceNameDoesNotExist, new String[]{name}));
      throw e;
    }
    return this;
  }

  public HttpMock setStaticResource(String endpoint, String name) {
    try {
      StaticResource sr = this.staticResourceByEndpoint.get(endpoint);
      if (sr == null) {
        // try to find by name
        sr = this.staticResourceByName.get(name);
        if (sr == null) {
          // when still null query it
          sr = [SELECT Body FROM StaticResource WHERE Name = :name LIMIT 1];
          this.staticResourceByName.put(name, sr);
        }
        this.staticResourceByEndpoint.put(endpoint, sr);
      }
      getCurrent().setBody(sr.Body.toString());
    } catch (System.QueryException e) {
      e.setMessage(String.format(System.Label.HttpResourceEndpointDoesNotExist, new String[]{name, endpoint}));
      throw e;
    }
    return this;
  }

  private System.HttpResponse getCurrent() {
    return this.mocks[this.mocks.size() - 1].response;
  }

/**
 *  The HttpCalloutMock abstract method
 *  Returns an HTTP response for the given request.
 *  The implementation of this method is called by the Apex runtime to send a fake
 *     response when an HTTP callout is made after Test.setMock has been called.
 */
  public System.HttpResponse respond(System.HttpRequest request) {
    try {
      System.HttpResponse response = this.mocks.remove(0).response;
      // TODO: get a static resource by the endpoint so multiple definitions are not necessary
      // TODO: need to set the response, not just the body...
      if (response.getBodyAsBlob() == null || response.getBodyAsBlob().size() <= 0) {
        StaticResource sr = this.staticResourceByEndpoint.get(request.getEndpoint());
        if (sr != null) {
          response.setBody(sr.Body.toString());
        }
      }
      return response;
    } catch (System.ListException e) {
      e.setMessage(String.format(System.Label.HttpNoMockCreated, new String[]{request.getEndpoint()}));
      throw e;
    }
  }

  private class Mock {

    public System.HttpResponse response;

    public Mock() {
      this.response = new System.HttpResponse();
      this.response.setBody('{"example":"test"}');
      this.response.setStatus('OK');
      this.response.setStatusCode(200);
    }

  }

}
