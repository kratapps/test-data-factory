/**
 * Inspiration: https://docs.spring.io/spring-framework/docs/1.2.x/javadoc-api/org/springframework/util/Assert.html
 */
public virtual class Assert {
    public class AssertionException extends Exception {
    }
    
    protected Assert() {
    }

    public static Object fail(String message) {
        throw new Assert.AssertionException(cleanMessage(message));
    }

    public static void fail() {
        fail(null);
    }

    public static void isTrue(Boolean condition, String message) {
        if (!condition) {
            fail(message);
        }
    }

    public static void isTrue(Boolean condition) {
        isTrue(condition, null);
    }

    public static void isFalse(Boolean condition, String message) {
        isTrue(!condition, message);
    }

    public static void isFalse(Boolean condition) {
        isFalse(condition, null);
    }

    public static void isNull(Object obj, String message) {
        isTrue(obj == null, message);
    }

    public static void isNull(Object obj) {
        isNull(obj, null);
    }

    public static void notNull(Object obj, String message) {
        isTrue(obj != null, message);
    }

    public static void notNull(Object obj) {
        notNull(obj, null);
    }

    public static void isBlank(String obj, String message) {
        isTrue(String.isBlank(obj), message);
    }

    public static void isBlank(String obj) {
        isBlank(obj, null);
    }

    public static void notBlank(String obj, String message) {
        isTrue(String.isNotBlank(obj), message);
    }

    public static void notBlank(String obj) {
        notBlank(obj, null);
    }
    
    public static void isEqual(Object expected, Object actual, String message) {
        if (expected != actual) {
            failNotEqual(message, expected, actual);
        }
    }

    public static void isEqual(Object expected, Object actual) {
        isEqual(expected, actual, null);
    }

    public static void isEqual(Decimal expected, Decimal actual, Decimal delta, String message) {
        if (expected == actual) {
            return;
        }
        if (!(Math.abs(expected - actual) <= delta)) {
            failNotEqual(message, expected, actual);
        }
    }

    public static void isEqual(Decimal expected, Decimal actual, Decimal delta) {
        isEqual(expected, actual, delta, null);
    }

    public static void notEqual(Object expected, Object actual, String message) {
        if (expected == actual) {
            failEqual(message);
        }
    }

    public static void notEqual(Object expected, Object actual) {
        notEqual(expected, actual, null);
    }

    public static void isSame(Object expected, Object actual, String message) {
        if (expected !== actual) {
            failNotSame(message, expected, actual);
        }
    }

    public static void isSame(Object expected, Object actual) {
        isSame(expected, actual, null);
    }

    public static void notSame(Object expected, Object actual, String message) {
        if (expected === actual) {
            failSame(message);
        }
    }

    public static void notSame(Object expected, Object actual) {
        notSame(expected, actual, null);
    }
    
    public static void contains(String textToSearch, String substring, String message) {
        if (textToSearch == null || substring == null || !textToSearch.contains(substring)) {
            failNotContains(message, textToSearch, substring);
        }
    }

    public static void contains(String textToSearch, String substring) {
        contains(textToSearch, substring, null);
    }
    
    public static void notContains(String textToSearch, String substring, String message) {
        if (textToSearch == null || substring == null || textToSearch.contains(substring)) {
            failContains(message, textToSearch, substring);
        }
    }

    public static void notContains(String textToSearch, String substring) {
        notContains(textToSearch, substring, null);
    }
    
    private static String cleanMessage(String message) {
        return message == null ? '' : message;
    }

    @TestVisible
    private static String formatFailMessage(String message, Object expected, Object actual) {
        String formatted = '';

        if (message != null && !message.equals(' ')) {
            formatted = message + ' ';
        }

        String expectedString = String.valueOf(expected);
        String actualString = String.valueOf(actual);

        if (getObjectType(expected) != getObjectType(actual)) {
            return formatted + '\nexpected: '
                    + formatClassAndValue(expected, expectedString)
                    + '\nactual: ' + formatClassAndValue(actual, actualString);
        }
        return formatted + '\nexpected: ' + expectedString + '\nactual: ' + actualString;
    }

    private static String formatClassAndValue(Object value, String valueString) {
        String className = value == null ? 'null' : getObjectTypeString(value);
        return className + '<' + valueString + '>';
    }

    private static void failNotEqual(String message, Object expected, Object actual) {
        fail(formatFailMessage(message, expected, actual));
    }
    
    private static void failEqual(String message) {
        fail((message == null ? '' : message + ' ') + 'expected not equals');
    }

    private static void failNotSame(String message, Object expected, Object actual) {
        fail((message == null ? '' : message + ' ') + 'expected same:<' + expected + '> was not <' + actual + '>');
    }
    
    private static void failSame(String message) {
        fail((message == null ? '' : message + ' ') + 'expected not same');
    }

    private static void failNotContains(String message, String textToSearch, String substring) {
        fail((message == null ? '' : message + ' ') + 'expected <' + textToSearch + '> to contain <' + substring + '>');
    }

    private static void failContains(String message, String textToSearch, String substring) {
        fail((message == null ? '' : message + ' ') + 'expected <' + textToSearch + '> to not contain <' + substring + '>');
    }
    
    @TestVisible
    private static Type getObjectType(Object obj) {
        String typeString =  getObjectTypeString(obj);
        return typeString == null ? null : Type.forName(typeString);
    }

    @TestVisible
    private static String getObjectTypeString(Object obj){
        if (obj == null) {
            return null;
        }
        // Idea by Robert Strunk https://ideas.salesforce.com/s/idea/a0B8W00000GdY4zUAF
        String result = 'DateTime';
        try {
            Datetime typeCheck = (Datetime) obj;
        } catch(System.TypeException ex){
            result = ex.getMessage()
                    .substringAfter('Invalid conversion from runtime type ')
                    .substringBefore(' to Datetime');
        }
        return result;
    }
}