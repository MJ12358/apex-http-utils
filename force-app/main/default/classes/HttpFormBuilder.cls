/**
 * Created on Feb 14 2020
 *
 * Copyright (c) 2020 MJ12358
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
 *  Huge thanks to @Gup3rSuR4c on stackoverflow for the bulk of this code
 *    All I did was wrap it in a fluent api pattern
 *  https://salesforce.stackexchange.com/questions/132135/how-can-i-compose-a-multipart-form-data-request
 */

public class HttpFormBuilder {
  
  // The boundary is alligned so it doesn't produce padding characters when base64 encoded
  private final String BOUNDARY = '1ff13444ed8140c7a32fc4e6451aa76d';
  private final String CRLF = '\r\n';
  private final String CR = '\r';
  private final String LF = '\n';
  private String body = '';
  private Map<String, Object> params = new Map<String, Object>();

  //* Public methods

  public HttpFormBuilder put(String key, Object value) {
    if (String.isBlank(key)) {
      throw new HttpFormBuilderException(System.Label.HttpFormKeyInvalid);
    }
    if (value == null) {
      throw new HttpFormBuilderException(System.Label.HttpFormValueInvalid);
    }
    this.body += writeBoundary();
    this.body += writeBodyParameter(key, String.valueOf(value));
    this.params.put(key, value);
    return this;
  }

  public HttpFormBuilder put(String key, String file64, String filename) {
    if (String.isBlank(key)) {
      throw new HttpFormBuilderException(System.Label.HttpFormKeyInvalid);
    }
    if (String.isBlank(file64)) {
      throw new HttpFormBuilderException(System.Label.HttpFormFileInvalid);
    }
    if (String.isBlank(filename)) {
      throw new HttpFormBuilderException(System.Label.HttpFormFilenameInvalid);
    }
    this.body += writeBoundary();
    this.body += writeBodyParameter(key, file64, filename);
    this.params.put(key, file64);
    return this;
  }

  public HttpFormBuilder put(String key, Blob fileBlob, String filename) {
    String file64 = System.EncodingUtil.base64Encode(fileBlob);
    return put(key, file64, filename);
  }

  public Object get(String key) {
    return this.params.get(key);
  }

  public Blob build() {
    this.body += writeBoundary(EndingType.CrLf);
    return System.EncodingUtil.base64Decode(this.body);
  }

  public String getContentDisposition(String key) {
    return 'Content-Disposition: form-data; name="' + key + '"';
  }

  public String getContentType() {
    return 'multipart/form-data; charset="UTF-8"; boundary="' + BOUNDARY + '"';
  }

  //* Private methods

/**
 *  Write a boundary between parameters to the form's body.
 */
  private String writeBoundary() {
    String value = '--' + BOUNDARY + this.CRLF;
    Blob valueBlob = Blob.valueOf(value);
    return System.EncodingUtil.base64Encode(valueBlob);
  }

/**
 *  Write a boundary at the end of the form's body.
 */
  private String writeBoundary(EndingType ending) {
    String value = '';

    if (ending == EndingType.Cr) {
      //  The file's base64 was padded with a single '=',
      //  so it was replaced with '\r'. Now we have to
      //  prepend the boundary with '\n' to complete
      //  the line break.
      value += this.LF;
    } else if (ending == EndingType.None) {
      //  The file's base64 was not padded at all,
      //  so we have to prepend the boundary with
      //  '\r\n' to create the line break.
      value += this.CRLF;
    }
    //  Else:
    //  The file's base64 was padded with a double '=',
    //  so they were replaced with '\r\n'. We don't have to
    //  do anything to the boundary because there's a complete
    //  line break before it.

    value += '--' + BOUNDARY + '--';

    Blob valueBlob = Blob.valueOf(value);

    return System.EncodingUtil.base64Encode(valueBlob);
  }

/**
 *  Write a key-value pair to the form's body.
 */
  private String writeBodyParameter(String key, String value) {
    String contentDisposition = getContentDisposition(key);
    String contentDispositionCrLf = contentDisposition + this.CRLF + this.CRLF;
    Blob contentDispositionCrLfBlob = Blob.valueOf(contentDispositionCrLf);
    String contentDispositionCrLf64 = System.EncodingUtil.base64Encode(contentDispositionCrLfBlob);
    String content = safelyPad(contentDisposition, contentDispositionCrLf64, this.CRLF + this.CRLF);
    String valueCrLf = value + this.CRLF;
    Blob valueCrLfBlob = Blob.valueOf(valueCrLf);
    String valueCrLf64 = System.EncodingUtil.base64Encode(valueCrLfBlob);

    content += safelyPad(value, valueCrLf64, this.CRLF);

    return content;
  }
  
/**
 *  Write a key-value pair to the form's body for a file.
 */
  private String writeBodyParameter(String key, String file64, String filename) {
    
    // TODO: mimeType
    // String mimeType = FileUtil.getMimeType(filename);
    String mimeType = 'text/plain';
    
    String contentDisposition = getContentDisposition(key) + '; filename="' + filename + '"';
    String contentDispositionCrLf = contentDisposition + this.CRLF;
    Blob contentDispositionCrLfBlob = Blob.valueOf(contentDispositionCrLf);
    String contentDispositionCrLf64 = System.EncodingUtil.base64Encode(contentDispositionCrLfBlob);
    String content = safelyPad(contentDisposition, contentDispositionCrLf64, this.CRLF);
    
    String contentTypeHeader = 'Content-Type: ' + mimeType;
    String contentTypeCrLf = contentTypeHeader + this.CRLF + this.CRLF;
    Blob contentTypeCrLfBlob = Blob.valueOf(contentTypeCrLf);
    String contentTypeCrLf64 = System.EncodingUtil.base64Encode(contentTypeCrLfBlob);
    content += safelyPad(contentTypeHeader, contentTypeCrLf64, this.CRLF + this.CRLF);
    
    Integer file64Length = file64.length();
    String last4Bytes = file64.substring(file64.length() - 4, file64.length());

    // Avoid padding the file data with spaces, which safelyPad does
    // http://salesforce.stackexchange.com/a/33326/102
    EndingType ending = EndingType.None;
    if (last4Bytes.endsWith('==')) {
      // The '==' sequence indicates that the last group contained only one 8 bit byte
      // 8 digit binary representation of CR is 00001101
      // 8 digit binary representation of LF is 00001010
      // Stitch them together and then from the right split them into 6 bit chunks
      // 0000110100001010 becomes 0000 110100 001010
      // Note the first 4 bits 0000 are identical to the padding used to encode the
      // second original 6 bit chunk, this is handy it means we can hard code the response in
      // The decimal values of 110100 001010 are 52 10
      // The base64 mapping values of 52 10 are 0 K
      // See http://en.wikipedia.org/wiki/Base64 for base64 mapping table
      // Therefore, we replace == with 0K
      // Note: if using \n\n instead of \r\n replace == with '0K'
      last4Bytes = last4Bytes.substring(0, 2) + '0K';
      file64 = file64.substring(0, file64.length() - 4) + last4Bytes;
      // We have appended the \r\n to the Blob, so leave footer as it is.
      ending = EndingType.CrLf;
    } else if (last4Bytes.endsWith('=')) {
      // '=' indicates that encoded data already contained two out of 3x 8 bit bytes
      // We replace final 8 bit byte with a CR e.g. \r
      // 8 digit binary representation of CR is 00001101
      // Ignore the first 2 bits of 00 001101 they have already been used up as padding
      // for the existing data.
      // The Decimal value of 001101 is 13
      // The base64 value of 13 is N
      // Therefore, we replace = with N
      last4Bytes = last4Bytes.substring(0, 3) + 'N';
      file64 = file64.substring(0, file64.length() - 4) + last4Bytes;
      // We have appended the CR e.g. \r, still need to prepend the line feed to the footer
      ending = EndingType.Cr;
    }
            
    content += file64;
    
    content += writeBoundary(ending);
    return content;
  }

/**
 *  Pad the value with spaces until the base64 encoding is no longer padded.
 */
  private String safelyPad(String value, String valueCrLf64, String lineBreaks) {
    String valueCrLf = '';
    Blob valueCrLfBlob = null;

    while (valueCrLf64.endsWith('=')) {
      value += ' ';
      valueCrLf = value + lineBreaks;
      valueCrLfBlob = Blob.valueOf(valueCrLf);
      valueCrLf64 = System.EncodingUtil.base64Encode(valueCrLfBlob);
    }

    return valueCrLf64;
  }

/**
 *  Helper enum indicating how a file's base64 padding was replaced.
 */
  private enum EndingType {
    Cr,
    CrLf,
    None
  }
}