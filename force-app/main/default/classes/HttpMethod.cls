/**
 * Created on Tue Nov 26 2019
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

public enum HttpMethod {

/****
 * @CRUD = Create, Read, Update, Delete
 * @Features =
 *  Cacheable: A response that can be cached, retrieved and used at a later time.
 *  Idempotent: An identical request can be made several times with the same effect while leaving the server in the same state.
 *  Safe: Doesn't alter the state of the server, eg. a read-only operation
 ****/

/**
 * The CONNECT method establishes a tunnel to the server identified by the target resource.
 * @CRUD Read/Retrieve
 */
    CONNECT,

/**
 * The DELETE method deletes the specified resource.
 * @CRUD Delete
 * @Features Idempotent
 */
    DELETEX, // DELETE is a reserved word in apex

/**
 * The GET method requests a representation of the specified resource.
 * @CRUD Read/Retrieve
 * @Features Cacheable,Idempotent,Safe
 */
    GET,

/**
 * The HEAD method asks for a response identical to that of a GET request, but without the response body.
 * @CRUD Read/Retrieve
 * @Features Cacheable,Idempotent,Safe
 */
    HEAD,

/**
 * The OPTIONS method is used to describe the communication options for the target resource.
 * @CRUD Read/Retrieve
 * @Features Idempotent,Safe
 */
    OPTIONS,

/**
 * The PATCH method is used to apply partial modifications to a resource.
 * @CRUD Update
 */
    PATCH,

/**
 * The POST method is used to submit an entity to the specified resource, often causing a change in state or side effects on the server.
 * @CRUD Create
 * @Features Cacheable(only if freshness info is included)
 */
    POST,

/**
 * The PUT method replaces all current representations of the target resource with the request payload.
 * @CRUD Update
 * @Features Idempotent
 */
    PUT,

/**
 * The TRACE method performs a message loop-back test along the path to the target resource.
 * @CRUD Read/Retrieve
 * @Features Idempotent
 */
    TRACE

}
