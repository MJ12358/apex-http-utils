@IsTest
public class JwtBuilderTest {

	@IsTest
	static void testRS256() {
		String key = [SELECT Body FROM StaticResource WHERE Name = 'key_RS256'].Body.toString();
		Test.startTest();
		String result = new JwtBuilder(JwtBuilder.Algorithm.RS256)
			.audience('salesforce.com')
			.contentType('contentType')
			.expires(Datetime.now().addSeconds(3600))
			.notBefore(Datetime.now())
			.id('id')
			.subject('1234567890')
			.type('JWT')
			.claim('name', 'John Doe')
			.claim(new Map<String, Object>{'email' => 'test@test.com'})
			.issuedAt(Datetime.now())
			.key(key)
			.build();
		Test.stopTest();
		System.assert(String.isNotBlank(result));
	}

	@IsTest
	static void testHS256() {
		String key = [SELECT Body FROM StaticResource WHERE Name = 'key_HS256'].Body.toString();
		Test.startTest();
		String result = new JwtBuilder(JwtBuilder.Algorithm.HS256)
			.issuer('1234567890')
			.key(key)
			.build();
		Test.stopTest();
		System.assert(String.isNotBlank(result));
	}

	@IsTest
	static void testCertFailure() {
		Test.startTest();
		try {
			new JwtBuilder(JwtBuilder.Algorithm.RS256)
				.cert(null)
				.build();
			System.assert(false, 'Excepted an exception');
		} catch (JwtBuilder.JwtBuilderException e) {
			System.assert(true, 'Exception caught');
		}
		Test.stopTest();
	}

	@IsTest
	static void testKeyFailure() {
		Test.startTest();
		try {
			new JwtBuilder(JwtBuilder.Algorithm.RS256)
				.key(null)
				.build();
			System.assert(false, 'Excepted an exception');
		} catch (JwtBuilder.JwtBuilderException e) {
			System.assert(true, 'Exception caught');
		}
		Test.stopTest();
	}

	@IsTest
	static void testExpiresFailure() {
		Test.startTest();
		try {
			new JwtBuilder(JwtBuilder.Algorithm.RS256)
				.expires(Datetime.now().addSeconds(-3600))
				.build();
			System.assert(false, 'Excepted an exception');
		} catch (JwtBuilder.JwtBuilderException e) {
			System.assert(true, 'Exception caught');
		}
		Test.stopTest();
	}

}
