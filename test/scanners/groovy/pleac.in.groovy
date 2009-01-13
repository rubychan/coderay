// -*- groovy -*-
// The examples make use of Groovy's built-in assert
// command so that the script is self-checking

// @@PLEAC@@_NAME
// @@SKIP@@ Groovy

// @@PLEAC@@_WEB
// @@SKIP@@ http://groovy.codehaus.org

// @@PLEAC@@_1.0
//----------------------------------------------------------------------------------
string = '\\n'                    // two characters, \ and an n
assert string.size() == 2
string = "\n"                     // a "newline" character
string = '\n'                     // a "newline" character

string = "Jon 'Maddog' Orwant"    // literal single quote inside double quotes
string = 'Jon \'Maddog\' Orwant'  // escaped single quotes

string = 'Jon "Maddog" Orwant'    // literal double quotes inside single quotes
string = "Jon \"Maddog\" Orwant"  // escaped double quotes

string = '''
This is a multiline string declaration
using single quotes (you can use double quotes)
'''
//----------------------------------------------------------------------------------

// @@PLEAC@@_1.1
//----------------------------------------------------------------------------------
// accessing substrings
string = 'hippopotamus'
start = 5; end = 7; endplus1 = 8
assert string.substring(start, endplus1) == 'pot'
assert string[start..end] == 'pot'

assert string.substring(start) == 'potamus'
assert string[start..-1] == 'potamus'

// String is immutable but new strings can be created in various ways
assert string - 'hippo' - 'mus' + 'to' == 'potato'
assert string.replace('ppopotam','bisc') == 'hibiscus'
assert string.substring(0, 2) + 'bisc' + string[-2..-1] == 'hibiscus'
// StringBuffer is mutable
sb = new StringBuffer(string)
sb[2..-3] = 'bisc'
assert sb.toString() == 'hibiscus'

// No exact pack/unpack equivalents exist in Groovy. Examples here use a custom
// implementation to split an original string into chunks of specified length
// the method is a modified version of the Java PLEAC version

// get a 5-character string, skip 8, then grab 2 5-character strings
// skipping the trailing spaces, then grab the rest
data = 'hippopotamus means river horse'
def fields = unpack('A5 x8 A5 x1 A5 x1 A*', data)
assert fields == ['hippo', 'means', 'river', 'horse']

// On a Java 5 or 6 JVM, Groovy can also make use of Scanners:
s = new Scanner(data)
s.findInLine(/(.{5}).{8}(.{5}) (.{5}) (.*)/)
m = s.match()
fields = []
(1..m.groupCount()).each{ fields << m.group(it) }
assert fields == ['hippo', 'means', 'river', 'horse']

// another scanner example similar to the javadoc example
input = '1 fish 2 fish red fish blue fish'
s = new Scanner(input).useDelimiter(/\s*fish\s*/)
fields = []
2.times{ fields << s.nextInt() }
2.times{ fields << s.next() }
assert fields == [1, 2, 'red', 'blue']

// split at five characters boundaries
String[] fivers = unpack('A5 ' * (data.length() / 5), data)
assert fivers == ["hippo", "potam", "us me", "ans r", "iver ", "horse"]

// chop string into individual characters
assert 'abcd' as String[] == ['a', 'b', 'c', 'd']

string = "This is what you have"
// Indexing forwards  (left to right)
// tens   000000000011111111112
// units +012345678901234567890
// Indexing backwards (right to left)
// tens   221111111111000000000
// units  109876543210987654321-

assert string[0]          == 'T'
assert string[5..6]       == 'is'
assert string[13..-1]     == 'you have'
assert string[-1]         == 'e'
assert string[-4..-1]     == 'have'
assert string[-8, -7, -6] == 'you'

data = new StringBuffer(string)
data[5..6] = "wasn't"       ; assert data.toString() == "This wasn't what you have"
data[-12..-1] = "ondrous"   ; assert data.toString() == "This wasn't wondrous"
data[0..0] = ""             ; assert data.toString() == "his wasn't wondrous"
data[-10..-1]  = ""         ; assert data.toString() == "his wasn'"

string = "This wasn't wondrous"
// check last ten characters match some pattern
assert string[-10..-1] =~ /^t\sw.*s$/

string = 'This is a test'
assert string[0..4].replaceAll('is', 'at') + string[5..-1] == 'That is a test'

// exchange the first and last letters in a string
string = 'make a hat'
string = string[-1] + string[1..-2] + string[0]
assert string == 'take a ham'

// extract column with unpack
string = 'To be or not to be'

// skip 6, grab 6
assert unpack("x6 A6", string) == ['or not']

// forward 6, grab 2, backward 5, grab 2
assert unpack("x6 A2 X5 A2", string) == ['or', 'be']

assert cut2fmt([8, 14, 20, 26, 30]) == 'A7 A6 A6 A6 A4 A*'

// utility method (derived from Java PLEAC version)
def unpack(String format, String data) {
    def result = []
    int formatOffset = 0, dataOffset = 0
    int minDataOffset = 0, maxDataOffset = data.size()

    new StringTokenizer(format).each{ token ->
        int tokenLen = token.length()

        // count determination
        int count = 0
        if (tokenLen == 1) count = 1
        else if (token.charAt(1) == '*') count = -1
        else count = token[1..-1].toInteger()

        // action determination
        char action = token.charAt(0)
        switch (action) {
            case 'A':
                if (count == -1) {
                    start = [dataOffset, maxDataOffset].min()
                    result.add(data[start..-1])
                    dataOffset = maxDataOffset
                } else {
                    start = [dataOffset, maxDataOffset].min()
                    end = [dataOffset + count, maxDataOffset].min()
                    result.add(data[start..<end])
                    dataOffset += count
                }
                break
            case 'x':
                if (count == -1) dataOffset = maxDataOffset
                else dataOffset += count
                break
            case 'X':
                if (count == -1) dataOffset = minDataOffset
                else dataOffset -= count
                break
            default:
                throw new RuntimeException('Unknown action token', formatOffset)
        }
        formatOffset += tokenLen + 1
    }
    return result as String[]
}

// utility method
def cut2fmt(positions) {
    template = ''
    lastpos = 1
    for (pos in positions) {
        template += 'A' + (pos - lastpos) + ' '
        lastpos = pos
    }
    return template + 'A*'
}
//----------------------------------------------------------------------------------

// @@PLEAC@@_1.2
//----------------------------------------------------------------------------------
// use b if b is true, else c
b = false; c = 'cat'
assert (b ? b : c) == 'cat'
b = true
assert (b ? b : c)
// can be simplified to 'b || c' if c is a boolean
// strictly speaking, b doesn't have to be a boolean,
// e.g. an empty list is coerced to boolean false
b = []
assert (b ? b : c) == 'cat'

// set x to y unless x is already true
x = false; y = 'dog'
if (!x) x = y
assert x == 'dog'
// can be simplified to 'x ||= y' if y is a boolean
// x doesn't need to be a boolean, e.g. a non-empty
// string is coerced to boolean true
x = 'cat'
if (!x) x = y
assert x == 'cat'

// JVM supplies user name
// otherwise could use exec or built-in Ant features for reading environment vars
assert System.getProperty('user.name')

// test for nullity then for emptyness
def setDefaultIfNullOrEmpty(startingPoint) {
    (!startingPoint || startingPoint.length() == 0) ? 'Greenwich' : startingPoint
}
assert setDefaultIfNullOrEmpty(null) == 'Greenwich'
assert setDefaultIfNullOrEmpty('') == 'Greenwich'
assert setDefaultIfNullOrEmpty('Something else') == 'Something else'
//----------------------------------------------------------------------------------

// @@PLEAC@@_1.3
//----------------------------------------------------------------------------------
v1 = 'alpha'; v2 = 'omega'
// this can done with explicit swapping via a temp variable
// or in a slightly more interesting way with a closure
swap = { temp = v1; v1 = v2; v2 = temp }
swap()
assert v1 == 'omega' && v2 == 'alpha'
// a more generic swap() is also possible using Groovy's metaclass mechanisms
// but is not idiomatic of Groovy usage
//----------------------------------------------------------------------------------

// @@PLEAC@@_1.4
//----------------------------------------------------------------------------------
// char and int are interchangable, apart from precision difference
// char use 16 bits while int use 32, requiring a cast from int to char
char ch = 'e'
int num = ch         // no problem
ch = (char) num  // needs an explicit cast

s1 = "Number " + num + " is character " + (char) num
assert s1 == 'Number 101 is character e'
s2 = "Character " + ch + " is number " + (int) ch
assert s2 == 'Character e is number 101'

// easy conversion between char arrays, char lists and Strings
char[] ascii = "sample".toCharArray() // {115, 97, 109, 112, 108, 101}
assert new String(ascii) == "sample"
assert new String([115, 97, 109, 112, 108, 101] as char[]) == "sample"

// convert 'HAL' to 'IBM' (in increasing order of Grooviness)
assert "HAL".toCharArray().collect{new String(it+1 as char[])}.join() == 'IBM'
assert ("HAL" as String[]).collect{it.next()}.join() == 'IBM'
assert "HAL".replaceAll('.', {it.next()}) == 'IBM'
//----------------------------------------------------------------------------------

// @@PLEAC@@_1.5
//----------------------------------------------------------------------------------
string = "an apple a day"
assert string[3..7].split('')[1..5] == ['a', 'p', 'p', 'l', 'e']
assert string.split('').toList().unique().sort().join() == ' adelnpy'

//----------------------------------------------------------------------------------
// CheckSum.groovy: Compute 16-bit checksum of input file
// Usage: groovy CheckSum <file>
// script:
checksum = 0
new File(args[0]).eachByte{ checksum += it }
checksum %= (int) Math.pow(2, 16) - 1
println checksum
//----------------------------------------------------------------------------------
// to run on its own source code:
//=> % groovy CheckSum CheckSum.groovy
//=> 9349
//----------------------------------------------------------------------------------
// Slowcat.groovy: Emulate a  s l o w  line printer
// Usage: groovy Slowcat <file> <delay_millis_between_each_char>
// script:
delay = args[1].toInteger()
new File(args[0]).eachByte{ print ((char) it); Thread.sleep(delay) }
//----------------------------------------------------------------------------------

// @@PLEAC@@_1.6
//----------------------------------------------------------------------------------
assert 'string'.reverse() == 'gnirts'

string = 'Yoda said, "can you see this?"'
revwords = string.split(' ').toList().reverse().join(' ')
assert revwords == 'this?" see you "can said, Yoda'

words = ['bob', 'alpha', 'rotator', 'omega', 'reviver']
long_palindromes = words.findAll{ w -> w == w.reverse() && w.size() > 5 }
assert long_palindromes == ['rotator', 'reviver']
//----------------------------------------------------------------------------------

// @@PLEAC@@_1.7
//----------------------------------------------------------------------------------
s1 = 'abc\t def\tghi \n\tx'
s2 = 'abc      def    ghi \n        x'
def expand(s) {
    s.split('\n').toList().collect{
        line = it
        while (line.contains('\t')) {
            line = line.replaceAll(/([^\t]*)(\t)(.*)/){
                all,pre,tab,suf -> pre + ' ' * (8 - pre.size() % 8) + suf
            }
        }
        return line
    }.join('\n')
}
def unexpand(s) {
    s.split('\n').toList().collect{
        line = it
        for (i in line.size()-1..1) {
            if (i % 8 == 0) {
                prefix = line[0..<i]
                if (prefix.trim().size() != prefix.size()) {
                    line = prefix.trim() + '\t' + line[i..-1]
                }
            }
        }
        return line
    }.join('\n')
}
assert expand(s1) == s2
assert unexpand(s2) == s1
//----------------------------------------------------------------------------------

// @@PLEAC@@_1.8
//----------------------------------------------------------------------------------
debt = 150
assert "You owe $debt to me" == 'You owe 150 to me'

rows = 24; cols = 80
assert "I am $rows high and $cols wide" == 'I am 24 high and 80 wide'

assert 'I am 17 years old'.replaceAll(/\d+/, {2*it.toInteger()}) == 'I am 34 years old'
//----------------------------------------------------------------------------------

// @@PLEAC@@_1.9
//----------------------------------------------------------------------------------
assert "bo peep".toUpperCase() == 'BO PEEP'
assert 'JOHN'.toLowerCase() == 'john'
def capitalize(s) {s[0].toUpperCase() + (s.size()<2 ? '' : s[1..-1]?.toLowerCase())}
assert capitalize('joHn') == 'John'

s = "thIS is a loNG liNE".replaceAll(/\w+/){capitalize(it)}
assert s == 'This Is A Long Line'

s1 = 'JOhn'; s2 = 'joHN'
assert s1.equalsIgnoreCase(s2)

private Random rand
def randomCase(char ch) {
    (rand.nextInt(100) < 20) ? Character.toLowerCase(ch) : ch
}
//----------------------------------------------------------------------------------

// @@PLEAC@@_1.10
//----------------------------------------------------------------------------------
n = 10
assert "I have ${n+1} guanacos." == 'I have 11 guanacos.'
assert "I have " + (n+1) + " guanacos." == 'I have 11 guanacos.'

// sending templated email is solved in two parts: templating and sending
// Part 1: creating an email template
naughty = 'Mr Bad Credit'
def get_manager_list(s) { 'The Big Boss' }
msg = """
To: $naughty
From: Your Bank
Cc: ${ get_manager_list(naughty) }
Date: ${ new Date() }

Dear $naughty,

Today, you bounced check number ${ 500 + new Random().nextInt(100) } to us.
Your account is now closed.

Sincerely,
the management
"""
expected = '''
To: Mr Bad Credit
From: Your Bank
Cc: The Big Boss
Date: XXX

Dear Mr Bad Credit,

Today, you bounced check number XXX to us.
Your account is now closed.

Sincerely,
the management
'''
sanitized = msg.replaceAll('(?m)^Date: (.*)$','Date: XXX')
sanitized = sanitized.replaceAll(/(?m)check number (\d+) to/,'check number XXX to')
assert sanitized == expected
// note: Groovy also has several additional built-in templating facilities
// Part 2: sending email
// SendMail.groovy: Send email
// Usage: groovy SendEmail <msgfile>
// script:
ant = new AntBuilder()
ant.mail(from:'manager@grumpybank.com', tolist:'innocent@poorhouse.com',
    encoding:'plain', mailhost:'mail.someserver.com',
    subject:'Friendly Letter', message:'this is a test message')
// Ant has many options for setting encoding, security, attachments, etc., see:
// http://ant.apache.org/manual/CoreTasks/mail.html
// Groovy could also use the Java Mail Api directly if required
//----------------------------------------------------------------------------------

// @@PLEAC@@_1.11
//----------------------------------------------------------------------------------
def raw = '''
    your text
    goes here
'''

def expected = '''
your text
goes here
'''

assert raw.split('\n').toList().collect{
    it.replaceAll(/^\s+/,'')
}.join('\n') + '\n' == expected
//----------------------------------------------------------------------------------

// @@PLEAC@@_1.12
//----------------------------------------------------------------------------------
input = '''Folding and splicing is the work of an editor,
 not a mere collection of silicon
 and
 mobile electrons!'''

expected = '''Folding and splicing
is the work of an
editor, not a mere
collection of
silicon and mobile
electrons!'''

def wrap(text, maxSize) {
    all = []
    line = ''
    text.eachMatch(/\S+/) {
        word = it[0]
        if (line.size() + 1 + word.size() > maxSize) {
            all += line
            line = word
        } else {
            line += (line == '' ? word : ' ' + word)
        }
    }
    all += line
    return all.join('\n')
}
assert wrap(input, 20) == expected
//----------------------------------------------------------------------------------

// @@PLEAC@@_1.13
//----------------------------------------------------------------------------------
string = /Mom said, "Don't do that."/
// backslash special chars
assert string.replaceAll(/['"]/){/\\/+it[0]} == /Mom said, \"Don\'t do that.\"/   //'
// double special chars
assert string.replaceAll(/['"]/){it[0]+it[0]} == /Mom said, ""Don''t do that.""/  //'
//backslash quote all non-capital letters
assert "DIR /?".replaceAll(/[^A-Z]/){/\\/+it[0]} == /DIR\ \/\?/
//----------------------------------------------------------------------------------

// @@PLEAC@@_1.14
//----------------------------------------------------------------------------------
assert '     x     '.trim() == 'x'
// print what's typed, but surrounded by >< symbols
// script:
new BufferedReader(new InputStreamReader(System.in)).eachLine{
    println(">" + it.trim() + "<");
}
//----------------------------------------------------------------------------------

// @@PLEAC@@_1.15
//----------------------------------------------------------------------------------
pattern = /"([^\"\\]*(?:\\.[^\"\\]*)*)",?|([^,]+),?|,/
line = /XYZZY,"","O'Reilly, Inc","Wall, Larry","a \"glug\" bit,",5,"Error, Core Dumped"/
m = line =~ pattern
expected = [/XYZZY/, '', /O'Reilly, Inc/, /Wall, Larry/,     //'
            /a \"glug\" bit,/, /5/, /Error, Core Dumped/]
for (i in 0..<m.size().toInteger())
    assert expected[i] == (m[i][2] ? m[i][2] : m[i][1])

//----------------------------------------------------------------------------------

// @@PLEAC@@_1.16
//----------------------------------------------------------------------------------
// A quick google search found several Java implementations.
// As an example, how to use commons codec is shown below.
// Just place the respective jar in your classpath.
// Further details: http://jakarta.apache.org/commons/codec
// require(groupId:'commons-codec', artifactId:'commons-codec', version:'1.3')
soundex = new org.apache.commons.codec.language.Soundex()
assert soundex.soundex('Smith') == soundex.soundex('Smyth')
//----------------------------------------------------------------------------------

// @@PLEAC@@_1.17
//----------------------------------------------------------------------------------
input = '''I have analysed the new part. As long as you
aren't worried about the colour, it is a dropin replacement.'''        //'

expected = '''I have analyzed the new part. As long as you
aren't worried about the color, it is a drop-in replacement.'''        //'

translations = [colour:'color', analysed:'analyzed', dropin:'drop-in']

def fixstyle(s) {
    s.split('\n').toList().collect{
        line = it
        translations.each{ key, value ->
            line = line.replaceAll(/(?<=\W)/ + key + /(?=\W)/, value)
        }
        return line
    }.join('\n')
}
assert fixstyle(input) == expected
//----------------------------------------------------------------------------------

// @@PLEAC@@_1.18
//----------------------------------------------------------------------------------
// Solved in two parts: 'screenscrape' text stream and return stream from process
// Part 1: text scraping
input = '''
      PID    PPID    PGID     WINPID  TTY  UID    STIME COMMAND
     4636       1    4636       4636  con 1005 08:24:50 /usr/bin/bash
      676    4636     676        788  con 1005 13:53:32 /usr/bin/ps
'''
select1 = '''
      PID    PPID    PGID     WINPID  TTY  UID    STIME COMMAND
      676    4636     676        788  con 1005 13:53:32 /usr/bin/ps
'''
select2 = '''
      PID    PPID    PGID     WINPID  TTY  UID    STIME COMMAND
     4636       1    4636       4636  con 1005 08:24:50 /usr/bin/bash
'''

// line below must be configured for your unix - this one's cygwin
format = cut2fmt([10, 18, 26, 37, 42, 47, 56])
def psgrep(s) {
    out = []
    lines = input.split('\n').findAll{ it.size() }
    vars = unpack(format, lines[0]).toList().collect{ it.toLowerCase().trim() }
    out += lines[0]
    lines[1..-1].each{
        values = unpack(format, it).toList().collect{
            try {
                return it.toInteger()
            } catch(NumberFormatException e) {
                return it.trim()
            }
        }
        vars.eachWithIndex{ var, i ->
            binding.setVariable(var, values[i])
        }
        if (new GroovyShell(binding).evaluate(s)) out += it
    }
    return '\n' + out.join('\n') + '\n'
}
assert psgrep('winpid < 800') == select1
assert psgrep('uid % 5 == 0 && command =~ /sh$/') == select2
// Part 2: obtaining text stream from process
// unixScript:
input = 'ps'.execute().text
// cygwinScript:
input = 'path_to_cygwin/bin/ps.exe'.execute().text
// windowsScript:
// can use something like sysinternal.com s pslist (with minor script tweaks)
input = 'pslist.exe'.execute().text
//----------------------------------------------------------------------------------

// @@PLEAC@@_2.1
//----------------------------------------------------------------------------------
// four approaches possible (shown for Integers, similar for floats, double etc.):
// (1) NumberFormat.getInstance().parse(s)    // getInstance() can take locale
// (2) Integer.parseInt(s)
// (3) new Integer(s)
// (4) regex
import java.text.*
int nb = 0
try {
    nb = NumberFormat.getInstance().parse('33.5') // '.5' will be ignored
    nb = NumberFormat.getInstance().parse('abc')
} catch (ParseException ex) {
    assert ex.getMessage().contains('abc')
}
assert nb == 33

try {
    nb = Integer.parseInt('34')
    assert nb == 34
    nb = new Integer('35')
    nb = Integer.parseInt('abc')
} catch (NumberFormatException ex) {
    assert ex.getMessage().contains('abc')
}
assert nb == 35

integerPattern = /^[+-]?\d+$/
assert '-36' =~ integerPattern
assert !('abc' =~ integerPattern)
decimalPattern = /^-?(?:\d+(?:\.\d*)?|\.\d+)$/
assert '37.5' =~ decimalPattern
//----------------------------------------------------------------------------------

// @@PLEAC@@_2.2
//----------------------------------------------------------------------------------
// Groovy defaults to BigDecimal if you don't use an explicit float or double
wage = 5.36
week = 40 * wage
assert "One week's wage is: \$$week" == /One week's wage is: $214.40/
// if you want to use explicit doubles and floats you can still use
// printf in version 5, 6 or 7 JVMs
// printf('%5.2f', week as double)
// => 214.40
//----------------------------------------------------------------------------------

// @@PLEAC@@_2.3
//----------------------------------------------------------------------------------
a = 0.255
b = a.setScale(2, BigDecimal.ROUND_HALF_UP);
assert a.toString() == '0.255'
assert b.toString() == '0.26'

a = [3.3 , 3.5 , 3.7, -3.3] as double[]
// warning rint() rounds to nearest integer - slightly different to Perl's int()
rintExpected = [3.0, 4.0, 4.0, -3.0] as double[]
floorExpected = [3.0, 3.0, 3.0, -4.0] as double[]
ceilExpected = [4.0, 4.0, 4.0, -3.0] as double[]
a.eachWithIndex{ val, i ->
    assert Math.rint(val) == rintExpected[i]
    assert Math.floor(val) == floorExpected[i]
    assert Math.ceil(val) == ceilExpected[i]
}
//----------------------------------------------------------------------------------

// @@PLEAC@@_2.4
//----------------------------------------------------------------------------------
assert Integer.parseInt('0110110', 2) == 54
assert Integer.toString(54, 2) == '110110'
// also works for other radix values, e.g. hex
assert Integer.toString(60, 16) == '3c'

//----------------------------------------------------------------------------------

// @@PLEAC@@_2.5
//----------------------------------------------------------------------------------
x = 3; y = 20
for (i in x..y) {
    //i is set to every integer from x to y, inclusive
}

(x..<y).each {
    //implicit closure variable it is set to every integer from x up to but excluding y
}

assert (x..y).step(7) == [3, 10, 17]

years = []
(5..<13).each{ age -> years += age }
assert years == [5, 6, 7, 8, 9, 10, 11, 12]
//----------------------------------------------------------------------------------

// @@PLEAC@@_2.6
//----------------------------------------------------------------------------------
// We can add additional methods to the Integer class
class IntegerCategory {
    static def romanMap = [1000:'M', 900:'CM', 500:'D', 400:'CD', 100:'C', 90:'XC',
                           50:'L', 40:'XL', 10:'X', 9:'IX', 5:'V', 4:'IV', 1:'I']

    static getRoman(Integer self) {
        def remains = self
        def text = ''
        romanMap.keySet().sort().reverse().each{ key ->
            while (remains >= key) {
                remains -= key
                text += romanMap[key]
            }
        }
        return text
    }

    static int parseRoman(Object self, String input) {
        def ustr = input.toUpperCase()
        int sum = 0
        romanMap.keySet().sort().reverse().each{ key ->
            while (ustr.startsWith(romanMap[key])) {
                sum += key
                ustr -= romanMap[key]
            }
        }
        return sum
    }
}

use(IntegerCategory) {
    int fifteen = 15
    assert fifteen.roman == 'XV'
    assert parseRoman('XXVI') == 26
    for (i in 1..3900) {
        assert i == parseRoman(i.roman)
    }
}
//----------------------------------------------------------------------------------

// @@PLEAC@@_2.7
//----------------------------------------------------------------------------------
random = new Random()
100.times{
    next = random.nextInt(50) + 25
    assert next > 24
    assert next < 76
}
chars = []
['A'..'Z','a'..'z','0'..'9',('!@$%^&*' as String[]).toList()].each{chars += it}
password = (1..8).collect{ chars[random.nextInt(chars.size())] }.join()
assert password.size() == 8
//----------------------------------------------------------------------------------

// @@PLEAC@@_2.8
//----------------------------------------------------------------------------------
// By default Groovy uses Java's Random facilities which use the current time
// as the initial seed. This always changes but does so slowly over time.
// You are free to select a better seed if you want greater randomness or
// use the same one each time if you need repeatability.
long seed = System.currentTimeMillis()
random1 = new Random(seed)
random2 = new Random(seed)
assert random1.nextInt() == random2.nextInt()
//----------------------------------------------------------------------------------

// @@PLEAC@@_2.9
//----------------------------------------------------------------------------------
// java.util.Random which Groovy uses already uses a 48-bit seed
// You can make use 64 not 48 bits (and make better use of the 48 bits) see here:
// http://alife.co.uk/nonrandom/
// You can choose a better seed, e.g. Ant uses:
seed = System.currentTimeMillis() + Runtime.runtime.freeMemory()
// You can accept input from the user, e.g.
// http://examples.oreilly.com/javacrypt/files/oreilly/jonathan/util/Seeder.java
//----------------------------------------------------------------------------------

// @@PLEAC@@_2.10
//----------------------------------------------------------------------------------
// use Java's Random.nextGaussian() method
random = new Random()
mean = 25
sdev = 2
salary = random.nextGaussian() * sdev + mean
// script:
printf 'You have been hired at \$%.2f', salary
// => You have been hired at $25.05
//----------------------------------------------------------------------------------

// @@PLEAC@@_2.11
//----------------------------------------------------------------------------------
// radians = Math.toRadians(degrees)
assert Math.toRadians(90) == Math.PI / 2
// degrees = Math.toDegrees(radians)
assert Math.toDegrees(Math.PI) == 180
//----------------------------------------------------------------------------------

// @@PLEAC@@_2.12
//----------------------------------------------------------------------------------
// use Java's trigonometry methods in java.lang.Math
//----------------------------------------------------------------------------------
t = Math.tan(1.5)
assert t > 14.1 && t < 14.11
ac = Math.acos(0.1)
assert ac > 1.47 && ac < 1.48
//----------------------------------------------------------------------------------

// @@PLEAC@@_2.13
//----------------------------------------------------------------------------------
assert Math.log(Math.E) == 1
assert Math.log10(10000) == 4
def logn(base, val) { Math.log(val)/Math.log(base) }
assert logn(2, 1024) == 10
//----------------------------------------------------------------------------------

// @@PLEAC@@_2.14
//----------------------------------------------------------------------------------
// there are several Java Matrix packages available, e.g.
// http://math.nist.gov/javanumerics/jama
import Jama.Matrix
matrix1 = new Matrix([
   [3, 2, 3],
   [5, 9, 8]
] as double[][])

matrix2 = new Matrix([
   [4, 7],
   [9, 3],
   [8, 1]
] as double[][])

expectedArray = [[54.0, 30.0], [165.0, 70.0]] as double[][]
productArray = matrix1.times(matrix2).array

for (i in 0..<productArray.size()) {
    assert productArray[i] == expectedArray[i]
}
//----------------------------------------------------------------------------------

// @@PLEAC@@_2.15
//----------------------------------------------------------------------------------
// there are several Java Complex number packages, e.g.:
// http://jakarta.apache.org/commons/math/userguide/complex.html
import org.apache.commons.math.complex.Complex
a = new Complex(3, 5)  // 3 + 5i
b = new Complex(2, -2) // 2 - 2i
expected = new Complex (16, 4) // 16 + 4i
assert expected == a * b
//----------------------------------------------------------------------------------

// @@PLEAC@@_2.16
//----------------------------------------------------------------------------------
assert Integer.parseInt('101', 16) == 257
assert Integer.parseInt('077', 8) == 63
//----------------------------------------------------------------------------------
// conversionScript:
print 'Gimme a number in decimal, octal, or hex: '
reader = new BufferedReader(new InputStreamReader(System.in))
input = reader.readLine().trim()
switch(input) {
    case ~'^0x\\d+':
        number = Integer.parseInt(input.substring(2), 16); break
    case ~'^0\\d+':
        number = Integer.parseInt(input.substring(1), 8); break
    default:
        number = Integer.parseInt(input)
}
println 'Decimal value: ' + number

// permissionScript:
print 'Enter file permission in octal: '
input = new BufferedReader(new InputStreamReader(System.in))
num = input.readLine().trim()
permission = Integer.parseInt(num, 8)
println 'Decimal value: ' + permission
//----------------------------------------------------------------------------------

// @@PLEAC@@_2.17
//----------------------------------------------------------------------------------
nf = NumberFormat.getInstance()
assert nf.format(-1740525205) == '-1,740,525,205'
//----------------------------------------------------------------------------------
// @@PLEAC@@_2.18
//----------------------------------------------------------------------------------
def timeMessage(hour) { 'It took ' + hour + ' hour' + (hour == 1 ? '' : 's') }
assert 'It took 1 hour' == timeMessage(1)
assert 'It took 2 hours' == timeMessage(2)

// you can also use Java's ChoiceFormat
// overkill for this example but extensible and compatible with MessageFormat
limits = [1, ChoiceFormat.nextDouble(1)] as double[]
names = ['century', 'centuries'] as String[]
choice = new ChoiceFormat(limits, names)
numCenturies = 1
expected = 'It took 1 century'
assert expected == "It took $numCenturies " + choice.format(numCenturies)
// an alternate constructor syntax
choice = new ChoiceFormat('0#are no files|1#is one file|2#are multiple files')
assert choice.format(3) == 'are multiple files'

// more complex pluralization can be done with Java libraries, e.g.:
// http://www.elvis.ac.nz/brain?PluralizationMapping
// org.springframework.util.Pluralizer within the Spring Framework (springframework.org)
//----------------------------------------------------------------------------------

// @@PLEAC@@_2.19
//----------------------------------------------------------------------------------
// calculating prime factors
def factorize(BigInteger orig) {
    factors = [:]
    def addFactor = { x -> if (factors[x]) factors[x] += 1 else factors[x] = 1 }
    n = orig
    i = 2
    sqi = 4               // square of i
    while (sqi <= n) {
        while (n.remainder(i) == 0) {
            n /= i
            addFactor i
        }
        // we take advantage of the fact that (i+1)**2 = i**2 + 2*i + 1
        sqi += 2 * i + 1
        i += 1
    }
    if ((n != 1) && (n != orig)) addFactor n
    return factors
}

def pretty(factors) {
    if (!factors) return "PRIME"
    sb = new StringBuffer()
    factors.keySet().sort().each { key ->
        sb << key
        if (factors[key] > 1) sb << "**" + factors[key]
        sb << " "
    }
    return sb.toString().trim()
}

assert pretty(factorize(2178)) == '2 3**2 11**2'
assert pretty(factorize(39887)) == 'PRIME'
assert pretty(factorize(239322000000000000000000)) == '2**19 3 5**18 39887'
//----------------------------------------------------------------------------------

// @@PLEAC@@_3.0
//----------------------------------------------------------------------------------
// use Date to get the current time
println new Date()
// => Mon Jan 01 07:12:32 EST 2007
// use Calendar to compute year, month, day, hour, minute, and second values
cal = Calendar.instance
println 'Today is day ' + cal.get(Calendar.DAY_OF_YEAR) + ' of the current year.'
// => Today is day 1 of the current year.
// there are other Java Date/Time packages with extended capabilities, e.g.:
//     http://joda-time.sourceforge.net/
// there is a special Grails (grails.codehaus.org) time DSL (see below)
//----------------------------------------------------------------------------------

// @@PLEAC@@_3.1
//----------------------------------------------------------------------------------
cal = Calendar.instance
Y = cal.get(Calendar.YEAR)
M = cal.get(Calendar.MONTH) + 1
D = cal.get(Calendar.DATE)
println "The current date is $Y $M $D"
// => The current date is 2006 04 28
//----------------------------------------------------------------------------------

// @@PLEAC@@_3.2
//----------------------------------------------------------------------------------
// create a calendar with current time and time zone
cal = Calendar.instance
// set time zone using long or short timezone values
cal.timeZone = TimeZone.getTimeZone("America/Los_Angeles")
cal.timeZone = TimeZone.getTimeZone("UTC")
// set date fields one at a time
cal.set(Calendar.MONTH, Calendar.DECEMBER)
// or several together
//calendar.set(year, month - 1, day, hour, minute, second)
// get time in seconds since EPOCH
long time = cal.time.time / 1000
println time
// => 1196522682
//----------------------------------------------------------------------------------

// @@PLEAC@@_3.3
//----------------------------------------------------------------------------------
// create a calendar with current time and time zone
cal = Calendar.instance
// set time
cal.time = new Date(time * 1000)
// get date fields
println('Dateline: '
    + cal.get(Calendar.HOUR_OF_DAY) + ':'
    + cal.get(Calendar.MINUTE) + ':'
    + cal.get(Calendar.SECOND) + '-'
    + cal.get(Calendar.YEAR) + '/'
    + (cal.get(Calendar.MONTH) + 1) + '/'
    + cal.get(Calendar.DATE))
// => Dateline: 7:33:16-2007/1/1
//----------------------------------------------------------------------------------

// @@PLEAC@@_3.4
//----------------------------------------------------------------------------------
import java.text.SimpleDateFormat
long difference = 100
long after = time + difference
long before = time - difference

// any field of a calendar is incrementable via add() and roll() methods
cal = Calendar.instance
df = new SimpleDateFormat()
printCal = {cal -> df.format(cal.time)}
cal.set(2000, 0, 1, 00, 01, 0)
assert printCal(cal) == '1/01/00 00:01'
// roll minute back by 2 but don't adjust other fields
cal.roll(Calendar.MINUTE, -2)
assert printCal(cal) == '1/01/00 00:59'
// adjust hour back 1 and adjust other fields if needed
cal.add(Calendar.HOUR, -1)
assert printCal(cal) == '31/12/99 23:59'

// larger example
cal.timeZone = TimeZone.getTimeZone("UTC")
cal.set(1973, 0, 18, 3, 45, 50)
cal.add(Calendar.DATE, 55)
cal.add(Calendar.HOUR_OF_DAY, 2)
cal.add(Calendar.MINUTE, 17)
cal.add(Calendar.SECOND, 5)
assert printCal(cal) == '14/03/73 16:02'

// alternatively, work with epoch times
long birthTime = 96176750359       // 18/Jan/1973, 3:45:50 am
long interval = 5 +                // 5 second
                17 * 60 +          // 17 minute
                2  * 60 * 60 +     // 2 hour
                55 * 60 * 60 * 24  // and 55 day
then = new Date(birthTime + interval * 1000)
assert df.format(then) == '14/03/73 16:02'

// Alternatively, the Google Data module has a category with DSL-like time support:
// http://docs.codehaus.org/display/GROOVY/Google+Data+Support
// which supports the following syntax
// def interval = 5.seconds + 17.minutes + 2.hours + 55.days
//----------------------------------------------------------------------------------

// @@PLEAC@@_3.5
//----------------------------------------------------------------------------------
bree = 361535725  // 16 Jun 1981, 4:35:25
nat  =  96201950  // 18 Jan 1973, 3:45:50
difference = bree - nat
println "There were $difference seconds between Nat and Bree"
// => There were 265333775 seconds between Nat and Bree
seconds    =  difference % 60
difference = (difference - seconds) / 60
minutes    =  difference % 60
difference = (difference - minutes) / 60
hours      =  difference % 24
difference = (difference - hours)   / 24
days       =  difference % 7
weeks      = (difference - days)    /  7
println "($weeks weeks, $days days, $hours:$minutes:$seconds)"
// => (438 weeks, 4 days, 23:49:35)
//----------------------------------------------------------------------------------
cal = Calendar.getInstance(TimeZone.getTimeZone("UTC"))
cal.set(1981, 5, 16)  // 16 Jun 1981
date1 = cal.time
cal.set(1973, 0, 18)  // 18 Jan 1973
date2 = cal.time
difference = Math.abs(date2.time - date1.time)
days = difference / (1000 * 60 * 60 * 24)
assert days == 3071
//----------------------------------------------------------------------------------

// @@PLEAC@@_3.6
//----------------------------------------------------------------------------------
// create a calendar with current time and time zone
cal = Calendar.instance
cal.set(1981, 5, 16)
yearDay = cal.get(Calendar.DAY_OF_YEAR);
year = cal.get(Calendar.YEAR);
yearWeek = cal.get(Calendar.WEEK_OF_YEAR);
df1 = new SimpleDateFormat("dd/MMM/yy")
df2 = new SimpleDateFormat("EEEE")
print(df1.format(cal.time) + ' was a ' + df2.format(cal.time))
println " and was day number $yearDay and week number $yearWeek of $year"
// => 16/Jun/81 was a Tuesday and was day number 167 and week number 25 of 1981
//----------------------------------------------------------------------------------

// @@PLEAC@@_3.7
//----------------------------------------------------------------------------------
input = "1998-06-03"
df1 = new SimpleDateFormat("yyyy-MM-dd")
date = df1.parse(input)
df2 = new SimpleDateFormat("MMM/dd/yyyy")
println 'Date was ' + df2.format(date)
// => Date was Jun/03/1998
//----------------------------------------------------------------------------------

// @@PLEAC@@_3.8
//----------------------------------------------------------------------------------
import java.text.DateFormat
df = new SimpleDateFormat('E M d hh:mm:ss z yyyy')
cal.set(2007, 0, 1)
println 'Customized format gives: ' + df.format(cal.time)
// => Mon 1 1 09:02:29 EST 2007 (differs depending on your timezone)
df = DateFormat.getDateInstance(DateFormat.FULL, Locale.FRANCE)
println 'Customized format gives: ' + df.format(cal.time)
// => lundi 1 janvier 2007
//----------------------------------------------------------------------------------

// @@PLEAC@@_3.9
//----------------------------------------------------------------------------------
// script:
println 'Press return when ready'
before = System.currentTimeMillis()
input = new BufferedReader(new InputStreamReader(System.in)).readLine()
after = System.currentTimeMillis()
elapsed = (after - before) / 1000
println "You took $elapsed seconds."
// => You took2.313 seconds.

// take mean sorting time
size = 500; number = 100; total = 0
for (i in 0..<number) {
    array = []
    size.times{ array << Math.random() }
    doubles = array as double[]
    // sort it
    long t0 = System.currentTimeMillis()
    Arrays.sort(doubles)
    long t1 = System.currentTimeMillis()
    total += (t1 - t0)
}
println "On average, sorting $size random numbers takes ${total / number} milliseconds"
// => On average, sorting 500 random numbers takes 0.32 milliseconds
//----------------------------------------------------------------------------------

// @@PLEAC@@_3.10
//----------------------------------------------------------------------------------
delayMillis = 50
Thread.sleep(delayMillis)
//----------------------------------------------------------------------------------

// @@PLEAC@@_3.11
//----------------------------------------------------------------------------------
// this could be done more simply using JavaMail's getAllHeaderLines() but is shown
// in long hand for illustrative purposes
sampleMessage = '''Delivered-To: alias-someone@somewhere.com.au
Received: (qmail 27284 invoked from network); 30 Dec 2006 15:16:26 -0000
Received: from unknown (HELO lists-outbound.sourceforge.net) (66.35.250.225)
  by bne012m.server-web.com with SMTP; 30 Dec 2006 15:16:25 -0000
Received: from sc8-sf-list2-new.sourceforge.net (sc8-sf-list2-new-b.sourceforge.net [10.3.1.94])
    by sc8-sf-spam2.sourceforge.net (Postfix) with ESMTP
    id D8CCBFDE3; Sat, 30 Dec 2006 07:16:24 -0800 (PST)
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
    helo=mail.sourceforge.net)
    by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
    id 1H0fwX-0003c0-GA
    for pleac-discuss@lists.sourceforge.net; Sat, 30 Dec 2006 07:16:20 -0800
Received: from omta05ps.mx.bigpond.com ([144.140.83.195])
    by mail.sourceforge.net with esmtp (Exim 4.44) id 1H0fwY-0005D4-DD
    for pleac-discuss@lists.sourceforge.net; Sat, 30 Dec 2006 07:16:19 -0800
Received: from win2K001 ([138.130.127.127]) by omta05ps.mx.bigpond.com
    with SMTP
    id <20061230151611.XVWL19269.omta05ps.mx.bigpond.com@win2K001>;
    Sat, 30 Dec 2006 15:16:11 +0000
From: someone@somewhere.com
To: <pleac-discuss@lists.sourceforge.net>
Date: Sun, 31 Dec 2006 02:14:57 +1100
Subject: Re: [Pleac-discuss] C/Posix/GNU - @@pleac@@_10x
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: pleac-discuss-bounces@lists.sourceforge.net
Errors-To: pleac-discuss-bounces@lists.sourceforge.net

----- Original Message -----
From: someone@somewhere.com
To: otherperson@somewhereelse.com
Cc: <pleac-discuss@lists.sourceforge.net>
Sent: Wednesday, December 27, 2006 9:18 AM
Subject: Re: [Pleac-discuss] C/Posix/GNU - @@pleac@@_10x

I really like that description of PLEAC.
'''
expected = '''
Sender                    Recipient                 Time              Delta
<origin>                  somewhere.com             01:14:57 06/12/31 
win2K001                  omta05ps.mx.bigpond.com   01:14:57 06/12/31 1m 14s
omta05ps.mx.bigpond.com   mail.sourceforge.net      01:16:11 06/12/31 8s
sc8-sf-mx1-b.sourceforge. sc8-sf-list2-new.sourcefo 01:16:19 06/12/31 1s
sc8-sf-list2-new.sourcefo sc8-sf-spam2.sourceforge. 01:16:20 06/12/31 4s
unknown                   bne012m.server-web.com    01:16:24 06/12/31 1s
'''

class MailHopDelta {
    def headers, firstSender, firstDate, out

    MailHopDelta(mail) {
        extractHeaders(mail)
        out = new StringBuffer()
        def m = (mail =~ /(?m)^Date:\s+(.*)/)
        firstDate = parseDate(m[0][1])
        firstSender = (mail =~ /(?m)^From.*\@([^\s>]*)/)[0][1]
        out('Sender Recipient Time Delta'.split(' '))
    }

    def parseDate(date) {
        try {
            return new SimpleDateFormat('EEE, dd MMM yyyy hh:mm:ss Z').parse(date)
        } catch(java.text.ParseException ex) {}
        try {
            return new SimpleDateFormat('dd MMM yyyy hh:mm:ss Z').parse(date)
        } catch(java.text.ParseException ex) {}
        try {
            return DateFormat.getDateInstance(DateFormat.FULL).parse(date)
        } catch(java.text.ParseException ex) {}
        DateFormat.getDateInstance(DateFormat.LONG).parse(date)
    }

    def extractHeaders(mail) {
        headers = []
        def isHeader = true
        def currentHeader = ''
        mail.split('\n').each{ line ->
            if (!isHeader) return
            switch(line) {
                case ~/^\s*$/:
                    isHeader = false
                    if (currentHeader) headers << currentHeader
                    break
                case ~/^\s+.*/:
                    currentHeader += line; break
                default:
                    if (currentHeader) headers << currentHeader
                    currentHeader = line
            }
        }
    }

    def out(line) {
        out << line[0][0..<[25,line[0].size()].min()].padRight(26)
        out << line[1][0..<[25,line[1].size()].min()].padRight(26)
        out << line[2].padRight(17) + ' '
        out << line[3] + '\n'
    }

    def prettyDate(date) {
        new SimpleDateFormat('hh:mm:ss yy/MM/dd').format(date)
    }

    def process() {
        out(['<origin>', firstSender, prettyDate(firstDate), ''])
        def prevDate = firstDate
        headers.grep(~/^Received:\sfrom.*/).reverseEach{ hop ->
            def from = (hop =~ /from\s+(\S+)|\((.*?)\)/)[0][1]
            def by   = (hop =~ /by\s+(\S+\.\S+)/)[0][1]
            def hopDate = parseDate(hop[hop.lastIndexOf(';')+2..-1])
            out([from, by, prettyDate(prevDate), prettyDelta(hopDate.time - prevDate.time)])
            prevDate = hopDate
        }
        return out.toString()
    }

    def prettyField(secs, sign, ch, multiplier, sb) {
        def whole = (int)(secs / multiplier)
        if (!whole) return 0
        sb << '' + (sign * whole) + ch + ' '
        return whole * multiplier
    }

    def prettyDelta(millis) {
        def sign = millis < 0 ? -1 : 1
        def secs = (int)Math.abs(millis/1000)
        def sb = new StringBuffer()
        secs -= prettyField(secs, sign, 'd', 60 * 60 * 24, sb)
        secs -= prettyField(secs, sign, 'h', 60 * 60, sb)
        secs -= prettyField(secs, sign, 'm', 60, sb)
        prettyField(secs, sign, 's', 1, sb)
        return sb.toString().trim()
    }
}

assert '\n' + new MailHopDelta(sampleMessage).process() == expected
//----------------------------------------------------------------------------------


// @@PLEAC@@_4.0
//----------------------------------------------------------------------------------
simple = [ "this", "that", "the", "other" ]
nested = [ "this", "that", [ "the", "other" ] ]
assert nested.size() == 3
assert nested[2].size() == 2

flattenNestedToSimple = [ "this", "that", [ "the", "other" ] ].flatten()
assert flattenNestedToSimple.size() == 4
//----------------------------------------------------------------------------------

// @@PLEAC@@_4.1
//----------------------------------------------------------------------------------
a = [ "quick", "brown", "fox" ]
assert a.size() == 3
a = 'Why are you teasing me?'.split(' ')
assert a == ["Why", "are", "you", "teasing", "me?"]

removeLeadingSpaces = { it.trim() }
nonBlankLines = { it }
lines = '''
    The boy stood on the burning deck,
    It was as hot as glass.
'''.split('\n').collect(removeLeadingSpaces).findAll(nonBlankLines)

assert lines == ["The boy stood on the burning deck,",
                 "It was as hot as glass."]

// initialiseListFromFileScript:
lines = new File('mydata.txt').readLines()

// processFileScript:
new File('mydata.txt').eachLine{
    // dosomething
}
//----------------------------------------------------------------------------------

// @@PLEAC@@_4.2
//----------------------------------------------------------------------------------
marbleColors = ['red', 'green', 'yellow']
assert marbleColors.join(', ') == 'red, green, yellow'

def commify(items) {
    if (!items) return items
    def sepchar = items.find{ it =~ /,/ } ? '; ' : ', '
    switch (items.size()) {
        case 1: return items[0]
        case 2: return items.join(' and ')
    }
    items[0..-2].join(sepchar) + sepchar + 'and ' + items[-1]
}

assert commify(marbleColors) == 'red, green, and yellow'

lists = [
    [ 'just one thing' ],
    [ 'Mutt', 'Jeff' ],
    'Peter Paul Mary'.split(' '),
    [ 'To our parents', 'Mother Theresa', 'God' ],
    [ 'pastrami', 'ham and cheese', 'peanut butter and jelly', 'tuna' ],
    [ 'recycle tired, old phrases', 'ponder big, happy thoughts' ],
    [ 'recycle tired, old phrases',
      'ponder big, happy thoughts',
      'sleep and dream peacefully' ],
]

expected = '''
just one thing
Mutt and Jeff
Peter, Paul, and Mary
To our parents, Mother Theresa, and God
pastrami, ham and cheese, peanut butter and jelly, and tuna
recycle tired, old phrases and ponder big, happy thoughts
recycle tired, old phrases; ponder big, happy thoughts; and sleep and dream peacefully
'''

assert expected == '\n' + lists.collect{commify(it)}.join('\n') + '\n'
//----------------------------------------------------------------------------------

// @@PLEAC@@_4.3
//----------------------------------------------------------------------------------
// In Groovy, lists and arrays are more or less interchangeable
// here is the example using lists
people = ['Crosby', 'Stills', 'Nash']
assert people.size() == 3
people[3] = 'Young'
assert people.size() == 4
assert people == ['Crosby', 'Stills', 'Nash', 'Young']
// to use arrays simply do 'people = peopleArray.toList()' at the start
// and 'peopleArray = people as String[]' at the end
// if you attempt to do extension on a Java array you will get an
// ArrayIndexOutOfBoundsException - which is why Java has ArrayList et al
//----------------------------------------------------------------------------------

// @@PLEAC@@_4.4
//----------------------------------------------------------------------------------
// list to process
people == ['Crosby', 'Stills', 'Nash', 'Young']
// helper
startsWithCapital = { word -> word[0] in 'A'..'Z' }

// various styles are possible for processing lists
// closure style
people.each { person -> assert startsWithCapital(person) }
// for loop style
for (person in people) { assert startsWithCapital(person) }

// unixScriptToFindAllUsersStartingWithLetterA:
all = 'who'.execute().text.replaceAll('\r', '').split('\n')
all.grep(~/^a.*/).each{ println it }

// printFileWithWordsReversedScript:
new File('Pleac/src/SlowCat.groovy').eachLine{ line ->
     line.split(' ').each{ print it.reverse() }
}

a = [0.5, 3]; b = [0, 1]
assert [a, b].flatten().collect{ it * 7 } == [3.5, 21, 0, 7]
// above doesn't modify original arrays
// instead use a = a.collect{ ... }
//----------------------------------------------------------------------------------

// @@PLEAC@@_4.5
//----------------------------------------------------------------------------------
// not relevant in Groovy since we have always references
items = []
for (item in items) {
    // do something with item
}
//----------------------------------------------------------------------------------

// @@PLEAC@@_4.6
//----------------------------------------------------------------------------------
assert [ 1, 1, 2, 2, 3, 3, 3, 5 ].unique() == [ 1, 2, 3, 5 ]
//----------------------------------------------------------------------------------

// @@PLEAC@@_4.7
//----------------------------------------------------------------------------------
assert [ 1, 1, 2, 2, 3, 3, 3, 4, 5 ] - [ 1, 2, 4 ]  ==  [3, 3, 3, 5]
assert [ 1, 1, 2, 2, 3, 3, 3, 4, 5 ].unique() - [ 1, 2, 4 ]  ==  [3, 5]
//----------------------------------------------------------------------------------

// @@PLEAC@@_4.8
//----------------------------------------------------------------------------------
a = [1, 3, 5, 6, 7, 8]
b = [2, 3, 5, 7, 9]
// intersection
assert a.intersect(b) == [3, 5, 7]
// union
assert (a + b).unique().sort() == [1, 2, 3, 5, 6, 7, 8, 9]
// difference
assert (a - b) == [1, 6, 8]
//----------------------------------------------------------------------------------

// @@PLEAC@@_4.9
//----------------------------------------------------------------------------------
members = [ "Time", "Flies" ]
initiates =  [ "An", "Arrow" ]
members += initiates
assert members == ["Time", "Flies", "An", "Arrow"]

members.add(2, "Like")
assert members == ["Time", "Flies", "Like", "An", "Arrow"]

members[0] = "Fruit"
members[3..4] = ["A", "Banana"]
assert members == ["Fruit", "Flies", "Like", "A", "Banana"]
//----------------------------------------------------------------------------------

// @@PLEAC@@_4.10
//----------------------------------------------------------------------------------
items = ["the", "quick", "brown", "fox"]
assert items.reverse() == ["fox", "brown", "quick", "the"]

firstLetters = []
items.reverseEach{ firstLetters += it[0] }
assert firstLetters.join() == 'fbqt'

descending = items.sort().reverse()
assert descending == ["the", "quick", "fox", "brown"]
descendingBySecondLastLetter = items.sort { a,b -> b[-2] <=> a[-2] }
assert descendingBySecondLastLetter == ["brown", "fox", "the", "quick"]
//----------------------------------------------------------------------------------

// @@PLEAC@@_4.11
//----------------------------------------------------------------------------------
// warning: not an exact equivalent, idiomatic use would return copies
def shift2 = {one = friends[0]; two = friends[1]; 2.times{friends.remove(0)}}
friends = 'Peter Paul Mary Jim Tim'.split(' ').toList()
shift2()
assert one == 'Peter'
assert two == 'Paul'
assert friends == ["Mary", "Jim", "Tim"]

def pop2(items) { items[0..1] }
beverages = 'Dew Jolt Cola Sprite Fresca'.split(' ').toList()
pair = pop2(beverages)
assert pair == ["Dew", "Jolt"]
//----------------------------------------------------------------------------------


// @@PLEAC@@_4.12
//----------------------------------------------------------------------------------
class Employee {
    def name
    def position
    def salary
}
staff = [new Employee(name:'Jim',position:'Manager',salary:26000),
         new Employee(name:'Jill',position:'Engineer',salary:24000),
         new Employee(name:'Jack',position:'Engineer',salary:22000)]
highestEngineer = staff.find { emp -> emp.position == 'Engineer' }
assert highestEngineer.salary == 24000
//----------------------------------------------------------------------------------

// @@PLEAC@@_4.13
//----------------------------------------------------------------------------------
engineers = staff.findAll { e -> e.position == 'Engineer' }
assert engineers.size() == 2

highPaid = staff.findAll { e -> e.salary > 23000 }
assert highPaid*.name == ["Jim", "Jill"]
//----------------------------------------------------------------------------------

// @@PLEAC@@_4.14
//----------------------------------------------------------------------------------
// sort works for numbers
assert [100, 3, 20].sort() == [3, 20, 100]
// strings representing numbers will be sorted alphabetically
assert ['100', '3', '20'].sort() == ["100", "20", "3"]
// closure style sorting allows arbitrary expressions for the comparison
assert ['100', '3', '20'].sort{ a,b -> a.toLong() <=> b.toLong()} == ["3", "20", "100"]

// obtain the following on unix systems using: 'ps ux'.execute().text
processInput = '''
      PID    PPID    PGID     WINPID  TTY  UID    STIME COMMAND
     3868       1    3868       3868  con 1005 06:23:34 /usr/bin/bash
     3456    3868    3456       3528  con 1005 06:23:39 /usr/bin/ps
'''
nonEmptyLines = {it.trim()}
lines = processInput.split("\n").findAll(nonEmptyLines)[1..-1]
def col(n, s) { s.tokenize()[n] }
commandIdx = 7
pidIdx = 0
ppidIdx = 1
linesByPid = lines.sort{ col(pidIdx,it).toLong() }
assert col(commandIdx, linesByPid[0]) == '/usr/bin/ps'
linesByPpid = lines.sort{ col(ppidIdx,it).toLong() }
assert col(commandIdx, linesByPpid[0]) == '/usr/bin/bash'
//----------------------------------------------------------------------------------

// @@PLEAC@@_4.15
//----------------------------------------------------------------------------------
// sort staff from 4.12 by name
assert staff.sort { a,b -> a.name <=> b.name }*.name == ["Jack", "Jill", "Jim"]
// sort by first two characters of name and if equal by descending salary
assert staff.sort { a,b ->
    astart = a.name[0..1]
    bstart = b.name[0..1]
    if (astart == bstart) return b.salary <=> a.salary
    return astart <=> bstart
}*.name == ["Jack", "Jim", "Jill"]
//----------------------------------------------------------------------------------

// @@PLEAC@@_4.16
//----------------------------------------------------------------------------------
items = [1, 2, 3, 4, 5]
processed = []
10.times{
    processed << items[0]
    items = items[1..-1] + items[0]
}
assert processed == [1, 2, 3, 4, 5, 1, 2, 3, 4, 5]
//----------------------------------------------------------------------------------

// @@PLEAC@@_4.17
//----------------------------------------------------------------------------------
import java.text.DateFormatSymbols as Symbols
items = new Symbols().shortWeekdays.toList()[1..7]
assert items == ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
// not as random as you might expect
println items.sort{ Math.random() }
// => ["Sat", "Tue", "Sun", "Wed", "Mon", "Thu", "Fri"]
// better to use the built-in method for this purpose
Collections.shuffle(items)
println items
// => ["Wed", "Tue", "Fri", "Sun", "Sat", "Thu", "Mon"]
//----------------------------------------------------------------------------------

// @@PLEAC@@_4.18
//----------------------------------------------------------------------------------
symbols = new Symbols()
words = symbols.weekdays.toList()[1..7] +
    symbols.months.toList()[0..11] +
    symbols.eras.toList() +
    symbols.amPmStrings.toList()

expected = //
'AD        August    February  July      May       October   September Tuesday   \n' +
'AM        BC        Friday    June      Monday    PM        Sunday    Wednesday \n' +
'April     December  January   March     November  Saturday  Thursday  \n'

class WordFormatter {
    def cols

    def process(list) {
        def sb = new StringBuffer()
        def colWidth = list.max{it.size()}.size() + 1
        int columns = [cols/colWidth, 1].max()
        def numWords = list.size()
        int rows = (numWords + columns - 1) / columns
        for (row in 0..<rows) {
            for (col in 0..<columns) {
                def target = row + col * rows
                if (target < numWords)
                    sb << list[target].padRight(colWidth)
            }
            sb << '\n'
        }
        return sb.toString()
    }
}

// get nr of chars that fit in window or console, see PLEAC 15.4
// hard-coded here but several packages are available, e.g. in JLine
// use a concrete implementation of Terminal.getTerminalWidth()
def getWinCharWidth() { 80 }

// main script
actual = new WordFormatter(cols:getWinCharWidth()).process(words.sort())
assert actual == expected
//----------------------------------------------------------------------------------

// @@PLEAC@@_4.19
//----------------------------------------------------------------------------------
// recursive version is simplest but can be inefficient
def fact(n) { (n == 1) ? 1 : n * fact(n-1)}
assert fact(10) == 3628800
// unwrapped version: note use of BigInteger
def factorial(n) {
    def result = 1G // 1 as BigInteger
    while (n > 0) {
        result *= n
        n -= 1
    }
    return result
}
expected = 93326215443944152681699238856266700490715968264381621468592963895217599993229915608941463976156518286253697920827223758251185210916864000000000000000000000000
assert expected == factorial(100)
// println factorial(10000)
// => 284625... (greater than 35,000 digits)

// simple version but less efficient
def simplePermute(items, perms) {
    if (items.size() == 0)
        println perms.join(' ')
    else
        for (i in items) {
            newitems = items.clone()
            newperms = perms.clone()
            newperms.add(i)
            newitems.remove(i)
            simplePermute(newitems, newperms)
        }
}
simplePermute(['dog', 'bites', 'man'], [])
// =>
//dog bites man
//dog man bites
//bites dog man
//bites man dog
//man dog bites
//man bites dog

// optimised version below
expected = '''
man bites dog
man dog bites
bites man dog
bites dog man
dog man bites
dog bites man
'''

// n2pat(n, len): produce the N-th pattern of length len
def n2pat(n, length) {
    def pat = []
    int i = 1
    while (i <= length) {
        pat << (n % i)
        n = n.intdiv(i)
        i += 1
    }
    pat
}

// pat2perm(pat): turn pattern returned by n2pat() into
// permutation of integers.
def pat2perm(pat) {
    def source = (0 ..< pat.size()).collect{ it/*.toString()*/ }
    def perm = []
    while (pat.size() > 0) {
        def next = pat.remove(pat.size()-1)
        perm << source[next]
        source.remove(next)
    }
    perm
}

def n2perm(n, len) {
    pat2perm(n2pat((int)n,len))
}

data = ['man', 'bites', 'dog']
sb = new StringBuffer()
numPermutations = fact(data.size())
for (j in 0..<numPermutations) {
    def permutation = n2perm(j, data.size()).collect { k -> data[k] }
    sb << permutation.join(' ') + '\n'
}
assert '\n' + sb.toString() == expected
//----------------------------------------------------------------------------------

// @@PLEAC@@_5.0
//----------------------------------------------------------------------------------
// quotes are optional around the key
age = [ Nat:24, Jules:25, Josh:17 ]

assert age['Nat']  == 24
// alternate syntax
assert age."Jules" == 25

foodColor = [
    Apple:  'red',
    Banana: 'yellow',
    Lemon:  'yellow',
    Carrot: 'orange'
]
assert foodColor.size() == 4
//----------------------------------------------------------------------------------

// @@PLEAC@@_5.1
//----------------------------------------------------------------------------------
foodColor['Lemon'] = 'green'
assert foodColor.size() == 4
assert foodColor['Lemon'] == 'green'
foodColor['Raspberry'] = 'pink'
assert foodColor.size() == 5
//----------------------------------------------------------------------------------

// @@PLEAC@@_5.2
//----------------------------------------------------------------------------------
assert ['Banana', 'Martini'].collect{ foodColor.containsKey(it)?'food':'drink' } == [ 'food', 'drink' ]

age = [Toddler:3, Unborn:0, Phantasm:null]
['Toddler', 'Unborn', 'Phantasm', 'Relic'].each{ key ->
    print "$key: "
    if (age.containsKey(key)) print 'has key '
    if (age.containsKey(key) && age[key]!=null) print 'non-null '
    if (age.containsKey(key) && age[key]) print 'true '
    println ''
}
// =>
// Toddler: has key non-null true
// Unborn: has key non-null
// Phantasm: has key
// Relic:
//----------------------------------------------------------------------------------

// @@PLEAC@@_5.3
//----------------------------------------------------------------------------------
assert foodColor.size() == 5
foodColor.remove('Banana')
assert foodColor.size() == 4
//----------------------------------------------------------------------------------

// @@PLEAC@@_5.4
//----------------------------------------------------------------------------------
hash = [:]
hash.each { key, value ->
    // do something with key and value
}

hash.each { entry ->
    // do something with entry
}

hash.keySet().each { key ->
    // do something with key
}

sb = new StringBuffer()
foodColor.each { food, color ->
    sb << "$food is $color\n"
}
assert '\n' + sb.toString() == '''
Lemon is green
Carrot is orange
Apple is red
Raspberry is pink
'''

foodColor.each { entry ->
    assert entry.key.size() > 4 && entry.value.size() > 2
}

foodColorsSortedByFood = []
foodColor.keySet().sort().each { k -> foodColorsSortedByFood << foodColor[k] }
assert foodColorsSortedByFood == ["red", "orange", "green", "pink"]

fakedInput = '''
From: someone@somewhere.com
From: someone@spam.com
From: someone@somewhere.com
'''

from = [:]
fakedInput.split('\n').each{
    matcher = (it =~ /^From:\s+([^\s>]*)/)
    if (matcher.matches()) {
        sender = matcher[0][1]
        if (from.containsKey(sender)) from[sender] += 1
        else from[sender] = 1
    }
}

// More useful to sort by number of received mail by person
from.entrySet().sort { a,b -> b.value<=>a.value}.each { e->
    println "${e.key}: ${e.value}"
}
// =>
// someone@somewhere.com: 2
// someone@spam.com: 1
//----------------------------------------------------------------------------------

// @@PLEAC@@_5.5
//----------------------------------------------------------------------------------
hash = [a:1, b:2, c:3]
// Map#toString already produce a pretty decent output:
println hash
// => ["b":2, "a":1, "c":3]

// Or do it by longhand for customised formatting
hash.each { k,v -> println "$k => $v" }
// =>
// b => 2
// a => 1
// c => 3
//----------------------------------------------------------------------------------

// @@PLEAC@@_5.6
//----------------------------------------------------------------------------------
// java.util.LinkedHashMap "maintains a doubly-linked list running through all of its entries.
// This linked list defines the iteration ordering, which is normally the order in which keys
// were inserted into the map (insertion-order)".
foodColor = new LinkedHashMap()
foodColor['Banana'] = 'Yellow'
foodColor['Apple'] = 'Green'
foodColor['Lemon'] = 'Yellow'

foodColor.keySet().each{ key -> println key }
// =>
// Banana
// Apple
// Lemon
//----------------------------------------------------------------------------------

// @@PLEAC@@_5.7
//----------------------------------------------------------------------------------
foodsOfColor = [ Yellow:['Banana', 'Lemon'], Green:['Apple'] ]
foodsOfColor['Green'] += 'Melon'
assert foodsOfColor == ["Green":["Apple", "Melon"], "Yellow":["Banana", "Lemon"]]
//----------------------------------------------------------------------------------

// @@PLEAC@@_5.8
//----------------------------------------------------------------------------------
surname = [Mickey: 'Mantle', Babe: 'Ruth']
assert surname.findAll{ it.value == 'Mantle' }.collect{ it.key } == ["Mickey"]

firstname = [:]
surname.each{ entry -> firstname[entry.value] = entry.key }
assert firstname == ["Ruth":"Babe", "Mantle":"Mickey"]

// foodfindScript:
#!/usr/bin/groovy
// usage: foodfind food_or_color"
color = [Apple:'red', Banana:'yellow', Lemon:'yellow', Carrot:'orange']
given = args[0]
if (color.containsKey(given))
    println "$given is a food with color ${color[given]}."
if (color.containsValue(given)) {
    // could use commify() here - see 4.2
    foods = color.findAll{it.value == given}.collect{it.key}
    join = foods.size() == 1 ? 'is a food' : 'are foods'
    println "${foods.join(', ')} $join with color ${given}."
}
// foodfind red
// => Apple is a food with color red.
// foodfind yellow
// => Lemon, Banana are foods with color yellow.
// foodfind Carrot
// => Carrot is a food with color orange.
//----------------------------------------------------------------------------------

// @@PLEAC@@_5.9
//----------------------------------------------------------------------------------
foodColor = [Apple:'red', Carrot:'orange', Banana:'yellow', Cherry:'black']

// Sorted by keys
assert foodColor.keySet().sort() == ["Apple", "Banana", "Carrot", "Cherry"]
// you could now iterate through the hash with the sorted keys
assert foodColor.values().sort() == ["black", "orange", "red", "yellow"]
assert foodColor.values().sort{it.size()} == ["red", "black", "orange", "yellow"]
//----------------------------------------------------------------------------------

// @@PLEAC@@_5.10
//----------------------------------------------------------------------------------
//merged = a.clone.update(b)        # because Hash#update changes object in place

drinkColor = [Galliano:'yellow', 'Mai Tai':'blue']
ingestedColor = [:]
ingestedColor.putAll(drinkColor)
// overrides any common keys
ingestedColor.putAll(foodColor)

totalColors = ingestedColor.values().sort().unique()
assert totalColors == ["black", "blue", "orange", "red", "yellow"]
//----------------------------------------------------------------------------------

// @@PLEAC@@_5.11
//----------------------------------------------------------------------------------
foodColor['Lemon']='yellow'
citrusColor = [Lemon:'yellow', Orange:'orange', Lime:'green']
println foodColor
println citrusColor
common = foodColor.keySet().intersect(citrusColor.keySet())
assert common == ["Lemon"]

foodButNotCitrus = foodColor.keySet().toList() - citrusColor.keySet().toList()
assert foodButNotCitrus == ["Carrot", "Apple", "Banana", "Cherry"]
//----------------------------------------------------------------------------------

// @@PLEAC@@_5.12
//----------------------------------------------------------------------------------
// no problem here, Groovy handles any kind of object for key-ing
//----------------------------------------------------------------------------------

// @@PLEAC@@_5.13
//----------------------------------------------------------------------------------
// Groovy uses Java implementations for storing hashes and these
// support setting an initial capacity and load factor (which determines
// at what point the hash will be resized if needed)
hash = [:]                              // Groovy shorthand gets defaults
hash = new HashMap()                    // default capacity and load factor
println hash.capacity()
// => 16
('A'..'Z').each{ hash[it] = it }
println hash.capacity()
// => 64
hash = new HashMap(100)                 // initial capacity of 100 and default load factor
hash = new HashMap(100, 0.8f)    // initial capacity of 100 and 0.8 load factor
//----------------------------------------------------------------------------------

// @@PLEAC@@_5.14
//----------------------------------------------------------------------------------
count = [:]
letters = []
foodColor.values().each{ letters.addAll((it as String[]).toList()) }
letters.each{ if (count.containsKey(it)) count[it] += 1 else count[it] = 1 }
assert count == ["o":3, "d":1, "k":1, "w":2, "r":2, "c":1, "l":5, "g":1, "b":1, "a":2, "y":2, "n":1, "e":4]
//----------------------------------------------------------------------------------

// @@PLEAC@@_5.15
//----------------------------------------------------------------------------------
father = [
    Cain:'Adam',
    Abel:'Adam',
    Seth:'Adam',
    Enoch:'Cain',
    Irad:'Enoch',
    Mehujael:'Irad',
    Methusael:'Mehujael',
    Lamech:'Methusael',
    Jabal:'Lamech',
    Jubal:'Lamech',
    Tubalcain:'Lamech',
    Enos:'Seth'
]

def upline(person) {
    while (father.containsKey(person)) {
        print person + ' '
        person = father[person]
    }
    println person
}

upline('Irad')
// => Irad Enoch Cain Adam

children = [:]
father.each { k,v ->
    if (!children.containsKey(v)) children[v] = []
    children[v] += k
}
def downline(person) {
    println "$person begat ${children.containsKey(person)?children[person].join(', '):'Nobody'}.\n"
}
downline('Tubalcain')
// => Tubalcain begat Nobody.
downline('Adam')
// => Adam begat Abel, Seth, Cain.

// This one doesn't recurse through subdirectories (as a simplification)
// scriptToFindIncludeFilesWhichContainNoIncludesScript:
dir = '<path_to_usr/include>'
includes = [:]
new File(dir).eachFile{ file ->
    if (file.directory) return
    file.eachLine{ line ->
        matcher = (line =~ '^\\s*#\\s*include\\s*<([^>]+)>')
        if (matcher.matches()) {
            if (!includes.containsKey(file.name)) includes[file.name] = []
            includes[file.name] += matcher[0][1]
        }
    }
}
// find referenced files which have no includes; assumes all files
// were processed and none are missing
println includes.values().sort().flatten().unique() - includes.keySet()
//----------------------------------------------------------------------------------

// @@PLEAC@@_5.16
//----------------------------------------------------------------------------------
// dutree - print sorted indented rendition of du output
// obtaining this input is not shown, it is similar to other examples
// on some unix systems it will be: duProcessFakedInput = "du options".process().text
duProcessFakedInput = '''
11732   groovysoap/lib
68      groovysoap/src/main/groovy/net/soap
71      groovysoap/src/main/groovy/net
74      groovysoap/src/main/groovy
77      groovysoap/src/main
9       groovysoap/src/examples
8       groovysoap/src/examples/groovy
102     groovysoap/src/test
202     groovysoap/src
11966   groovysoap
'''

// The DuNode class collects all information about a directory,
class DuNode {
    def name
    def size
    def kids = []

    // support for sorting nodes with side
    def compareTo(node2) { size <=> node2.size }

    def getBasename() {
        name.replaceAll(/.*\//, '')
    }

    // returns substring before last "/", otherwise null
    def getParent() {
        def p = name.replaceAll(/\/[^\/]+$/,'')
        return (p == name) ? null : p
    }
}

// The DuTree does the actual work of
// getting the input, parsing it, building up a tree
// and formatting it for output
class DuTree {
    def input
    def topdir
    def nodes = [:]
    def dirsizes = [:]
    def kids = [:]

    // get a node by name, create it if it does not exist yet
    def getOrCreateNode(name) {
        if (!nodes.containsKey(name))
            nodes[name] = new DuNode(name:name)
        return nodes[name]
    }

    // figure out how much is taken in each directory
    // that isn't stored in the subdirectories. Add a new
    // fake kid called "." containing that much.
    def getDots(node) {
        def cursize = node.size
        for (kid in node.kids) {
            cursize -=  kid.size
            getDots(kid)
        }
        if (node.size != cursize) {
            def newnode = getOrCreateNode(node.name + "/.")
            newnode.size = cursize
            node.kids += newnode
        }
    }

    def processInput() {
        def name = ''
        input.split('\n').findAll{it.trim()}.each{ line ->
            def tokens = line.tokenize()
            def size = tokens[0]
            name = tokens[1]
            def node = getOrCreateNode(name)
            node.size = size.toInteger()
            nodes[name] = node
            def parent = node.parent
            if (parent)
                getOrCreateNode(parent).kids << node
        }
        topdir = nodes[name]
    }

    // recursively output everything
    // passing padding and number width as well
    // on recursive calls
    def output(node, prefix='', width=0) {
        def line = node.size.toString().padRight(width) + ' ' + node.basename
        println (prefix + line)
        prefix += line.replaceAll(/\d /, '| ')
        prefix = prefix.replaceAll(/[^|]/, ' ')
        if (node.kids.size() > 0) {    // not a bachelor node
            kids = node.kids
            kids.sort{ a,b -> b.compareTo(a) }
            width = kids[0].size.toString().size()
            for (kid in kids) output(kid, prefix, width)
        }
    }
}

tree = new DuTree(input:duProcessFakedInput)
tree.processInput()
tree.getDots(tree.topdir)
tree.output(tree.topdir)
// =>
// 11966 groovysoap
//     |           11732 lib
//     |           202   src
//     |             |      102 test
//     |             |      77  main
//     |             |       |      74 groovy
//     |             |       |       |       71 net
//     |             |       |       |        |    68 soap
//     |             |       |       |        |    3  .
//     |             |       |       |       3  .
//     |             |       |      3  .
//     |             |      14  .
//     |             |      9   examples
//     |             |      |           8 groovy
//     |             |      |           1 .
//     |           32    .
//----------------------------------------------------------------------------------


// @@PLEAC@@_6.0
//----------------------------------------------------------------------------------
// Groovy has built-in language support for Regular Expressions:
// *  Strings quoted with '/' characters have special escaping
//    rules for backslashes and the like.
// *  ~string (regex pattern operator)
// *  m =~ /pattern/ (regex find operator)
// *  m ==~/pattern/ (regex match operator)
// *  patterns can be used in case expressions in a switch statement
// *  string.replaceAll can take a closure expression as the second argument
// In addition, Groovy can make use of Java's Pattern, Matcher and Scanner classes
// directly. (The sugar coating metnioed above sits on top of these anyway).
// There are also additional open source Java regex libraries which can be used.

meadow1 = 'cow grass butterflies Ovine'
meadow2 = 'goat sheep flowers dog'
// pattern strings can benefit from 'slashy' quotes
partial = /sheep/
full = /.*sheep.*/

// find operator
assert !(meadow1 =~ partial)
assert meadow2 =~ partial
finder = (meadow2 =~ partial)
// underneath Groovy sugar coating is Java implementation
assert finder instanceof java.util.regex.Matcher

// match operator
assert !(meadow1 ==~ full)
assert meadow2 ==~ full
matcher = (meadow2 ==~ full)
// under the covers is just a boolean
assert matcher instanceof Boolean

assert meadow1 =~ /(?i)\bovines?\b/ // (?i) == case flag

string = 'good food'
println string.replaceFirst(/o*/, 'e')
// => egood food
println string.replaceAll(/o*/, 'e')
// => egeede efeede (global)
// beware this one is just textual replacement
println string.replace(/o*/, 'e')
// => good food
println 'o*o*'.replace(/o*/, 'e')
// => ee

// groovy -e "m = args[0] =~ /(a|ba|b)+(a|ac)+/; if (m.matches()) println m[0][0]" ababacaca
// => ababa

digits = "123456789"
nonlap = digits =~ /\d\d\d/
assert nonlap.count == 3
print 'Non-overlapping:  '
(0..<nonlap.count).each{ print nonlap[it] + ' ' }; print '\n'
print 'Overlapping:      '
yeslap = (digits =~ /(?=(\d\d\d))/)
assert yeslap.count == 7
(0..<yeslap.count).each{ print yeslap[it][1] + ' ' }; print '\n'
// Non-overlapping:  123 456 789
// Overlapping:      123 234 345 456 567 678 789

string = 'And little lambs eat ivy'
// Greedy version
parts = string =~ /(.*)(l[^s]*s)(.*)/
(1..parts.groupCount()).each{ print "(${parts[0][it]}) " }; print '\n'
// (And little ) (lambs) ( eat ivy)

// Reluctant version
parts = string =~ /(.*?)(l[^s]*s)(.*)/
(1..parts.groupCount()).each{ print "(${parts[0][it]}) " }; print '\n'
// (And ) (little lambs) ( eat ivy)
//----------------------------------------------------------------------------------

// @@PLEAC@@_6.1
//----------------------------------------------------------------------------------
// Groovy splits src and dest to avoid this problem
src = 'Go this way'
dst = src.replaceFirst('this', 'that')
assert dst == 'Go that way'

// extract basename
src = 'c:/some/path/file.ext'
dst = src.replaceFirst('^.*/', '')
assert dst == 'file.ext'

// Make All Words Title-Cased (not that you would do it this way)
//  The preprocessing operations \X where X is one of l, u, L, and U are not supported
// in the sun regex library but other Java regex libraries may support this. Instead:
src = 'make all words title-cased'
dst = src
('a'..'z').each{ dst = dst.replaceAll(/([^a-zA-Z])/+it+/|\A/+it, /$1/+it.toUpperCase()) }
assert dst == 'Make All Words Title-Cased'

// rename list of dirs
bindirs = '/usr/bin /bin /usr/local/bin'.split(' ').toList()
expected = '/usr/lib /lib /usr/local/lib'.split(' ').toList()
libdirs = bindirs.collect { dir -> dir.replaceFirst('bin', 'lib') }
assert libdirs == expected
//----------------------------------------------------------------------------------

// @@PLEAC@@_6.2
//----------------------------------------------------------------------------------
// Groovy uses Java regex (other Java regex packages would also be possible)
// It doesn't support Locale-based settings but you can roll your own to some
// extent, you can use any Unicode characters as per below and you can use
// \p{Punct}    Punctuation: One of !"#$%&'()*+,-./:;<=>?@[\]^_`{|}~
// or the other special character classes
words = '''
silly
façade
coöperate
niño
Renée
Moliçre
hæmoglobin
naïve
tschüß
random!stuff#here\u0948
'''
results = ''
greekAlpha = '\u0391'
special = 'çéüßöñàæï?' + greekAlpha
// flag as either Y (alphabetic) or N (not)
words.split('\n').findAll{it.trim()}.each{ results += it ==~ /^[\w/+special+/]+$/ ?'Y':'N' }
assert results == 'YYYYYYYYYN'
results = ''
words.split('\n').findAll{it.trim()}.each{ results += it ==~ /^[^\p{Punct}]+$/ ?'Y':'N' }
assert results == 'YYYYYYYYYN'
//----------------------------------------------------------------------------------

// @@PLEAC@@_6.3
//----------------------------------------------------------------------------------
// as many non-whitespace bytes as possible
finder = 'abczqz z' =~ /a\S+z/
assert finder[0] == 'abczqz'

// as many letters, apostrophes, and hyphens
finder = "aAzZ'z-z0z" =~ /a[A-Za-z'-]+z/          //'
assert finder[0] == "aAzZ'z-z"

// selecting words
finder = '23rd Psalm' =~ /\b([A-Za-z]+)\b/   // usually best
println finder[0][0]
// => Psalm (23rd is not matched)
finder = '23rd Psalm' =~ /\s([A-Za-z]+)\s/   // fails at ends or w/ punctuation
println finder.matches()
// => false (no whitespaces at ends)
//----------------------------------------------------------------------------------

// @@PLEAC@@_6.4
//----------------------------------------------------------------------------------
str = 'groovy.codehaus.org and www.aboutgroovy.com'
re = '''(?x)          # to enable whitespace and comments
      (               # capture the hostname in $1
        (?:           # these parens for grouping only
          (?! [-_] )  # lookahead for neither underscore nor dash
          [\\w-] +    # hostname component
          \\.         # and the domain dot
        ) +           # now repeat that whole thing a bunch of times
        [A-Za-z]      # next must be a letter
        [\\w-] +      # now trailing domain part
      )               # end of $1 capture
     '''

finder = str =~ re
out = str
(0..<finder.count).each{
    adr = finder[it][0]
    out = out.replaceAll(adr, "$adr [${InetAddress.getByName(adr).hostAddress}]")
}
println out
// => groovy.codehaus.org [63.246.7.187] and www.aboutgroovy.com [63.246.7.76]

// to match whitespace or #-characters in an extended re you need to escape them.
foo = 42
str = 'blah #foo# blah'
re = '''(?x)         # to enable whitespace and comments
              \\#    # a pound sign
              (\\w+) # the variable name
              \\#    # another pound sign
     '''
finder = str =~ re
found = finder[0]
out = str.replaceAll(found[0], evaluate(found[1]).toString())
assert out == 'blah 42 blah'
//----------------------------------------------------------------------------------

// @@PLEAC@@_6.5
//----------------------------------------------------------------------------------
fish = 'One fish two fish red fish blue fish'
expected = 'The third fish is a red one.'
thirdFish = /(?:\w+\s+fish\s+){2}(\w+)\s+fish.*/
assert expected == (fish.replaceAll(thirdFish, 'The third fish is a $1 one.'))

anyFish = /(\w+)\s+fish\b/
finder = fish =~ anyFish
// finder contains an array of matched groups
// 2 = third one (index start at 0), 1 = matched word in group
out = "The third fish is a ${finder[2][1]} one."
assert out == expected

evens = []
(0..<finder.count).findAll{it%2!=0}.each{ evens += finder[it][1] }
println "Even numbered fish are ${evens.join(' ')}."
// => Even numbered fish are two blue.

// one of several ways to do this
pond = fish + ' in the pond'
fishInPond = (/(\w+)(\s+fish\b\s*)/) * 4 + /(.*)/
found = (pond =~ fishInPond)[0]
println ((found[1..6] + 'sushi' + found[8..9]).join())
// => One fish two fish red fish sushi fish in the pond

// find last fish
expected = 'Last fish is blue'
pond = 'One fish two fish red fish blue fish swim here.'
finder = (pond =~ anyFish)
assert expected == "Last fish is ${finder[finder.count-1][1]}"
// => Last fish is blue

// greedy match version of above
finder = (pond =~ /.*\b/ + anyFish)
assert expected == "Last fish is ${finder[0][1]}"

// last fish match version of above
finder = (pond =~ /\b(\w+)\s+fish\b(?!.*\bfish\b)/)
assert expected == "Last fish is ${finder[0][1]}"
//----------------------------------------------------------------------------------

// @@PLEAC@@_6.6
//----------------------------------------------------------------------------------
// Html Stripper
// get this using: fakedfile = new File('path_to_file.htm').text
fakedFile = '''
<html>
<head><title>Chapter 1 Title</title></head>
<body>
<h1>Chapter 1: Some Heading</h1>
A paragraph.
</body>
</html>
'''

stripExpectations = '''
Chapter 1 Title

Chapter 1: Some Heading
A paragraph.
'''.trim()

stripped = fakedFile.replaceAll(/(?m)<.*?>/,'').trim()
assert stripExpectations == stripped

pattern = '''(?x)
      (                    # capture in $1
          Chapter          # text string
          \\s+             # mandatory whitespace
          \\d+             # decimal number
          \\s*             # optional whitespace
          :                # a real colon
          . *              # anything not a newline till end of line
      )
'''

headerfyExpectations = '''
Chapter 1 Title

<H1>Chapter 1: Some Heading</H1>
A paragraph.
'''.trim()

headerfied = stripped.replaceAll(pattern, '<H1>$1</H1>')
assert headerfyExpectations == headerfied

// one liner equivalent which prints to stdout
//% groovy -p -e "line.replaceAll(/^(Chapter\s+\d+\s*:.*)/,'<H1>$1</H1>')"

// one liner equivalent which modifies file in place and creates *.bak original file
//% groovy -pi .bak -e "line.replaceAll(/^(Chapter\s+\d+\s*:.*)/,'<H1>$1</H1>')"

// use: realFileInput = new File(path_to_file).text
fakeFileInput = '''
0
START
1
2
END
3
4
5
START
6
END
'''

chunkyPattern = /(?ms)^START(.*?)^END/
finder = fakeFileInput =~ chunkyPattern
(0..<finder.count).each {
    println "Chunk #$it contains ${new StringTokenizer(finder[it][1],'\n').countTokens()} lines."
}
// =>
// Chunk #0 contains 2 lines.
// Chunk #1 contains 1 lines.
//----------------------------------------------------------------------------------

// @@PLEAC@@_6.7
//----------------------------------------------------------------------------------
// general pattern is:
//file = new File("datafile").text.split(/pattern/)
// .Ch, .Se and .Ss divide chunks of input text
fakedFiletext = '''
.Ch
abc
.Se
def
.Ss
ghi
.Se
jkl
.Se
mno
.Ss
pqr
.Ch
stu
.Ch
vwx
.Se
yz!
'''
chunks = fakedFiletext.split(/(?m)^\.(Ch|Se|Ss)$/)
println "I read ${chunks.size()} chunks."
// => I read 10 chunks.
//----------------------------------------------------------------------------------

// @@PLEAC@@_6.8
//----------------------------------------------------------------------------------
// Groovy doesn't support the ~/BEGIN/ .. ~/END/ notation
// you have to emulate it as shown in the example below
// The from line number to line number processing is supported
// from the command line but not within a script, e.g.
// command-line to print lines 15 through 17 inclusive (see below)
// > groovy -p -e "if (count in 15..17) return line" datafile
// Within a script itself, you emulate the count by keeping state

htmlContent = '''
<h1>A Heading</h1>
Here is <XMP>inline AAA</XMP>.
And the bigger Example 2:
<XMP>
line BBB
line CCC
</XMP>
Done.
'''.trim()

examplePattern = /(?ms)<XMP>(.*?)<\/XMP>/
finder = htmlContent =~ examplePattern
(0..<finder.count).each {
    println "Example ${it+1}:"
    println finder[it][1]
}
// =>
// Example 1:
// inline AAA
// Example 2:
//
// line BBB
// line CCC
//

htmlContent.split('\n').eachWithIndex{ line, count ->
    if (count in 4..5) println line
}
// =>
// line BBB
// line CCC

// You would probably use a mail Api for this in Groovy
fakedMailInput = '''
From: A Person <someone@somewhere.com>
To: <pleac-discuss@lists.sourceforge.net>
Date: Sun, 31 Dec 2006 02:14:57 +1100

From: noone@nowhere.com
To: <pleac-discuss@lists.sourceforge.net>
Date: Sun, 31 Dec 2006 02:14:58 +1100

From: someone@somewhere.com
To: <pleac-discuss@lists.sourceforge.net>
Date: Sun, 31 Dec 2006 02:14:59 +1100
'''.trim()+'\n'

seen = [:]
fakedMailInput.split('\n').each{ line ->
    m = (line =~ /^From:?\s(.*)/)
    if (m) {
        addr = m[0][1] =~ /([^<>(),;\s]+\@[^<>(),;\s]+)/
        x = addr[0][1]
        if (seen.containsKey(x)) seen[x] += 1 else seen[x] = 1
    }
}
seen.each{ k,v -> println "Address $k seen $v time${v==1?'':'s'}." }
// =>
// Address noone@nowhere.com seen 1 time.
// Address someone@somewhere.com seen 2 times.
//----------------------------------------------------------------------------------

// @@PLEAC@@_6.9
//----------------------------------------------------------------------------------
import java.util.regex.Pattern

names = '''
myFile.txt
oldFile.tex
myPicture.jpg
'''

def glob2pat(globstr) {
    def patmap = [ '*':'.*', '?':'.', '[':'[', ']':']' ]
    def result = '(?m)^'
    '^' + globstr.replaceAll(/(.)/) { all, c ->
        result += (patmap.containsKey(c) ? patmap[c] : Pattern.quote(c))
    }
     result + '$'
}

def checkNumMatches(pat, count) {
    assert (names =~ glob2pat(pat)).count == count
}

checkNumMatches('*.*', 3)
checkNumMatches('my*.*', 2)
checkNumMatches('*.t*', 2)
checkNumMatches('*File.*', 2)
checkNumMatches('*Rabbit*.*', 0)
//----------------------------------------------------------------------------------

// @@PLEAC@@_6.10
//----------------------------------------------------------------------------------
// version 1: simple obvious way
states = 'CO ON MI WI MN'.split(' ').toList()

def popgrep1(file) {
    file.eachLine{ line ->
        if (states.any{ line =~ /\b$it\b/ }) println line
    }
}
// popgrep1(new File('path_to_file'))

// version 2: eval strings; fast but hard to quote (SLOW)
def popgrep2(file) {
    def code = 'def found = false\n'
    states.each{
        code += "if (!found && line =~ /\\b$it\\b/) found = true\n"
    }
    code += "if (found) println line\n"
    file.eachLine{ line = it; evaluate(code) }
}
// popgrep2(new File('path_to_file'))

// version 2b: eval using switch/case (not in Perl cookbook) (SLOW)
def popgrep2b(file) {
    def code = 'switch(line) {\n'
    states.each{
        code += "case ~/.*\\b$it\\b.*/:\nprintln line;break\n"
    }
    code += "default:break\n}\n"
    file.eachLine{ line = it; evaluate(code) }
}
// popgrep2b(new File('path_to_file'))

// version3: build a match_any function as a GString
def popgrep3(file) {
    def code = states.collect{ "line =~ /\\b$it\\b/" }.join('||')
    file.eachLine{ line = it; if (evaluate(code)) println line }
}
// popgrep3(new File('path_to_file'))

// version4: pretty fast, but simple: compile all re's first:
patterns = states.collect{ ~/\b$it\b/ }
def popgrep4(file) {
    file.eachLine{ line ->
        if (patterns.any{ it.matcher(line)}) println line
    }
}
// popgrep4(new File('path_to_file'))

// version5: faster
str = states.collect{ /\b$it\b/ }.join('|')
def popgrep5(file) {
    file.eachLine{ line ->
        if (line =~ str) println line
    }
}
// popgrep5(new File('path_to_file'))

// version5b: faster (like 5 but compiled outside loop)
pattern = ~states.collect{ /\b$it\b/ }.join('|')
def popgrep5b(file) {
    file.eachLine{ line ->
        if (pattern.matcher(line)) println line
    }
}
// popgrep5b(new File('path_to_file'))

// speeds trials ON the current source file (~1200 lines)
// popgrep1   =>  0.39s
// popgrep2   => 25.08s
// popgrep2b  => 23.86s
// popgrep3   => 22.42s
// popgrep4   =>  0.12s
// popgrep5   =>  0.05s
// popgrep5b  =>  0.05s
// Groovy's built-in support is the way to go in terms of
// both speed and simplicity of understanding. Avoid using
// evaluate() unless you absolutely need it

// generic matching functions
input = '''
both cat and dog
neither
just a cat
just a dog
'''.split('\n').findAll{it.trim()}

def matchAny(line, patterns) { patterns.any{ line =~ it } }
def matchAll(line, patterns) { patterns.every{ line =~ it } }

assert input.findAll{ matchAny(it, ['cat','dog']) }.size() == 3
assert input.findAll{ matchAny(it, ['cat$','^n.*']) }.size() == 2
assert input.findAll{ matchAll(it, ['cat','dog']) }.size() == 1
assert input.findAll{ matchAll(it, ['cat$','^n.*']) }.size() == 0
//----------------------------------------------------------------------------------

// @@PLEAC@@_6.11
//----------------------------------------------------------------------------------
// patternCheckingScript:
prompt = '\n> '
print 'Enter patterns to check:' + prompt
new BufferedReader(new InputStreamReader(System.in)).eachLine{ line ->
    try {
        Pattern.compile(line)
        print 'Valid' + prompt
    } catch (java.util.regex.PatternSyntaxException ex) {
        print 'Invalid pattern: ' + ex.message + prompt
    }
}
// =>
// Enter patterns to check:
// > ab*.c
// Valid
// > ^\s+[^a-z]*$
// Valid
// > **
// Invalid pattern: Dangling meta character '*' near index 0
// **
// ^
//----------------------------------------------------------------------------------

// @@PLEAC@@_6.12
//----------------------------------------------------------------------------------
src = 'dierk könig'
// simplistic with locale issue
dst = src
('a'..'z').each{ dst = dst.replaceAll(/(?<=[^a-zA-Z])/+it+/|\A/+it, it.toUpperCase()) }
println dst
// => Dierk KöNig
// locale avoidance
dst = src
('a'..'z').each{ dst = dst.replaceAll(/(?<=\A|\b)/+it, it.toUpperCase()) }
println dst
// => Dierk König
//----------------------------------------------------------------------------------

// @@PLEAC@@_6.13
//----------------------------------------------------------------------------------
// Several libraries exist, e.g.
// http://secondstring.sourceforge.net/
// http://sourceforge.net/projects/simmetrics/
// both support numerous algorithms. Using the second as an example:
import uk.ac.shef.wit.simmetrics.similaritymetrics.*
target = 'balast'
candidates = '''
quick
brown
fox
jumped
over
the
lazy
dog
ballast
ballasts
balustrade
balustrades
blast
blasted
blaster
blasters
blasting
blasts
'''.split('\n').findAll{it.trim()}
metrics = [new Levenshtein(), new MongeElkan(), new JaroWinkler(), new Soundex()]
def out(name, results) {
    print name.padLeft(14) + '  '; results.each{print(it.padRight(16))}; println()
}
def outr(name, results){out(name, results.collect{''+((int)(it*100))/100})}
out ('Word/Metric', metrics.collect{it.shortDescriptionString} )
candidates.each{ w -> outr(w, metrics.collect{ m -> m.getSimilarity(target, w)} )}
// =>
//   Word/Metric  Levenshtein     MongeElkan      JaroWinkler     Soundex
//         quick  0               0.11            0               0.66
//         brown  0.16            0.23            0.5             0.73
//           fox  0               0.2             0               0.66
//        jumped  0               0.2             0               0.66
//          over  0               0.44            0               0.55
//           the  0               0.33            0               0.55
//          lazy  0.33            0.5             0.44            0.66
//           dog  0               0.2             0               0.66
//       ballast  0.85            0.83            0.96            1
//      ballasts  0.75            0.83            0.94            0.94
//    balustrade  0.5             0.93            0.3             0.94
//   balustrades  0.45            0.93            0.3             0.94
//         blast  0.83            0.8             0.88            1
//       blasted  0.57            0.66            0.8             0.94
//       blaster  0.57            0.66            0.8             0.94
//      blasters  0.5             0.66            0.77            0.94
//      blasting  0.5             0.66            0.77            0.94
//        blasts  0.66            0.66            0.84            0.94
// to implement the example, iterate through /usr/dict/words selecting words
// where one or a combination of metrics are greater than some threshold
//----------------------------------------------------------------------------------

// @@PLEAC@@_6.14
//----------------------------------------------------------------------------------
n = "   49 here"
println n.replaceAll(/\G /,'0')
// => 00049 here

str = "3,4,5,9,120"
print 'Found numbers:'
str.eachMatch(/\G,?(\d+)/){ print ' ' + it[1] }
println()
// => Found numbers: 3 4 5 9 120

// Groovy doesn't have the String.pos or a /c re modifier like Perl
// But it does have similar functionality. Matcher has start() and
// end() for find the position and Matcher's usePattern() allows
// you to swap patterns without changing the buffer position
text = 'the year 1752 lost 10 days on the 3rd of September'
p = ~/(?<=\D)(\d+)/
m = p.matcher(text)
while (m.find()) {
    println 'Found ' + m.group() + ' starting at pos ' + m.start() +
            ' and ending at pos ' + m.end()
}
// now reset pos back to between 1st and 2nd numbers
if (m.find(16)) { println 'Found ' + m.group() }
// =>
// Found 1752 starting at pos 9 and ending at pos 13
// Found 10 starting at pos 19 and ending at pos 21
// Found 3 starting at pos 34 and ending at pos 35
// Found 10

// Alternatively you can use Scanner in Java 5-7+:
p1 = ~/(?<=\D)(\d+)/
p2 = ~/\S+/
s = new Scanner(text)
while ((f = s.findInLine(p1))) { println 'Found: ' + f }
if ((f = s.findInLine(p2))) { println "Found $f after the last number." }
// =>
// Found: 1752
// Found: 10
// Found: 3
// Found rd after the last number.
//----------------------------------------------------------------------------------

// @@PLEAC@@_6.15
//----------------------------------------------------------------------------------
html = '<b><i>this</i> and <i>that</i> are important</b> Oh, <b><i>me too!</i></b>'

greedyHtmlStripPattern = ~/(?m)<.*>/       // not good
nonGreedyHtmlStripPattern = ~/(?m)<.*?>/   // not great
simpleNested = ~/(?mx)<b><i>(.*?)<\/i><\/b>/
// match BEGIN, then not BEGIN, then END
generalPattern = ~/BEGIN((?:(?!BEGIN).)*)END/
betterButInefficient1 = ~/(?mx)<b><i>(  (?: (?!<\/b>|<\/i>). )*  ) <\/i><\/b>/
betterButInefficient2 = ~/(?mx)<b><i>(  (?: (?!<\/[ib]>). )*  ) <\/i><\/b>/

efficientPattern = '''(?mx)
    <b><i>
    [^<]*  # stuff not possibly bad, and not possibly the end.
    (?:
 # at this point, we can have '<' if not part of something bad
     (?!  </?[ib]>  )   # what we can't have
     <                  # okay, so match the '<'
     [^<]*              # and continue with more safe stuff
    ) *
    </i></b>
'''                   //'
//----------------------------------------------------------------------------------

// @@PLEAC@@_6.16
//----------------------------------------------------------------------------------
input = 'This is a test\nTest of the duplicate word finder.\n'
dupWordPattern = '''(?ix)
       \\b    # start at word boundary
      (\\S+)  # find chunk of non-whitespace
       \\b    # until a word boundary
      (
       \\s+   # followed by whitespace
       \\1    # and that same chunk again
       \\b    # and a word boundary
      ) +     # one or more times
'''
finder = input =~ dupWordPattern
println 'Found duplicate word: ' + finder[0][1]
// => Found duplicate word: test

astr = 'nobody'
bstr = 'bodysnatcher'
m = "$astr $bstr" =~ /^(\w+)(\w+) \2(\w+)$/
actual = "${m[0][2]} overlaps in ${m[0][1]}-${m[0][2]}-${m[0][3]}"
assert actual == 'body overlaps in no-body-snatcher'

cap = 'o' * 180
while (m = (cap =~ /^(oo+?)\1+$/)) {
    p1 = m[0][1]
    print p1.size() + ' '
    cap = cap.replaceAll(p1,'o')
}
println cap.size()
// => 2 2 3 3 5

// diophantine
// solve for 12x + 15y + 16z = 281, maximizing x
if ((m = ('o' * 281) =~ /^(o*)\1{11}(o*)\2{14}(o*)\3{15}$/)) {
    x=m[0][1].size(); y=m[0][2].size(); z=m[0][3].size()
    println "One solution is: x=$x; y=$y; z=$z"
} else println "No solution."
// => One solution is: x=17; y=3; z=2

// using different quantifiers:
// /^(o+)\1{11}(o+)\2{14}(o+)\3{15}$/
// => One solution is: x=17; y=3; z=2

// /^(o*?)\1{11}(o*)\2{14}(o*)\3{15}$/
// => One solution is: x=0; y=7; z=11

// /^(o+?)\1{11}(o*)\2{14}(o*)\3{15}$/
// => One solution is: x=1; y=3; z=14
//----------------------------------------------------------------------------------

// @@PLEAC@@_6.17
//----------------------------------------------------------------------------------
// Groovy doesn't currently support x!~y so you must use the !(x=~y) style

// alpha OR beta
assert 'alpha' ==~ /alpha|beta/
assert 'beta' ==~ /alpha|beta/
assert 'betalpha' =~ /alpha/ || 'betalpha' =~ /beta/

// alpha AND beta
assert !('alpha' =~ /(?=.*alpha)(?=.*beta)/)
assert 'alphabeta' =~ /(?=.*alpha)(?=.*beta)/
assert 'betalpha' =~ /(?=.*alpha)(?=.*beta)/
assert 'betalpha' =~ /alpha/ && 'betalpha' =~ /beta/

// alpha AND beta,  no overlap
assert 'alphabeta' =~ /alpha.*beta|beta.*alpha/
assert !('betalpha' =~ /alpha.*beta|beta.*alpha/)

// NOT beta
assert 'alpha gamma' =~ /^(?:(?!beta).)*$/
assert !('alpha beta gamma' =~ /^(?:(?!beta).)*$/)

// NOT bad BUT good
assert !('GOOD and BAD' =~ /(?=(?:(?!BAD).)*$)GOOD/)
assert !('BAD' =~ /(?=(?:(?!BAD).)*$)GOOD/)
assert !('WORSE' =~ /(?=(?:(?!BAD).)*$)GOOD/)
assert 'GOOD' =~ /(?=(?:(?!BAD).)*$)GOOD/

// minigrep could be done as a one-liner as follows
// groovy -p -e "if (line =~ /pat/) return line" datafile

string = 'labelled'
assert string =~ /^(?=.*bell)(?=.*lab)/
assert string =~ /bell/ && string =~ 'lab'
fakeAddress = "blah bell blah "
murrayHillRegex = '''(?x)
             ^              # start of string
            (?=             # zero-width lookahead
                .*          # any amount of intervening stuff
                bell        # the desired bell string
            )               # rewind, since we were only looking
            (?=             # and do the same thing
                .*          # any amount of intervening stuff
                lab         # and the lab part
            )
'''
assert string =~ murrayHillRegex
assert !(fakeAddress =~ murrayHillRegex)

// eliminate overlapping
assert !(string =~ /(?:^.*bell.*lab)|(?:^.*lab.*bell)/)

brandRegex = '''(?x)
            (?:                 # non-capturing grouper
                ^ .*?           # any amount of stuff at the front
                  bell          # look for a bell
                  .*?           # followed by any amount of anything
                  lab           # look for a lab
              )                 # end grouper
        |                       # otherwise, try the other direction
            (?:                 # non-capturing grouper
                ^ .*?           # any amount of stuff at the front
                  lab           # look for a lab
                  .*?           # followed by any amount of anything
                  bell          # followed by a bell
              )                 # end grouper
'''
assert !(string =~ brandRegex)

map = 'the great baldo'

assert map =~ /^(?:(?!waldo).)*$/
noWaldoRegex = '''(?x)
        ^                   # start of string
        (?:                 # non-capturing grouper
            (?!             # look ahead negation
                waldo       # is he ahead of us now?
            )               # is so, the negation failed
            .               # any character (cuzza /s)
        ) *                 # repeat that grouping 0 or more
        $                   # through the end of the string
'''
assert map =~ noWaldoRegex

// on unix systems use: realFakedInput = 'w'.process().text
fakedInput = '''
 7:15am  up 206 days, 13:30,  4 users,  load average: 1.04, 1.07, 1.04
USER     TTY      FROM              LOGIN@  IDLE   JCPU   PCPU  WHAT
tchrist  tty1                       5:16pm 36days 24:43   0.03s  xinit
tchrist  tty2                       5:19pm  6days  0.43s  0.43s  -tcsh
tchrist  ttyp0    chthon            7:58am  3days 23.44s  0.44s  -tcsh
gnat     ttyS4    coprolith         2:01pm 13:36m  0.30s  0.30s  -tcsh
'''.trim() + '\n'

def miniGrepMethod(input) {
    input.split('\n').findAll{it =~ '^(?!.*ttyp).*tchrist'}
}
assert miniGrepMethod(fakedInput).size() == 2

findUserRegex = '''(?xm)
    ^                       # anchored to the start
    (?!                     # zero-width look-ahead assertion
        .*                  # any amount of anything (faster than .*?)
        ttyp                # the string you don't want to find
    )                       # end look-ahead negation; rewind to start
    .*                      # any amount of anything (faster than .*?)
    tchrist                 # now try to find Tom
'''
assert (fakedInput =~ findUserRegex).count == 2
//----------------------------------------------------------------------------------

// @@PLEAC@@_6.18
//----------------------------------------------------------------------------------
// Groovy uses Unicode character encoding
// special care needs to be taken when using unicode because of the different
// byte lengths, e.g. à can be encoded as two bytes \u0061\u0300 and is also
// supported in legacy character sets by a single character \u00E0.  To Match
// this character, you can't use any of /./, /../, /a/, /\u00E0/, /\u0061/\u0300
// or /\pL/. The correct way is to use /X (not currently supported) or one
// of /\pL/\pM*/ to ensure that it is a letter or /\PM\pM*/ when you just want
// to combine multicharacter sequences and don't care whether it is a letter
def checkUnicode(s) {
    println s + ' is of size ' + s.size()
    println 'Exactly matches /./   ' + (s ==~ /./)
    println 'Exactly matches /../  ' + (s ==~ /../)
    println 'Exactly matches /a/   ' + (s ==~ /a/)
    println 'Exactly matches /\\u00E0/       '  + (s ==~ /\u00E0/)
    println 'Exactly matches /\\u0061\\u0300/ ' + (s ==~ /\u0061\u0300/)
    println 'Exactly matches /\\pL/          '  + (s ==~ /\pL/)
    println 'Exactly matches /\\pL\\pM*/      ' + (s ==~ /\pL\pM*/)
    println 'Exactly matches /\\PM\\pM*/      ' + (s ==~ /\PM\pM*/)
}
checkUnicode('à')
checkUnicode('\u0061\u0300')
checkUnicode('\u00E0')
// =>
// à is of size 1
// Exactly matches /./   true
// Exactly matches /../  false
// Exactly matches /a/   false
// Exactly matches /\u00E0/       true
// Exactly matches /\u0061\u0300/ false
// Exactly matches /\pL/          true
// Exactly matches /\pL\pM*/      true
// Exactly matches /\PM\pM*/      true
// a? is of size 2
// Exactly matches /./   false
// Exactly matches /../  true
// Exactly matches /a/   false
// Exactly matches /\u00E0/       false
// Exactly matches /\u0061\u0300/ true
// Exactly matches /\pL/          false
// Exactly matches /\pL\pM*/      true
// Exactly matches /\PM\pM*/      true
// à is of size 1
// Exactly matches /./   true
// Exactly matches /../  false
// Exactly matches /a/   false
// Exactly matches /\u00E0/       true
// Exactly matches /\u0061\u0300/ false
// Exactly matches /\pL/          true
// Exactly matches /\pL\pM*/      true
// Exactly matches /\PM\pM*/      true
//----------------------------------------------------------------------------------

// @@PLEAC@@_6.19
//----------------------------------------------------------------------------------
// The Perl Cookbook categorizes this as a hard problem ... mostly for
// reasons not related to the actual regex - but with a 60-line regex
// perhaps there are some issues with that too. Further details:
// http://www.perl.com/CPAN/authors/Tom_Christiansen/scripts/ckaddr.gz

simpleCommentStripper = /\([^()]*\)/
println 'Book Publishing <marketing@books.com> (We will spam you)'.replaceAll(simpleCommentStripper, '')
// => Book Publishing <marketing@books.com>

// inspired by the fact that domain names can contain any foreign character these days
modern = /^.+@[^\.].*\.[a-z]{2,}>?$/

// .Net 
lenient = /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/

// a little more checking
strict = /^[_a-zA-Z0-9- <]+(\.[_a-zA-Z0-9- <]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\./ +
         /(([0-9]{1,3})|([a-zA-Z]{2,3})|(aero|coop|info|museum|name))>?$/

addresses = ['someuser@somehost.com',
             'Book Publishing <marketing@books.com>']
addresses.each{
    assert it =~ lenient
    assert it =~ strict
    assert it =~ modern
}

//----------------------------------------------------------------------------------

// @@PLEAC@@_6.20
//----------------------------------------------------------------------------------
def findAction(ans) {
    def re = '(?i)^' + Pattern.quote(ans)
    if      ("SEND"  =~ re) println "Action is send"
    else if ("STOP"  =~ re) println "Action is stop"
    else if ("ABORT" =~ re) println "Action is abort"
    else if ("EDIT"  =~ re) println "Action is edit"
    else println 'No Match'
}
findAction('edit something')
// => No Match
findAction('edit')
// => Action is edit
findAction('se')
// => Action is send
findAction('e')
// => Action is edit

def buildAbbrev(words) {
    def table = new TreeMap()
    words.each{ w ->
        (0..<w.size()).each { n ->
            if (!(words - w).any{
                it.size() >= n+1 && it[0..n] == w[0..n]
            }) table[w[0..n]] = w
        }
    }
    table
}
println buildAbbrev('send stop abort edit'.split(' ').toList())
// => ["a":"abort", "ab":"abort", "abo":"abort", "abor":"abort", "abort":"abort",
//     "e":"edit", "ed":"edit", "edi":"edit", "edit":"edit", "se":"send", "sen":"send",
//     "send":"send", "st":"stop", "sto":"stop", "stop":"stop"]

// miniShellScript:
// dummy methods
def invokeEditor() { println "invoking editor" }
def deliverMessage() { println "delivering message at " + new Date() }
actions = [
    edit:    this.&invokeEditor,
    send:    this.&deliverMessage,
    list:    { println Runtime.runtime.freeMemory() },
    abort:   { System.exit(0) },
    unknown: { println "Unknown Command"}
]

table = buildAbbrev(actions.keySet().toList())
prompt = '\n> '
print 'Enter Commands: edit send list abort' + prompt
new BufferedReader(new InputStreamReader(System.in)).eachLine{ line ->
    def idx = (table.containsKey(line)) ? table[line] : 'unknown'
    actions[idx]()
    print prompt
}
//----------------------------------------------------------------------------------

// @@PLEAC@@_6.21
//----------------------------------------------------------------------------------
//% gunzip -c ~/mail/archive.gz | urlify > archive.urlified
//% urlify ~/mail/*.inbox > ~/allmail.urlified

urls = '(https?|telnet|gopher|file|wais|ftp|mail)'
ltrs = /\w/
gunk = /\#\/~:.?+=&%@!\-/
punc = /.:?\-/
doll = /$/
all  = /$ltrs$gunk$punc/

findUrls = """(?ix)
        \\b                   # start at word boundary
        (                     # begin group 1  {
         $urls   :            # need resource and a colon
         [$all] +?            # followed by on or more of any valid
                              #  character, but be conservative and
                              #  take only what you need to...
        )                     # end   group 1  }
        (?=                   # look-ahead non-consumptive assertion
         [$punc]*             # either 0 or more punctuation
         [^$all]              #   followed by a non-url character
         |                    # or else
         $doll                #   then end of the string
        )
"""

input = '''
If you find a typo on http://groovy.codehaus.org please
send an email to mail:spelling.pedant@codehaus.org
'''

println input.replaceAll(findUrls,'<a href="$1">$1</a>')
// =>
// If you find a typo on <a href="http://groovy.codehaus.org">http://groovy.codehaus.org</a> please
// send an email to <a href="mail:spelling.pedant@codehaus.org">mail:spelling.pedant@codehaus.org</a>

// urlifyScript:
#!/usr/bin/groovy
// urlify - wrap HTML links around URL-like constructs
// definitions from above
args.each{ file ->
    new File(file).eachLine{ line ->
        println line.replaceAll(findUrls,'<a href="$1">$1</a>')
    }
}

//----------------------------------------------------------------------------------

// @@PLEAC@@_6.22
//----------------------------------------------------------------------------------
// @@INCOMPLETE@@
// @@INCOMPLETE@@

//----------------------------------------------------------------------------------

// @@PLEAC@@_6.23
//----------------------------------------------------------------------------------
romans = /(?i)^m*(d?c{0,3}|c[dm])(l?x{0,3}|x[lc])(v?i{0,3}|i[vx])$/
assert 'cmxvi' =~ romans
// can't have tens before 1000s (M) or 100s (C) after 5s (V)
assert !('xmvci' =~ romans)

// swap first two words
assert 'the words'.replaceAll(/(\S+)(\s+)(\S+)/, '$3$2$1') == 'words the'

// extract keyword and value
m = 'k=v' =~ /(\w+)\s*=\s*(.*)\s*$/
assert m.matches()
assert m[0][1] == 'k'
assert m[0][2] == 'v'

hasAtLeastSize = { n -> /.{$n,}/ }
assert 'abcdefghijklmnopqrstuvwxyz' =~ hasAtLeastSize(20)

// MM/DD/YY HH:MM:SS (lenient - doesn't check HH > 23 etc)
d = /\d+/
datetime = "($d)/($d)/($d) ($d):($d):($d)"
assert '04/05/2006 10:26:59' =~ datetime

orig = '/usr/bin/vi'
expected = '/usr/local/bin/vi'
orig.replaceAll('/usr/bin','/usr/local/bin') == expected

escapeSequenceRegex = /%([0-9A-Fa-f][0-9A-Fa-f])/
convertEscapeToChar = { Object[] ch -> new Character((char)Integer.parseInt(ch[1],16)) }
assert 'abc%3cdef'.replaceAll(escapeSequenceRegex, convertEscapeToChar) == 'abc<def'

commentStripper = '''(?xms)
    /\\*        # Match the opening delimiter
    .*          # Match a minimal number of characters */
    \\*/        # Match the closing delimiter
'''

input = '''
a line
/*
some comment
*/
another line
'''
expected = '''
a line

another line
'''

assert input.replaceAll(commentStripper,'') == expected

// emulate s.trim()
assert '  x  y  '.replaceAll(/^\s+/, '').replaceAll(/\s+$/, '') == 'x  y'

// convert \\n into \n
assert (/a\nb/.replaceAll(/\\n/,"\n") == 'a\nb')

// remove package symbol (Groovy/Java doesn't use this as package symbol)
assert 'A::B'.replaceAll(/^.*::/, '') == 'B'

// match IP Address (requires leading 0's)
ipregex = /^([01]?\d\d|2[0-4]\d|25[0-5])\.([01]?\d\d|2[0-4]\d|25[0-5])\./ +
    /([01]?\d\d|2[0-4]\d|25[0-5])\.([01]?\d\d|2[0-4]\d|25[0-5])$/
assert !('123.456.789' =~ ipregex)
assert '192.168.000.001' =~ ipregex

// extract basename
assert 'c:/usr/temp.txt'.replaceAll(/^.*\/{1}/, '') == 'temp.txt'

termcap = ':co#80:li#24:'
m = (termcap =~ /:co\#(\d+):/)
assert m.count == 1
assert m[0][1] == '80'

assert 'cmd c:/tmp/junk.txt'.replaceAll(/ \S+\/{1}/, ' ') == 'cmd junk.txt'

os = System.getProperty('os.name')
println 'Is Linux? ' + (os ==~ /(?i)linux.*/)
println 'Is Windows? ' + (os ==~ /(?i)windows.*/)
println 'Is Mac? ' + (os ==~ /(?i)mac.*/)

// join multiline sting
multi = '''
This is
    a test
'''.trim()
assert multi.replaceAll(/(?m)\n\s+/, ' ') == 'This is a test'

// nums in string
string = 'The 5th test was won today by 10 wickets after 10.5 overs'
nums = string =~ /(\d+\.?\d*|\.\d+)/
assert (0..<nums.count).collect{ nums[it][1] }.join(' ') == '5 10 10.5'

// capitalize words
words = 'the Capital words ARE hiding'
capwords = words =~ /(\b\p{Upper}+\b)/
assert (0..<capwords.count).collect{ capwords[it][1] }.join(' ') == 'ARE'

lowords = words =~ /(\b\p{Lower}+\b)/
assert (0..<lowords.count).collect{ lowords[it][1] }.join(' ') == 'the words hiding'

capWords = words =~ /(\b\p{Upper}\p{Lower}*\b)/
assert (0..<capWords.count).collect{ capWords[it][1] }.join(' ') == 'Capital'

input = '''
If you find a typo on <a href="http://groovy.codehaus.org">http://groovy.codehaus.org</a> please
send an email to <a href="mail:spelling.pedant@codehaus.org">mail:spelling.pedant@codehaus.org</a>
'''

linkRegex = /(?im)<A[^>]+?HREF\s*=\s*["']?([^'" >]+?)[ '"]?>/          //'
links = input =~ linkRegex
(0..<links.count).each{ println links[it][1] }
// =>
// http://groovy.codehaus.org
// mail:spelling.pedant@codehaus.org

// find middle initial if any
m = 'Lee Harvey Oswald' =~ /^\S+\s+(\S)\S*\s+\S/
initial = m.count ? m[0][1] : ""
assert initial == 'H'

// inch marks to quotes
println 'I said "Hello" to you.'.replaceAll(/"([^"]*)"/, /``$1''/)     //"
// => I said ``Hello'' to you.

// extract sentences (2 spaces or newline after punctuation)
input = '''
Is this a sentence?
Yes!  And so
is this.  And the fourth.
'''
sentences = []
strip = input.replaceAll(/(\p{Punct})\n/, '$1  ').replaceAll(/\n/, ' ').replaceAll(/ {3,}/,'  ')
m = strip =~ /(\S.*?\p{Punct})(?=  |\Z)/
(0..<m.count).each{ sentences += m[it][1] }
assert sentences == ["Is this a sentence?", "Yes!", "And so is this.", "And the fourth."]

// YYYY-MM-DD
m = '2007-2-28' =~ /(\d{4})-(\d\d?)-(\d\d?)/
assert m.matches()
assert ['2007', '2', '28'] == [m[0][1], m[0][2], m[0][3]]

usPhoneRegex = /^[01]?[- .]?(\([2-9]\d{2}\)|[2-9]\d{2})[- .]?\d{3}[- .]?\d{4}$/
numbers = '''
(425) 555-0123
425-555-0123
425 555 0123
1-425-555-0123
'''.trim().split('\n').toList()
assert numbers.every{ it ==~ usPhoneRegex }

exclaimRegex = /(?i)\boh\s+my\s+gh?o(d(dess(es)?|s?)|odness|sh)\b/
assert 'Oh my Goodness!' =~ exclaimRegex
assert !('Golly gosh' =~ exclaimRegex)

input = 'line 1\rline 2\nline\r\nline 3\n\rline 4'
m = input =~ /(?m)^([^\012\015]*)(\012\015?|\015\012?)/
assert m.count == 4


// @@PLEAC@@_6.22
// not an exact equivalent to original cookbook but has
// a reasonable subset of mostly similar functionality
// instead of -r recursion option, use Ant fileset wildcards
// e.g. **/*.c.  You can also specify an excludes pattern
// e.g. **/*.* -X **/*.h will process all but header files
// (currently not optimised and with minimal error checking)
// uses jopt-simple (jopt-simple.sf.net)

op = new joptsimple.OptionParser()
NOCASE  = 'i';  op.accepts( NOCASE,  "case insensitive" )
WITHN   = 'n';  op.accepts( WITHN,   "display line/para with line/para number" )
WITHF   = 'H';  op.accepts( WITHF,   "display line/para with filename" )
NONAME  = 'h';  op.accepts( NONAME,  "hide filenames" )
COUNT   = 'c';  op.accepts( COUNT,   "give count of lines/paras matching" )
TCOUNT  = 'C';  op.accepts( TCOUNT,  "give count of total matches (multiple per line/para)" )
WORD    = 'w';  op.accepts( WORD,    "word boundaries only" )
EXACT   = 'x';  op.accepts( EXACT,   "exact matches only" )
INVERT  = 'v';  op.accepts( INVERT,  "invert search sense (lines that DON'T match)" )
EXCLUDE = 'X';  op.accepts( EXCLUDE, "exclude files matching pattern [default is '**/*.bak']" ).
                    withRequiredArg().describedAs('path_pattern')
MATCH   = 'l';  op.accepts( MATCH,   "list names of files with matches" )
NOMATCH = 'L';  op.accepts( NOMATCH, "list names of files with no match" )
PARA    = 'p';  op.accepts( PARA,    "para mode (.* matches newlines)" ).
                    withOptionalArg().describedAs('para_pattern')
EXPR    = 'e';  op.accepts( EXPR,    "expression (when pattern begins with '-')" ).
                    withRequiredArg().describedAs('pattern')
FILE    = 'f';  op.accepts( FILE,    "file containing pattern" ).
                    withRequiredArg().describedAs('filename')
HELP = 'help';  op.accepts( HELP,    "display this message" )

options = op.parse(args)
params = options.nonOptionArguments()
if (options.wasDetected( HELP )) {
    op.printHelpOn( System.out )
} else if (params.size() == 0) {
    println "Usage: grep [OPTION]... PATTERN [FILE]...\nTry 'grep --$HELP' for more information."
} else {
    modifiers = []
    paraPattern = ''
    o_withn   = options.wasDetected( WITHN )
    o_withf   = options.wasDetected( WITHF )
    o_noname  = options.wasDetected( NONAME )
    o_count   = options.wasDetected( COUNT )
    o_tcount  = options.wasDetected( TCOUNT )
    o_invert  = options.wasDetected( INVERT )
    o_match   = options.wasDetected( MATCH )
    o_nomatch = options.wasDetected( NOMATCH )
    if (options.wasDetected( EXPR )) {
        pattern = options.valueOf( EXPR )
    } else if (options.wasDetected( FILE )) {
        pattern = new File(options.valueOf( FILE )).text.trim()
    } else {
        pattern = params[0]
        params = params[1..-1]
    }
    if (options.wasDetected( EXCLUDE )) excludes = options.valueOf( EXCLUDE )
    else excludes = ['**/*.bak']
    if (options.wasDetected( EXACT )) pattern = '^' + pattern + '$'
    else if (options.wasDetected( WORD )) pattern = /\b$pattern\b/
    if (options.wasDetected( NOCASE )) modifiers += 'i'
    if (options.wasDetected( PARA )) {
        if (options.hasArgument( PARA )) paraPattern = options.valueOf( PARA )
        else paraPattern = '^$'
        paraPattern = '(?sm)' + paraPattern
        modifiers += 'sm'
    }
    if (modifiers) pattern = "(?${modifiers.join()})" + pattern

    if (params.size() == 0) grepStream(System.in, '<stdin>')
    else {
        scanner = new AntBuilder().fileScanner {
            fileset(dir:'.', includes:params.join(','), excludes:excludes)
        }
        for (f in scanner) {
            grepStream(new FileInputStream(f), f)
        }
    }
}

def grepStream(s, name) {
    def count = 0
    def tcount = 0
    def pieces
    if (paraPattern) pieces = s.text.split(paraPattern)
    else pieces = s.readLines()
    def fileMode = o_match || o_nomatch || o_count || o_tcount
    pieces.eachWithIndex{line, index ->
        def m = line =~ pattern
        boolean found = m.count
        if (found != o_invert) {
            count++
            tcount += m.count
            if (!fileMode) {
                linefields = []
                if (o_withf) linefields += name
                if (o_withn) linefields += index + 1
                linefields += line
                println linefields.join(':')
            }
        }
    }
    def display = true
    if ((o_match && count == 0) || (o_nomatch && count != 0)) display = false
    if (fileMode && display) {
        filefields = []
        if (!o_noname) filefields += name
        if (o_tcount) filefields += tcount
        else if (o_count) filefields += count
        println filefields.join(':')
    }
}
//----------------------------------------------------------------------------------


// @@PLEAC@@_7.0
//----------------------------------------------------------------------------------
//testfile = new File('/usr/local/widgets/data')  // unix
testfile = new File('Pleac/data/blue.txt')      // windows
testfile.eachLine{ if (it =~ /blue/) println it }

// Groovy (like Java) uses the File class as an abstraction for
// the path representing a potential file system resource.
// Channels and Streams (along with Reader adn Writer helper
// classes) are used to read and write to files (and other
// things). Files, channels, streams etc are all "normal"
// objects; they can be passed around in your programs just
// like other objects (though there are some restrictions
// covered elsewhere - e.g. you can't expect to pass a File
// object between JVMs on different machines running different
// operating systems and expect them to maintain a meaningful
// value across the different JVMs). In addition to Streams,
// there is also support for random access to files.

// Many operations are available on streams and channels. Some
// return values to indicate success or failure, some can throw
// exceptions, other times both styles of error reporting may be
// available.

// Streams at the lowest level are just a sequence of bytes though
// there are various abstractions at higher levels to allow
// interacting with streams at encoded character, data type or
// object levels if desired. Standard streams include System.in,
// System.out and System.err. Java and Groovy on top of that
// provide facilities for buffering, filtering and processing
// streams in various ways.

// File channels provide more powerful operations than streams
// for reading and writing files such as locks, buffering,
// positioning, concurrent reading and writing, mapping to memory
// etc. In the examples which follow, streams will be used for
// simple cases, channels when more advanced features are
// required. Groovy currently focusses on providing extra support
// at the file and stream level rather than channel level.
// This makes the simple things easy but lets you do more complex
// things by just using the appropriate Java classes. All Java
// classes are available within Groovy by default.

// Groovy provides syntactic sugar over the top of Java's file
// processing capabilities by providing meaning to shorthand
// operators and by automatically handling scaffolding type
// code such as opening, closing and handling exceptions behind
// the scenes. It also provides many powerful closure operators,
// e.g. file.eachLineMatch(pattern){ some_operation } will open
// the file, process it line-by-line, finding all lines which
// match the specified pattern and then invoke some operation
// for the matching line(s) if any, before closing the file.


// this example shows how to access the standard input stream
// numericCheckingScript:
prompt = '\n> '
print 'Enter text including a digit:' + prompt
new BufferedReader(new InputStreamReader(System.in)).eachLine{ line ->
                                               // line is read from System.in
    if (line =~ '\\d') println "Read: $line"   // normal output to System.out
    else System.err.println 'No digit found.'  // this message to System.err
}
//----------------------------------------------------------------------------------

// @@PLEAC@@_7.1
//----------------------------------------------------------------------------------
// test values (change for your os and directories)
inputPath='Pleac/src/pleac7.groovy'; outPath='Pleac/temp/junk.txt'

// For input Java uses InputStreams (for byte-oriented processing) or Readers
// (for character-oriented processing). These can throw FileNotFoundException.
// There are also other stream variants: buffered, data, filters, objects, ...
inputFile = new File(inputPath)
inputStream = new FileInputStream(inputFile)
reader = new FileReader(inputFile)
inputChannel = inputStream.channel

// Examples for random access to a file
file = new RandomAccessFile(inputFile, "rw") // for read and write
channel = file.channel

// Groovy provides some sugar coating on top of Java
println inputFile.text.size()
// => 13496

// For output Java use OutputStreams or Writers. Can throw FileNotFound
// or IO exceptions. There are also other flavours of stream: buffered,
// data, filters, objects, ...
outFile = new File(outPath)
appendFlag = false
outStream = new FileOutputStream(outFile, appendFlag)
writer = new FileWriter(outFile, appendFlag)
outChannel = outStream.channel

// Also some Groovy sugar coating
outFile << 'A Chinese sailing vessel'
println outFile.text.size() // => 24

// @@PLEAC@@_7.2
//----------------------------------------------------------------------------------
// No problem with Groovy since the filename doesn't contain characters with
// special meaning; like Perl's sysopen. Options are either additional parameters
// or captured in different classes, e.g. Input vs Output, Buffered vs non etc.
new FileReader(inputPath)
//----------------------------------------------------------------------------------

// @@PLEAC@@_7.3
//----------------------------------------------------------------------------------
// '~' is a shell expansion feature rather than file system feature per se.
// Because '~' is a valid filename character in some operating systems, and Java
// attempts to be cross-platform, it doesn't automatically expand Tilde's.
// Given that '~' expansion is commonly used however, Java puts the $HOME
// environment variable (used by shells to do typical expansion) into the
// "user.home" system property. This works across operating systems - though
// the value inside differs from system to system so you shouldn't rely on its
// content to be of a particular format. In most cases though you should be
// able to write a regex that will work as expected. Also, Apple's
// NSPathUtilities can expand and introduce Tildes on platforms it supports.
path = '~paulk/.cvspass'
name = System.getProperty('user.name')
home = System.getProperty('user.home')
println home + path.replaceAll("~$name(.*)", '$1')
// => C:\Documents and Settings\Paul/.cvspass
//----------------------------------------------------------------------------------

// @@PLEAC@@_7.4
//----------------------------------------------------------------------------------
// The exception raised in Groovy reports the filename
try {
    new File('unknown_path/bad_file.ext').text
} catch (Exception ex) {
    System.err.println(ex.message)
}
// =>
// unknown_path\bad_file.ext (The system cannot find the path specified)
//----------------------------------------------------------------------------------

// @@PLEAC@@_7.5
//----------------------------------------------------------------------------------
try {
    temp = File.createTempFile("prefix", ".suffix")
    temp.deleteOnExit()
} catch (IOException ex) {
    System.err.println("Temp file could not be created")
}
//----------------------------------------------------------------------------------

// @@PLEAC@@_7.6
//----------------------------------------------------------------------------------
// no special features are provided, here is a way to do it manually
// DO NOT REMOVE THE FOLLOWING STRING DEFINITION.
pleac_7_6_embeddedFileInfo = '''
Script size is 13731
Last script update: Wed Jan 10 19:05:58 EST 2007
'''
ls = System.getProperty('line.separator')
file = new File('Pleac/src/pleac7.groovy')
regex = /(?ms)(?<=^pleac_7_6_embeddedFileInfo = ''')(.*)(?=^''')/
def readEmbeddedInfo() {
    m = file.text =~ regex
    println 'Found:\n' + m[0][1]
}
def writeEmbeddedInfo() {
    lastMod = new Date(file.lastModified())
    newInfo = "${ls}Script size is ${file.size()}${ls}Last script update: ${lastMod}${ls}"
    file.write(file.text.replaceAll(regex, newInfo))
}
readEmbeddedInfo()
// writeEmbeddedInfo()  // uncomment to make script update itself
// readEmbeddedInfo()   // uncomment to redisplay the embedded info after the update

// => (output when above two method call lines are uncommented)
// Found:
//
// Script size is 13550
// Last script update: Wed Jan 10 18:56:03 EST 2007
//
// Found:
//
// Script size is 13731
// Last script update: Wed Jan 10 19:05:58 EST 2007
//----------------------------------------------------------------------------------

// @@PLEAC@@_7.7
//----------------------------------------------------------------------------------
// general pattern for reading from System.in is:
// System.in.readLines().each{ processLine(it) }

// general pattern for a filter which can either process file args or read from System.in is:
// if (args.size() != 0) args.each{
//     file -> new File(file).eachLine{ processLine(it) }
// } else System.in.readLines().each{ processLine(it) }

// note: the following examples are file-related per se. They show
// how to do option processing in scenarios which typically also
// involve file arguments. The reader should also consider using a
// pre-packaged options parser package (there are several popular
// ones) rather than the hard-coded processing examples shown here.

chopFirst = false
columns = 0
args = ['-c', '-30', 'somefile']

// demo1: optional c
if (args[0] == '-c') {
    chopFirst = true
    args = args[1..-1]
}

assert args == ["-30", "somefile"]
assert chopFirst

// demo2: processing numerical options
if (args[0] =~ /^-(\d+)$/) {
    columns = args[0][1..-1].toInteger()
    args = args[1..-1]
}

assert args == ["somefile"]
assert columns == 30

// demo3: multiple args (again consider option parsing package)
args = ['-n','-a','file1','file2']
nostdout = false
append = false
unbuffer = false
ignore_ints = false
files = []
args.each{ arg ->
    switch(arg) {
        case '-n': nostdout    = true; break
        case '-a': append      = true; break
        case '-u': unbuffer    = true; break
        case '-i': ignore_ints = true; break
        default: files += arg
    }
}
if (files.any{ it.startsWith('-')}) {
    System.err.println("usage: demo3 [-ainu] [filenames]")
}
// process files ...
assert nostdout && append && !unbuffer && !ignore_ints
assert files == ['file1','file2']

// find login: print all lines containing the string "login" (command-line version)
//% groovy -ne "if (line =~ 'login') println line" filename

// find login variation: lines containing "login" with line number (command-line version)
//% groovy -ne "if (line =~ 'login') println count + ':' + line" filename

// lowercase file (command-line version)
//% groovy -pe "line.toLowerCase()"


// count chunks but skip comments and stop when reaching "__DATA__" or "__END__"
chunks = 0; done = false
testfile = new File('Pleac/data/chunks.txt') // change on your system
lines = testfile.readLines()
for (line in lines) {
    if (!line.trim()) continue
    words = line.split(/[^\w#]+/).toList()
    for (word in words) {
        if (word =~ /^#/) break
        if (word in ["__DATA__", "__END__"]) { done = true; break }
        chunks += 1
    }
    if (done) break
}
println "Found $chunks chunks"


// groovy "one-liner" (cough cough) for turning .history file into pretty version:
//% groovy -e "m=new File(args[0]).text=~/(?ms)^#\+(\d+)\r?\n(.*?)$/;(0..<m.count).each{println ''+new Date(m[it][1].toInteger())+'  '+m[it][2]}" .history
// =>
// Sun Jan 11 18:26:22 EST 1970  less /etc/motd
// Sun Jan 11 18:26:22 EST 1970  vi ~/.exrc
// Sun Jan 11 18:26:22 EST 1970  date
// Sun Jan 11 18:26:22 EST 1970  who
// Sun Jan 11 18:26:22 EST 1970  telnet home
//----------------------------------------------------------------------------------


// @@PLEAC@@_7.8
//----------------------------------------------------------------------------------
// test data for below
testPath = 'Pleac/data/process.txt'

// general pattern
def processWithBackup(inputPath, Closure processLine) {
    def input = new File(inputPath)
    def out = File.createTempFile("prefix", ".suffix")
    out.write('') // create empty file
    count = 0
    input.eachLine{ line ->
        count++
        processLine(out, line, count)
    }
    def dest = new File(inputPath + ".orig")
    dest.delete() // clobber previous backup
    input.renameTo(dest)
    out.renameTo(input)
}

// use withPrintWriter if you don't want the '\n''s appearing
processWithBackup(testPath) { out, line, count ->
    if (count == 20) {   // we are at the 20th line
        out << "Extra line 1\n"
        out << "Extra line 2\n"
    }
    out << line + '\n'
}

processWithBackup(testPath) { out, line, count ->
    if (!(count in 20..30)) // skip the 20th line to the 30th
        out << line + '\n'
}
// equivalent to "one-liner":
//% groovy -i.orig -pe "if (!(count in 20..30)) out << line" testPath
//----------------------------------------------------------------------------------


// @@PLEAC@@_7.9
//----------------------------------------------------------------------------------
//% groovy -i.orig -pe 'FILTER COMMAND' file1 file2 file3 ...

// the following may also be possible on unix systems (unchecked)
//#!/usr/bin/groovy -i.orig -p
// filter commands go here

// "one-liner" templating scenario: change DATE -> current time
//% groovy -pi.orig -e 'line.replaceAll(/DATE/){new Date()}'

//% groovy -i.old -pe 'line.replaceAll(/\bhisvar\b/, 'hervar')' *.[Cchy] (globbing platform specific)

// one-liner for correcting spelling typos
//% groovy -i.orig -pe 'line.replaceAll(/\b(p)earl\b/i, '\1erl')' *.[Cchy] (globbing platform specific)
//----------------------------------------------------------------------------------


// @@PLEAC@@_7.10
//----------------------------------------------------------------------------------
// general pattern
def processFileInplace(file, Closure processText) {
    def text = file.text
    file.write(processText(text))
}

// templating scenario: change DATE -> current time
testfile = new File('Pleac/data/pleac7_10.txt') // replace on your system
processFileInplace(testfile) { text ->
    text.replaceAll(/(?m)DATE/, new Date().toString())
}
//----------------------------------------------------------------------------------


// @@PLEAC@@_7.11
//----------------------------------------------------------------------------------
// You need to use Java's Channel class to acquire locks. The exact
// nature of the lock is somewhat dependent on the operating system.
def processFileWithLock(file, processStream) {
    def random = new RandomAccessFile(file, "rw")
    def lock = random.channel.lock() // acquire exclusive lock
    processStream(random)
    lock.release()
    random.close()
}

// Instead of an exclusive lock you can acquire a shared lock.

// Also, you can acquire a lock for a region of a file by specifying
// start and end positions of the region when acquiring the lock.

// For non-blocking functionality, use tryLock() instead of lock().
def processFileWithTryLock(file, processStream) {
    random = new RandomAccessFile(file, "rw")
    channel = random.channel
    def MAX_ATTEMPTS = 30
    for (i in 0..<MAX_ATTEMPTS) {
        lock = channel.tryLock()
        if (lock != null) break
        println 'Could not get lock, pausing ...'
        Thread.sleep(500) // 500 millis = 0.5 secs
    }
    if (lock == null) {
        println 'Unable to acquire lock, aborting ...'
    } else {
        processStream(random)
        lock.release()
    }
    random.close()
}


// non-blocking multithreaded example: print first line while holding lock
Thread.start{
    processFileWithLock(testfile) { source ->
        println 'First reader: ' + source.readLine().toUpperCase()
        Thread.sleep(2000) // 2000 millis = 2 secs
    }
}
processFileWithTryLock(testfile) { source ->
    println 'Second reader: ' + source.readLine().toUpperCase()
}
// =>
// Could not get lock, pausing ...
// First reader: WAS LOWERCASE
// Could not get lock, pausing ...
// Could not get lock, pausing ...
// Could not get lock, pausing ...
// Could not get lock, pausing ...
// Second reader: WAS LOWERCASE
//----------------------------------------------------------------------------------


// @@PLEAC@@_7.12
//----------------------------------------------------------------------------------
// In Java, input and output streams have a flush() method and file channels
// have a force() method (applicable also to memory-mapped files). When creating
// PrintWriters and // PrintStreams, an autoFlush option can be provided.
// From a FileInput or Output Stream you can ask for the FileDescriptor
// which has a sync() method - but you wouldn't you'd just use flush().

inputStream = testfile.newInputStream()    // returns a buffered input stream
autoFlush = true
printStream = new PrintStream(outStream, autoFlush)
printWriter = new PrintWriter(outStream, autoFlush)
//----------------------------------------------------------------------------------


// @@PLEAC@@_7.13
//----------------------------------------------------------------------------------
// See the comments in 7.14 about scenarios where non-blocking can be
// avoided. Also see 7.14 regarding basic information about channels.
// An advanced feature of the java.nio.channels package is supported
// by the Selector and SelectableChannel classes. These allow efficient
// server multiplexing amongst responses from a number of potential sources.
// Under the covers, it allows mapping to native operating system features
// supporting such multiplexing or using a pool of worker processing threads
// much smaller in size than the total available connections.
//
// The general pattern for using selectors is:
//
//      while (true) {
//         selector.select()
//         def it = selector.selectedKeys().iterator()
//         while (it.hasNext()) {
//            handleKey(it++)
//            it.remove()
//         }
//      }
//----------------------------------------------------------------------------------


// @@PLEAC@@_7.14
//----------------------------------------------------------------------------------
// Groovy has no special support for this apart from making it easier to
// create threads (see note at end); it relies on Java's features here.

// InputStreams in Java/Groovy block if input is not yet available.
// This is not normally an issue, because if you have a potential blocking
// operation, e.g. save a large file, you normally just create a thread
 // and save it in the background.

// Channels are one way to do non-blocking stream-based IO.
// Classes which implement the AbstractSelectableChannel interface provide
// a configureBlocking(boolean) method as well as an isBlocking() method.
// When processing a non-blocking stream, you need to process incoming
// information based on the number of bytes read returned by the various
// read methods. For non-blocking, this can be 0 bytes even if you pass
// a fixed size byte[] buffer to the read method. Non-blocking IO is typically
// not used with Files but more normally with network streams though they
// can when Pipes (couple sink and source channels) are involved where
// one side of the pipe is a file.
//----------------------------------------------------------------------------------


// @@PLEAC@@_7.15
//----------------------------------------------------------------------------------
// Groovy uses Java's features here.
// For both blocking and non-blocking reads, the read operation returns the number
// of bytes read. In blocking operations, this normally corresponds to the number
// of bytes requested (typically the size of some buffer) but can have a smaller
// value at the end of a stream. Java also makes no guarantees about whether
// other streams in general will return bytes as they become available under
// certain circumstances (rather than blocking until the entire buffer is filled.
// In non-blocking operations, the number of bytes returned will typically be
// the number of bytes available (up to some maximum buffer or requested size).
//----------------------------------------------------------------------------------


// @@PLEAC@@_7.16
//----------------------------------------------------------------------------------
// This just works in Java and Groovy as per the previous examples.
//----------------------------------------------------------------------------------

// @@PLEAC@@_7.17
//----------------------------------------------------------------------------------
// Groovy uses Java's features here.
// More work has been done in the Java on object caching than file caching
// with several open source and commercial offerings in that area. File caches
// are also available, for one, see:
// http://portals.apache.org/jetspeed-1/apidocs/org/apache/jetspeed/cache/FileCache.html
//----------------------------------------------------------------------------------

// @@PLEAC@@_7.18
//----------------------------------------------------------------------------------
// The general pattern is: streams.each{ stream -> stream.println 'item to print' }
// See the MultiStream example in 13.5 for a coded example.
//----------------------------------------------------------------------------------

// @@PLEAC@@_7.19
//----------------------------------------------------------------------------------
// You wouldn't normally be dealing with FileDescriptors. In case were you have
// one you would normally walk through all known FileStreams asking each for
// it's FileDescriptor until you found one that matched. You would then close
// that stream.
//----------------------------------------------------------------------------------

// @@PLEAC@@_7.20
//----------------------------------------------------------------------------------
// There are several concepts here. At the object level, any two object references
// can point to the same object. Any changes made by one of these will be visible
// in the 'alias'. You can also have multiple stream, reader, writer or channel objects
// referencing the same resource. Depending on the kind of resource, any potential
// locks, the operations being requested and the behaviour of third-party programs,
// the result of trying to perform such concurrent operations may not always be
// deterministic. There are strategies for coping with such scenarious but the
// best bet is to avoid the issue.

// For the scenario given, copying file handles, that corresponds most closely
// with cloning streams. The best bet is to just use individual stream objects
// both created from the same file. If you are attempting to do write operations,
// then you should consider using locks.
//----------------------------------------------------------------------------------

// @@PLEAC@@_7.21
//----------------------------------------------------------------------------------
// locking is built in to Java (since 1.4), so should not be missing
//----------------------------------------------------------------------------------

// @@PLEAC@@_7.22
//----------------------------------------------------------------------------------
// Java locking supports locking just regions of files.
//----------------------------------------------------------------------------------


// @@PLEAC@@_8.0
//----------------------------------------------------------------------------------
datafile = new File('Pleac/data/pleac8_0.txt') // change on your system

datafile.eachLine{ line -> print line.size() }

lines = datafile.readLines()

wholeTextFile = datafile.text

// on command line Groovy use -a auto split pattern instead of record separator
// default pattern is /\s/
// groovy -a -e 'println "First word is ${split[0][1]}"'

// (additional examples to original cookbook to illustrate -a)
// Print processes owned by root:
// ps aux|groovy -ane "if(split[0][1] =~ 'root')println split[0][10..-1]"

// Print all logins from /etc/passwd that are not commented:
// groovy -a':' -ne "if(!(split[0][1] =~ /^#/))println split[0][1]" /etc/passwd

// Add the first and the penultimate column of a file:
// groovy -ape "split[0][1].toInteger()+split[0][-2].toInteger()" accounts.txt

// no BEGIN and END in Groovy (has been proposed, may be added soon)

datafile.withOutputStream{ stream ->
    stream.print "one" + "two" + "three"    // "onetwothree" -> file
    println "Baa baa black sheep."          // sent to $stdout
}

// use streams or channels for advanced file handling
int size = datafile.size()
buffer = ByteBuffer.allocate(size) // for large files, use some block size, e.g. 4096
channel = new FileInputStream(datafile).channel
println "Number of bytes read was: ${channel.read(buffer)}" // -1 = EOF

channel = new FileOutputStream(File.createTempFile("pleac8", ".junk")).channel
size = channel.size()
channel.truncate(size) // shrinks file (in our case to same size)

pos = channel.position()
println "I'm $pos bytes from the start of datafile"
channel.position(pos)  // move to pos (in our case unchanged)
channel.position(0)    // move to start of file
channel.position(size) // move to end of file

// no sysread and syswrite are available but dataInput/output streams
// can be used to achieve similar functionality, see 8.15.
//----------------------------------------------------------------------------------


// @@PLEAC@@_8.1
//----------------------------------------------------------------------------------
testfile = new File('Pleac/data/pleac8_1.txt') // change on your system
// contents of testfile:
// DISTFILES = $(DIST_COMMON) $(SOURCES) $(HEADERS) \
//         $(TEXINFOS) $(INFOS) $(MANS) $(DATA)
// DEP_DISTFILES = $(DIST_COMMON) $(SOURCES) $(HEADERS) \
//         $(TEXINFOS) $(INFO_DEPS) $(MANS) $(DATA) \
//         $(EXTRA_DIST)

lines = []
continuing = false
regex = /\\$/
testfile.eachLine{ line ->
    stripped = line.replaceAll(regex,'')
    if (continuing) lines[-1] += stripped
    else lines += stripped
    continuing = (line =~ regex)
}
println lines.join('\n')
// =>
// DISTFILES = $(DIST_COMMON) $(SOURCES) $(HEADERS)         $(TEXINFOS) $(INFOS) $(MANS) $(DATA)
// DEP_DISTFILES = $(DIST_COMMON) $(SOURCES) $(HEADERS)         $(TEXINFOS) $(INFO_DEPS) $(MANS) $(DATA)         $(EXTRA_DIST)

// to remove hidden spaces after the slash (but keep the slash):
def trimtail(line) {
    line = line.replaceAll(/(?<=\\)\s*$/, '')
}
b = /\\/  // backslash
assert "abc  $b"   == trimtail("abc  $b")
assert "abc  "     == trimtail("abc  ")
assert "abc  $b"   == trimtail("abc  $b  ")
//----------------------------------------------------------------------------------


// @@PLEAC@@_8.2
//----------------------------------------------------------------------------------
// unixScript:
println ("wc -l < $filename".execute().text)

// for small files which fit in memory
println testfile.readLines().size()

// streaming approach (lines and paras)
lines = 0; paras = 1
testfile.eachLine{ lines++; if (it =~ /^$/) paras++ }
println "Found $lines lines and $paras paras."
// note: counts blank line at end as start of next empty para

// with a StreamTokenizer
st = new StreamTokenizer(testfile.newReader())
while (st.nextToken() != StreamTokenizer.TT_EOF) {}
println st.lineno()
//----------------------------------------------------------------------------------


// @@PLEAC@@_8.3
//----------------------------------------------------------------------------------
// general pattern
def processWordsInFile(file, processWord) {
    testfile.splitEachLine(/\W+/) { matched ->
        matched.each{ w -> if (w) processWord(w) }
    }
}

testfile = new File('Pleac/src/pleac8.groovy')  // change path on your system

// count words
count = 0
processWordsInFile(testfile){ count++ }
println count

// (variation to Perl example)
// with a StreamTokenizer (counting words and numbers in Pleac chapter 8 source file)
words = 0; numbers = 0
st = new StreamTokenizer(testfile.newReader())
st.slashSlashComments(true) // ignore words and numbers in comments
while (st.nextToken() != StreamTokenizer.TT_EOF) {
    if (st.ttype == StreamTokenizer.TT_WORD) words++
    else if (st.ttype == StreamTokenizer.TT_NUMBER) numbers++
}
println "Found $words words and $numbers numbers."


// word frequency count
seen = [:]
processWordsInFile(testfile) {
    w = it.toLowerCase()
    if (seen.containsKey(w)) seen[w] += 1
    else seen[w] = 1
}
// output map in a descending numeric sort of its values
seen.entrySet().sort { a,b -> b.value <=> a.value }.each{ e ->
    printf("%5d %s\n", [e.value, e.key] )
}
// =>
//    25 pleac
//    22 line
//    20 file
//    19 println
//    19 lines
//    13 testfile
//    ...
//----------------------------------------------------------------------------------


// @@PLEAC@@_8.4
//----------------------------------------------------------------------------------
testfile.readLines().reverseEach{
    println it
}

lines = testfile.readLines()
// normally one would use the reverseEach, but you can use
// a numerical index if you want
((lines.size() - 1)..0).each{
    println lines[it]
}

// Paragraph-based processing could be done as in 8.2.

// A streaming-based solution could use random file access
// and have a sliding buffer working from the back of the
// file to the front.
//----------------------------------------------------------------------------------


// @@PLEAC@@_8.5
//----------------------------------------------------------------------------------
logfile = new File('Pleac/data/sampleLog.txt')
// logTailingScript:
sampleInterval = 2000 // 2000 millis = 2 secs
file = new RandomAccessFile( logfile, "r" )
filePointer = 0 // set to logfile.size() to begin tailing from the end of the file
while( true ) {
    // Compare the length of the file to the file pointer
    long fileLength = logfile.size()
    if( fileLength < filePointer ) {
        // Log file must have been rotated or deleted;
        System.err.println "${new Date()}: Reopening $logfile"
        file = new RandomAccessFile( logfile, "r" )
        filePointer = 0
    }
    if( fileLength > filePointer ) {
        // There is data to read
        file.seek( filePointer )
        while( (line = file.readLine()) != null ) {
            println '##' + line
        }
        filePointer = file.filePointer
    }
    // Sleep for the specified interval
    Thread.sleep( sampleInterval )
}
//----------------------------------------------------------------------------------


// @@PLEAC@@_8.6
//----------------------------------------------------------------------------------
//testfile = newFile('/usr/share/fortune/humorists')

// small files:
random = new Random()
lines = testfile.readLines()
println lines[random.nextInt(lines.size())]

// streamed alternative
count = 0
def adage
testfile.eachLine{ line ->
    count++
    if (random.nextInt(count) < 1) adage = line
}
println adage
//----------------------------------------------------------------------------------


// @@PLEAC@@_8.7
//----------------------------------------------------------------------------------
// non-streamed solution (like Perl and Ruby)
lines = testfile.readLines()
Collections.shuffle(lines)
println lines.join('\n')
//----------------------------------------------------------------------------------


// @@PLEAC@@_8.8
//----------------------------------------------------------------------------------
desiredLine = 235
// for small files
lines = testfile.readLines()
println "Line $desiredLine: ${lines[desiredLine-1]}"

// streaming solution
reader = testfile.newReader()
count = 0
def line
while ((line = reader.readLine())!= null) {
    if (++count == desiredLine) break
}
println "Line $desiredLine: $line"
//----------------------------------------------------------------------------------


// @@PLEAC@@_8.9
//----------------------------------------------------------------------------------
println testfile.text.split(/@@pleac@@_8./i).size()
// => 23 (21 sections .0 .. .20 plus before .0 plus line above)
//----------------------------------------------------------------------------------


// @@PLEAC@@_8.10
//----------------------------------------------------------------------------------
file = new RandomAccessFile( logfile, "rw" )
long previous, lastpos = 0
while( (line = file.readLine()) != null ) {
    previous = lastpos
    lastpos = file.filePointer
}
if (previous) file.setLength(previous)
//----------------------------------------------------------------------------------


// @@PLEAC@@_8.11
//----------------------------------------------------------------------------------
// Java's streams are binary at the lowest level if not processed with
// higher level stream mechanisms or readers/writers. Some additions
// to the Perl cookbook which illustrate the basics.

// Print first ten bytes of a binary file:
def dumpStart(filename) {
    bytes = new File(filename).newInputStream()
    10.times{
        print bytes.read() + ' '
    }
    println()
}
dumpStart(System.getProperty('java.home')+'/lib/rt.jar')
// => 80 75 3 4 10 0 0 0 0 0 (note first two bytes = PK - you might recognize this
// as the starting sequence of a zip file)
dumpStart('Pleac/classes/pleac8.class') // after running groovyc compiler in src directory
// => 202 254 186 190 0 0 0 47 2 20 (starting bytes in HEX: CAFEBABE)

binfile = new File('Pleac/data/temp.bin')
binfile.withOutputStream{ stream -> (0..<20).each{ stream.write(it) }}
binfile.eachByte{ print it + ' ' }; println()
// => 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19
//----------------------------------------------------------------------------------


// @@PLEAC@@_8.12
//----------------------------------------------------------------------------------
// lets treat binfile as having 5 records of size 4, let's print out the 3rd record
recsize = 4
recno = 2 // index starts at 0
address = recsize * recno
randomaccess = new RandomAccessFile(binfile, 'r')
randomaccess.seek(address)
recsize.times{ print randomaccess.read() + ' ' }; println()  // => 8 9 10 11
randomaccess.close()
//----------------------------------------------------------------------------------


// @@PLEAC@@_8.13
//----------------------------------------------------------------------------------
// let's take the example from 8.12 but replace the 3rd record with
// 90 - the original value in the file
// this is an alternative example to the Perl cookbook which is cross platform
// see chapter 1 regarding un/pack which could be combined with below
// to achieve the full functionality of the original 8.13
recsize = 4
recno = 2 // index starts at 0
address = recsize * recno
randomaccess = new RandomAccessFile(binfile, 'rw')
randomaccess.seek(address)
bytes = []
recsize.times{ bytes += randomaccess.read() }
randomaccess.seek(address)
bytes.each{ b -> randomaccess.write(90 - b) }
randomaccess.close()
binfile.eachByte{ print it + ' ' }; println()
// => 0 1 2 3 4 5 6 7 82 81 80 79 12 13 14 15 16 17 18 19
//----------------------------------------------------------------------------------


// @@PLEAC@@_8.14
//----------------------------------------------------------------------------------
// reading a String would involve looping and collecting the read bytes

// simple bgets
// this is similar to the revised 8.13 but would look for the terminating 0

// simplistic strings functionality
binfile.eachByte{ b -> if ((int)b in 32..126) print ((char)b) }; println() // => RQPO
//----------------------------------------------------------------------------------


// @@PLEAC@@_8.15
//----------------------------------------------------------------------------------
// You could combine the byte-level reading/writing mechanisms shown
// in 8.11 - 8.12 and combine that with the un/pack functionality from
// Chapter 1 to achieve the desired functionality. A more Java and Groovy
// friendly way to do this would be to use the Scattering and Gathering
// stream operations of channels for byte-oriented record fields or
// data-oriented records. Alternatively, the dataInput/output stream
// capabilities for data-oriented records. Finally, the
// objectInput/output stream capabilities could be used for object types.
// Note, these examples mix reading and writing even though the original
// Perl example was just about reading.


// fixed-length byte-oriented records using channels
// typical approach used with low-level protocols or file formats
import java.nio.*
binfile.delete(); binfile.createNewFile() // start from scratch
buf1 = ByteBuffer.wrap([10,11,12,13] as byte[]) // simulate 4 byte field
buf2 = ByteBuffer.wrap([44,45] as byte[])       // 2 byte field
buf3 = ByteBuffer.wrap('Hello'.bytes)           // String
records = [buf1, buf2, buf3] as ByteBuffer[]
channel = new FileOutputStream(binfile).channel
channel.write(records) // gathering byte records
channel.close()
binfile.eachByte{ print it + ' ' }; println()
// => 10 11 12 13 44 45 72 101 108 108 111
// ScatteringInputStream would convert this back into an array of byte[]


// data-oriented streams using channels
binfile.delete(); binfile.createNewFile() // start from scratch
buf = ByteBuffer.allocate(24)
now = System.currentTimeMillis()
buf.put('PI='.bytes).putDouble(Math.PI).put('Date='.bytes).putLong(now)
buf.flip() // readies for writing: set length and point back to start
channel = new FileOutputStream(binfile).channel
channel.write(buf)
channel.close()
// now read it back in
channel = new FileInputStream(binfile).channel
buf = ByteBuffer.allocate(24)
channel.read(buf)
buf.flip()
3.times{ print ((char)buf.get()) }
println (buf.getDouble())
5.times{ print ((char)buf.get()) }
println (new Date(buf.getLong()))
channel.close()
// =>
// PI=3.141592653589793
// Date=Sat Jan 13 00:14:50 EST 2007

// object-oriented streams
binfile.delete(); binfile.createNewFile() // start from scratch
class Person implements Serializable { def name, age }
binfile.withObjectOutputStream{ oos ->
    oos.writeObject(new Person(name:'Bernie',age:16))
    oos.writeObject([1:'a', 2:'b'])
    oos.writeObject(new Date())
}
// now read it back in
binfile.withObjectInputStream{ ois ->
    person = ois.readObject()
    println "$person.name is $person.age"
    println ois.readObject()
    println ois.readObject()
}
// =>
// Bernie is 16
// [1:"a", 2:"b"]
// Sat Jan 13 00:22:13 EST 2007
//----------------------------------------------------------------------------------


// @@PLEAC@@_8.16
//----------------------------------------------------------------------------------
// use built-in Java property class
// suppose you have the following file:
// # set your database settings here
// server=localhost
// url=jdbc:derby:derbyDB;create=true
// user.name=me
// user.password=secret
props = new Properties()
propsfile=new File('Pleac/data/plain.properties')
props.load(propsfile.newInputStream())
props.list(System.out)
// =>
// -- listing properties --
// user.name=me
// user.password=secret
// url=jdbc:derby:derbyDB;create=true
// server=localhost

// There are also provisions for writing properties file.

// (additional example to Perl)
// You can also read and write xml properties files.
new File('Pleac/data/props.xml').withOutputStream{ os ->
    props.storeToXML(os, "Database Settings")
}
// =>
// <?xml version="1.0" encoding="UTF-8"?>
// <!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
// <properties>
// <comment>Database Settings</comment>
// <entry key="user.password">secret</entry>
// <entry key="user.name">me</entry>
// <entry key="url">jdbc:derby:derbyDB;create=true</entry>
// <entry key="server">localhost</entry>
// </properties>
//----------------------------------------------------------------------------------


// @@PLEAC@@_8.17
//----------------------------------------------------------------------------------
// The File class provides canRead(), canWrite() and canExecute() (JDK6) methods
// for finding out about security information specific to the user. JSR 203
// (expected in Java 7) provides access to additional security related attributes.

// Another useful package to use when wondering about the trustworthiness of a
// file is the java.security package. It contains many classes. Just one is
// MessageDigest. This would allow you to create a strong checksum of a file.
// Your program could refuse to operate if a file it was accessing didn't have the
// checksum it was expecting - an indication that it may have been tampered with.

// (additional info)
// While getting file-based security permissions correct is important, it isn't the
// only mechanism to use for security when using Java based systems. Java provides
// policy files and an authorization and authentication API which lets you secure
// any reources (not just files) at various levels of granularity with various
// security mechanisms.
// Security policies may be universal, apply to a particular codebase, or
// using JAAS apply to individuals. Some indicative policy statements:
// grant {
//     permission java.net.SocketPermission "*", "connect";
//     permission java.io.FilePermission "C:\\users\\cathy\\foo.bat", "read";
// };
// grant codebase "file:./*", Principal ExamplePrincipal "Secret" {
//     permission java.io.FilePermission "dummy.txt", "read";
// };
//----------------------------------------------------------------------------------


// @@PLEAC@@_8.18
//----------------------------------------------------------------------------------
// general purpose utility methods
def getString(buf,size){
    // consider get(buf[]) instead of get(buf) for efficiency
    b=[]; size.times{b+=buf.get()}; new String(b as byte[]).trim()
}
def getInt(buf,size) {
    // normally in Java we would just use methods like getLong()
    // to read a long but wish to ignore platform issues here
    long val = 0
    for (n in 0..<size) { val += ((int)buf.get() & 0xFF) << (n * 8) }
    return val
}
def getDate(buf) {
    return new Date(getInt(buf,4) * 1000) // Java uses millis
}

// specific utility method (wtmp file from ubuntu 6.10)
def processWtmpRecords(file, origpos) {
    channel = new RandomAccessFile(file, 'r').channel
    recsize = 4 + 4 + 32 + 4 + 32 + 256 + 8 + 4 + 40
    channel.position(origpos)
    newpos = origpos
    buf = ByteBuffer.allocate(recsize)
    while ((count = channel.read(buf)) != -1) {
        if (count != recsize) break
        buf.flip()
        print getInt(buf,4) + ' '         // type
        print getInt(buf,4) + ' '         // pid
        print getString(buf,32) + ' '     // line
        print getString(buf,4) + ' '      // inittab
        print getString(buf,32) + ' '     // user
        print getString(buf,256) + ' '    // hostname
        buf.position(buf.position() + 8)  // skip
        println "${getDate(buf)} "        // time
        buf.clear()
        newpos = channel.position()
    }
    return newpos
}

wtmp = new File('Pleac/data/wtmp')
// wtmpTailingScript:
sampleInterval = 2000 // 2000 millis = 2 secs
filePointer = wtmp.size() // begin tailing from the end of the file
while(true) {
    // Compare the length of the file to the file pointer
    long fileLength = wtmp.size()
    if( fileLength > filePointer ) {
        // There is data to read
        filePointer = processWtmpRecords(wtmp, filePointer)
    }
    // Sleep for the specified interval
    Thread.sleep( sampleInterval )
}
//----------------------------------------------------------------------------------


// @@PLEAC@@_8.19
//----------------------------------------------------------------------------------
// contains most of the functionality of the original (not guaranteed to be perfect)
// -i ignores errors, e.g. if one target is write protected, the others will work
// -u writes files in unbuffered mode (ignore for '|')
// -n not to stdout
// -a all files are in append mode
// '>>file1' turn on append for individual file
// '|wc' or '|grep x' etc sends output to forked process (only one at any time)
class MultiStream {
    private targets
    private ignoreErrors
    MultiStream(List targets, ignore) {
        this.targets = targets
        ignoreErrors = ignore
    }
    def println(String content) {
        targets.each{
            try {
                it?.write(content.bytes)
            } catch (Exception ex) {
                if (!ignoreErrors) throw ex
                targets -= it
                it?.close()
            }
        }
    }
    def close() { targets.each{ it?.close() } }
}

class TeeTarget {
    private filename
    private stream
    private p

    TeeTarget(String name, append, buffered, ignore) {
        if (name.startsWith('>>')) {
            createFileStream(name[2..-1],true,buffered,ignore)
        } else if (name.startsWith('|')) {
            createProcessReader(name[1..-1])
        } else {
            createFileStream(name,append,buffered,ignore)
        }
    }

    TeeTarget(OutputStream stream) { this.stream = stream }

    def write(bytes) { stream?.write(bytes) }
    def close() { stream?.close() }

    private createFileStream(name, append, buffered, ignore) {
        filename = name
        def fos
        try {
            fos = new FileOutputStream(name, append)
        } catch (Exception ex) {
            if (ignore) return
        }
        if (!buffered) stream = fos
        else stream = new BufferedOutputStream(fos)
    }
    private createWriter(os) {new PrintWriter(new BufferedOutputStream(os))}
    private createReader(is) {new BufferedReader(new InputStreamReader(is))}
    private createPiperThread(br, pw) {
        Thread.start{
            def next
            while((next = br.readLine())!=null) {
                pw.println(next)
            }
            pw.flush(); pw.close()
        }
    }
    private createProcessReader(name) {
        def readFromStream = new PipedInputStream()
        def r1 = createReader(readFromStream)
        stream = new BufferedOutputStream(new PipedOutputStream(readFromStream))
        p = Runtime.runtime.exec(name)
        def w1 = createWriter(p.outputStream)
        createPiperThread(r1, w1)
        def w2 = createWriter(System.out)
        def r2 = createReader(p.inputStream)
        createPiperThread(r2, w2)
    }
}

targets = []
append = false; ignore = false; includeStdout = true; buffer = true
(0..<args.size()).each{
    arg = args[it]
    if (arg.startsWith('-')) {
        switch (arg) {
            case '-a': append = true; break
            case '-i': ignore = true; break
            case '-n': includeStdout = false; break
            case '-u': buffer = false; break
            default:
                println "usage: tee [-ainu] [filenames] ..."
                System.exit(1)
        }
    } else targets += arg
}
targets = targets.collect{ new TeeTarget(it, append, buffer, ignore) }
if (includeStdout) targets += new TeeTarget(System.out)
def tee = new MultiStream(targets, ignore)
while (line = System.in.readLine()) {
    tee.println(line)
}
tee.close()
//----------------------------------------------------------------------------------


// @@PLEAC@@_8.20
//----------------------------------------------------------------------------------
// most of the functionality - uses an explicit uid - ran on ubuntu 6.10 on intel
lastlog = new File('Pleac/data/lastlog')
channel = new RandomAccessFile(lastlog, 'r').channel
uid = 1000
recsize = 4 + 32 + 256
channel.position(uid * recsize)
buf = ByteBuffer.allocate(recsize)
channel.read(buf)
buf.flip()
date = getDate(buf)
line = getString(buf,32)
host = getString(buf,256)
println "User with uid $uid last logged on $date from ${host?host:'unknown'} on $line"
// => User with uid 1000 last logged on Sat Jan 13 09:09:35 EST 2007 from unknown on :0
//----------------------------------------------------------------------------------


// @@PLEAC@@_9.0
//----------------------------------------------------------------------------------
// Groovy builds on Java's file and io classes which provide an operating
// system independent abstraction of a file system. The actual File class
// is the main class of interest. It represents a potential file or
// directory - which may or may not (yet) exist. In versions of Java up to
// and including Java 6, the File class was missing some of the functionality
// required to implement some of the examples in the Chapter (workarounds
// and alternatives are noted below). In Java 7, (also known as "Dolphin")
// new File abstraction facilities are being worked on but haven't yet been
// publically released. These new features are known as JSR 203 and are
// referred to when relevant to some of the examples. Thanks to Alan Bateman
// from Sun for clarification regarding various aspects of JSR 203. Apologies
// if I misunderstood any aspects relayed to me and also usual disclaimers
// apply regarding features which may change or be dropped before release.

// path='/usr/bin'; file='vi' // linux/mac os?
path='C:/windows'; file='explorer.exe' // windows
entry = new File("$path")
assert entry.isDirectory()
entry = new File("$path/$file")
assert entry.isFile()

println File.separator
// => \ (on Windows)
// => / (on Unix)
// however if you just stick to backslashes Java converts for you
// in most situations

// File modification time (no exact equivalent of ctime - but you can
// call stat() using JNI or use exec() of dir or ls to get this kind of info)
// JSR 203 also plans to provide such info in Java 7.
println new Date(entry.lastModified())
// => Wed Aug 04 07:00:00 EST 2004

// file size
println entry.size()
// => 1032192

// check if we have permission to read the file
assert entry.canRead()

// check if file is binary or text?
// There is no functionality for this at the file level.
// Java has the Java Activation Framework (jaf) which is used to
// associate files (and streams) with MIME Types and subsequently
// binary data streams or character encodings for (potentially
// multilanguage) text files. JSR-203 provides a method to determine
// the MIME type of a file. Depending on the platform the file type may
// be determined based on a file attribute, file name "extension", the
// bytes of the files (byte sniffing) or other means. It is service
// provider based so developers can plug in their own file type detection
// mechanisms as required. "Out of the box" it will ship with file type
// detectors that are appropriate for the platform (integrates with GNOME,
// Windows registry, etc.).

// Groovy uses File for directories and files
// displayAllFilesInUsrBin:
new File('/usr/bin').eachFile{ file ->
  println "Inside /usr/bin is something called $file.name"
}
//----------------------------------------------------------------------------------

// @@PLEAC@@_9.1
//----------------------------------------------------------------------------------
file = new File("filename")
file << 'hi'
timeModified = file.lastModified()
println new Date(timeModified)
// => Sun Jan 07 11:49:02 EST 2007

MILLIS_PER_WEEK = 60 * 60 * 24 * 1000 * 7
file.setLastModified(timeModified - MILLIS_PER_WEEK)
println new Date(file.lastModified())
// => Sun Dec 31 11:49:02 EST 2006

// Java currently doesn't provide access to other timestamps but
// there are things that can be done:
// (1) You can use JNI to call to C, e.g. stat()
// (2) Use exec() and call another program, e.g. dir, ls, ... to get the value you are after
// (3) Here is a Windows specific patch to get lastAccessedTime and creationTime
//     http://forum.java.sun.com/thread.jspa?forumID=31&start=0&threadID=409921&range=100#1800193
// (4) There is an informal patch for Java 5/6 which gives lastAccessedTime on Windows and Linux
//     and creationTime on windows:
//     http://bugs.sun.com/bugdatabase/view_bug.do?bug_id=6314708
// (5) JSR 203 (currently targetted for Java 7) aims to provide
//     "bulk access to file attributes, change notification, escape to filesystem-specific APIs"
//     this is supposed to include creationTime and lastAccessedTime along with many
//     security-related file attributes

// viFileWithoutChangingModificationTimeScript:
#!/usr/bin/groovy
// uvi - vi a file without changing it's last modified time
if (args.size() != 1)
  println "usage: uvi filename"
  System.exit(1)
}
file = args[0]
origTime = new File(file).lastModified()
"vi $file".execute()
new File(file).setLastModified(origTime)
//----------------------------------------------------------------------------------

// @@PLEAC@@_9.2
//----------------------------------------------------------------------------------
println new File('/doesnotexist').exists()  // => false
println new File('/doesnotexist').delete()  // => false

new File('/createme') << 'Hi there'
println new File('/createme').exists()  // => true
println new File('/createme').delete()  // => true

names = ['file1','file2','file3']
files = names.collect{ new File(it) }
// create 2 of the files
files[0..1].each{ f -> f << f.name }

def deleteFiles(files) {
    def problemFileNames = []
    files.each{ f ->
        if (!f.delete())
            problemFileNames += f.name
    }
    def delCnt = files.size() - problemFileNames.size()
    println "Successfully deleted $delCnt of ${files.size()} file(s)"
    if (problemFileNames)
        println "Problems file(s): " + problemFileNames.join(', ')
}

deleteFiles(files)
// =>
// Successfully deleted 2 of 3 file(s)
// Problems file(s): file3

// we can also set files for deletion on exit
tempFile = new File('/xxx')
assert !tempFile.exists()
tempFile << 'junk'
assert tempFile.exists()
tempFile.deleteOnExit()
assert tempFile.exists()
// To confirm this is working, run these steps multiple times in a row.

// Discussion:
// Be careful with deleteOnExit() as there is no way to cancel it.
// There are also mechanisms specifically for creating unqiuely named temp files.
// On completion of JSR 203, there will be additional methods available for
// deleting which throw exceptions with detailed error messages rather than
// just return booleans.
//----------------------------------------------------------------------------------

// @@PLEAC@@_9.3
//----------------------------------------------------------------------------------
// (1) Copy examples

//shared setup
dummyContent = 'some content' + System.getProperty('line.separator')
setUpFromFile()
setUpToFile()

// built-in copy via memory (text files only)
to << from.text
checkSuccessfulCopyAndDelete()

// built-in as a stream (text or binary) with optional encoding
to << from.asWritable('US-ASCII')
checkSuccessfulCopyAndDelete()

// built-in using AntBuilder
// for options, see: http://ant.apache.org/manual/CoreTasks/copy.html
new AntBuilder().copy( file: from.canonicalPath, tofile: to.canonicalPath )
checkSuccessfulCopyAndDelete()
// =>
//     [copy] Copying 1 file to D:\


// use Apache Jakarta Commons IO (jakarta.apache.org)
import org.apache.commons.io.FileUtils
// Copies a file to a new location preserving the lastModified date.
FileUtils.copyFile(from, to)
checkSuccessfulCopyAndDelete()

// using execute()
// "cp $from.canonicalPath $to.canonicalPath".execute()      // unix
println "cmd /c \"copy $from.canonicalPath $to.canonicalPath\"".execute().text    // dos vms
checkSuccessfulCopyAndDelete()
// =>
//        1 file(s) copied.

// (2) Move examples
// You can just do copy followed by delete but many OS's can just 'rename' in place
// so you can additionally do using Java's functionality:
assert from.renameTo(to)
assert !from.exists()
checkSuccessfulCopyAndDelete()
// whether renameTo succeeds if from and to are on different platforms
// or if to pre-exists is OS dependent, so you should check the return boolean

// alternatively, Ant has a move task:
// http://ant.apache.org/manual/CoreTasks/move.html

//helper methods
def checkSuccessfulCopyAndDelete() {
    assert to.text == dummyContent
    assert to.delete()
    assert !to.exists()
}
def setUpFromFile() {
    from = new File('/from.txt') // just a name
    from << dummyContent         // now its a real file with content
    from.deleteOnExit()          // that will be deleted on exit
}
def setUpToFile() {
    to = new File('C:/to.txt')     // target name
    to.delete() // ensure not left from previous aborted run
    assert !to.exists()          // double check
}
//----------------------------------------------------------------------------------

// @@PLEAC@@_9.4
//----------------------------------------------------------------------------------
// Groovy (because of its Java heritage) doesn't have an exact
// equivalent of stat - as per 9.2 there are numerous mechanisms
// to achieve the equivalent, in particular, JSR203 (still in draft)
// has specific SymLink support including a FileId class in the
// java.nio.filesystems package. This will allow (depending on the
// operating system capabilities) files to be uniquely identified.
// If you work on Unix or Linux then you'll recognize this as it device/inode.

// If you are not interested in the above workarounds/future features
// and you are on a unix system, you can compare the absolutePath and
// canonicalPath attributes for a file. If they are different it is
// a symbolic link. On other operating systems, this difference is not
// to be relied upon and even on *nix systems, this will only get you
// so far and will also be relatively expensive resource and timewise.

// process only unique files
seen = []
def myProcessing(file) {
    def path = file.canonicalPath
    if (!seen.contains(path)) {
        seen << path
        // do something with file because we haven't seen it before
    }
}

// find linked files
seen = [:]
filenames = ['/dummyfile1.txt','/test.lnk','/dummyfile2.txt']
filenames.each{ filename ->
    def file = new File(filename)
    def cpath = file.canonicalPath
    if (!seen.containsKey(cpath)) {
        seen[cpath] = []
    }
    seen[cpath] += file.absolutePath
}

println 'Files with links:'
println seen.findAll{ k,v -> v.size() > 1 }
//---------------------------------------------------------------------------------

// @@PLEAC@@_9.5
//----------------------------------------------------------------------------------
// general pattern is:
// new File('dirname').eachFile{ /* do something ... */ }

// setup (change this on your system)
basedir = 'Pleac/src'

// process all files printing out full name (. and .. auto excluded)
new File(basedir).eachFile{ f->
    if (f.isFile()) println f.canonicalPath
}
// also remove dot files such as '.svn' and '.cvs' etc.
new File(basedir).eachFileMatch(~'^[^.].*'){ f->
    if (f.isFile()) println f.canonicalPath
}
//----------------------------------------------------------------------------------

// @@PLEAC@@_9.6
//----------------------------------------------------------------------------------
// Globbing via Apache Jakarta ORO
import org.apache.oro.io.GlobFilenameFilter
dir = new File(basedir)
namelist = dir.list(new GlobFilenameFilter('*.c'))
filelist = dir.listFiles(new GlobFilenameFilter('*.h') as FilenameFilter)

// Built-in matching using regex's
files = []
new File(basedir).eachFileMatch(~/\.[ch]$/){ f->
    if (f.isFile()) files += f
}

// Using Ant's FileScanner (supports arbitrary nested levels using **)
// For more details about Ant FileSets, see here:
// http://ant.apache.org/manual/CoreTypes/fileset.html
scanner = new AntBuilder().fileScanner {
    fileset(dir:basedir) {
        include(name:'**/pleac*.groovy')
        include(name:'Slowcat.*y')
        exclude(name:'**/pleac??.groovy') // chaps 10 and above
        exclude(name:'**/*Test*', unless:'testMode')
    }
}
for (f in scanner) {
    println "Found file $f"
}

// find and sort directories with numeric names
candidateFiles = new File(basedir).listFiles()
allDigits = { it.name =~ /^\d+$/ }
isDir = { it.isDirectory() }
dirs = candidateFiles.findAll(isDir).findAll(allDigits)*.canonicalPath.sort()
println dirs
//----------------------------------------------------------------------------------

// @@PLEAC@@_9.7
//----------------------------------------------------------------------------------
// find all files recursively
dir = new File(basedir)
files = []
dir.eachFileRecurse{ files += it }

// find total size
sum = files.sum{ it.size() }
println "$basedir contains $sum bytes"
// => Pleac/src contains 365676 bytes

// find biggest
biggest = files.max{ it.size() }
println "Biggest file is $biggest.name with ${biggest.size()} bytes"
// => Biggest file is pleac6.groovy with 42415 bytes

// find most recently modified
youngest = files.max{ it.lastModified() }
println "Most recently modified is $youngest.name, changed ${new Date(youngest.lastModified())}"
// => Most recently modified is pleac9.groovy, changed Tue Jan 09 07:35:39 EST 2007

// find all directories
dir.eachDir{ println 'Found: ' + it.name}

// find all directories recursively
dir.eachFileRecurse{ f -> if (f.isDirectory()) println 'Found: ' + f.canonicalPath}
//----------------------------------------------------------------------------------

// @@PLEAC@@_9.8
//----------------------------------------------------------------------------------
base = new File('path_to_somewhere_to_delete')

// delete using Jakarta Apache Commons IO
FileUtils.deleteDirectory(base)

// delete using Ant, for various options see:
// http://ant.apache.org/manual/CoreTasks/delete.html
ant = new AntBuilder()
ant.delete(dir: base)
//----------------------------------------------------------------------------------

// @@PLEAC@@_9.9
//----------------------------------------------------------------------------------
names = ['Pleac/src/abc.java', 'Pleac/src/def.groovy']
names.each{ name -> new File(name).renameTo(new File(name + '.bak')) }

// The Groovy way of doing rename using an expr would be to use a closure
// for the expr:
// groovySimpleRenameScript:
#!/usr/bin/groovy
// usage rename closure_expr filenames
op = args[0]
println op
files = args[1..-1]
shell = new GroovyShell(binding)
files.each{ f ->
    newname = shell.evaluate("$op('$f')")
    new File(f).renameTo(new File(newname))
}

// this would allow processing such as:
//% rename "{n -> 'FILE_' + n.toUpperCase()}" files
// with param pleac9.groovy => FILE_PLEAC9.GROOVY
//% rename "{n -> n.replaceAll(/9/,'nine') }" files
// with param pleac9.groovy => pleacnine.groovy
// The script could also be modified to take the list of
// files from stdin if no args were present (not shown).

// The above lets you type any Groovy code, but instead you might
// decide to provide the user with some DSL-like additions, e.g.
// adding the following lines into the script:
sep = File.separator
ext = { '.' + it.tokenize('.')[-1] }
base = { new File(it).name - ext(it) }
parent = { new File(it).parent }
lastModified = { new Date(new File(it).lastModified()) }
// would then allow the following more succinct expressions:
//% rename "{ n -> parent(n) + sep + base(n).reverse() + ext(n) }" files
// with param Pleac/src/pleac9.groovy => Pleac\src\9caelp.groovy
//% rename "{ n -> base(n) + '_' + lastModified(n).year + ext(n) }" files
// with param pleac9.groovy => pleac9_07.groovy

// As a different alternative, you could hook into Ant's mapper mechanism.
// You wouldn't normally type in this from the command-line but it could
// be part of a script, here is an example (excludes the actual rename part)
ant = new AntBuilder()
ant.pathconvert(property:'result',targetos:'windows'){
    path(){ fileset(dir:'Pleac/src', includes:'pleac?.groovy') }
    compositemapper{
        globmapper(from:'*1.groovy', to:'*1.groovy.bak')
        regexpmapper(from:/^(.*C2)\.(.*)$/, to:/\1_beta.\2/, casesensitive:'no')
        chainedmapper{
            packagemapper(from:'*pleac3.groovy', to:'*3.xml')
            filtermapper(){ replacestring(from:'C:.', to:'') }
        }
        chainedmapper{
            regexpmapper(from:/^(.*)4\.(.*)$/, to:/\1_4.\2/)
            flattenmapper()
            filtermapper(){ replacestring(from:'4', to:'four') }
        }
    }
}
println ant.antProject.getProperty('result').replaceAll(';','\n')
// =>
// C:\Projects\GroovyExamples\Pleac\src\pleac1.groovy.bak
// C:\Projects\GroovyExamples\Pleac\src\pleac2_beta.groovy
// Projects.GroovyExamples.Pleac.src.3.xml
// pleac_four.groovy
//----------------------------------------------------------------------------------

// @@PLEAC@@_9.10
//----------------------------------------------------------------------------------
// Splitting a Filename into Its Component Parts
path = new File('Pleac/src/pleac9.groovy')
assert path.parent == 'Pleac' + File.separator + 'src'
assert path.name == 'pleac9.groovy'
ext = path.name.tokenize('.')[-1]
assert ext == 'groovy'

// No fileparse_set_fstype() equivalent in Groovy/Java. Java's File constructor
// automatically performs such a parse and does so appropriately of the operating
// system it is running on. In addition, 3rd party libraries allow platform
// specific operations ot be performed. As an example, many Ant tasks are OS
// aware, e.g. the pathconvert task (callable from an AntBuilder instance) has
// a 'targetos' parameter which can be one of 'unix', 'windows', 'netware',
// 'tandem' or 'os/2'.
//----------------------------------------------------------------------------------

// @@PLEAC@@_9.11
//----------------------------------------------------------------------------------
// Given the previous discussion regarding the lack of support for symlinks
// in Java's File class without exec'ing to the operating system or doing
// a JNI call (at least until JSR 203 arrives), I have modified this example
// to perform an actual replica forest of actual file copies rather than
// a shadow forest full of symlinks pointing back at the real files.
// Use Apache Jakarta Commons IO
srcdir = new File('Pleac/src') // path to src
destdir = new File('C:/temp') // path to dest
preserveFileStamps = true
FileUtils.copyDirectory(srcdir, destdir, preserveFileStamps)
//----------------------------------------------------------------------------------

// @@PLEAC@@_9.12
//----------------------------------------------------------------------------------
#!/usr/bin/groovy
// lst - list sorted directory contents (depth first)
// Given the previous discussion around Java's more limited Date
// information available via the File class, this will be a reduced
// functionality version of ls
LONG_OPTION = 'l'
REVERSE_OPTION = 'r'
MODIFY_OPTION = 'm'
SIZE_OPTION = 's'
HELP_OPTION = 'help'

op = new joptsimple.OptionParser()
op.accepts( LONG_OPTION, 'long listing' )
op.accepts( REVERSE_OPTION, 'reverse listing' )
op.accepts( MODIFY_OPTION, 'sort based on modification time' )
op.accepts( SIZE_OPTION, 'sort based on size' )
op.accepts( HELP_OPTION, 'display this message' )

options = op.parse(args)
if (options.wasDetected( HELP_OPTION )) {
    op.printHelpOn( System.out )
} else {
    sort = {}
    params = options.nonOptionArguments()
    longFormat = options.wasDetected( LONG_OPTION )
    reversed = options.wasDetected( REVERSE_OPTION )
    if (options.wasDetected( SIZE_OPTION )) {
        sort = {a,b -> a.size()<=>b.size()}
    } else if (options.wasDetected( MODIFY_OPTION )) {
        sort = {a,b -> a.lastModified()<=>b.lastModified()}
    }
    displayFiles(params, longFormat, reversed, sort)
}

def displayFiles(params, longFormat, reversed, sort) {
    files = []
    params.each{ name -> new File(name).eachFileRecurse{ files += it } }
    files.sort(sort)
    if (reversed) files = files.reverse()
    files.each { file ->
        if (longFormat) {
            print (file.directory ? 'd' : '-' )
            print (file.canRead() ? 'r' : '-' )
            print (file.canWrite() ? 'w ' : '- ' )
            //print (file.canExecute() ? 'x' : '-' ) // Java 6
            print file.size().toString().padLeft(12) + ' '
            print new Date(file.lastModified()).toString().padRight(22)
            println '  ' + file
        } else {
            println file
        }
    }
}

// =>
// % lst -help
// Option Description
// ------ -------------------------------
// --help display this message
// -l     long listing
// -m     sort based on modification time
// -r     reverse listing
// -s     sort based on size
//
// % lst -l -m Pleac/src Pleac/lib
// ...
// drw            0 Mon Jan 08 22:33:00 EST 2007  Pleac\lib\.svn
// -rw        18988 Mon Jan 08 22:33:41 EST 2007  Pleac\src\pleac9.groovy
// -rw         2159 Mon Jan 08 23:15:41 EST 2007  Pleac\src\lst.groovy
//
// % -l -s -r Pleac/src Pleac/lib
// -rw      1034049 Sun Jan 07 19:24:41 EST 2007  Pleac\lib\ant.jar
// -r-      1034049 Sun Jan 07 19:40:27 EST 2007  Pleac\lib\.svn\text-base\ant.jar.svn-base
// -rw       421008 Thu Jun 02 15:15:34 EST 2005  Pleac\lib\ant-nodeps.jar
// -rw       294436 Sat Jan 06 21:19:58 EST 2007  Pleac\lib\geronimo-javamail_1.3.1_mail-1.0.jar
// ...
//----------------------------------------------------------------------------------


// @@PLEAC@@_10.0
//----------------------------------------------------------------------------------
def hello() {
    greeted += 1
    println "hi there!"
}

// We need to initialize greeted before it can be used, because "+=" assumes predefinition
greeted = 0
hello()
println greeted
// =>
// hi there
// 1
//----------------------------------------------------------------------------------

// @@PLEAC@@_10.1
//----------------------------------------------------------------------------------
// basic method calling examples
// In Groovy, parameters are named anyway
def hypotenuse(side1, side2) {
    Math.sqrt(side1**2 + side2**2)    // sqrt in Math package
}
diag = hypotenuse(3, 4)
assert diag == 5

// the star operator will magically convert an Array into a "tuple"
a = [5, 12]
assert hypotenuse(*a) == 13

// both = men + women

// In Groovy, all objects are references, so the same problem arises.
// Typically we just return a new object. Especially for immutable objects
// this style of processing is very common.
nums = [1.4, 3.5, 6.7]
def toInteger(n) {
    n.collect { v -> v.toInteger() }
}
assert toInteger(nums) == [1, 3, 6]

orignums = [1.4, 3.5, 6.7]
def truncMe(n) {
    (0..<n.size()).each{ idx -> n[idx] = n[idx].toInteger() }
}
truncMe(orignums)
assert orignums == [1, 3, 6]
//----------------------------------------------------------------------------------

// @@PLEAC@@_10.2
//----------------------------------------------------------------------------------
// variable scope examples
def somefunc() {
    def variableInMethod  // private is default in a method
}

def name // private is default for variable in a script

bindingVar = 10 // this will be in the binding (sort of global)
globalArray = []

// In Groovy, run_check can't access a, b, or c until they are
// explicitely defined global (using leading $), even if they are
// both defined in the same scope

def checkAccess(x) {
    def y = 200
    return x + y + bindingVar // access private, param, global
}
assert checkAccess(7) == 217

def saveArray(ary) {
    globalArray << 'internal'
    globalArray += ary
}

saveArray(['important'])
assert globalArray == ["internal", "important"]
//----------------------------------------------------------------------------------

// @@PLEAC@@_10.3
//----------------------------------------------------------------------------------
// you want a private persistent variable within a script method

// you could use a helper class for this
class CounterHelper {
    private static counter = 0
    def static next() { ++counter }
}
def greeting(s) {
    def n = CounterHelper.next()
    println "Hello $s  (I have been called $n times)"
}
greeting('tom')
greeting('dick')
greeting('harry')
// =>
// Hello tom  (I have been called 1 times)
// Hello dick  (I have been called 2 times)
// Hello harry  (I have been called 3 times)

// you could make it more fancy by having separate keys,
// using synchronisation, singleton pattern, ThreadLocal, ...
//----------------------------------------------------------------------------------


// @@PLEAC@@_10.4
//----------------------------------------------------------------------------------
// Determining Current Method Name
// Getting class, package and static info is easy. Method info is just a little work.
// From Java we can use:
//     new Exception().stackTrace[0].methodName
// or for Java 5 and above (saves relatively expensive exception creation)
//     Thread.currentThread().stackTrace[3].methodName
// But these give the Java method name. Groovy wraps its own runtime
// system over the top. It's still a Java method, just a little bit further up the
// stack from where we might expect. Getting the Groovy method name can be done in
// an implementation specific way (subject to change as the language evolves):
def myMethod() {
    names = new Exception().stackTrace*.methodName
    println groovyUnwrap(names)
}
def myMethod2() {
    names = Thread.currentThread().stackTrace*.methodName
    names = names[3..<names.size()] // skip call to dumpThread
    println groovyUnwrap(names)
}
def groovyUnwrap(names) { names[names.indexOf('invoke0')-1] }
myMethod()  // => myMethod
myMethod2() // => myMethod2

// Discussion: If what you really wanted was a tracing mechanism, you could overrie
// invokeMethod and print out method names before calling the original method. Or
// you could use one of the Aspect-Oriented Programming packages for Java.
//----------------------------------------------------------------------------------

// @@PLEAC@@_10.5
//----------------------------------------------------------------------------------
// Passing Arrays and Hashes by Reference
// In Groovy, every value is a reference to an object, thus there is
// no such problem, just call: arrayDiff(array1, array2)

// pairwise add (altered so it doesn't require equal sizes)
def pairWiseAdd(a1, a2) {
    s1 = a1.size(); s2 = a2.size()
    (0..<[s1,s2].max()).collect{
        it > s1-1 ? a2[it] : (it > s2-1 ? a1[it] : a1[it] + a2[it])
    }
}
a = [1, 2]
b = [5, 8]
assert pairWiseAdd(a, b) == [6, 10]

// also works for unequal sizes
b = [5, 8, -1]
assert pairWiseAdd(a, b) == [6, 10, -1]
b = [5]
assert pairWiseAdd(a, b) == [6, 2]

// We could check if both arguments were of a particular type, e.g.
// (a1 instanceof List) or (a2.class.isArray()) but duck typing allows
// it to work on other things as well, so while wouldn't normally do this
// you do need to be a little careful when calling the method, e.g.
// here we call it with two maps of strings and get back strings
// the important thing here was that the arguments were indexed
// 0..size-1 and that the items supported the '+' operator (as String does)
a = [0:'Green ', 1:'Grey ']
b = [0:'Frog', 1:'Elephant', 2:'Dog']
assert pairWiseAdd(a, b) == ["Green Frog", "Grey Elephant", "Dog"]
//----------------------------------------------------------------------------------

// @@PLEAC@@_10.6
//----------------------------------------------------------------------------------
// Detecting Return Context
// There is no exact equivalent of return context in Groovy but
// you can behave differently when called under different circumstances
def addValueOrSize(a1, a2) {
     b1 = (a1 instanceof Number) ? a1 : a1.size()
     b2 = (a2 instanceof Number) ? a2 : a2.size()
     b1 + b2
}
assert (addValueOrSize(10, 'abcd')) == 14
assert (addValueOrSize(10, [25, 50])) == 12
assert (addValueOrSize('abc', [25, 50])) == 5
assert (addValueOrSize(25, 50)) == 75

// Of course, a key feature of many OO languages including Groovy is
// method overloading so that responding to dofferent parameters has
// a formal way of being captured in code with typed methods, e.g.
class MakeBiggerHelper {
    def triple(List iList) { iList.collect{ it * 3 } }
    def triple(int i) { i * 3 }
}
mbh = new MakeBiggerHelper()
assert mbh.triple([4, 5]) == [12, 15]
assert mbh.triple(4) == 12

// Of course with duck typing, we can rely on dynamic typing if we want
def directTriple(arg) {
    (arg instanceof Number) ? arg * 3 : arg.collect{ it * 3 }
}
assert directTriple([4, 5]) == [12, 15]
assert directTriple(4) == 12
//----------------------------------------------------------------------------------

// @@PLEAC@@_10.7
//----------------------------------------------------------------------------------
// Passing by Named Parameter
// Groovy supports named params or positional arguments with optional
// defaults to simplify method calling

// named arguments work by using a map
def thefunc(Map args) {
    // in this example, we just call the positional version
    thefunc(args.start, args.end, args.step)
}

// positional arguments with defaults
def thefunc(start=0, end=30, step=10) {
    ((start..end).step(step))
}

assert thefunc()                        == [0, 10, 20, 30]
assert thefunc(15)                      == [15, 25]
assert thefunc(0,40)                    == [0, 10, 20, 30, 40]
assert thefunc(start:5, end:20, step:5) == [5, 10, 15, 20]
//----------------------------------------------------------------------------------

// @@PLEAC@@_10.8
//----------------------------------------------------------------------------------
// Skipping Selected Return Values
// Groovy 1.0 doesn't support multiple return types, so you always use
// a holder class, array or collection to return multiple values.
def getSystemInfo() {
    def millis = System.currentTimeMillis()
    def freemem = Runtime.runtime.freeMemory()
    def version = System.getProperty('java.vm.version')
    return [millis:millis, freemem:freemem, version:version]
    // if you are likely to want all the information use a list
    //     return [millis, freemem, version]
    // or dedicated holder class
    //     return new SystemInfo(millis, freemem, version)
}
result = getSystemInfo()
println result.version
// => 1.5.0_08-b03
//----------------------------------------------------------------------------------

// @@PLEAC@@_10.9
//----------------------------------------------------------------------------------
// Returning More Than One Array or Hash
// As per 10.8, Groovy 1.0 doesn't support multiple return types but you
// just use a holder class, array or collection. There are no limitations
// on returning arbitrary nested values using this technique.
def getInfo() {
    def system = [millis:System.currentTimeMillis(),
                  version:System.getProperty('java.vm.version')]
    def runtime = [freemem:Runtime.runtime.freeMemory(),
                   maxmem:Runtime.runtime.maxMemory()]
    return [system:system, runtime:runtime]
}
println info.runtime.maxmem // => 66650112 (info automatically calls getInfo() here)
//----------------------------------------------------------------------------------

// @@PLEAC@@_10.10
//----------------------------------------------------------------------------------
// Returning Failure
// This is normally done in a heavy-weight way via Java Exceptions
// (see 10.12) or in a lightweight way by returning null
def sizeMinusOne(thing) {
    if (thing instanceof Number) return
    thing.size() - 1
}
def check(thing) {
    result = sizeMinusOne(thing)
    println (result ? "Worked with result: $result" : 'Failed')
}
check(4)
check([1, 2])
check('abc')
// =>
// Failed
// Worked with result: 1
// Worked with result: 2
//----------------------------------------------------------------------------------

// @@PLEAC@@_10.11
//----------------------------------------------------------------------------------
// Prototyping Functions: Not supported by Groovy but arguably
// not important given other language features.

// Omitting Parentheses Scenario: Groovy only lets you leave out
// parentheses in simple cases. If you had two methods sum(a1,a2,a3)
// and sum(a1,a2), there would be no way to indicate that whether
// 'sum sum 2, 3, 4, 5' meant sum(sum(2,3),4,5) or sum(sum(2,3,4),5).
// You would have to include the parentheses. Groovy does much less
// auto flattening than some other languages; it provides a *args
// operator, varargs style optional params and supports method
// overloading and ducktyping. Perhaps these other features mean
// that this scenario is always easy to avoid.
def sum(a,b,c){ a+b+c*2 }
def sum(a,b){ a+b }
// sum sum 1,2,4,5
// => compilation error
sum sum(1,2),4,5
sum sum(1,2,4),5
// these work but if you try to do anything fancy you will run into trouble;
// your best bet is to actually include all the parentheses:
println sum(sum(1,2),4,5) // => 17
println sum(sum(1,2,4),5) // => 16

// Mimicking built-ins scenario: this is a mechanism to turn-off
// auto flattening, Groovy only does flattening in restricted circumstances.
// func(array, 1, 2, 3) is never coerced into a single list but varargs
// and optional args can be used instead
def push(list, Object[] optionals) {
    optionals.each{ list.add(it) }
}
items = [1,2]
newItems = [7, 8, 9]
push items, 3, 4
push items, 6
push (items, *newItems) // brackets currently required, *=flattening
                        // without *: items = [1, 2, 3, 4, 6, [7, 8, 9]]
assert items == [1, 2, 3, 4, 6, 7, 8, 9]
//----------------------------------------------------------------------------------

// @@PLEAC@@_10.12
//----------------------------------------------------------------------------------
// Handling Exceptions
// Same story as in Java but Groovy has some nice Checked -> Unchecked
// magic behind the scenes (Java folk will know what this means)
// When writing methods:
//     throw exception to raise it
// When calling methods:
//     try ... catch ... finally surrounds processing logic
def getSizeMostOfTheTime(s) {
    if (s =~ 'Full Moon') throw new RuntimeException('The world is ending')
    s.size()
}
try {
    println 'Size is: ' + getSizeMostOfTheTime('The quick brown fox')
    println 'Size is: ' + getSizeMostOfTheTime('Beware the Full Moon')
} catch (Exception ex) {
    println "Error was: $ex.message"
} finally {
    println 'Doing common cleanup'
}
// =>
// Size is: 19
// Error was: The world is ending
// Doing common cleanup
//----------------------------------------------------------------------------------

// @@PLEAC@@_10.13
//----------------------------------------------------------------------------------
// Saving Global Values
// We can just save the value and restore it later:
def printAge() { println "Age is $age" }

age = 18         // binding "global" variable
printAge()       // => 18

if (age > 0) {
    def origAge = age
    age = 23
    printAge()   // => 23
    age = origAge
}
printAge()       // => 18

// Depending on the circmstances we could enhance this in various ways
// such as synchronizing, surrounding with try ... finally, using a
// memento pattern, saving the whole binding, using a ThreadLocal ...

// There is no need to use local() for filehandles or directory
// handles in Groovy because filehandles are normal objects.
//----------------------------------------------------------------------------------

// @@PLEAC@@_10.14
//----------------------------------------------------------------------------------
// Redefining a Function
// This can be done via a number of ways:

// OO approach:
// The standard trick using OO is to override methods in subclasses
class Parent { def foo(){ println 'foo' } }
class Child extends Parent { def foo(){ println 'bar' } }
new Parent().foo()   // => foo
new Child().foo()    // => bar

// Category approach:
// If you want to redefine a method from an existing library
// you can use categories. This can be done to avoid name conflicts
// or to patch functionality with local mods without changing
// original code
println new Date().toString()
// => Sat Jan 06 16:44:55 EST 2007
class DateCategory {
    static toString(Date self) { 'not telling' }
}
use (DateCategory) {
    println new Date().toString()
}
// => not telling

// Closure approach:
// Groovy's closures let you have "anonymous methods" as objects.
// This allows you to be very flexible with "method" redefinition, e.g.:
colors = 'red yellow blue green'.split(' ').toList()
color2html = new Expando()
colors.each { c ->
    color2html[c] = { args -> "<FONT COLOR='$c'>$args</FONT>" }
}
println color2html.yellow('error')
// => <FONT COLOR='yellow'>error</FONT>
color2html.yellow = { args -> "<b>$args</b>" } // too hard to see yellow
println color2html.yellow('error')
// => <b>error</b>

// Other approaches:
// you could use invokeMethod to intercept the original method and call
// your modified method on just particular input data
//----------------------------------------------------------------------------------

// @@PLEAC@@_10.15
//----------------------------------------------------------------------------------
// Trapping Undefined Function Calls
class FontHelper {
    // we could define all the important colors explicitly like this
    def pink(info) {
        buildFont('hot pink', info)
    }
    // but this method will catch any undefined ones
    def invokeMethod(String name, Object args) {
        buildFont(name, args.join(' and '))
    }
    def buildFont(name, info) {
        "<FONT COLOR='$name'>" + info + "</FONT>"
    }
}
fh = new FontHelper()
println fh.pink("panther")
println fh.chartreuse("stuff", "more stuff")
// =>
// <FONT COLOR='hot pink'>panther</FONT>
// <FONT COLOR='chartreuse'>stuff and more stuff</FONT>
//----------------------------------------------------------------------------------

// @@PLEAC@@_10.16
//----------------------------------------------------------------------------------
// Simulating Nested Subroutimes: Using Closures within Methods
def outer(arg) {
    def x = arg + 35
    inner = { x * 19 }
    x + inner()
}
assert outer(10) == 900
//----------------------------------------------------------------------------------

// @@PLEAC@@_10.17
//----------------------------------------------------------------------------------
// Program: Sorting Your Mail
#!/usr/bin/groovy
import javax.mail.*

// solution using mstor package (mstor.sf.net)
session = Session.getDefaultInstance(new Properties())
store = session.getStore(new URLName('mstor:/path_to_your_mbox_directory'))
store.connect()

// read messages from Inbox
inbox = store.defaultFolder.getFolder('Inbox')
inbox.open(Folder.READ_ONLY)
messages = inbox.messages.toList()

// extractor closures
subject = { m -> m.subject }
subjectExcludingReplyPrefix = { m -> subject(m).replaceAll(/(?i)Re:\\s*/,'') } // double slash to single outside triple quotes
date = { m -> d = m.sentDate; new Date(d.year, d.month, d.date) } // ignore time fields

// sort by subject excluding 'Re:' prefixs then print subject for first 6
println messages.sort{subjectExcludingReplyPrefix(it)}[0..5]*.subject.join('\n')
// =>
// Additional Resources for JDeveloper 10g (10.1.3)
// Amazon Web Services Developer Connection Newsletter #18
// Re: Ant 1.7.0?
// ARN Daily | 2007: IT predictions for the year ahead
// Big Changes at Gentleware
// BigPond Account Notification

// sort by date then subject (print first 6 entries)
sorted = messages.sort{ a,b ->
    date(a) == date(b) ?
        subjectExcludingReplyPrefix(a) <=> subjectExcludingReplyPrefix(b) :
        date(a) <=> date(b)
}
sorted[0..5].each{ m -> println "$m.sentDate: $m.subject" }
// =>
// Wed Jan 03 08:54:15 EST 2007: ARN Daily | 2007: IT predictions for the year ahead
// Wed Jan 03 15:33:31 EST 2007: EclipseSource: RCP Adoption, Where Art Thou?
// Wed Jan 03 00:10:11 EST 2007: What's New at Sams Publishing?
// Fri Jan 05 08:31:11 EST 2007: Building a Sustainable Open Source Business
// Fri Jan 05 09:53:45 EST 2007: Call for Participation: Agile 2007
// Fri Jan 05 05:51:36 EST 2007: IBM developerWorks Weekly Edition, 4 January 2007

// group by date then print first 2 entries of first 2 dates
groups = messages.groupBy{ date(it) }
groups.keySet().toList()[0..1].each{
    println it
    println groups[it][0..1].collect{ '    ' + it.subject }.join('\n')
}
// =>
// Wed Jan 03 00:00:00 EST 2007
//     ARN Daily | 2007: IT predictions for the year ahead
//     EclipseSource: RCP Adoption, Where Art Thou?
// Fri Jan 05 00:00:00 EST 2007
//     Building a Sustainable Open Source Business
//     Call for Participation: Agile 2007


// @@PLEAC@@_11.0
//----------------------------------------------------------------------------------
// In Groovy, most usages of names are references (there are some special
// rules for the map shorthand notation and builders).
// Objects are inherently anonymous, they don't know what names refer to them.
ref = 3       // points ref to an Integer object with value 3.
println ref   // prints the value that the name ref refers to.

myList = [3, 4, 5]       // myList is a name for this list
anotherRef = myList
myMap = ["How": "Now", "Brown": "Cow"] // myMap is a name for this map

anArray = [1, 2, 3] as int[] // creates an array of three references to Integer objects

list = [[]]  // a list containing an empty list
list[2] = 'Cat'
println list // => [[], null, "Cat"]
list[0][2] = 'Dog'
println list // => [[null, null, "Dog"], null, "Cat"]

a = [2, 1]
b = a  // b is a reference to the same thing as a
a.sort()
println b // => [1, 2]

nat = [ Name: "Leonhard Euler",
        Address: "1729 Ramanujan Lane\nMathworld, PI 31416",
        Birthday: 0x5bb5580
]
println nat
// =>["Address":"1729 Ramanujan Lane\nMathworld, PI 31416", "Name":"Leonhard Euler", "Birthday":96163200]
//----------------------------------------------------------------------------------


// @@PLEAC@@_11.1
//----------------------------------------------------------------------------------
aref = myList
anonList = [1, 3, 5, 7, 9]
anonCopy = anonList
implicitCreation = [2, 4, 6, 8, 10]

anonList += 11
println anonList  // => [1, 3, 5, 7, 9, 11]

two = implicitCreation[0]
assert two == 2

//  To get the last index of a list, you can use size()
// but you never would
lastIdx = aref.size() - 1

// Normally, though, you'd use an index of -1 for the last
// element, -2 for the second last, etc.
println implicitCreation[-1]
//=> 10

// And if you were looping through (and not using a list closure operator)
(0..<aref.size()).each{ /* do something */ }

numItems = aref.size()

assert anArray instanceof int[]
assert anArray.class.isArray()
println anArray

myList.sort() // sort is in place.
myList += "an item" // append item

def createList() { return [] }
aref1 = createList()
aref2 = createList()
// aref1 and aref2 point to different lists.

println anonList[4] // refers to the 4th item in the list_ref list.

// The following two statements are equivalent and return up to 3 elements
// at indices 3, 4, and 5 (if they exist).
x = anonList[3..5]
x = anonList[(3..5).step(1)]

//   This will insert 3 elements, overwriting elements at indices 3,4, or 5 - if they exist.
anonList[3..5] = ["blackberry", "blueberry", "pumpkin"]

// non index-based looping
for (item in anonList) println item
anonList.each{ println it }

// index-based looping
(0..<anonList.size()).each{ idx -> println anonList[idx] }
for (idx in 0..<anonList.size()) println anonList[idx]
//----------------------------------------------------------------------------------


// @@PLEAC@@_11.2
//----------------------------------------------------------------------------------
// Making Hashes of Arrays
hash = [:] // empty map
hash["KEYNAME"] = "new value"

hash.each{ key, value -> println key + ' ' + value }

hash["a key"] = [3, 4, 5]
values = hash["a key"]

hash["a key"] += 6
println hash
// => ["KEYNAME":"new value", "a key":[3, 4, 5, 6]]

// attempting to access a value for a key not in the map yields null
assert hash['unknown key'] == null
assert hash.get('unknown key', 45) == 45
println hash
// => ["unknown key":45, "KEYNAME":"new value", "a key":[3, 4, 5, 6]]
//----------------------------------------------------------------------------------


// @@PLEAC@@_11.3
//----------------------------------------------------------------------------------
// Hashes are no different to other objects
myHash = [ key1:100, key2:200 ]
myHashCopy = myHash.clone()

value = myHash['key1']
value = myHash.'key1'
slice = myHash[1..3]
keys = myHash.keySet()

assert myHash instanceof Map

[myHash, hash].each{ m ->
    m.each{ k, v -> println "$k => $v"}
}
// =>
// key1 => 100
// key2 => 200
// unknown key => 45
// KEYNAME => new value
// a key => [3, 4, 5, 6]

values = ['key1','key2'].collect{ myHash[it] }
println values  // => [100, 200]

for (key in ["key1", "key2"]) {
    myHash[key] += 7
}
println myHash  // => ["key1":107, "key2":207]
//----------------------------------------------------------------------------------


// @@PLEAC@@_11.4
//----------------------------------------------------------------------------------
// you can use closures or the &method notation
def joy() { println 'joy' }
def sullen() { println 'sullen' }
angry = { println 'angry' }
commands = [happy: this.&joy,
            sad:   this.&sullen,
            done:  { System.exit(0) },
            mad:   angry
]

print "How are you?"
cmd = System.in.readLine()
if (cmd in commands.keySet()) commands[cmd]()
else println "No such command: $cmd"


// a counter of the type referred to in the original cookbook
// would be implemented using a class
def counterMaker(){
    def start = 0
    return { -> start++; start-1 }
}

counter = counterMaker()
5.times{ print "${counter()} " }; println()

counter1 = counterMaker()
counter2 = counterMaker()

5.times{ println "${counter1()} " }
println "${counter1()} ${counter2()}"
//=> 0
//=> 1
//=> 2
//=> 3
//=> 4
//=> 5 0


def timestamp() {
    def start = System.currentTimeMillis()
    return { (System.currentTimeMillis() - start).intdiv(1000) }
}
early = timestamp()
//sleep(10000)
later = timestamp()
sleep(2000)
println "It's been ${early()} seconds since early."
println "It's been ${later()} seconds since later."
//=> It's been 12 seconds since early.
//=> It's been 2 seconds since later.
//----------------------------------------------------------------------------------


// @@PLEAC@@_11.5
//----------------------------------------------------------------------------------
// All variables in Groovy are objects including primitives. Some objects
// are immutable. Some operations on objects change mutable objects.
// Some operations produce new objects.

// 15 is an Integer which is an immutable object.
// passing 15 to a method passes a reference to the Integer object.
def print(n) { println "${n.toString()}" }
print(15)  // no need to create any kind of explicit reference

// even though Integers are immutable, references to them are not
x = 1
y = x
println "$x $y"  // => 1 1
x += 1    // "x" now refers to a different object than y
println "$x $y"  // => 2 1
y = 4     // "y" now refers to a different object than it did before
println "$x $y"  // => 2 4

// Some objects (including ints and strings) are immutable, however, which
// can give the illusion of a by-value/by-reference distinction:
list = [[1], 1, 's']
list.each{ it += 1 } // plus operator doesn't operate inplace
print list //=> [[1] 1 s]
list = list.collect{ it + 1 }
print list //=> [[1, 1], 2, s1]

list = [['Z', 'Y', 'X'], ['C', 'B', 'A'], [5, 3, 1]]
list.each{ it.sort() } // sort operation operates inline
println list // => [["X", "Y", "Z"], ["A", "B", "C"], [1, 3, 5]]
//----------------------------------------------------------------------------------


// @@PLEAC@@_11.6
//----------------------------------------------------------------------------------
// As indicated by the previous section, everything is referenced, so
// just create a list as normal, and beware that augmented assignment
// works differently with immutable objects to mutable ones and depends
// on the semantics of the particular operation invoked:
mylist = [1, "s", [1]]
print mylist
//=> [1, s, [1]]

mylist.each{ it *= 2 }
print mylist
//=> [1, s, [1,1]]

mylist[0] *= 2
mylist[-1] *= 2
print mylist
//=> [2, s, [1, 1]]

// If you need to modify every value in a list, you use collect
// which does NOT modify inplace but rather returns a new collection:
mylist = 1..4
println mylist.collect{ it**3 * 4/3 * Math.PI }
// => [4.188790204681671, 33.510321638395844, 113.09733552923255, 268.0825731062243]
//----------------------------------------------------------------------------------


// @@PLEAC@@_11.7
//----------------------------------------------------------------------------------
def mkcounter(count) {
    def start = count
    def bundle = [:]
    bundle.'NEXT' = { count += 1 }
    bundle.'PREV' = { count -= 1 }
    bundle.'RESET' = { count = start }
    bundle["LAST"] = bundle["PREV"]
    return bundle
}

c1 = mkcounter(20)
c2 = mkcounter(77)

println "next c1: ${c1["NEXT"]()}"  // 21
println "next c2: ${c2["NEXT"]()}"  // 78
println "next c1: ${c1["NEXT"]()}"  // 22
println "last c1: ${c1["PREV"]()}"  // 21
println "last c1: ${c1["LAST"]()}"  // 20
println "old  c2: ${c2["RESET"]()}" // 77
//----------------------------------------------------------------------------------


// @@PLEAC@@_11.8
//----------------------------------------------------------------------------------
def addAndMultiply(a, b) {
    println "${a+b} ${a*b}"
}
methRef = this.&addAndMultiply
// or use direct closure
multiplyAndAdd = { a,b -> println "${a*b} ${a+b}" }
// later ...
methRef(2,3)                   // => 5 6
multiplyAndAdd(2,3)            // => 6 5
//----------------------------------------------------------------------------------


// @@PLEAC@@_11.9
//----------------------------------------------------------------------------------
record = [
    "name": "Jason",
    "empno": 132,
    "title": "deputy peon",
    "age": 23,
    "salary": 37000,
    "pals": ["Norbert", "Rhys", "Phineas"],
]
println "I am ${record.'name'}, and my pals are ${record.'pals'.join(', ')}."
// => I am Jason, and my pals are Norbert, Rhys, Phineas.

byname = [:]
byname[record["name"]] = record

rp = byname.get("Aron")
if (rp) println "Aron is employee ${rp["empno"]}."

byname["Jason"]["pals"] += "Theodore"
println "Jason now has ${byname['Jason']['pals'].size()} pals."

byname.each{ name, record ->
    println "$name is employee number ${record['empno']}."
}

employees = [:]
employees[record["empno"]] = record

// lookup by id
rp = employees[132]
if (rp) println "Employee number 132 is ${rp.'name'}."

byname["Jason"]["salary"] *= 1.035
println record
// => ["pals":["Norbert", "Rhys", "Phineas", "Theodore"], "age":23,
//      "title":"deputy peon", "name":"Jason", "salary":38295.000, "empno":132]

peons = employees.findAll{ k, v -> v.'title' =~ /(?i)peon/ }
assert peons.size() == 1
tsevens = employees.findAll{ k, v -> v.'age' == 27 }
assert tsevens.size() == 0

// Go through all records
println 'Names are: ' + employees.values().collect{r->r.'name'}.join(', ')

byAge = {a,b-> a.value().'age' <=> b.value().'age'}
employees.values().sort{byAge}.each{ r->
    println "${r.'name'} is ${r.'age'}"
}

// byage, a hash: age => list of records
byage = [:]
byage[record["age"]] = byage.get(record["age"], []) + [record]

byage.each{ age, list ->
    println "Age $age: ${list.collect{it.'name'}.join(', ')}"
}
//----------------------------------------------------------------------------------


// @@PLEAC@@_11.10
//----------------------------------------------------------------------------------
// if you are using a Properties (see 8.16) then just use load
// and store (or storeToXML)
// variation to original cookbook as Groovy can use Java's object serialization
map = [1:'Jan', 2:'Feb', 3:'Mar']
// write
new File('months.dat').withObjectOutputStream{ oos ->
    oos.writeObject(map)
}
// reset
map = null
// read
new File('months.dat').withObjectInputStream{ ois ->
    map = ois.readObject()
}
println map // => [1:"Jan", 2:"Feb", 3:"Mar"]
//----------------------------------------------------------------------------------


// @@PLEAC@@_11.11
//----------------------------------------------------------------------------------
// Groovy automatically does pretty printing for some of the key types, e.g.
mylist = [[1,2,3], [4, [5,6,7], 8,9, [0,3,5]], 7, 8]
println mylist
// => [[1, 2, 3], [4, [5, 6, 7], 8, 9, [0, 3, 5]], 7, 8]

mydict = ["abc": "def", "ghi":[1,2,3]]
println mydict
// => ["abc":"def", "ghi":[1, 2, 3]]

// if you have another type of object you can use the built-in dump() method
class PetLover {
    def name
    def age
    def pets
}
p = new PetLover(name:'Jason', age:23, pets:[dog:'Rover',cat:'Garfield'])
println p
// => PetLover@b957ea
println p.dump()
// => <PetLover@b957ea name=Jason age=23 pets=["cat":"Garfield", "dog":"Rover"]>

// If that isn't good enough, you can use Boost (http://tara-indigo.org/daisy/geekscape/g2/128)
// or Jakarta Commons Lang *ToStringBuilders (jakarta.apache.org/commons)
// Here's an example of Boost, just extend the supplied Primordial class
import au.net.netstorm.boost.primordial.Primordial
class PetLover2 extends Primordial { def name, age, pets }
println new PetLover2(name:'Jason', age:23, pets:[dog:'Rover',cat:'Garfield'])
// =>
// PetLover2[
//     name=Jason
//     age=23
//     pets={cat=Garfield, dog=Rover}
//     metaClass=groovy.lang.MetaClassImpl@1d8d39f[class PetLover2]
// ]

// using Commons Lang ReflectionToStringBuilder (equivalent to dump())
import org.apache.commons.lang.builder.*
class PetLover3 {
    def name, age, pets
    String toString() {
        ReflectionToStringBuilder.toString(this)
    }
}
println new PetLover3(name:'Jason', age:23, pets:[dog:'Rover',cat:'Garfield'])
// => PetLover3@196e136[name=Jason,age=23,pets={cat=Garfield, dog=Rover}]

// using Commons Lang ToStringBuilder if you want a custom format
class PetLover4 {
    def name, dob, pets
    String toString() {
        def d1 = dob.time; def d2 = (new Date()).time
        int age = (d2 - d1)/1000/60/60/24/365 // close approx good enough here
        return new ToStringBuilder(this).
            append("Pet Lover's name", name).
            append('Pets', pets).
            append('Age', age)
    }
}
println new PetLover4(name:'Jason', dob:new Date(83,03,04), pets:[dog:'Rover',cat:'Garfield'])
// => PetLover4@fdfc58[Pet Lover's name=Jason,Pets={cat=Garfield, dog=Rover},Age=23]
//----------------------------------------------------------------------------------


// @@PLEAC@@_11.12
//----------------------------------------------------------------------------------
oldlist = [1, 2, 3]
newlist = new ArrayList(oldlist) // shallow copy
newlist = oldlist.clone() // shallow copy

oldmap = [a:1, b:2, c:3]
newmap = new HashMap(oldmap) // shallow copy
newmap = oldmap.clone() // shallow copy

oldarray = [1, 2, 3] as int[]
newarray = oldarray.clone()

// shallow copies copy a data structure, but don't copy the items in those
// data structures so if there are nested data structures, both copy and
// original will refer to the same object
mylist = ["1", "2", "3"]
newlist = mylist.clone()
mylist[0] = "0"
println "$mylist $newlist"
//=> ["0", "2", "3"] ["1", "2", "3"]

mylist = [["1", "2", "3"], 4]
newlist = mylist.clone()
mylist[0][0] = "0"
println "$mylist $newlist"
//=> [["0", "2", "3"], 4] [["0", "2", "3"], 4]

// standard deep copy implementation
def deepcopy(orig) {
     bos = new ByteArrayOutputStream()
     oos = new ObjectOutputStream(bos)
     oos.writeObject(orig); oos.flush()
     bin = new ByteArrayInputStream(bos.toByteArray())
     ois = new ObjectInputStream(bin)
     return ois.readObject()
}

newlist = deepcopy(oldlist) // deep copy
newmap  = deepcopy(oldmap)  // deep copy

mylist = [["1", "2", "3"], 4]
newlist = deepcopy(mylist)
mylist[0][0] = "0"
println "$mylist $newlist"
//=> [["0", "2", "3"], 4] [["1", "2", "3"], 4]

// See also:
// http://javatechniques.com/public/java/docs/basics/low-memory-deep-copy.html
// http://javatechniques.com/public/java/docs/basics/faster-deep-copy.html
//----------------------------------------------------------------------------------


// @@PLEAC@@_11.13
//----------------------------------------------------------------------------------
// use Java's serialization capabilities as per 11.10
//----------------------------------------------------------------------------------


// @@PLEAC@@_11.14
//----------------------------------------------------------------------------------
// There are numerous mechanisms for persisting objects to disk
// using Groovy and Java mechanisms. Some are completely transparent,
// some require some initialization only, others make the persistence
// mechanisms visible. Here is a site that lists over 20 options:
// http://www.java-source.net/open-source/persistence
// (This list doesn't include EJB offerings which typically
// require an application server or XML-based options)

// We'll just consider one possibility from prevayler.sf.net.
// This package doesn't make changes to persistent data transparent;
// instead requiring an explicit call via a transaction object.
// It saves all such transaction objects in a journal file so
// that it can rollback the system any number of times (or if
// you make use of the timestamp feature) to a particular point
// in time. It can also be set up to create snapshots which
// consolidate all changes made up to a certain point. The
// journalling will begin again from that point.
import org.prevayler.*
class ImportantHash implements Serializable {
    private map = [:]
    def putAt(key, value) { map[key] = value }
    def getAt(key) { map[key] }
}
class StoreTransaction implements Transaction {
    private val
    StoreTransaction(val) { this.val = val }
    void executeOn(prevayler, Date ignored) { prevayler.putAt(val,val*2) }
}
def save(n){ store.execute(new StoreTransaction(n)) }
store = PrevaylerFactory.createPrevayler(new ImportantHash(), "pleac11")
hash = store.prevalentSystem()
for (i in 0..1000) {
    save(i)
}
println hash[750] // => 1500

store = null; hash = null // *** could shutdown here

store = PrevaylerFactory.createPrevayler(new ImportantHash(), "pleac11")
hash = store.prevalentSystem()
println hash[750] // => 1500
//----------------------------------------------------------------------------------


// @@PLEAC@@_11.15
//----------------------------------------------------------------------------------
// bintree - binary tree demo program
class BinaryTree {
    def value, left, right
    BinaryTree(val) {
        value = val
        left = null
        right = null
    }

    // insert given value into proper point of
    // provided tree.  If no tree provided,
    // use implicit pass by reference aspect of @_
    // to fill one in for our caller.
    def insert(val) {
        if (val < value) {
            if (left) left.insert(val)
            else left = new BinaryTree(val)
        } else if (val > value) {
            if (right) right.insert(val)
            else right = new BinaryTree(val)
        } else println "double" // ignore double values
    }

    // recurse on left child,
    // then show current value,
    // then recurse on right child.
    def inOrder() {
        if (left) left.inOrder()
        print value + ' '
        if (right) right.inOrder()
    }

    // show current value,
    // then recurse on left child,
    // then recurse on right child.
    def preOrder() {
        print value + ' '
        if (left) left.preOrder()
        if (right) right.preOrder()
    }

    // show current value,
    // then recurse on left child,
    // then recurse on right child.
    def dumpOrder() {
        print this.dump() + ' '
        if (left) left.dumpOrder()
        if (right) right.dumpOrder()
    }

    // recurse on left child,
    // then recurse on right child,
    // then show current value.
    def postOrder() {
        if (left) left.postOrder()
        if (right) right.postOrder()
        print value + ' '
    }

    // find out whether provided value is in the tree.
    // if so, return the node at which the value was found.
    // cut down search time by only looking in the correct
    // branch, based on current value.
    def search(val) {
        if (val == value) {
            return this.dump()
        } else if (val < value) {
            return left ? left.search(val) : null
        } else {
            return right ? right.search(val) : null
        }
    }
}

// first generate 20 random inserts
test = new BinaryTree(500)
rand = new Random()
20.times{
    test.insert(rand.nextInt(1000))
}

// now dump out the tree all three ways
print "Pre order:  "; test.preOrder();  println ""
print "In order:   "; test.inOrder();   println ""
print "Post order: "; test.postOrder(); println ""

println "\nSearch?"
while ((item = System.in.readLine()?.trim()) != null) {
    println test.search(item.toInteger())
    println "\nSearch?"
}
// Randomly produces a tree such as:
//           -------- 500 ------
//         /                     \
//       181                     847
//     /    \                    /  \
//   3       204              814   970
//    \       /  \            /
//    126  196  414        800
//             /   \       /
//          353   438   621
//                /     /  \
//             423    604   776
//                   /     /
//                 517   765
//                      /
//                    646
//                   /
//                 630
// Pre order:
// 500 181 3 126 204 196 414 353 438 423 847 814 800 621 604 517 776 765 646 630 970
// In order:
// 3 126 181 196 204 353 414 423 438 500 517 604 621 630 646 765 776 800 814 847 970
// Post order:
// 126 3 196 353 423 438 414 204 181 517 604 630 646 765 776 621 800 814 970 847 500
//
// Search?
// 125
// null
//
// Search?
// 126
// <BinaryTree@ae97c4 value=126 left=null right=null>
//----------------------------------------------------------------------------------


// @@PLEAC@@_12.0
//----------------------------------------------------------------------------------
// Groovy adopts many of the Java structuring conventions and terminology
// and adds some concepts of its own.
// Code-reuse can occur at the script, class, library, component or framework level.
// Source code including class file source and scripts are organised into packages.
// These can be thought of as like hierarchical folders or directories. Two class
// with the same name can be distinguished by having different packages. Compiled
// byte code and sometimes source code including scripts can be packaged up into
// jar files. Various conventions exist for packaging classes and resources in
// such a way to allow them to be easily reused. Some of these conventions allow
// reusable code to be placed within repositories for easy use by third parties.
// One such repository is the maven repository, e.g.: ibiblio.org/maven2
// When reusing classes, it is possible to compartmentalise knowledge of
// particular packages using multiple (potentially hierarchical) classloaders.
// By convention, package names are all lowercase. Class names are capitalized.
// Naming examples:
// package my.package1.name     // at most one per source file - at top of file
// class MyClass ...            // actually defines my.package1.name.MyClass
// import my.package1.name.MyClass  // allows package to be dropped within current file
// import my.package2.name.MyClass  // if class basenames are the same, can't
//                                  // import both, leave one fully qualified
// import my.package.name.*         // all classes in package can drop package prefix
//----------------------------------------------------------------------------------


// @@PLEAC@@_12.1
//----------------------------------------------------------------------------------
// No equivalent export process exists for Groovy.

// If you have some Groovy functionality that you would like others to use
// you either make the source code available or compile it into class files
// and package those up in a jar file. Some subset of your class files will
// define the OO interface to your functionality, e.g. public methods,
// interfaces, etc. Depending on the circumstances, various conventions are
// used to indicate this functionality including Manifest files, javadocs,
// deployment descriptors, project metadata and dependency management files.
// See 12.18 for an example.
//----------------------------------------------------------------------------------


// @@PLEAC@@_12.2
//----------------------------------------------------------------------------------
// Groovy supports both static and dynamic (strong) typing. When trying to
// compile or run files using static typing, the required classes referenced
// must be available. Classes used in more dynamic ways may be loaded (or
// created) at runtime. Errors in loading such dynamic cases are handled
// using the normal exception handling mechanisms.

// attempt to load an unknown resource or script:
try {
    evaluate(new File('doesnotexist.groovy'))
} catch (Exception FileNotFoundException) {
    println 'File not found, skipping ...'
}
// => File not found, skipping ...

// attempt to load an unknown class:
try {
    Class.forName('org.happytimes.LottoNumberGenerator')
} catch (ClassNotFoundException ex) {
    println 'Class not found, skipping ...'
}
// -> Class not found, skipping ...

// dynamicallly look for a database driver (slight variation to original cookbook)
// Note: this hypothetical example ignores certain issues e.g. different url
// formats for configuration when establishing a connection with the driver
candidates = [
    'oracle.jdbc.OracleDriver',
    'com.ibm.db2.jcc.DB2Driver',
    'com.microsoft.jdbc.sqlserver.SQLServerDriver',
    'net.sourceforge.jtds.jdbc.Driver',
    'com.sybase.jdbc3.jdbc.SybDriver',
    'com.informix.jdbc.IfxDriver',
    'com.mysql.jdbc.Driver',
    'org.postgresql.Driver',
    'com.sap.dbtech.jdbc.DriverSapDB',
    'org.hsqldb.jdbcDriver',
    'com.pointbase.jdbc.jdbcUniversalDriver',
    'org.apache.derby.jdbc.ClientDriver',
    'com.mckoi.JDBCDriver',
    'org.firebirdsql.jdbc.FBDriver',
    'sun.jdbc.odbc.JdbcOdbcDriver'
]
loaded = null
for (driver in candidates) {
    try {
        loaded = Class.forName(driver).newInstance()
        break
    } catch (Exception ex) { /* ignore */ }
}
println loaded?.class?.name // => sun.jdbc.odbc.JdbcOdbcDriver
//----------------------------------------------------------------------------------


// @@PLEAC@@_12.3
//----------------------------------------------------------------------------------
// In Groovy (like Java), any static reference to an external class within
// your class will cause the external class to be loaded from the classpath.
// You can dynamically add to the classpath using:
// this.class.rootLoader.addURL(url)
// To delay loading of external classes, use Class.forName() or evaluate()
// the script separately as shown in 12.2.

// For the specific case of initialization code, here is another example:
// (The code within the anonymous { ... } block is called whenever the
// class is loaded.)
class DbHelper {
    def driver
    {
        if (System.properties.'driver' == 'oracle')
            driver = Class.forName('oracle.jdbc.OracleDriver')
        else
            driver = Class.forName('sun.jdbc.odbc.JdbcOdbcDriver')
    }
}
println new DbHelper().driver.name // => sun.jdbc.odbc.JdbcOdbcDriver
// call program with -Ddriver=oracle to swap to other driver

// A slightly related feature: If you want to load a script (typically in a
// server environment) whenever the source file changes, use GroovyScriptEngine()
// instead of GroovyShell() when embedding groovy.
//----------------------------------------------------------------------------------


// @@PLEAC@@_12.4
//----------------------------------------------------------------------------------
// class variables are private unless access functions are defined
class Alpha {
    def x = 10
    private y = 12
}

println new Alpha().x    // => 10
println new Alpha().y    // => 12 when referenced inside source file, error outside
//----------------------------------------------------------------------------------


// @@PLEAC@@_12.5
//----------------------------------------------------------------------------------
// You can examine the stacktrace to determine the calling class: see 10.4
// When executing a script from a groovy source file, you can either:
println getClass().classLoader.resourceLoader.loadGroovySource(getClass().name)
// => file:/C:/Projects/GroovyExamples/Pleac/classes/pleac12.groovy
// or for the initially started script when started using the standard .bat/.sh files
println System.properties.'script.name'
//----------------------------------------------------------------------------------


// @@PLEAC@@_12.6
//----------------------------------------------------------------------------------
// For code which executes at class startup, see the initialization code block
// mechanism mentioned in 12.3. For code which should execute during shutdown
// see the finalize() method discussed (including limitations) in 13.2.
//----------------------------------------------------------------------------------


// @@PLEAC@@_12.7
//----------------------------------------------------------------------------------
// Each JVM process may have its own classpath (and indeed its own version of Java
// runtime and libraries). You "simply" supply a classpath pointing to different
// locations to obtain different modules.
// Groovy augments the JVM behaviour by allowing individuals to have a ~/.groovy/lib
// directory with additional libraries (and potentially other resources).
//----------------------------------------------------------------------------------


// @@PLEAC@@_12.8
//----------------------------------------------------------------------------------
// To make your code available to others could involve any of the following:
// (1) make your source code available
// (2) if you are creating a standard class, use the jar tool to package the
//     compiled code into a jar - this is then added to the classpath to use
// (3) if the jar relies on additional jars, this is sometimes specified in
//     a special manifest file within the jar
// (4) if the code is designed to run within a container environment, there
//     might be additional packaging, e.g. servlets might be packaged in a war
//     file - essentially a jar file with extra metadata in xml format.
// (5) you might also supply your package to a well known repository such as the
//     maven repository - and you will add dependency information in xml format
// (6) you may use platform specific installers to produce easily installable
//     components (e.g. windows .exe files or linux rpm's)
// (7) you may spackage up your components as a plugin (e.g. as an eclipse plugin)
//     this is also typically in jar/zip like format with additional metadata
//----------------------------------------------------------------------------------


// @@PLEAC@@_12.9
//----------------------------------------------------------------------------------
// Groovy has no SelfLoader. Class loading can be delayed using external scripts
// and by using the Class.forName() approach discussed in 12.2/12.3. If you have
// critical performance issues, you can use these techniques and keep your class
// size small to maximise the ability to defer loading. There are other kinds of
// performance tradeoffs you can make too. Alot of work has been done with JIT
// (just in time) compilers for bytecode. You can pre-compile Groovy source files
// into bytecode using the groovy compiler (groovyc). You can also do this on
// the fly for scripts you know you are going to need shortly.
//----------------------------------------------------------------------------------


// @@PLEAC@@_12.10
//----------------------------------------------------------------------------------
// Groovy has no AutoLoader. See the discussion in 12.9 for some techniques to
// impact program performance. There are many techniques available to speed up
// program performance (and in particular load speed). Some of these utilise
// techniques similar in nature to the technique used by the AutoLoader.
// As already mentioned, when you load a class into the JVM, any statically
// referenced class is also loaded. If you reference interfaces rather than
// concrete implementations, only the interface need be loaded. If you must
// reference a concrete implementation you can use either a Proxy class or
// classloader tricks to delay the loading of a full class (e.g. you supply a
// Proxy class with just one method implemented or a lazy-loading Proxy which
// loads the real class only when absolutely required)
//----------------------------------------------------------------------------------


// @@PLEAC@@_12.11
//----------------------------------------------------------------------------------
// You can use Categories to override Groovy and Java base functionality.
println new Date().time // => 1169019557140

class DateCategory {  // the class name by convention ends with category
    // we can add new functionality
    static float getFloatTime(Date self) {
        return (float) self.getTime()
    }
    // we can override existing functionality (now seconds since 1970 not millis)
    static long asSeconds(Date self) {
        return (long) (self.getTime()/1000)
    }
}

use (DateCategory) {
    println new Date().floatTime    // => 1.1690195E12
    println new Date().asSeconds()  // => 1169019557
}

// We can also use the 'as' keyword
class MathLib {
    def triple(n) { n * 4 }
    def twice(n) { n * 2 }
}
def m = new MathLib()
println m.twice(10)     // => 20
println m.triple(10)    // => 40 (Intentional Bug!)
// we might want to make use of some funtionality in the math
// library but want to later some of its features slightly or fix
// some bugs, we can simply import the original using a different name
import MathLib as BuggyMathLib
// now we could define our own MathLib which extended or had a delegate
// of the BuggyMathLib class
//----------------------------------------------------------------------------------


// @@PLEAC@@_12.12
//----------------------------------------------------------------------------------
// Many Java and Groovy programs emit a stacktrace when an error occurs.
// This shows both the calling and called programs (with line numbers if
// supplied). Groovy pretties up stacktraces to show less noise. You can use -d
// or --debug on the commandline to force it to always produce full stacktraces.
//----------------------------------------------------------------------------------


// @@PLEAC@@_12.13
//----------------------------------------------------------------------------------
// already have log10, how to create log11 to log100
(11..100).each { int base ->
    binding."log$base" = { int n -> Math.log(n) / Math.log(base) }
}
println log20(400)  // => 2.0
println log100(1000000)  // => 3.0 (displays 2.9999999999999996 using doubles)

// same thing again use currying
def logAnyBase = { base, n -> Math.log(n) / Math.log(base) }
(11..100).each { int base ->
    binding."log$base" = logAnyBase.curry(base)
}
println log20(400)  // => 2.0
println log100(1000000)  // => 3.0 (displays 2.9999999999999996 using doubles)
//----------------------------------------------------------------------------------


// @@PLEAC@@_12.14
//----------------------------------------------------------------------------------
// Groovy intefaces with C in the same way as Java: using JNI
// For this discussion we will ignoring platform specific options and CORBA.
// This tutorial here describes how to allow Java (and hence Groovy) to
// call a C program which generates UUIDs:
// http://ringlord.com/publications/jni-howto/
// Here's another useful reference:
// http://weblogs.java.net/blog/kellyohair/archive/2006/01/compilation_of_1.html
// And of course, Sun's tutorial:
// http://java.sun.com/developer/onlineTraining/Programming/JDCBook/jni.html

// You might also want to consider SWIG which simplifies connecting
// C/C++ to many scripting languages including Java (and hence Groovy)
// More details: http://www.swig.org/
//----------------------------------------------------------------------------------


// @@PLEAC@@_12.15
//----------------------------------------------------------------------------------
// See discussion for 12.14
//----------------------------------------------------------------------------------


// @@PLEAC@@_12.16
//----------------------------------------------------------------------------------
// The standard documentation system for Java is JavaDoc.
// Documentation for JavaDoc is part of a Java installation.
// Groovy has a GroovyDoc tool planned which expands upon the JavaDoc tool
// but work on the tool hasn't progressed much as yet.
//----------------------------------------------------------------------------------


// @@PLEAC@@_12.17
//----------------------------------------------------------------------------------
// Most libraries for Java (and hence Groovy) come precompiled. You simply download
// the jar and place it somewhere on your CLASSPATH.

// If only source code is available, you need to download the source and follow any
// instuctions which came with the source. Most projects use one of a handful of
// build tools to compile, test and package their artifacts. Typical ones are Ant
// and Maven which you need to install according to their respective instructions.

// If using Ant, you need to unpack the source files then type 'ant'.

// If using Maven, you need to unpack the source files then type 'maven'.

// If you are using Maven or Ivy for dependency management you can add
// the following lines to your project description file.
/*
    <dependency>
      <groupId>commons-collections</groupId>
      <artifactId>commons-collections</artifactId>
      <version>3.2</version>
    </dependency>
*/
// This will automatically download the particular version of the referenced
// library file and also provide hooks so that you can make this automatically
// available in your classpath.
//----------------------------------------------------------------------------------


// @@PLEAC@@_12.18
//----------------------------------------------------------------------------------
// example groovy file for a "module"
import org.apache.commons.lang.WordUtils

class Greeter {
    def name
    Greeter(who) { name = WordUtils.capitalize(who) }
    def salute() { "Hello $name!" }
}

// test class
class GreeterTest extends GroovyTestCase {
    def testGreeting() {
        assert new Greeter('world').salute()
    }
}

// Typical Ant build file (could be in Groovy instead of XML):
/*
<?xml version="1.0"?>
<project name="sample" default="jar" basedir=".">
    <property name="src" value="src"/>
    <property name="build" value="build"/>

    <target name="init">
        <mkdir dir="${build}"/>
    </target>

    <target name="compile" depends="init">
        <mkdir dir="${build}/classes"/>
        <groovyc srcdir="${src}" destdir="${build}/classes"/>
    </target>

    <target name="test" depends="compile">
        <groovy src="${src}/GreeterTest.groovy">
    </target>

    <target name="jar" depends="compile,test">
        <mkdir dir="${build}/jar"/>
        <jar destfile="${build}/jar/Greeter.jar" basedir="${build}/classes">
            <manifest>
                <attribute name="Main-Class" value="Greeter"/>
            </manifest>
        </jar>
    </target>
</project>

*/

// Typical dependency management file
/*
<?xml version="1.0" encoding="UTF-8"?>
<project
  xmlns="http://maven.apache.org/POM/4.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
          http://maven.apache.org/maven-v4_0_0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>groovy</groupId>
  <artifactId>module</artifactId>
  <name>Greeter</name>
  <version>1.0</version>
  <packaging>jar</packaging>
  <description>Greeter Module/description>
  <dependencies>
    <dependency>
      <groupId>commons-lang</groupId>
      <artifactId>commons-lang</artifactId>
      <version>2.2</version>
    </dependency>
  </dependencies>
</project>
*/
//----------------------------------------------------------------------------------


// @@PLEAC@@_12.19
//----------------------------------------------------------------------------------
// Searching available modules in repositories:
// You can browse the repositories online, e.g. ibiblio.org/maven2 or various
// plugins are available for IDEs which do this for you, e.g. JarJuggler for IntelliJ.

// Searching currently "installed" modules:
// Browse your install directory, view your maven POM file, look in your ~/.groovy/lib
// directory, turn on debug modes and watch classloader messages ...
//----------------------------------------------------------------------------------


// @@PLEAC@@_13.0
//----------------------------------------------------------------------------------
// Classes and objects in Groovy are rather straigthforward
class Person {
    // Class variables (also called static attributes) are prefixed by the keyword static
    static personCounter=0
    def age, name               // this creates setter and getter methods
    private alive

    // object constructor
    Person(age, name, alive = true) {            // Default arg like in C++
        this.age = age
        this.name = name
        this.alive = alive
        personCounter += 1
        // There is a '++' operator in Groovy but using += is often clearer.
    }

    def die() {
        alive = false
        println "$name has died at the age of $age."
        alive
    }

    def kill(anotherPerson) {
        println "$name is killing $anotherPerson.name."
        anotherPerson.die()
    }

    // methods used as queries generally start with is, are, will or can
    // usually have the '?' suffix
    def isStillAlive() {
        alive
    }

    def getYearOfBirth() {
        new Date().year - age
    }

    // Class method (also called static method)
    static getNumberOfPeople() { // accessors often start with get
                                 // in which case you can call it like
                                 // it was a field (without the get)
        personCounter
    }
}

// Using the class:
// Create objects of class Person
lecter = new Person(47, 'Hannibal')
starling = new Person(29, 'Clarice', true)
pazzi = new Person(40, 'Rinaldo', true)

// Calling a class method
println "There are $Person.numberOfPeople Person objects."

println "$pazzi.name is ${pazzi.alive ? 'alive' : 'dead'}."
lecter.kill(pazzi)
println "$pazzi.name is ${pazzi.isStillAlive() ? 'alive' : 'dead'}."

println "$starling.name was born in $starling.yearOfBirth."
//----------------------------------------------------------------------------------


// @@PLEAC@@_13.1
//----------------------------------------------------------------------------------
// Classes may have no constructor.
class MyClass { }

aValidButNotVeryUsefulObject = new MyClass()

// If no explicit constructor is given a default implicit
// one which supports named parameters is provided.
class MyClass2 {
    def start = new Date()
    def age = 0
}
println new MyClass2(age:4).age // => 4

// One or more explicit constructors may also be provided
class MyClass3 {
    def start
    def age
    MyClass3(date, age) {
        start = date
        this.age = age
    }
}
println new MyClass3(new Date(), 20).age // => 20
//----------------------------------------------------------------------------------


// @@PLEAC@@_13.2
//----------------------------------------------------------------------------------
// Objects are destroyed by the JVM garbage collector.
// The time of destroying is not predicated but left up to the JVM.
// There is no direct support for destructor. There is a courtesy
// method called finalize() which the JVM may call when disposing
// an object. If you need to free resources for an object, like
// closing a socket or killing a spawned subprocess, you should do
// it explicitly - perhaps by supporting your own lifecycle methods
// on your class, e.g. close().

class MyClass4{
    void finalize() {
        println "Object [internal id=${hashCode()}] is dying at ${new Date()}"
    }
}

// test code
50.times {
    new MyClass4()
}
20.times {
    System.gc()
}
// => (between 0 and 50 lines similar to below)
// Object [internal id=10884088] is dying at Wed Jan 10 16:33:33 EST 2007
// Object [internal id=6131844] is dying at Wed Jan 10 16:33:33 EST 2007
// Object [internal id=12245160] is dying at Wed Jan 10 16:33:33 EST 2007
// ...
//----------------------------------------------------------------------------------


// @@PLEAC@@_13.3
//----------------------------------------------------------------------------------
// You can write getter and setter methods explicitly as shown below.
// One convention is to use set and get at the start of method names.
class Person2 {
    private name
    def getName() { name }
    def setName(name) { this.name = name }
}

// You can also just use def which auto defines default getters and setters.
class Person3 {
    def age, name
}

// Any variables marked as final will only have a default getter.
// You can also write an explicit getter. For a write-only variable
// just write only a setter.
class Person4 {
    final age      // getter only
    def name       // getter and setter
    private color  // private
    def setColor() { this.color = color } // setter only
}
//----------------------------------------------------------------------------------


// @@PLEAC@@_13.4
//----------------------------------------------------------------------------------
class Person5 {
    // Class variables (also called static attributes) are prefixed by the keyword static
    static personCounter = 0

    static getPopulation() {
        personCounter
    }
    Person5() {
        personCounter += 1
    }
    void finalize() {
        personCounter -= 1
    }
}
people = []
10.times {
    people += new Person5()
}
println "There are ${Person5.population} people alive"
// => There are 10 people alive

alpha = new FixedArray()
println "Bound on alpha is $alpha.maxBounds"

beta = new FixedArray()
beta.maxBounds = 50
println "Bound on alpha is $alpha.maxBounds"

class FixedArray {
    static maxBounds = 100

    def getMaxBounds() {
        maxBounds
    }
    def setMaxBounds(value) {
        maxBounds = value
    }
}
// =>
// Bound on alpha is 100
// Bound on alpha is 50
//----------------------------------------------------------------------------------


// @@PLEAC@@_13.5
//----------------------------------------------------------------------------------
// The fields of this struct-like class are dynamically typed
class DynamicPerson { def name, age, peers }
p = new DynamicPerson()
p.name = "Jason Smythe"
p.age = 13
p.peers = ["Wilbur", "Ralph", "Fred"]
p.setPeers(["Wilbur", "Ralph", "Fred"])     // alternative using implicit setter
p["peers"] = ["Wilbur", "Ralph", "Fred"]    // alternative access using name of field
println "At age $p.age, $p.name's first friend is ${p.peers[0]}"
// => At age 13, Jason Smythe's first friend is Wilbur

// The fields of this struct-like class are statically typed
class StaticPerson { String name; int age; List peers }
p = new StaticPerson(name:'Jason', age:14, peers:['Fred','Wilbur','Ralph'])
println "At age $p.age, $p.name's first friend is ${p.peers[0]}"
// => At age 14, Jason's first friend is Fred


class Family { def head, address, members }
folks = new Family(head:new DynamicPerson(name:'John',age:34))

// supply of own accessor method for the struct for error checking
class ValidatingPerson {
    private age
    def printAge() { println 'Age=' + age }
    def setAge(value) {
        if (!(value instanceof Integer))
            throw new IllegalArgumentException("Argument '${value}' isn't an Integer")
        if (value > 150)
            throw new IllegalArgumentException("Age ${value} is unreasonable")
        age = value
    }
}

// test ValidatingPerson
def tryCreate(arg) {
    try {
        new ValidatingPerson(age:arg).printAge()
    } catch (Exception ex) {
        println ex.message
    }
}

tryCreate(20)
tryCreate('Youngish')
tryCreate(200)
// =>
// Age=20
// Argument 'Youngish' isn't an Integer
// Age 200 is unreasonable
//----------------------------------------------------------------------------------


// @@PLEAC@@_13.6
//----------------------------------------------------------------------------------
// Groovy objects are (loosely speaking) extended Java objects.
// Java's Object class provides a clone() method. The conventions of
// clone() are that if I say a = b.clone() then a and b should be
// different objects with the same type and value. Java doesn't
// enforce a class to implement a clone() method at all let alone
// require that one has to meet these conventions. Classes which
// do support clone() should implement the Cloneable interface and
// implement an equals() method.
// Groovy follows Java's conventions for clone().

class A implements Cloneable {
    def name
    boolean equals(Object other) {
        other instanceof A && this.name == other.name
    }
}
ob1 = new A(name:'My named thing')

ob2 = ob1.clone()
assert !ob1.is(ob2)
assert ob1.class == ob2.class
assert ob2.name == ob1.name
assert ob1 == ob2
//----------------------------------------------------------------------------------


// @@PLEAC@@_13.7
//----------------------------------------------------------------------------------
class CanFlicker {
    def flicker(arg) { return arg * 2 }
}
methname = 'flicker'
assert new CanFlicker().invokeMethod(methname, 10) == 20
assert new CanFlicker()."$methname"(10) == 20

class NumberEcho {
    def one() { 1 }
    def two() { 2 }
    def three() { 3 }
}
obj = new NumberEcho()
// call methods on the object, by name
assert ['one', 'two', 'three', 'two', 'one'].collect{ obj."$it"() }.join() == '12321'
//----------------------------------------------------------------------------------


// @@PLEAC@@_13.8
//----------------------------------------------------------------------------------
// Groovy can work with Groovy objects which inherit from a common base
// class called GroovyObject or Java objects which inherit from Object.

// the class of the object
assert 'a string'.class == java.lang.String

// Groovy classes are actually objects of class Class and they
// respond to methods defined in the Class class as well
assert 'a string'.class.class == java.lang.Class
assert !'a string'.class.isArray()

// ask an object whether it is an instance of particular class
n = 4.7f
println (n instanceof Integer)          // false
println (n instanceof Float)            // true
println (n instanceof Double)           // false
println (n instanceof String)           // false
println (n instanceof StaticPerson)     // false

// ask if a class or interface is either the same as, or is a
// superclass or superinterface of another class
println n.class.isAssignableFrom(Float.class)       // true
println n.class.isAssignableFrom(String.class)      // false

// can a Groovy object respond to a particular method?
assert new CanFlicker().metaClass.methods*.name.contains('flicker')

class POGO{}
println (obj.metaClass.methods*.name - new POGO().metaClass.methods*.name)
// => ["one", "two", "three"]
//----------------------------------------------------------------------------------


// @@PLEAC@@_13.9
//----------------------------------------------------------------------------------
// Most classes in Groovy are inheritable
class Person6{ def age, name }
dude = new Person6(name:'Jason', age:23)
println "$dude.name is age $dude.age."

// Inheriting from Person
class Employee extends Person6 {
    def salary
}
empl = new Employee(name:'Jason', age:23, salary:200)
println "$empl.name is age $empl.age and has salary $empl.salary."

// Many built-in class can be inherited the same way
class WierdList extends ArrayList {
    def size() {  // size method in this class is overridden
        super.size() * 2
    }
}
a = new WierdList()
a.add('dog')
a.add('cat')
println a.size() // => 4
//----------------------------------------------------------------------------------


// @@PLEAC@@_13.10
//----------------------------------------------------------------------------------
class Person7 { def firstname, surname; def getName(){ firstname + ' ' + surname } }
class Employee2 extends Person7 {
    def employeeId
    def getName(){ 'Employee Number ' + employeeId }
    def getRealName(){ super.getName() }
}
p = new Person7(firstname:'Jason', surname:'Smythe')
println p.name
// =>
// Jason Smythe
e = new Employee2(firstname:'Jason', surname:'Smythe', employeeId:12349876)
println e.name
println e.realName
// =>
// Employee Number 12349876
// Jason Smythe
//----------------------------------------------------------------------------------


// @@PLEAC@@_13.11
//----------------------------------------------------------------------------------
// Groovy's built in constructor and auto getter/setter features
 // give you the required functionalty already but you could also
 // override invokeMethod() for trickier scenarios.
class Person8 {
    def name, age, peers, parent
    def newChild(args) { new Person8(parent:this, *:args) }
}

dad = new Person8(name:'Jason', age:23)
kid = dad.newChild(name:'Rachel', age:2)
println "Kid's parent is ${kid.parent.name}"
// => Kid's parent is Jason

// additional fields ...
class Employee3 extends Person8 { def salary, boss }
//----------------------------------------------------------------------------------


// @@PLEAC@@_13.12
//----------------------------------------------------------------------------------
// Fields marked as private in Groovy can't be trampled by another class in
// the class hierarchy
class Parent {
    private name // my child's name
    def setChildName(value) { name = value }
    def getChildName() { name }
}
class GrandParent extends Parent {
    private name // my grandchild's name
    def setgrandChildName(value) { name = value }
    def getGrandChildName() { name }
}
g = new GrandParent()
g.childName = 'Jason'
g.grandChildName = 'Rachel'
println g.childName       // => Jason
println g.grandChildName  // => Rachel
//----------------------------------------------------------------------------------


// @@PLEAC@@_13.13
//----------------------------------------------------------------------------------
// The JVM garbage collector copes with circular structures.
// You can test it with this code:
class Person9 {
    def friend
    void finalize() {
        println "Object [internal id=${hashCode()}] is dying at ${new Date()}"
    }
}

def makeSomeFriends() {
    def first = new Person9()
    def second = new Person9(friend:first)
    def third = new Person9(friend:second)
    def fourth = new Person9(friend:third)
    def fifth = new Person9(friend:fourth)
    first.friend = fifth
}

makeSomeFriends()
100.times{
    System.gc()
}
// =>
// Object [internal id=24478976] is dying at Tue Jan 09 22:24:31 EST 2007
// Object [internal id=32853087] is dying at Tue Jan 09 22:24:31 EST 2007
// Object [internal id=23664622] is dying at Tue Jan 09 22:24:31 EST 2007
// Object [internal id=10630672] is dying at Tue Jan 09 22:24:31 EST 2007
// Object [internal id=25921812] is dying at Tue Jan 09 22:24:31 EST 2007
//----------------------------------------------------------------------------------


// @@PLEAC@@_13.14
//----------------------------------------------------------------------------------
// Groovy provides numerous methods which are automatically associated with
// symbol operators, e.g. here is '<=>' which is associated with compareTo()
// Suppose we have a class with a compareTo operator, such as:
class Person10 implements Comparable {
    def firstname, initial, surname
    Person10(f,i,s) { firstname = f; initial = i; surname = s }
    int compareTo(other) { firstname <=> other.firstname }
}
a = new Person10('James', 'T', 'Kirk')
b = new Person10('Samuel', 'L', 'Jackson')
println a <=> b
// => -1

// we can override the existing Person10's <=> operator as below
// so that now comparisons are made using the middle initial
// instead of the fisrtname:
class Person11 extends Person10 {
    Person11(f,i,s) { super(f,i,s) }
    int compareTo(other) { initial <=> other.initial }
}

a = new Person11('James', 'T', 'Kirk')
b = new Person11('Samuel', 'L', 'Jackson')
println a <=> b
// => 1

// we could also in general use Groovy's categories to extend class functionality.

// There is no way to directly overload the '""' (stringify)
// operator in Groovy.  However, by convention, classes which
// can reasonably be converted to a String will define a
// 'toString()' method as in the TimeNumber class defined below.
// The 'println' method will automatcally call an object's
// 'toString()' method as is demonstrated below. Furthermore,
// an object of that class can be used most any place where the
// interpreter is looking for a String value.

//---------------------------------------
// NOTE: Groovy has various built-in Time/Date/Calendar classes
// which would usually be used to manipulate time objects, the
// following is supplied for educational purposes to demonstrate
// operator overloading.
class TimeNumber {
    def h, m, s
    TimeNumber(hour, min, sec) { h = hour; m = min; s = sec }

    def toDigits(s) { s.toString().padLeft(2, '0') }
    String toString() {
        return toDigits(h) + ':' + toDigits(m) + ':' + toDigits(s)
    }

    def plus(other) {
        s = s + other.s
        m = m + other.m
        h = h + other.h
        if (s >= 60) {
            s %= 60
            m += 1
        }
        if (m >= 60) {
            m %= 60
            h += 1
        }
        return new TimeNumber(h, m, s)
    }

}

t1 = new TimeNumber(0, 58, 59)
sec = new TimeNumber(0, 0, 1)
min = new TimeNumber(0, 1, 0)
println t1 + sec + min + min

//-----------------------------
// StrNum class example: Groovy's builtin String class already has the
// capabilities outlined in StrNum Perl example, however the '*' operator
// on Groovy's String class acts differently: It creates a string which
// is the original string repeated N times.
//
// Using Groovy's String class as is in this example:
x = "Red"; y = "Black"
z = x+y
r = z*3 // r is "RedBlackRedBlackRedBlack"
println "values are $x, $y, $z, and $r"
println "$x is ${x < y ? 'LT' : 'GE'} $y"
// prints:
// values are Red, Black, RedBlack, and RedBlackRedBlackRedBlack
// Red is GE Black

//-----------------------------
class FixNum {
    def REGEX = /(\.\d*)/
    static final DEFAULT_PLACES = 0
    def float value
    def int places
    FixNum(value) {
        initValue(value)
        def m = value.toString() =~ REGEX
        if (m) places = m[0][1].size() - 1
        else places = DEFAULT_PLACES
    }
    FixNum(value, places) {
        initValue(value)
        this.places = places
    }
    private initValue(value) {
        this.value = value
    }

    def plus(other) {
        new FixNum(value + other.value, [places, other.places].max())
    }

    def multiply(other) {
        new FixNum(value * other.value, [places, other.places].max())
    }

    def div(other) {
        println "DEUG: Divide = ${value/other.value}"
        def result = new FixNum(value/other.value)
        result.places = [places,other.places].max()
        result
    }

    String toString() {
        //m = value.toString() =~ /(\d)/ + REGEX
        String.format("STR%s: %.${places}f", [this.class.name, value as float] as Object[])
    }
}

x = new FixNum(40)
y = new FixNum(12, 0)

println "sum of $x and $y is ${x+y}"
println "product of $x and $y is ${x*y}"

z = x/y
println "$z has $z.places places"
z.places = 2
println "$z now has $z.places places"

println "div of $x by $y is $z"
println "square of that is ${z*z}"
// =>
// sum of STRFixNum: 40 and STRFixNum: 12 is STRFixNum: 52
// product of STRFixNum: 40 and STRFixNum: 12 is STRFixNum: 480
// DEUG: Divide = 3.3333333333333335
// STRFixNum: 3 has 0 places
// STRFixNum: 3.33 now has 2 places
// div of STRFixNum: 40 by STRFixNum: 12 is STRFixNum: 3.33
// square of that is STRFixNum: 11.11
//----------------------------------------------------------------------------------


// @@PLEAC@@_13.15
//----------------------------------------------------------------------------------
// Groovy doesn't use the tie terminology but you can achieve
// similar results with Groovy's metaprogramming facilities
class ValueRing {
    private values
    def add(value) { values.add(0, value) }
    def next() {
        def head = values[0]
        values = values[1..-1] + head
        return head
    }
}
ring = new ValueRing(values:['red', 'blue'])
def getColor() { ring.next() }
void setProperty(String n, v) {
    if (n == 'color') { ring.add(v); return }
    super.setProperty(n,v)
}

println "$color $color $color $color $color $color"
// => red blue red blue red blue

color = 'green'
println "$color $color $color $color $color $color"
// => green red blue green red blue

// Groovy doesn't have the $_ implicit variable so we can't show an
// example that gets rid of it. We can however show an example of how
// you could add in a simplified version of that facility into Groovy.
// We use Groovy's metaProgramming facilities. We execute our script
// in a new GroovyShell so that we don't affect subsequent examples.
// script:
x = 3
println "$_"
y = 'cat' * x
println "$_"

// metaUnderscore:
void setProperty(String n, v) {
    super.setProperty('_',v)
    super.setProperty(n,v)
}

new GroovyShell().evaluate(metaUnderscore + script)
// =>
// 3
// catcatcat

// We can get a little bit fancier by making an UnderscoreAware class
// that wraps up some of this functionality. This is not recommended
// as good Groovy style but mimicks the $_ behaviour in a sinple way.
class UnderscoreAware implements GroovyInterceptable {
    private _saved
    void setProperty(String n, v) {
        _saved = v
        this.metaClass.setProperty(this, n, v)
    }
    def getProperty(String n) {
        if (n == '_') return _saved
        this.metaClass.getProperty(this, n)
    }
    def invokeMethod(String name, Object args) {
        if (name.startsWith('print') && args.size() == 0)
            args = [_saved] as Object[]
        this.metaClass.invokeMethod(this, name, args)
    }
}

class PerlishClass extends UnderscoreAware {
    private _age
    def setAge(age){ _age = age }
    def getAge(){ _age }
    def test() {
        age = 25
        println "$_"   // explicit $_ supported
        age++
        println()      // implicit $_ will be injected
    }
}

def x = new PerlishClass()
x.test()
// =>
// 25
// 26

// Autoappending hash:
class AutoMap extends HashMap {
    void setProperty(String name, v) {
        if (containsKey(name)) {
            put(name, get(name) + v)
        } else {
            put(name, [v])
        }
    }
}
m = new AutoMap()
m.beer = 'guinness'
m.food = 'potatoes'
m.food = 'peas'
println m
// => ["food":["potatoes", "peas"], "beer":["guinness"]]

// Case-Insensitive Hash:
class FoldedMap extends HashMap {
    void setProperty(String name, v) {
        put(name.toLowerCase(), v)
    }
    def getProperty(String name) {
        get(name.toLowerCase())
    }
}
tab = new FoldedMap()
tab.VILLAIN = 'big '
tab.herOine = 'red riding hood'
tab.villain += 'bad wolf'
println tab
// => ["heroine":"red riding hood", "villain":"big bad wolf"]

// Hash That "Allows Look-Ups by Key or Value":
class RevMap extends HashMap {
    void setProperty(String n, v) { put(n,v); put(v,n) }
    void remove(n) { super.remove(get(n)); super.remove(n) }
}
rev = new RevMap()
rev.Rojo = 'Red'
rev.Azul = 'Blue'
rev.Verde = 'Green'
rev.EVIL = [ "No way!", "Way!!" ]
rev.remove('Red')
rev.remove('Azul')
println rev
// =>
// [["No way!", "Way!!"]:"EVIL", "EVIL":["No way!", "Way!!"], "Verde":"Green", "Green":"Verde"]

// Infinite loop scenario:
// def x(n) { x(++n) }; x(0)
// => Caught: java.lang.StackOverflowError

// Multiple Strrams scenario:
class MultiStream extends PrintStream {
    def streams
    MultiStream(List streams) {
        super(streams[0])
        this.streams = streams
    }
    def println(String x) {
        streams.each{ it.println(x) }
    }
}
tee = new MultiStream([System.out, System.err])
tee.println ('This goes two places')
// =>
// This goes two places
// This goes two places
//----------------------------------------------------------------------------------


// @@PLEAC@@_14.0
//----------------------------------------------------------------------------------
As discussed in 14.1, many database options exist, one of which is JDBC.
Over 200 JDBC drivers are listed at the following URL:
http://developers.sun.com/product/jdbc/drivers/browse_all.jsp
//----------------------------------------------------------------------------------


// @@PLEAC@@_14.1
//----------------------------------------------------------------------------------
// Groovy can make use of various Java persistence libraries and has special
// support built-in (e.g. datasets) for interacting wth RDBMS systems.
// Some of the options include:
//   object serialization (built in to Java)
//   pbeans: pbeans.sf.net
//   prevayler: http://www.prevayler.org
//   Berkeley DB Java edition: http://www.oracle.com/database/berkeley-db/je/
//   JDBC: Over 200 drivers are listed at http://developers.sun.com/product/jdbc/drivers
//   Datasets (special Groovy support)
//   XML via e.g. xstream or JAXB or XmlBeans or ...
//   ORM: over 20 are listed at http://java-source.net/open-source/persistence
//   JNI: can be used directly on a platform that supports e.g. DBM or via
//     a cross platform API such as Apache APR which includes DBM routines:
//     http://apr.apache.org/docs/apr-util/0.9/group__APR__Util__DBM.html
//   jmork: used for Firefox/Thunderbird databases, e.g. address books, history files
// JDBC or Datasets would normally be most common for all examples in this chapter.


// Example shown using berkeley db Java edition - not quite as transparent as
// cookbook example as Berkeley DB Java addition makes transactions visible.
import com.sleepycat.je.*
tx = null
envHome = new File("D:/Projects/GroovyExamples/Pleac/data/db")

myEnvConfig = new EnvironmentConfig()
myEnvConfig.setAllowCreate(true)
myEnv = new Environment(envHome, myEnvConfig)

myDbConfig = new DatabaseConfig()
myDbConfig.setAllowCreate(true)
myDb = myEnv.openDatabase(tx, "vendorDB", myDbConfig)

theKey = new DatabaseEntry("key".getBytes("UTF-8"))
theData = new DatabaseEntry("data".getBytes("UTF-8"))
myDb.put(tx, theKey, theData)
if (myDb.get(tx, theKey, theData, LockMode.DEFAULT) == OperationStatus.SUCCESS) {
    key = new String(theKey.data, "UTF-8")
    foundData = new String(theData.data, "UTF-8")
    println "For key: '$key' found data: '$foundData'."
}
myDb.delete(tx, theKey)
myDb.close()
myEnv.close()


// userstats using pbeans
import net.sourceforge.pbeans.*
// on *nix use: whotext = "who".execute().text
whotext = '''
gnat ttyp1 May 29 15:39 (coprolith.frii.com)
bill ttyp1 May 28 15:38 (hilary.com)
gnit ttyp1 May 27 15:37 (somewhere.org)
'''

class LoginInfo implements Persistent {
    LoginInfo() {}
    LoginInfo(name) { this.name = name; loginCount = 1 }
    String name
    int loginCount
}

def printAllUsers(store) {
    printUsers(store, store.select(LoginInfo.class).collect{it.name}.sort())
}

def printUsers(store, list) {
    list.each{
        println "$it  ${store.selectSingle(LoginInfo.class, 'name', it).loginCount}"
    }
}

def addUsers(store) {
    whotext.trim().split('\n').each{
        m = it =~ /^(\S+)/
        name = m[0][1]
        item = store.selectSingle(LoginInfo.class, 'name', name)
        if (item) {
            item.loginCount++
            store.save(item)
        } else {
            store.insert(new LoginInfo(name))
        }
    }
}

def ds = new org.hsqldb.jdbc.jdbcDataSource()
ds.database = 'jdbc:hsqldb:hsql://localhost/mydb'
ds.user = 'sa'
ds.password = ''
store = new Store(ds)
if (args.size() == 0) {
    addUsers(store)
} else if (args == ['ALL']) {
    printAllUsers(store)
} else {
    printUsers(store, args)
}
//----------------------------------------------------------------------------------


// @@PLEAC@@_14.2
//----------------------------------------------------------------------------------
// Groovy would normally use JDBC here (see 14.1 for details)
import com.sleepycat.je.*
tx = null
envHome = new File("D:/Projects/GroovyExamples/Pleac/data/db")

myEnvConfig = new EnvironmentConfig()
myEnvConfig.setAllowCreate(true)
myEnv = new Environment(envHome, myEnvConfig)

myDbConfig = new DatabaseConfig()
myDbConfig.setAllowCreate(true)
myDb = myEnv.openDatabase(tx, "vendorDB", myDbConfig)

theKey = new DatabaseEntry("key".getBytes("UTF-8"))
theData = new DatabaseEntry("data".getBytes("UTF-8"))
myDb.put(tx, theKey, theData)
myDb.close()
// clear out database
returnCount = true
println myEnv.truncateDatabase(tx, "vendorDB", returnCount) + ' records deleted'
// remove database
myEnv.removeDatabase(tx, "vendorDB")
myEnv.close()
//----------------------------------------------------------------------------------


// @@PLEAC@@_14.3
//----------------------------------------------------------------------------------
// Original cookbook example not likely in Groovy.
// Here is a more realistic example, copying pbeans -> jdbc
// Creation of pbeans database not strictly needed but shown for completion

import net.sourceforge.pbeans.*
import groovy.sql.Sql

def ds = new org.hsqldb.jdbc.jdbcDataSource()
ds.database = 'jdbc:hsqldb:hsql://localhost/mydb'
ds.user = 'sa'
ds.password = ''
store = new Store(ds)

class Person implements Persistent {
    String name
    String does
    String email
}

// populate with test data
store.insert(new Person(name:'Tom Christiansen', does:'book author', email:'tchrist@perl.com'))
store.insert(new Person(name:'Tom Boutell', does:'Poet Programmer', email:'boutell@boutell.com'))

people = store.select(Person.class)

db = new Sql(ds)

db.execute 'CREATE TABLE people ( name VARCHAR, does VARCHAR, email VARCHAR );'
people.each{ p ->
    db.execute "INSERT INTO people ( name, does, email ) VALUES ($p.name,$p.does,$p.email);"
}
db.eachRow("SELECT * FROM people where does like 'book%'"){
    println "$it.name, $it.does, $it.email"
}
db.execute 'DROP TABLE people;'
// => Tom Christiansen, book author, tchrist@perl.com
//----------------------------------------------------------------------------------


// @@PLEAC@@_14.4
//----------------------------------------------------------------------------------
// Groovy would normally use JDBC here (see 14.1 for details)
import com.sleepycat.je.*

def copyEntries(indb, outdb) {
    cursor = indb1.openCursor(null, null)
    while (cursor.getNext(foundKey, foundData, LockMode.DEFAULT) == OperationStatus.SUCCESS)
        outdb.out(tx, foundKey, foundData)
    cursor.close()
}

tx = null
envHome = new File("D:/Projects/GroovyExamples/Pleac/data/db")

myEnvConfig = new EnvironmentConfig()
myEnvConfig.setAllowCreate(true)
myEnv = new Environment(envHome, myEnvConfig)

myDbConfig = new DatabaseConfig()
myDbConfig.setAllowCreate(true)
indb1 = myEnv.openDatabase(tx, "db1", myDbConfig)
indb2 = myEnv.openDatabase(tx, "db2", myDbConfig)
outdb = myEnv.openDatabase(tx, "db3", myDbConfig)
foundKey = new DatabaseEntry()
foundData = new DatabaseEntry()
copyEntries(indb1, outdb)
copyEntries(indb2, outdb)
cursor = indb2.openCursor(null, null)
while (cursor.getNext(foundKey, foundData, LockMode.DEFAULT) == OperationStatus.SUCCESS)
    outdb.out(tx, foundKey, foundData)
cursor.close()
indb1.close()
indb2.close()
outdb.close()
myEnv.close()
//----------------------------------------------------------------------------------


// @@PLEAC@@_14.5
//----------------------------------------------------------------------------------
// If you are using a single file based persistence mechanism you can
// use the file locking mechanisms mentioned in 7.11 otherwise the
// database itself or the ORM layer will provide locking mechanisms.
//----------------------------------------------------------------------------------


// @@PLEAC@@_14.6
//----------------------------------------------------------------------------------
// N/A for most Java/Groovy persistent technologies.
// Use indexes for RDBMS systems.
//----------------------------------------------------------------------------------


// @@PLEAC@@_14.7
//----------------------------------------------------------------------------------
 // We can write a category that allows the ArrayList class
 // to be persisted as required.
 class ArrayListCategory {
     static file = new File('/temp.txt')
     public static void save(ArrayList self) {
         def LS = System.getProperty('line.separator')
         file.withWriter{ w ->
             self.each{ w.write(it + LS)  }
         }
     }
 }

 lines = '''
 zero
 one
 two
 three
 four
 '''.trim().split('\n') as ArrayList

 use(ArrayListCategory) {
     println "ORIGINAL"
     for (i in 0..<lines.size())
         println "${i}: ${lines[i]}"

     a = lines[-1]
     lines[-1] = "last"
     println "The last line was [$a]"

     a = lines[0]
     lines = ["first"] + lines[1..-1]
     println "The first line was [$a]"

     lines.add(3, 'Newbie')
     lines.add(1, 'New One')

     lines.remove(3)

     println "REVERSE"
     (lines.size() - 1).downto(0){ i ->
         println "${i}: ${lines[i]}"
     }
     lines.save()
 }
 // =>
 // ORIGINAL
 // 0: zero
 // 1: one
 // 2: two
 // 3: three
 // 4: four
 // The last line was [four]
 // The first line was [zero]
 // REVERSE
 // 5: last
 // 4: three
 // 3: Newbie
 // 2: one
 // 1: New One
 // 0: first
//----------------------------------------------------------------------------------


// @@PLEAC@@_14.8
//----------------------------------------------------------------------------------
// example using pbeans
import net.sourceforge.pbeans.*
def ds = new org.hsqldb.jdbc.jdbcDataSource()
ds.database = 'jdbc:hsqldb:hsql://localhost/mydb'
ds.user = 'sa'
ds.password = ''
store = new Store(ds)

class Person implements Persistent {
    String name
    String does
    String email
}

name1 = 'Tom Christiansen'
name2 = 'Tom Boutell'

store.insert(new Person(name:name1, does:'book author', email:'tchrist@perl.com'))
store.insert(new Person(name:name2, does:'shareware author', email:'boutell@boutell.com'))

tom1 = store.selectSingle(Person.class, 'name', name1)
tom2 = store.selectSingle(Person.class, 'name', name2)

println "Two Toming: $tom1 $tom2"

if (tom1.name == tom2.name && tom1.does == tom2.does && tom1.email == tom2.email)
    println "You're having runtime fun with one Tom made two."
else
    println "No two Toms are ever alike"

tom2.does = 'Poet Programmer'
store.save(tom2)
// =>
// Two Toming: Person@12884e0 Person@8ab708
// No two Toms are ever alike
//----------------------------------------------------------------------------------


// @@PLEAC@@_14.9
//----------------------------------------------------------------------------------
// Use one of the mechanisms mentioned in 14.1 to load variables at the start
// of the script and save them at the end. You can save the binding, individual
// variables, maps of variables or composite objects.
//----------------------------------------------------------------------------------


// @@PLEAC@@_14.10
//----------------------------------------------------------------------------------
import groovy.sql.Sql

users = ['20':'Joe Bloggs', '40':'Bill Clinton', '60':'Ben Franklin']

def source = new org.hsqldb.jdbc.jdbcDataSource()
source.database = 'jdbc:hsqldb:mem:PLEAC'
source.user = 'sa'
source.password = ''
db = new Sql(source)

db.execute 'CREATE TABLE users ( uid INT, login CHAR(8) );'
users.each{ uid, login ->
    db.execute "INSERT INTO users ( uid, login ) VALUES ($uid,$login);"
}
db.eachRow('SELECT uid, login FROM users WHERE uid < 50'){
    println "$it.uid $it.login"
}
db.execute 'DROP TABLE users;'
// =>
// 20 Joe Bloggs
// 40 Bill Clinton
//----------------------------------------------------------------------------------


// @@PLEAC@@_14.11
//----------------------------------------------------------------------------------
// variation to cookbook: uses Firefox instead of Netscape, always assumes
// argument is a regex, has some others args, retains no args to list all

// uses jmork mork dbm reading library:
//     http://www.smartwerkz.com/projects/jmork/index.html
import mork.*
def cli = new CliBuilder()
cli.h(longOpt: 'help', 'print this message')
cli.e(longOpt: 'exclude', 'exclude hidden history entries (js, css, ads and images)')
cli.c(longOpt: 'clean', 'clean off url query string when reporting urls')
cli.v(longOpt: 'verbose', 'show referrer and first visit date')
def options = cli.parse(args)
if (options.h) { cli.usage(); System.exit(0) }
regex = options.arguments()
if (regex) regex = regex[0]
reader = new FileReader('Pleac/data/history.dat')
morkDocument = new MorkDocument(reader)
tables = morkDocument.tables
tables.each{ table ->
    table.rows.each { row ->
        url = row.getValue('URL')
        if (options.c) url = url.tokenize('?')[0]
        if (!regex || url =~ regex) {
            if (!options.e || row.getValue('Hidden') != '1') {
                println "$url\n    Last Visited: ${date(row,'LastVisitDate')}"
                if (options.v) {
                    println "    First Visited: ${date(row,'FirstVisitDate')}"
                    println "    Referrer: ${row.getValue('Referrer')}"
                }
            }
        }
    }
}
def date(row, key) {
    return new Date((long)(row.getValue(key).toLong()/1000))
}
// $ groovy gfh -ev oracle' =>
// http://www.oracle.com/technology/products/jdev/index.html
//     Last Visited: Thu Feb 15 20:20:36 EST 2007
//     First Visited: Thu Feb 15 20:20:36 EST 2007
//     Referrer: http://docs.codehaus.org/display/GROOVY/Oracle+JDeveloper+Plugin
//----------------------------------------------------------------------------------


// @@PLEAC@@_15.1
//----------------------------------------------------------------------------------
// The are several Java options builder packages available. Some popular ones:
//   Apache Jakarta Commons CLI: http://jakarta.apache.org/commons/cli/
//   jopt-simple: http://jopt-simple.sourceforge.net
//   args4j: https://args4j.dev.java.net/ (requires Java 5 with annotations)
//   jargs: http://jargs.sourceforge.net/
//   te-code: http://te-code.sourceforge.net/article-20041121-cli.html
// Most of these can be used from Groovy with some Groovy code benefits.
// Groovy also has the CliBuilder built right in.


// CliBuilder example
def cli = new CliBuilder()
cli.v(longOpt: 'verbose', 'verbose mode')
cli.D(longOpt: 'Debug', 'display debug info')
cli.o(longOpt: 'output', 'use/specify output file')
def options = cli.parse(args)
if (options.v) // ...
if (options.D) println 'Debugging info available'
if (options.o) {
    println 'Output file flag was specified'
    println "Output file is ${options.o}"
}
// ...


// jopt-simple example 1 (short form)
cli = new joptsimple.OptionParser("vDo::")
options = cli.parse(args)
if (options.wasDetected('o')) {
    println 'Output file flag was specified.'
    println "Output file is ${options.argumentsOf('o')}"
}
// ...


// jopt-simple example 2 (declarative form)
op = new joptsimple.OptionParser()
VERBOSE = 'v';  op.accepts( VERBOSE,  "verbose mode" )
DEBUG   = 'D';  op.accepts( DEBUG,    "display debug info" )
OUTPUT  = 'o';  op.accepts( OUTPUT,   "use/specify output file" ).withOptionalArg().
    describedAs( "file" ).ofType( File.class )
options = op.parse(args)
params = options.nonOptionArguments()
if (options.wasDetected( DEBUG )) println 'Debugging info available'
// ...
//----------------------------------------------------------------------------------


// @@PLEAC@@_15.2
//----------------------------------------------------------------------------------
// Groovy like Java can be run in a variety of scenarios, not just interactive vs
// non-interative, e.g. within a servlet container. Sometimes InputStreams and other
// mechanisms are used to hide away differences between the different containers
// in which code is run; other times, code needs to be written purpose-built for
// the container in which it is running. In most situations where the latter applies
// the container will have specific lifecycle mechanisms to allow the code to
// access specific needs, e.g. javax.servlet.ServletRequest.getInputStream()
// rather than System.in
//----------------------------------------------------------------------------------


// @@PLEAC@@_15.3
//----------------------------------------------------------------------------------
// Idiomatically Groovy encourages GUI over text-based applications where a rich
// interface is desirable. Libraries for richer text-based interfaces include:
// jline: http://jline.sourceforge.net
// jcurses: http://sourceforge.net/projects/javacurses/
// java-readline: http://java-readline.sourceforge.net
// enigma console: http://sourceforge.net/projects/enigma-shell/
// Note: Run examples using these libraries from command line not inside an IDE.

// If you are using a terminal/console that understands ANSI codes
// (excludes WinNT derivatives) you can just print the ANSI codes
print ((char)27 + '[2J')

// jline has constants for ANSI codes
import jline.ANSIBuffer
print ANSIBuffer.ANSICodes.clrscr()
// Also available through ConsoleReader.clearScreen()

// Using jcurses
import jcurses.system.*
bg = CharColor.BLACK
fg = CharColor.WHITE
screenColors = new CharColor(bg, fg)
Toolkit.clearScreen(screenColors)
//----------------------------------------------------------------------------------


// @@PLEAC@@_15.4
//----------------------------------------------------------------------------------
// Not idiomatic for Groovy to use text-based applications here.

// Using jcurses: http://sourceforge.net/projects/javacurses/
// use Toolkit.screenWidth and Toolkit.screenHeight

// 'barchart' example
import jcurses.system.Toolkit
numCols = Toolkit.screenWidth
rand = new Random()
if (numCols < 20) throw new RuntimeException("You must have at least 20 characters")
values = (1..5).collect { rand.nextInt(20) }  // generate rand values
max = values.max()
ratio = (numCols - 12)/max
values.each{ i ->
    printf('%8.1f %s\n', [i as double, "*" * ratio * i])
}

// gives, for example:
//   15.0 *******************************
//   10.0 *********************
//    5.0 **********
//   14.0 *****************************
//   18.0 **************************************
// Run from command line not inside an IDE which may give false width/height values.
//----------------------------------------------------------------------------------


// @@PLEAC@@_15.5
//----------------------------------------------------------------------------------
// Idiomatically Groovy encourages GUI over text-based applications where a rich
// interface is desirable. See 15.3 for richer text-based interface libraries.
// Note: Run examples using these libraries from command line not inside an IDE.

// If you are using a terminal/console that understands ANSI codes
// (excludes WinNT derivatives) you can just print the ANSI codes
ESC = "${(char)27}"
redOnBlack = ESC + '[31;40m'
reset = ESC + '[0m'
println (redOnBlack + 'Danger, Will Robinson!' + reset)

// jline has constants for ANSI codes
import jline.ANSIBuffer
redOnBlack = ANSIBuffer.ANSICodes.attrib(31) + ANSIBuffer.ANSICodes.attrib(40)
reset = ANSIBuffer.ANSICodes.attrib(0)
println redOnBlack + 'Danger, Will Robinson!' + reset

// Using JavaCurses
import jcurses.system.*
import jcurses.widgets.*
whiteOnBlack = new CharColor(CharColor.BLACK, CharColor.WHITE)
Toolkit.clearScreen(whiteOnBlack)
redOnBlack = new CharColor(CharColor.BLACK, CharColor.RED)
Toolkit.printString("Danger, Will Robinson!", 0, 0, redOnBlack)
Toolkit.printString("This is just normal text.", 0, 1, whiteOnBlack)
// Blink not supported by JavaCurses

// Using jline constants for Blink
blink = ANSIBuffer.ANSICodes.attrib(5)
reset = ANSIBuffer.ANSICodes.attrib(0)
println (blink + 'Do you hurt yet?' + reset)

// Using jline constants for Coral snake rhyme
def ansi(code) { ANSIBuffer.ANSICodes.attrib(code) }
redOnBlack = ansi(31) + ansi(40)
redOnYellow = ansi(31) + ansi(43)
greenOnCyanBlink = ansi(32) + ansi(46) + ansi(5)
reset = ansi(0)
println redOnBlack + "venom lack"
println redOnYellow + "kill that fellow"
println greenOnCyanBlink + "garish!" + reset
//----------------------------------------------------------------------------------


// @@PLEAC@@_15.6
//----------------------------------------------------------------------------------
// Default Java libraries buffer System.in by default.

// Using JavaCurses:
import jcurses.system.Toolkit
print 'Press a key: '
println "\nYou pressed the '${Toolkit.readCharacter().character}' key"

// Also works for special keys:
import jcurses.system.InputChar
print "Press the 'End' key to finish: "
ch = Toolkit.readCharacter()
assert ch.isSpecialCode()
assert ch.code == InputChar.KEY_END

// See also jline Terminal#readCharacter() and Terminal#readVirtualKey()
//----------------------------------------------------------------------------------


// @@PLEAC@@_15.7
//----------------------------------------------------------------------------------
print "${(char)7}"

// Using jline constant
print "${jline.ConsoleOperations.KEYBOARD_BELL}"
// Also available through ConsoleReader.beep()

// Using JavaCurses (Works only with terminals that support 'beeps')
import jcurses.system.Toolkit
Toolkit.beep()
//----------------------------------------------------------------------------------


// @@PLEAC@@_15.8
//----------------------------------------------------------------------------------
// I think you would need to resort to platform specific calls here,
// E.g. on *nix systems call 'stty' using execute().
// Some things can be set through the packages mentioned in 15.3, e.g.
// echo can be turned on and off, but others like setting the kill character
// didn't appear to be supported (presumably because it doesn't make
// sense for a cross-platform toolkit).
//----------------------------------------------------------------------------------


// @@PLEAC@@_15.9
//----------------------------------------------------------------------------------
// Consider using Java's PushbackInputStream or PushbackReader
// Different functionality to original cookbook but can be used
// as an alternative for some scenarios.
//----------------------------------------------------------------------------------


// @@PLEAC@@_15.10
//----------------------------------------------------------------------------------
// If using Java 6, use Console.readPassword()
// Otherwise use jline (use 0 instead of mask character '*' for no echo):
password = new jline.ConsoleReader().readLine(new Character('*'))
//----------------------------------------------------------------------------------


// @@PLEAC@@_15.11
//----------------------------------------------------------------------------------
// In Groovy (like Java) normal input is buffered so you can normally make
// edits before hitting 'Enter'. For more control over editing (including completion
// and history etc.) use one of the packages mentioned in 15.3, e.g. jline.
//----------------------------------------------------------------------------------


// @@PLEAC@@_15.12
//----------------------------------------------------------------------------------
// Use javacurses or jline (see 15.3) for low level screen management.
// Java/Groovy would normally use a GUI for such functionality.

// Here is a slight variation to cookbook example. This repeatedly calls
// the command feedin on the command line, e.g. "cmd /c dir" on windows
// or 'ps -aux' on Linux. Whenever a line changes, the old line is "faded
// out" using font colors from white through to black. Then the new line
// is faded in using the reverse process.
import jcurses.system.*
color = new CharColor(CharColor.BLACK, CharColor.WHITE)
Toolkit.clearScreen(color)
maxcol = Toolkit.screenWidth
maxrow = Toolkit.screenHeight
colors = [CharColor.WHITE, CharColor.CYAN, CharColor.YELLOW, CharColor.GREEN,
          CharColor.RED, CharColor.BLUE, CharColor.MAGENTA, CharColor.BLACK]
done = false
refresh = false
waittime = 8000
oldlines = []
def fade(line, row, colorList) {
    for (i in 0..<colorList.size()) {
        Toolkit.printString(line, 0, row, new CharColor(CharColor.BLACK, colorList[i]))
        sleep 10
    }
}
while(!done) {
    if (waittime > 9999 || refresh) {
        proc = args[0].execute()
        lines = proc.text.split('\n')
        for (r in 0..<maxrow) {
            if (r >= lines.size() || r > oldlines.size() || lines[r] != oldlines[r]) {
                if (oldlines != [])
                    fade(r < oldlines.size() ? oldlines[r] : ' ' * maxcol, r, colors)
                fade(r < lines.size() ? lines[r] : ' ' * maxcol, r, colors.reverse())
            }
        }
        oldlines = lines
        refresh = false
        waittime = 0
    }
    waittime += 200
    sleep 200
}

// Keyboard handling would be similar to 15.6.
// Something like below but need to synchronize as we are in different threads.
Thread.start{
    while(!done) {
        ch = Toolkit.readCharacter()
        if (ch.isSpecialCode() || ch.character == 'q') done = true
        else refresh = true
    }
}
//----------------------------------------------------------------------------------


// @@PLEAC@@_15.13
//----------------------------------------------------------------------------------
// These examples uses expectj, a pure Java Expect-like module.
// http://expectj.sourceforge.net/
defaultTimeout = -1 // infinite
expect = new expectj.ExpectJ("logfile.log", defaultTimeout)
command = expect.spawn("program to run")
command.expect('Password', 10)
// expectj doesn't support regular expressions, but see readUntil
// in recipe 18.6 for how to manually code this
command.expect('invalid')
command.send('Hello, world\r')
// kill spawned process
command.stop()

// expecting multiple choices
// expectj doesn't support multiple choices, but see readUntil
// in recipe 18.6 for how to manually code this
//----------------------------------------------------------------------------------


// @@PLEAC@@_15.14
//----------------------------------------------------------------------------------
// Methods not shown for the edit menu items, they would be the same as for the
// file menu items.
import groovy.swing.SwingBuilder
def print() {}
def save() {}
frame = new SwingBuilder().frame(title:'Demo') {
    menuBar {
        menu(mnemonic:'F', 'File') {
            menuItem (actionPerformed:this.&print, 'Print')
            separator()
            menuItem (actionPerformed:this.&save, 'Save')
            menuItem (actionPerformed:{System.exit(0)}, 'Quit immediately')
        }
        menu(mnemonic:'O', 'Options') {
            checkBoxMenuItem ('Create Debugging Info', state:true)
        }
        menu(mnemonic:'D', 'Debug') {
            group = buttonGroup()
            radioButtonMenuItem ('Log Level 1', buttonGroup:group, selected:true)
            radioButtonMenuItem ('Log Level 2', buttonGroup:group)
            radioButtonMenuItem ('Log Level 3', buttonGroup:group)
        }
        menu(mnemonic:'F', 'Format') {
            menu('Font') {
                group = buttonGroup()
                radioButtonMenuItem ('Times Roman', buttonGroup:group, selected:true)
                radioButtonMenuItem ('Courier', buttonGroup:group)
            }
        }
        menu(mnemonic:'E', 'Edit') {
            menuItem (actionPerformed:{}, 'Copy')
            menuItem (actionPerformed:{}, 'Cut')
            menuItem (actionPerformed:{}, 'Paste')
            menuItem (actionPerformed:{}, 'Delete')
            separator()
            menu('Object ...') {
                menuItem (actionPerformed:{}, 'Circle')
                menuItem (actionPerformed:{}, 'Square')
                menuItem (actionPerformed:{}, 'Point')
            }
        }
    }
}
frame.pack()
frame.show()
//----------------------------------------------------------------------------------


// @@PLEAC@@_15.15
//----------------------------------------------------------------------------------
// Registration Example
import groovy.swing.SwingBuilder
def cancel(event) {
    println 'Sorry you decided not to register.'
    dialog.dispose()
}
def register(event) {
    if (swing.name?.text) {
        println "Welcome to the fold $swing.name.text"
        dialog.dispose()
    } else println "You didn't give me your name!"
}
def dialog(event) {
    dialog = swing.createDialog(title:'Entry')
    def panel = swing.panel {
        vbox {
            hbox {
                label(text:'Name')
                textField(columns:20, id:'name')
            }
            hbox {
                button('Register', actionPerformed:this.&register)
                button('Cancel', actionPerformed:this.&cancel)
            }
        }
    }
    dialog.getContentPane().add(panel)
    dialog.pack()
    dialog.show()
}
swing = new SwingBuilder()
frame = swing.frame(title:'Registration Example') {
    panel {
        button(actionPerformed:this.&dialog, 'Click Here For Registration Form')
        glue()
        button(actionPerformed:{System.exit(0)}, 'Quit')
    }
}
frame.pack()
frame.show()


// Error Example, slight variation to original cookbook
import groovy.swing.SwingBuilder
import javax.swing.WindowConstants as WC
import javax.swing.JOptionPane
def calculate(event) {
    try {
        swing.result.text = evaluate(swing.expr.text)
    } catch (Exception ex) {
        JOptionPane.showMessageDialog(frame, ex.message)
    }
}
swing = new SwingBuilder()
frame = swing.frame(title:'Calculator Example',
    defaultCloseOperation:WC.EXIT_ON_CLOSE) {
    panel {
        vbox {
            hbox {
                label(text:'Expression')
                hstrut()
                textField(columns:12, id:'expr')
            }
            hbox {
                label(text:'Result')
                glue()
                label(id:'result')
            }
            hbox {
                button('Calculate', actionPerformed:this.&calculate)
                button('Quit', actionPerformed:{System.exit(0)})
            }
        }
    }
}
frame.pack()
frame.show()
//----------------------------------------------------------------------------------


// @@PLEAC@@_15.16
//----------------------------------------------------------------------------------
// Resizing in Groovy follows Java rules, i.e. is dependent on the layout manager.
// You can set preferred, minimum and maximum sizes (may be ignored by some layout managers).
// You can setResizable(false) for some components.
// You can specify a weight value for some layout managers, e.g. GridBagLayout
// which control the degree of scaling which occurs during resizing.
// Some layout managers, e.g. GridLayout, automaticaly resize their contained widgets.
// You can capture resize events and do everything manually yourself.
//----------------------------------------------------------------------------------


// @@PLEAC@@_15.17
//----------------------------------------------------------------------------------
// Removing DOS console on Windows:
// If you are using java.exe to start your Groovy script, use javaw.exe instead.
// If you are using groovy.exe to start your Groovy script, use groovyw.exe instead.
//----------------------------------------------------------------------------------


// @@PLEAC@@_15.18
//----------------------------------------------------------------------------------
// additions to original cookbook:
// random starting position
// color changes after each bounce
import jcurses.system.*
color = new CharColor(CharColor.BLACK, CharColor.WHITE)
Toolkit.clearScreen(color)
rand = new Random()
maxrow = Toolkit.screenWidth
maxcol = Toolkit.screenHeight
rowinc = 1
colinc = 1
row = rand.nextInt(maxrow)
col = rand.nextInt(maxcol)
chars = '*-/|\\_'
colors = [CharColor.RED, CharColor.BLUE, CharColor.YELLOW,
          CharColor.GREEN, CharColor.CYAN, CharColor.MAGENTA]
delay = 20
ch = null
def nextChar(){
    ch = chars[0]
    chars = chars[1..-1] + chars[0]
    color = new CharColor(CharColor.BLACK, colors[0])
    colors = colors[1..-1] + colors[0]
}
nextChar()
while(true) {
    Toolkit.printString(ch, row, col, color)
    sleep delay
    row = row + rowinc
    col = col + colinc
    if (row in [0, maxrow]) { nextChar(); rowinc = -rowinc }
    if (col in [0, maxcol]) { nextChar(); colinc = -colinc }
}
//----------------------------------------------------------------------------------


// @@PLEAC@@_15.19
//----------------------------------------------------------------------------------
// Variation to cookbook. Let's you reshuffle lines in a multi-line string
// by drag-n-drop.
import java.awt.*
import java.awt.datatransfer.*
import java.awt.dnd.*
import javax.swing.*
import javax.swing.ScrollPaneConstants as SPC

class DragDropList extends JList implements
        DragSourceListener, DropTargetListener, DragGestureListener {
    def dragSource
    def dropTarget
    def dropTargetCell
    int draggedIndex = -1
    def localDataFlavor = new DataFlavor(DataFlavor.javaJVMLocalObjectMimeType)
    def supportedFlavors = [localDataFlavor] as DataFlavor[]

    public DragDropList(model) {
        super()
        setModel(model)
        setCellRenderer(new DragDropCellRenderer(this))
        dragSource = new DragSource()
        dragSource.createDefaultDragGestureRecognizer(this, DnDConstants.ACTION_MOVE, this)
        dropTarget = new DropTarget(this, this)
    }

    public void dragGestureRecognized(DragGestureEvent dge) {
        int index = locationToIndex(dge.dragOrigin)
        if (index == -1 || index == model.size() - 1) return
        def trans = new CustomTransferable(model.getElementAt(index), this)
        draggedIndex = index
        dragSource.startDrag(dge, Cursor.defaultCursor, trans, this)
    }

    public void dragDropEnd(DragSourceDropEvent dsde) {
        dropTargetCell = null
        draggedIndex = -1
        repaint()
    }

    public void dragEnter(DragSourceDragEvent dsde) { }

    public void dragExit(DragSourceEvent dse) { }

    public void dragOver(DragSourceDragEvent dsde) { }

    public void dropActionChanged(DragSourceDragEvent dsde) { }

    public void dropActionChanged(DropTargetDragEvent dtde) { }

    public void dragExit(DropTargetEvent dte) { }

    public void dragEnter(DropTargetDragEvent dtde) {
        if (dtde.source != dropTarget) dtde.rejectDrag()
        else dtde.acceptDrag(DnDConstants.ACTION_COPY_OR_MOVE)
    }

    public void dragOver(DropTargetDragEvent dtde) {
        if (dtde.source != dropTarget) dtde.rejectDrag()
        int index = locationToIndex(dtde.location)
        if (index == -1 || index == draggedIndex + 1) dropTargetCell = null
        else dropTargetCell = model.getElementAt(index)
        repaint()
    }

    public void drop(DropTargetDropEvent dtde) {
        if (dtde.source != dropTarget) {
            dtde.rejectDrop()
            return
        }
        int index = locationToIndex(dtde.location)
        if (index == -1 || index == draggedIndex) {
            dtde.rejectDrop()
            return
        }
        dtde.acceptDrop(DnDConstants.ACTION_MOVE)
        def dragged = dtde.transferable.getTransferData(localDataFlavor)
        boolean sourceBeforeTarget = (draggedIndex < index)
        model.remove(draggedIndex)
        model.add((sourceBeforeTarget ? index - 1 : index), dragged)
        dtde.dropComplete(true)
    }
}

class CustomTransferable implements Transferable {
    def object
    def ddlist

    public CustomTransferable(object, ddlist) {
        this.object = object
        this.ddlist = ddlist
    }

    public Object getTransferData(DataFlavor df) {
        if (isDataFlavorSupported(df)) return object
    }

    public boolean isDataFlavorSupported(DataFlavor df) {
        return df.equals(ddlist.localDataFlavor)
    }

    public DataFlavor[] getTransferDataFlavors() {
        return ddlist.supportedFlavors
    }
}

class DragDropCellRenderer extends DefaultListCellRenderer {
    boolean isTargetCell
    def ddlist

    public DragDropCellRenderer(ddlist) {
        super()
        this.ddlist = ddlist
    }

    public Component getListCellRendererComponent(JList list, Object value,
            int index, boolean isSelected, boolean hasFocus) {
        isTargetCell = (value == ddlist.dropTargetCell)
        boolean showSelected = isSelected && !isTargetCell
        return super.getListCellRendererComponent(list, value, index, showSelected, hasFocus)
    }

    public void paintComponent(Graphics g) {
        super.paintComponent(g)
        if (isTargetCell) {
            g.setColor(Color.black)
            g.drawLine(0, 0, size.width.intValue(), 0)
        }
    }
}

lines = '''
This is line 1
This is line 2
This is line 3
This is line 4
'''.trim().split('\n')
def listModel = new DefaultListModel()
lines.each{ listModel.addElement(it) }
listModel.addElement(' ') // dummy
def list = new DragDropList(listModel)
def sp = new JScrollPane(list, SPC.VERTICAL_SCROLLBAR_ALWAYS, SPC.HORIZONTAL_SCROLLBAR_NEVER)
def frame = new JFrame('Line Shuffle Example')
frame.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE)
frame.contentPane.add(sp)
frame.pack()
frame.setVisible(true)
//----------------------------------------------------------------------------------


// @@PLEAC@@_16.1
//----------------------------------------------------------------------------------
output = "program args".execute().text
//----------------------------------------------------------------------------------


// @@PLEAC@@_16.2
//----------------------------------------------------------------------------------
proc = "vi myfile".execute()
proc.waitFor()
//----------------------------------------------------------------------------------


// @@PLEAC@@_16.3
//----------------------------------------------------------------------------------
// Calling execute() on a String, String[] or List (of Strings or objects with
// a toString() method) will fork off another process.
// This doesn't replace the existing process but if you simply finish the original
// process (leaving the spawned process to finish asynchronously) you will achieve
// a similar thing.
"archive *.data".execute()
["archive", "accounting.data"].execute()
//----------------------------------------------------------------------------------


// @@PLEAC@@_16.4
//----------------------------------------------------------------------------------
// sending text to the input of another process
proc = 'groovy -e "print System.in.text.toUpperCase()"'.execute()
Thread.start{
    def writer = new PrintWriter(new BufferedOutputStream(proc.out))
    writer.println('Hello')
    writer.close()
}
proc.waitFor()
// further process output from process
print proc.text.reverse()
// =>
// OLLEH
//----------------------------------------------------------------------------------


// @@PLEAC@@_16.5
//----------------------------------------------------------------------------------
// filter your own output
keep = System.out
pipe = new PipedInputStream()
reader = new BufferedReader(new InputStreamReader(pipe))
System.setOut(new PrintStream(new BufferedOutputStream(new PipedOutputStream(pipe))))
int numlines = 2
Thread.start{
    while((next = reader.readLine()) != null) {
        if (numlines-- > 0) keep.println(next)
    }
}
(1..8).each{ println it }
System.out.close()
System.setOut(keep)
(9..10).each{ println it }
// =>
// 1
// 2
// 9
// 10


// filtering output by adding quotes and numbers
class FilterOutput extends Thread {
    Closure c
    Reader reader
    PrintStream orig
    FilterOutput(Closure c) {
        this.c = c
        orig = System.out
        def pipe = new PipedInputStream()
        reader = new BufferedReader(new InputStreamReader(pipe))
        System.setOut(new PrintStream(new BufferedOutputStream(new PipedOutputStream(pipe))))
    }
    void run() {
        def next
        while((next = reader.readLine()) != null) {
            c(orig, next)
        }
    }
    def close() {
        sleep 100
        System.out.close()
        System.setOut(orig)
    }
}
cnt = 0
number = { s, n -> cnt++; s.println(cnt + ':' + n) }
quote =  { s, n -> s.println('> ' + n) }
f1 = new FilterOutput(number); f1.start()
f2 = new FilterOutput(quote); f2.start()
('a'..'e').each{ println it }
f2.close()
f1.close()
//----------------------------------------------------------------------------------


// @@PLEAC@@_16.6
//----------------------------------------------------------------------------------
// Groovy programs (like Java ones) would use streams here. Just process
// another stream instead of System.in or System.out:

// process url text
input = new URL(address).openStream()
// ... process 'input' stream

// process compressed file
input = new GZIPInputStream(new FileInputStream('source.gzip'))
// ... process 'input' stream
//----------------------------------------------------------------------------------


// @@PLEAC@@_16.7
//----------------------------------------------------------------------------------
// To read STDERR of a process you execute
proc = 'groovy -e "println args[0]"'.execute()
proc.waitFor()
println proc.err.text
// => Caught: java.lang.ArrayIndexOutOfBoundsException: 0 ...

// To redirect your STDERR to a file
System.setErr(new PrintStream(new FileOutputStream("error.txt")))
//----------------------------------------------------------------------------------


// @@PLEAC@@_16.8
//----------------------------------------------------------------------------------
// See 16.2, the technique allows both STDIN and STDOUT of another program to be
// changed at the same time, not just one or the other as per Perl 16.2 solution
//----------------------------------------------------------------------------------


// @@PLEAC@@_16.9
//----------------------------------------------------------------------------------
// See 16.2 and 16.7, the techniques can be combined to allow all three streams
// (STDIN, STDOUT, STDERR) to be altered as required.
//----------------------------------------------------------------------------------


// @@PLEAC@@_16.10
//----------------------------------------------------------------------------------
// Groovy can piggy-back on the many options available to Java here:
// JIPC provides a wide set of standard primitives: semaphore, event,
//   FIFO queue, barrier, shared memory, shared and exclusive locks:
//   http://www.garret.ru/~knizhnik/jipc/jipc.html
// sockets allow process to communicate via low-level packets
// CORBA, RMI, SOAP allow process to communicate via RPC calls
// shared files can also be used
// JMS allows process to communicate via a messaging service

// Simplist approach is to just link streams:
proc1 = 'groovy -e "println args[0]" Hello'.execute()
proc2 = 'groovy -e "print System.in.text.toUpperCase()"'.execute()
Thread.start{
    def reader = new BufferedReader(new InputStreamReader(proc1.in))
    def writer = new PrintWriter(new BufferedOutputStream(proc2.out))
    while ((next = reader.readLine()) != null) {
        writer.println(next)
    }
    writer.close()
}
proc2.waitFor()
print proc2.text
// => HELLO
//----------------------------------------------------------------------------------


// @@PLEAC@@_16.11
//----------------------------------------------------------------------------------
// Java/Groovy would normally just use some socket-based technique for communicating
// between processes (see 16.10 for a list of options). If you really must use a named
// pipe, you have these options:
// (1) On *nix machines:
// * Create a named pipe by invoking the mkfifo utility using execute().
// * Open a named pipe by name - which is just like opening a file.
// * Run an external process setting its input and output streams (see 16.1, 16.4, 16.5)
// (2) On Windows machines, Using JCIFS to Connect to Win32 Named Pipes, see:
// http://jcifs.samba.org/src/docs/pipes.html
// Neither of these achieve exactly the same result as the Perl example but some
// scenarios will be almost identical.
//----------------------------------------------------------------------------------


// @@PLEAC@@_16.12
//----------------------------------------------------------------------------------
// The comments made in 16.10 regarding other alternative IPC mechanisms also apply here.

// This example would normally be done with multiple threads in Java/Groovy as follows.
class Shared {
    String buffer = "not set yet"
    synchronized void leftShift(value){
        buffer = value
        notifyAll()
    }
    synchronized Object read() {
        return buffer
    }
}
shared = new Shared()
rand = new Random()
threads = []
(1..5).each{
    t = new Thread(){
        def me = t
        for (j in 0..9) {
            shared << "$me.name $j"
            sleep 100 + rand.nextInt(200)
        }
    }
    t.start()
}
while(1) {
    println shared.read()
    sleep 50
}
// =>
// not set yet
// Thread-2 0
// Thread-5 1
// Thread-1 1
// Thread-4 2
// Thread-3 1
// ...
// Thread-5 9


// Using JIPC between processes (as a less Groovy alternative that is closer
// to the original cookbook) is shown below.

// ipcWriterScript:
import org.garret.jipc.client.JIPCClientFactory
port = 6000
factory = JIPCClientFactory.instance
session = factory.create('localhost', port)
mutex = session.createMutex("myMutex", false)
buffer = session.createSharedMemory("myBuffer", "not yet set")
name = args[0]
rand = new Random()
(0..99).each {
    mutex.lock()
    buffer.set("$name $it".toString())
    mutex.unlock()
    sleep 200 + rand.nextInt(500)
}
session.close()

// ipcReaderScript:
import org.garret.jipc.client.JIPCClientFactory
port = 6000
factory = JIPCClientFactory.instance
session = factory.create('localhost', port)
mutex = session.createMutex("myMutex", false)
buffer = session.createSharedMemory("myBuffer", "not yet set")
rand = new Random()
(0..299).each {
    mutex.lock()
    println buffer.get()
    mutex.unlock()
    sleep 150
}
session.close()

// kick off processes:
"java org.garret.jipc.server.JIPCServer 6000".execute()
"groovy ipcReaderScript".execute()
(0..3).each{ "groovy ipcWriterScript $it".execute() }

// =>
// ...
// 0 10
// 2 10
// 2 11
// 1 9
// 1 9
// 1 10
// 2 12
// 3 12
// 3 12
// 2 13
// ...
//----------------------------------------------------------------------------------


// @@PLEAC@@_16.13
//----------------------------------------------------------------------------------
// Signal handling in Groovy (like Java) is operating system and JVM dependent.
// The ISO C standard only requires the signal names SIGABRT, SIGFPE, SIGILL,
// SIGINT, SIGSEGV, and SIGTERM to be defined but depending on your platform
// other signals may be present, e.g. Windows supports SIGBREAK. For more info
// see: http://www-128.ibm.com/developerworks/java/library/i-signalhandling/
// Note: if you start up the JVM with -Xrs the JVM will try to reduce its
// internal usage of signals. Also the JVM takes over meany hooks and provides
// platform independent alternatives, e.g. see java.lang.Runtime#addShutdownHook()

// To see what signals are available for your system (excludes ones taken over
// by the JVM):
sigs = '''HUP INT QUIT ILL TRAP ABRT EMT FPE KILL BUS SEGV SYS PIPE ALRM TERM
USR1 USR2 CHLD PWR WINCH URG POLL STOP TSTP CONT TTIN TTOU VTALRM PROF XCPU
XFSZ WAITING LWP AIO IO INFO THR BREAK FREEZE THAW CANCEL EMT
'''

sigs.tokenize(' \n').each{
    try {
        print ' ' + new sun.misc.Signal(it)
    } catch(IllegalArgumentException iae) {}
}
// =>  on Windows XP:
// SIGINT SIGILL SIGABRT SIGFPE SIGSEGV SIGTERM SIGBREAK
//----------------------------------------------------------------------------------


// @@PLEAC@@_16.14
//----------------------------------------------------------------------------------
// To send a signal to your process:
Signal.raise(new Signal("INT"))
//----------------------------------------------------------------------------------


// @@PLEAC@@_16.15
//----------------------------------------------------------------------------------
// install a signal handler
class DiagSignalHandler implements SignalHandler { ... }
diagHandler = new DiagSignalHandler()
Signal.handle(new Signal("INT"), diagHandler)
//----------------------------------------------------------------------------------


// @@PLEAC@@_16.16
//----------------------------------------------------------------------------------
// temporarily install a signal handler
class DiagSignalHandler implements SignalHandler { ... }
diagHandler = new DiagSignalHandler()
oldHandler = Signal.handle(new Signal("INT"), diagHandler)
Signal.handle(new Signal("INT"), oldHandler)
//----------------------------------------------------------------------------------


// @@PLEAC@@_16.17
//----------------------------------------------------------------------------------
import sun.misc.Signal
import sun.misc.SignalHandler

class DiagSignalHandler implements SignalHandler {
    private oldHandler

    // Static method to install the signal handler
    public static install(signal) {
        def diagHandler = new DiagSignalHandler()
        diagHandler.oldHandler = Signal.handle(signal, diagHandler)
    }

    public void handle(Signal sig) {
        println("Diagnostic Signal handler called for signal "+sig)
        // Output information for each thread
        def list = []
        Thread.activeCount().each{ list += null }
        Thread[] threadArray = list as Thread[]
        int numThreads = Thread.enumerate(threadArray)
        println("Current threads:")
        for (i in 0..<numThreads) {
            println("    "+threadArray[i])
        }

        // Chain back to previous handler, if one exists
        if ( oldHandler != SIG_DFL && oldHandler != SIG_IGN ) {
            oldHandler.handle(sig)
        }
    }
}
// install using:
DiagSignalHandler.install(new Signal("INT"))
//----------------------------------------------------------------------------------


// @@PLEAC@@_16.18
//----------------------------------------------------------------------------------
// See 16.17, just don't chain to the previous handler because the default handler
// will abort the process.
//----------------------------------------------------------------------------------


// @@PLEAC@@_16.19
//----------------------------------------------------------------------------------
// Groovy relies on Java features here. Java doesn't keep the process around
// as it stores metadata in a Process object. You can call waitFor() or destroy()
// or exitValue() on the Process object. If the Process object is garbage collected,
// the process can still execute asynchronously with respect to the original process.

// For ensuring processes don't die, see:
// http://jakarta.apache.org/commons/daemon/
//----------------------------------------------------------------------------------


// @@PLEAC@@_16.20
//----------------------------------------------------------------------------------
// There is no equivalent to a signal mask available directly in Groovy or Java.
// You can override and ignore individual signals using recipes 16.16 - 16.18.
//----------------------------------------------------------------------------------


// @@PLEAC@@_16.21
//----------------------------------------------------------------------------------
t = new Timer()
t.runAfter(3500){
    println 'Took too long'
    System.exit(1)
}
def count = 0
6.times{
    count++
    sleep 1000
    println "Count = $count"
}
t.cancel()
// See also special JMX timer class: javax.management.timer.Timer
// For an external process you can also use: proc.waitForOrKill(3500)
//----------------------------------------------------------------------------------


// @@PLEAC@@_16.22
//----------------------------------------------------------------------------------
// One way to implement this functionality is to automatically replace the ~/.plan
// etc. files every fixed timed interval - though this wouldn't be efficient.
// Here is a simplified version which is a simplified version compared to the
// original cookbook. It only looks at the ~/.signature file and changes it
// freely. It also doesn't consider other news reader related files.

def sigs = '''
Make is like Pascal: everybody likes it, so they go in and change it.
--Dennis Ritchie
%%
I eschew embedded capital letters in names; to my prose-oriented eyes,
they are too awkward to read comfortably. They jangle like bad typography.
--Rob Pike
%%
God made the integers; all else is the work of Man.
--Kronecker
%%
I d rather have :rofix than const. --Dennis Ritchie
%%
If you want to program in C, program in C. It s a nice language.
I use it occasionally... :-) --Larry Wall
%%
Twisted cleverness is my only skill as a programmer.
--Elizabeth Zwicky
%%
Basically, avoid comments. If your code needs a comment to be understood,
it would be better to rewrite it so it s easier to understand.
--Rob Pike
%%
Comments on data are usually much more helpful than on algorithms.
--Rob Pike
%%
Programs that write programs are the happiest programs in the world.
--Andrew Hume
'''.trim().split(/\n%%\n/)
name = 'me@somewhere.org\n'
file = new File(System.getProperty('user.home') + File.separator + '.signature')
rand = new Random()
while(1) {
    file.delete()
    file << name + sigs[rand.nextInt(sigs.size())]
    sleep 10000
}

// Another way to implement this functionality (in a completely different way to the
// original cookbook) is to use a FileWatcher class, e.g.
// http://www.rgagnon.com/javadetails/java-0490.html (FileWatcher and DirWatcher)
// http://www.jconfig.org/javadoc/org/jconfig/FileWatcher.html

// These file watchers notify us whenever the file is modified, see Pleac chapter 7
// for workarounds to not being able to get last accessed time vs last modified time.
// (We would now need to touch the file whenever we accessed it to make it change).
// Our handler called from the watchdog class would update the file contents.
//----------------------------------------------------------------------------------


// @@PLEAC@@_17.0
//----------------------------------------------------------------------------------
myClient = new Socket("Machine name", portNumber)
myAddress = myClient.inetAddress
myAddress.hostAddress  // string representation of host address
myAddress.hostName     // host name
myAddress.address      // IP address as array of bytes
//----------------------------------------------------------------------------------


// @@PLEAC@@_17.1
//----------------------------------------------------------------------------------
s = new Socket("localhost", 5000);
s << "Why don't you call me anymore?\n"
s.close()
//----------------------------------------------------------------------------------


// @@PLEAC@@_17.2
//----------------------------------------------------------------------------------
// commandline socket server echoing input back to originator
groovy -l 5000 -e "println line"

// commandline socket server eching input to stderr
groovy -l 5000 -e "System.err.println line"

// a web server as a script (extension to cookbook)
 server = new ServerSocket(5000)
 while(true) {
     server.accept() { socket ->
         socket.withStreams { input, output ->
             // ignore input and just serve dummy content
             output.withWriter { writer ->
                 writer << "HTTP/1.1 200 OK\n"
                 writer << "Content-Type: text/html\n\n"
                 writer << "<html><body>Hello World! It's ${new Date()}</body></html>\n"
             }
         }
     }
 }
//----------------------------------------------------------------------------------


// @@PLEAC@@_17.3
//----------------------------------------------------------------------------------
server = new ServerSocket(5000)
while(true) {
    server.accept() { socket ->
        socket.withStreams { input, output ->
            w = new PrintWriter(output)
            w << "What is your name? "
            w.flush()
            r = input.readLine()
            System.err.println "User responded with $r"
            w.close()
        }
    }
}
//----------------------------------------------------------------------------------


// @@PLEAC@@_17.4
//----------------------------------------------------------------------------------
// UDP client
data = "Message".getBytes("ASCII")
addr = InetAddress.getByName("localhost")
port = 5000
packet = new DatagramPacket(data, data.length, addr, port)
socket = new DatagramSocket()
socket.send(packet)
//----------------------------------------------------------------------------------


// @@PLEAC@@_17.5
//----------------------------------------------------------------------------------
// UDP server
socket = new DatagramSocket(5000)
buffer = (' ' * 4096) as byte[]
while(true) {
    incoming = new DatagramPacket(buffer, buffer.length)
    socket.receive(incoming)
    s = new String(incoming.data, 0, incoming.length)
    String reply = "Client said: '$s'"
    outgoing = new DatagramPacket(reply.bytes, reply.size(),
            incoming.address, incoming.port);
    socket.send(outgoing)
}

// UDP client
data = "Original Message".getBytes("ASCII")
addr = InetAddress.getByName("localhost")
port = 5000
packet = new DatagramPacket(data, data.length, addr, port)
socket = new DatagramSocket()
socket.send(packet)
socket.setSoTimeout(30000) // block for no more than 30 seconds
buffer = (' ' * 4096) as byte[]
response = new DatagramPacket(buffer, buffer.length)
socket.receive(response)
s = new String(response.data, 0, response.length)
println "Server said: '$s'"
// => Server said: 'Client said: 'Original Message''
//----------------------------------------------------------------------------------


// @@PLEAC@@_17.6
//----------------------------------------------------------------------------------
// DOMAIN sockets not available in cross platform form.
// On Linux, use jbuds:
// http://www.graphixprose.com/jbuds/
//----------------------------------------------------------------------------------


// @@PLEAC@@_17.7
//----------------------------------------------------------------------------------
// TCP socket
socketAddress = tcpSocket.remoteSocketAddress
println "$socketAddress.address, $socketAddress.hostName, $socketAddress.port"
// UDP packet
println "$udpPacket.address, $udpPacket.port"
//----------------------------------------------------------------------------------


// @@PLEAC@@_17.8
//----------------------------------------------------------------------------------
// Print the fully qualified domain name for this IP address
println InetAddress.localHost.canonicalHostName
//----------------------------------------------------------------------------------


// @@PLEAC@@_17.9
//----------------------------------------------------------------------------------
socket.shutdownInput()
socket.shutdownOutput()
//----------------------------------------------------------------------------------


// @@PLEAC@@_17.10
//----------------------------------------------------------------------------------
// Spawn off a thread to handle each direction
//----------------------------------------------------------------------------------


// @@PLEAC@@_17.11
//----------------------------------------------------------------------------------
// Spawn off a thread to handle each request.
// This is done automatically by the Groovy accept() method on ServerSocket.
// See 17.3 for an example.
//----------------------------------------------------------------------------------


// @@PLEAC@@_17.12
//----------------------------------------------------------------------------------
// Use a thread pool
//----------------------------------------------------------------------------------


// @@PLEAC@@_17.13
//----------------------------------------------------------------------------------
// Consider using Selector and/or SocketChannel, ServerSocketChannel and DatagramChannel
//----------------------------------------------------------------------------------


// @@PLEAC@@_17.14
//----------------------------------------------------------------------------------
// When creating a socket on a multihomed machine, use the socket constructor with
// 4 params to select a specific address from those available:
socket = new Socket(remoteAddr, remotePort, localAddr, localPort)

// When creating a server on a multihomed machine supply the optional bindAddr param:
new ServerSocket(port, queueLength, bindAddr)
//----------------------------------------------------------------------------------


// @@PLEAC@@_17.15
//----------------------------------------------------------------------------------
// Fork off a thread for your server and call setDaemon(true) on the thread.
//----------------------------------------------------------------------------------


// @@PLEAC@@_17.16
//----------------------------------------------------------------------------------
// Consider using special packages designed to provide robust startup/shutdown
// capability, e.g.: http://jakarta.apache.org/commons/daemon/
//----------------------------------------------------------------------------------


// @@PLEAC@@_17.17
//----------------------------------------------------------------------------------
// Alternative to cookbook as proposed inetd solution is not cross platform.
host = 'localhost'
for (port in 1..1024) {
    try {
        s = new Socket(host, port)
        println("There is a server on port $port of $host")
    }
    catch (Exception ex) {}
}
// You could open a ServerSocket() on each unused port and monitor those.
//----------------------------------------------------------------------------------


// @@PLEAC@@_17.18
//----------------------------------------------------------------------------------
// It's not too hard to write a TCP Proxy in Groovy but numerous Java packages
// already exist, so we might as well use one of those:
// http://ws.apache.org/axis/java/user-guide.html#AppendixUsingTheAxisTCPMonitorTcpmon
//----------------------------------------------------------------------------------


// @@PLEAC@@_18.1
//----------------------------------------------------------------------------------
name = 'www.perl.com'
addresses = InetAddress.getAllByName(name)
println addresses // => {www.perl.com/208.201.239.36, www.perl.com/208.201.239.37}
// or to just resolve one:
println InetAddress.getByName(name) // => www.perl.com/208.201.239.36
// try a different address
name = 'groovy.codehaus.org'
addresses = InetAddress.getAllByName(name)
println addresses // => {groovy.codehaus.org/63.246.7.187}
// starting with IP address
address = InetAddress.getByAddress([208, 201, 239, 36] as byte[])
println address.hostName // => www.oreillynet.com

// For more complex operations use dnsjava: http://www.dnsjava.org/
import org.xbill.DNS.*
System.setProperty("sun.net.spi.nameservice.provider.1","dns,dnsjava")
Lookup lookup = new Lookup('cnn.com', Type.ANY)
records = lookup.run()
println "${records?.size()} record(s) found"
records.each{ println it }
// =>
// 17 record(s) found
// cnn.com.     55  IN  A   64.236.16.20
// cnn.com.     55  IN  A   64.236.16.52
// cnn.com.     55  IN  A   64.236.16.84
// cnn.com.     55  IN  A   64.236.16.116
// cnn.com.     55  IN  A   64.236.24.12
// cnn.com.     55  IN  A   64.236.24.20
// cnn.com.     55  IN  A   64.236.24.28
// cnn.com.     55  IN  A   64.236.29.120
// cnn.com.     324 IN  NS  twdns-02.ns.aol.com.
// cnn.com.     324 IN  NS  twdns-03.ns.aol.com.
// cnn.com.     324 IN  NS  twdns-04.ns.aol.com.
// cnn.com.     324 IN  NS  twdns-01.ns.aol.com.
// cnn.com.     3324    IN  SOA twdns-01.ns.aol.com. hostmaster.tbsnames.turner.com. 2007011203 900 300 604801 900
// cnn.com.     3324    IN  MX  10 atlmail3.turner.com.
// cnn.com.     3324    IN  MX  10 atlmail5.turner.com.
// cnn.com.     3324    IN  MX  20 nycmail2.turner.com.
// cnn.com.     3324    IN  MX  30 nycmail1.turner.com.

// faster reverse lookup using dnsjava
def reverseDns(hostIp) {
    name = ReverseMap.fromAddress(hostIp)
    rec = Record.newRecord(name, Type.PTR, DClass.IN)
    query = Message.newQuery(rec)
    response = new ExtendedResolver().send(query)
    answers = response.getSectionArray(Section.ANSWER)
    if (answers) return answers[0].rdataToString() else return hostIp
}
println '208.201.239.36 => ' + reverseDns('208.201.239.36')
// => 208.201.239.36 => www.oreillynet.com.

def hostAddrs(name) {
    addresses = Address.getAllByName(name)
    println addresses[0].canonicalHostName + ' => ' + addresses.collect{ it.hostAddress }.join(' ')
}
hostAddrs('www.ora.com')
// => www.oreillynet.com. => 208.201.239.36 208.201.239.37
hostAddrs('www.whitehouse.gov')
// => 61.9.209.153 => 61.9.209.153 61.9.209.151
//----------------------------------------------------------------------------------


// @@PLEAC@@_18.2
//----------------------------------------------------------------------------------
// commons net examples (explicit error handling not shown)
import java.text.DateFormat
import org.apache.commons.net.ftp.FTPClient
// connect
server = "localhost"                   //server = "ftp.host.com"

ftp = new FTPClient()
ftp.connect( server )
ftp.login( 'anonymous', 'guest' )     //ftp.login( 'username', 'password' )

println "Connected to $server. $ftp.replyString"

// retrieve file
ftp.changeWorkingDirectory( '.' )  //ftp.changeWorkingDirectory( 'serverFolder' )
file = new File('README.txt') //new File('localFolder' + File.separator + 'localFilename')

file.withOutputStream{ os ->
    ftp.retrieveFile( 'README.txt', os )  //ftp.retrieveFile( 'serverFilename', os )
}

// upload file
file = new File('otherFile.txt') //new File('localFolder' + File.separator + 'localFilename')
file.withInputStream{ fis -> ftp.storeFile( 'otherFile.txt', fis ) }

// List the files in the directory
files = ftp.listFiles()
println "Number of files in dir: $files.length"
df = DateFormat.getDateInstance( DateFormat.SHORT )
files.each{ file ->
    println "${df.format(file.timestamp.time)}\t $file.name"
}

// Logout from the FTP Server and disconnect
ftp.logout()
ftp.disconnect()
// =>
// Connected to localhost. 230 User logged in, proceed.
// Number of files in dir: 2
// 18/01/07  otherFile.txt
// 25/04/06  README.txt


// Using AntBuilder; for more details, see:
// http://ant.apache.org/manual/OptionalTasks/ftp.html
ant = new AntBuilder()
ant.ftp(action:'send', server:'ftp.hypothetical.india.org', port:'2121',
        remotedir:'/pub/incoming', userid:'coder', password:'java1',
        depends:'yes', binary:'no', systemTypeKey:'Windows',
        serverTimeZoneConfig:'India/Calcutta'){
    fileset(dir:'htdocs/manual'){
        include(name:'**/*.html')
    }
}
//----------------------------------------------------------------------------------


// @@PLEAC@@_18.3
//----------------------------------------------------------------------------------
// using AntBuilder; for more info, see:
// http://ant.apache.org/manual/CoreTasks/mail.html
ant = new AntBuilder()
ant.mail(mailhost:'smtp.myisp.com', mailport:'1025', subject:'Test build'){
  from(address:'config@myisp.com')
  replyto(address:'me@myisp.com')
  to(address:'all@xyz.com')
  message("The ${buildname} nightly build has completed")
  attachments(){ // ant 1.7 uses files attribute in earlier versions
    fileset(dir:'dist'){
      include(name:'**/*.zip')
    }
  }
}

// using commons net
import org.apache.commons.net.smtp.*
client = new SMTPClient()
client.connect( "mail.myserver.com", 25 )
if( !SMTPReply.isPositiveCompletion(client.replyCode) ) {
    client.disconnect()
    System.err.println("SMTP server refused connection.")
    System.exit(1)
}

// Login
client.login( "myserver.com" )

// Set the sender and recipient(s)
client.setSender( "config@myisp.com" )
client.addRecipient( "all@xyz.com" )

// Use the SimpleSMTPHeader class to build the header
writer = new PrintWriter( client.sendMessageData() )
header = new SimpleSMTPHeader( "config@myisp.com", "all@xyz.com", "My Subject")
header.addCC( "me@myisp.com" )
header.addHeaderField( "Organization", "My Company" )

// Write the header to the SMTP Server
writer.write( header.toString() )

// Write the body of the message
writer.write( "This is a test..." )

// Close the writer 
writer.close()
if ( !client.completePendingCommand() ) // failure
    System.exit( 1 )

// Logout from the e-mail server (QUIT) and close connection
client.logout()
client.disconnect()

// You can also use JavaMail; for more details, see:
// http://java.sun.com/products/javamail/

// For testing programs which send emails, consider:
// Dumbster (http://quintanasoft.com/dumbster/)
//----------------------------------------------------------------------------------


// @@PLEAC@@_18.4
//----------------------------------------------------------------------------------
// slight variation to original cookbook:
// prints 1st, 2nd and last articles from random newsgroup
import org.apache.commons.net.nntp.NNTPClient
postingPerm = ['Unknown', 'Moderated', 'Permitted', 'Prohibited']
client = new NNTPClient()
client.connect("news.example.com")
list = client.listNewsgroups()
println "Found ${list.size()} newsgroups"
aList = list[new Random().nextInt(list.size())]
println "$aList.newsgroup has $aList.articleCount articles"
println "PostingPermission = ${postingPerm[aList.postingPermission]}"
first = aList.firstArticle
println "First=$first, Last=$aList.lastArticle"
client.retrieveArticle(first)?.eachLine{ println it }
client.selectNextArticle()
client.retrieveArticle()?.eachLine{ println it }
client.retrieveArticle(aList.lastArticle)?.eachLine{ println it }
writer = client.postArticle()
// ... use writer ...
writer.close()
client.logout()
if (client.isConnected()) client.disconnect()
// =>
// Found 37025 newsgroups
// alt.comp.sys.palmtops.pilot has 730 articles
// PostingPermission = Permitted
// First=21904, Last=22633
// ...
//----------------------------------------------------------------------------------


// @@PLEAC@@_18.5
//----------------------------------------------------------------------------------
// slight variation to original cookbook to print summary of messages on server
// uses commons net
import org.apache.commons.net.pop3.POP3Client
server = 'pop.myisp.com'
username = 'gnat'
password = 'S33kr1T Pa55w0rD'
timeoutMillis = 30000

def printMessageInfo(reader, id) {
    def from, subject
    reader.eachLine{ line ->
        lower = line.toLowerCase()
        if (lower.startsWith("from: ")) from = line[6..-1].trim()
        else if (lower.startsWith("subject: ")) subject = line[9..-1].trim()
    }
    println "$id From: $from, Subject: $subject"
}

pop3 = new POP3Client()
pop3.setDefaultTimeout(timeoutMillis)
pop3.connect(server)

if (!pop3.login(username, password)) {
    System.err.println("Could not login to server.  Check password.")
    pop3.disconnect()
    System.exit(1)
}
messages = pop3.listMessages()
if (!messages) System.err.println("Could not retrieve message list.")
else if (messages.length == 0) println("No messages")
else {
    messages.each{ message ->
        reader = pop3.retrieveMessageTop(message.number, 0)
        if (!reader) {
            System.err.println("Could not retrieve message header. Skipping...")
        }
        printMessageInfo(new BufferedReader(reader), message.number)
    }
}

pop3.logout()
pop3.disconnect()

// You can also use JavaMail; for more details, see:
// http://java.sun.com/products/javamail/
//----------------------------------------------------------------------------------


// @@PLEAC@@_18.6
//----------------------------------------------------------------------------------
// Variation to original cookbook: this more extensive example
// uses telnet to extract weather information about Sydney from
// a telnet-based weather server at the University of Michigan.
import org.apache.commons.net.telnet.TelnetClient

def readUntil( pattern ) {
    sb = new StringBuffer()
    while ((ch = reader.read()) != -1) {
        sb << (char) ch
        if (sb.toString().endsWith(pattern)) {
            def found = sb.toString()
            sb = new StringBuffer()
            return found
        }
    }
    return null
}

telnet = new TelnetClient()
telnet.connect( 'rainmaker.wunderground.com', 3000 )
reader = telnet.inputStream.newReader()
writer = new PrintWriter(new OutputStreamWriter(telnet.outputStream),true)
readUntil( "Welcome" )
println 'Welcome' + readUntil( "!" )
readUntil( "continue:" )
writer.println()
readUntil( "-- " )
writer.println()
readUntil( "Selection:" )
writer.println("10")
readUntil( "Selection:" )
writer.println("3")
x = readUntil( "Return" )
while (!x.contains('SYDNEY')) {
    writer.println()
    x = readUntil( "Return" )
}
m = (x =~ /(?sm).*(SYDNEY.*?)$/)
telnet.disconnect()
println m[0][1]
// =>
// Welcome to THE WEATHER UNDERGROUND telnet service!
// SYDNEY           FAIR      10AM   81  27
//----------------------------------------------------------------------------------


// @@PLEAC@@_18.7
//----------------------------------------------------------------------------------
address = InetAddress.getByName("web.mit.edu")
timeoutMillis = 3000
println address.isReachable(timeoutMillis)
// => true (if firewalls don't get in the way, may require privileges on Linux,
//          may not use ICMP but rather Echo protocol on Windows machines)

// You can also use commons net EchoUDPClient and EchoTCPClient to interact
// with the Echo protocol - sometimes useful for ping-like functionality.
//----------------------------------------------------------------------------------


// @@PLEAC@@_18.8
//----------------------------------------------------------------------------------
import org.apache.commons.net.WhoisClient
whois = new WhoisClient()
whois.connect(WhoisClient.DEFAULT_HOST)
result = whois.query('cnn.com') // as text of complete query
println result // could extract info from result here (using e.g. regex)
whois.disconnect()
//----------------------------------------------------------------------------------


// @@PLEAC@@_18.9
//----------------------------------------------------------------------------------
// not exact equivalent to original cookbook: just shows raw functionality
client = new SMTPClient()
client.connect( "smtp.example.com", 25 )
println client.verify("george") // => true
println client.replyString // => 250 George Washington <george@wash.dc.gov>
println client.verify("jetson") // => false
println client.replyString // => 550 jetson... User unknown
client.expn("presidents")
println client.replyString
// =>
// 250-George Washington <george@wash.dc.gov>
// 250-Thomas Jefferson <tj@wash.dc.gov>
// 250-Ben Franklin <ben@here.us.edu>
// ...

// expect these commands to be disabled by most public servers due to spam
println client.replyString
// => 502 Command is locally disabled
//----------------------------------------------------------------------------------


// @@PLEAC@@_19.0
//----------------------------------------------------------------------------------
// URLs have the same form as in Perl

// Invoking dynamic content is done through the same standard urls:
// http://mox.perl.com/cgi-bin/program?name=Johann&born=1685
// http://mox.perl.com/cgi-bin/program

// Groovy has Groovelets and GSP page support built-in. For a full
// web framework, see Grails: http://grails.codehaus.org/
//----------------------------------------------------------------------------------


// @@PLEAC@@_19.1
//----------------------------------------------------------------------------------
// as a plain groovelet
param = request.getParameter('PARAM_NAME')
println """
<html><head>
<title>Howdy there!</title>
</head>
<body>
<p>
You typed: $param
</p>
</body>
</html>
"""

// as a groovelet using markup builder
import groovy.xml.MarkupBuilder
writer = new StringWriter()
builder = new MarkupBuilder(writer)
builder.html {
    head {
        title 'Howdy there!'
    }
    body {
        p('You typed: ' + request.getParameter('PARAM_NAME'))
    }
}
println writer.toString()

// as a GSP page:
<html><head>
<title>Howdy there!</title>
</head>
<body>
<p>
You typed: ${request.getParameter('PARAM_NAME')}
</p>
</body>
</html>

// Request parameters are often encoded by the browser before
// sending to the server and usually can be printed out as is.
// If you need to convert, use commons lang StringEscapeUtils#escapeHtml()
// and StringEscapeUtils#unescapeHtml().

// Getting parameters:
who = request.getParameter('Name')
phone = request.getParameter('Number')
picks = request.getParameterValues('Choices') // String array or null

// Changing headers:
response.setContentType('text/html;charset=UTF-8')
response.setContentType('text/plain')
response.setContentType('text/plain')
response.setHeader('Cache-control', 'no-cache')
response.setDateHeader('Expires', System.currentTimeMillis() + 3*24*60*60*1000)
//----------------------------------------------------------------------------------


// @@PLEAC@@_19.2
//----------------------------------------------------------------------------------
// The Java Servlet API has a special log() method for writing to the
// web server log.

// To send errors to custom HTML pages, update the web.xml deployment
// descriptor to include one or more <error-page> elements, e.g.:
<error-page>
    <error-code>404</error-code>
    <location>/404.html</location>
</error-page>
<error-page>
    <exception-type>java.lang.NullPointerException</exception-type>
    <location>/NpeError.gsp</location>
</error-page>

// Another trick is to catch an exception within the servlet/gsp code
// and print it out into the HTML as a comment.
//----------------------------------------------------------------------------------


// @@PLEAC@@_19.3
//----------------------------------------------------------------------------------
// 500 errors could occur if you have compile errors in your script.
// Pre-compile with your IDE or groovyc.

// You can use an expando, mock or map to run your scripts outside
// the web container environment. If you use Jetty as your container
// it has a special servlet tester, for more details:
// http://blogs.webtide.com/gregw/2006/12/16/1166307599250.html
//----------------------------------------------------------------------------------


// @@PLEAC@@_19.4
//----------------------------------------------------------------------------------
// Web servers should be invoked with an appropriate Java security policy in place.
// This can be used to limit possible actions from hacking attempts.

// Normal practices limit hacking exposure. The JDBC API encourages the use
// of Prepared queries rather than encouraging practices which lead to SQL
// injection. Using system or exec is rarely used either as Java provides
// cross-platform mechanisms for most operating system level functionality.

// Other security measures should be complemented with SSL and authentication.
//----------------------------------------------------------------------------------


// @@PLEAC@@_19.5
//----------------------------------------------------------------------------------
// Within the servlet element of your web.xml, there is a <load-on-startup> element.
// Use that on a per servlet basis to pre-load whichever servlets you like.
//----------------------------------------------------------------------------------


// @@PLEAC@@_19.6
//----------------------------------------------------------------------------------
// As discussed in 19.3 and 19.4:
// Web servers should be invoked with an appropriate Java security policy in place.
// This can be used to limit possible actions from hacking attempts.

// Normal practices limit hacking exposure. The JDBC API encourages the use
// of Prepared queries rather than encouraging practices which lead to SQL
// injection. Using system or exec is rarely used either as Java provides
// cross-platform mechanisms for most operating system level functionality.

// In addition, if authentication is used, security can be locked down at a
// very fine-grained level on a per servlet action or per user (with JAAS) basis.
//----------------------------------------------------------------------------------


// @@PLEAC@@_19.7
//----------------------------------------------------------------------------------
import groovy.xml.*
// using a builder:
Closure markup = {
    ol {
        ['red','blue','green'].each{ li(it) }
    }
}
println new StreamingMarkupBuilder().bind(markup).toString()
// => <ol><li>red</li><li>blue</li><li>green</li></ol>

names = 'Larry Moe Curly'.split(' ')
markup = {
    ul {
        names.each{ li(type:'disc', it) }
    }
}
println new StreamingMarkupBuilder().bind(markup).toString()
// <ul><li type="disc">Larry</li><li type="disc">Moe</li>
//     <li type="disc">Curly</li></ul>
//-----------------------------

m = { li("alpha") }
println new StreamingMarkupBuilder().bind(m).toString()
//     <li>alpha</li>

m = { ['alpha','omega'].each { li(it) } }
println new StreamingMarkupBuilder().bind(m).toString()
//     <li>alpha</li> <li>omega</li>
//-----------------------------

states = [
    "Wisconsin":  [ "Superior", "Lake Geneva", "Madison" ],
    "Colorado":   [ "Denver", "Fort Collins", "Boulder" ],
    "Texas":      [ "Plano", "Austin", "Fort Stockton" ],
    "California": [ "Sebastopol", "Santa Rosa", "Berkeley" ],
]

writer = new StringWriter()
builder = new MarkupBuilder(writer)
builder.table{
    caption('Cities I Have Known')
    tr{ th('State'); th(colspan:3, 'Cities') }
    states.keySet().sort().each{ state ->
        tr{
            th(state)
            states[state].sort().each{ td(it) }
        }
    }
}
println writer.toString()
// =>
// <table>
//   <caption>Cities I Have Known</caption>
//   <tr>
//     <th>State</th>
//     <th colspan='3'>Cities</th>
//   </tr>
//   <tr>
//     <th>California</th>
//     <td>Berkeley</td>
//     <td>Santa Rosa</td>
//     <td>Sebastopol</td>
//   </tr>
//   <tr>
//     <th>Colorado</th>
//     <td>Boulder</td>
//     <td>Denver</td>
//     <td>Fort Collins</td>
//   </tr>
//   <tr>
//     <th>Texas</th>
//     <td>Austin</td>
//     <td>Fort Stockton</td>
//     <td>Plano</td>
//   </tr>
//   <tr>
//     <th>Wisconsin</th>
//     <td>Lake Geneva</td>
//     <td>Madison</td>
//     <td>Superior</td>
//   </tr>
// </table>

import groovy.sql.Sql
import groovy.xml.MarkupBuilder

dbHandle = null
dbUrl = 'jdbc:hsqldb:...'
def getDb(){
    if (dbHandle) return dbHandle
    def source = new org.hsqldb.jdbc.jdbcDataSource()
    source.database = dbUrl
    source.user = 'sa'
    source.password = ''
    dbHandle = new Sql(source)
    return dbHandle
}

def findByLimit(limit) {
    db.rows "SELECT name,salary FROM employees where salary > $limit"
}

limit = request.getParameter('LIMIT')
writer = new StringWriter()
builder = new MarkupBuilder(writer)
builder.html {
    head { title('Salary Query') }
    h1('Search')
    form{
        p('Enter minimum salary')
        input(type:'text', name:'LIMIT')
        input(type:'submit')
    }
    if (limit) {
        h1('Results')
        table(border:1){
            findByLimit(limit).each{ row ->
                tr{ td(row.name); td(row.salary) }
            }
        }
    }
}
println writer.toString()
//----------------------------------------------------------------------------------


// @@PLEAC@@_19.8
//----------------------------------------------------------------------------------
// The preferred way to redirect to resources within the web application:
dispatcher = request.getRequestDispatcher('hello.gsp')
dispatcher.forward(request, response)
// Old versions of web containers allowed this mechanism to also redirect
// to external resources but this was deemed a potential security risk.

// The suggested way to external sites (less efficient for internal resources):
response.sendRedirect("http://www.perl.com/CPAN/")

// set cookie and forward
oreo = new Cookie('filling', 'vanilla creme')
THREE_MONTHS = 3 * 30 * 24 * 60 * 60
oreo.maxAge = THREE_MONTHS
oreo.domain = '.pleac.sourceforge.net'
whither = 'http://pleac.sourceforge.net/pleac_ruby/cgiprogramming.html'
response.addCookie(oreo)
response.sendRedirect(whither)

// forward based on user agent
dir = 'http://www.science.uva.nl/%7Emes/jargon'
agent = request.getHeader('user-agent')
menu = [
    [/Mac/, 'm/macintrash.html'],
    [/Win(dows )?NT/, 'e/evilandrude.html'],
    [/Win|MSIE|WebTV/, 'm/microslothwindows.html'],
    [/Linux/, 'l/linux.html'],
    [/HP-UX/, 'h/hpsux.html'],
    [/SunOS/, 's/scumos.html'],
]
page = 'a/aportraitofj.randomhacker.html'
menu.each{
    if (agent =~ it[0]) page = it[1]
}
response.sendRedirect("$dir/$page")

// no response output
response.sendError(204, 'No Response')
//----------------------------------------------------------------------------------


// @@PLEAC@@_19.9
//----------------------------------------------------------------------------------
// Consider TCPMON or similar: http://ws.apache.org/commons/tcpmon/
//----------------------------------------------------------------------------------


// @@PLEAC@@_19.10
//----------------------------------------------------------------------------------
// helper method
import javax.servlet.http.Cookie
import groovy.xml.MarkupBuilder

def getCookieValue(cookies, cookieName, defaultValue) {
    if (cookies) for (i in 0..<cookies.length) {
        if (cookieName == cookies[i].name) return cookies[i].value
    }
    return defaultValue
}

prefValue = getCookieValue(request.cookies, 'preference_name', 'default')
cookie = new Cookie('preference name',"whatever you'd like")
SECONDS_PER_YEAR = 60*60*24*365
cookie.maxAge = SECONDS_PER_YEAR * 2
response.addCookie(cookie)

cookname = 'fav_ice_cream'
favorite = request.getParameter('flavor')
tasty    = getCookieValue(request.cookies, cookname, 'mint')

writer = new StringWriter()
builder = new MarkupBuilder(writer)
builder.html {
    head { title('Ice Cookies') }
    body {
        h1('Hello Ice Cream')
        if (favorite) {
            p("You chose as your favorite flavor '$favorite'.")
            cookie = new Cookie(cookname, favorite)
            ONE_HOUR = 3600 // secs
            cookie.maxAge = ONE_HOUR
            response.addCookie(cookie)
        } else {
            hr()
            form {
                p('Please select a flavor: ')
                input(type:'text', name:'flavor', value:tasty)
            }
            hr()
        }
    }
}
println writer.toString()
//----------------------------------------------------------------------------------

// @@PLEAC@@_19.11
//----------------------------------------------------------------------------------
import groovy.xml.MarkupBuilder
// On Linux systems replace with: "who".execute().text
fakedWhoInput = '''
root tty1 Nov 2 17:57
hermie tty3 Nov 2 18:43
hermie tty4 Nov 1 20:01
sigmund tty2 Nov 2 18:08
'''.trim().split(/\n/)
name = request.getParameter('WHO')
if (!name) name = ''
writer = new StringWriter()
new MarkupBuilder(writer).html{
    head{ title('Query Users') }
    body{
        h1('Search')
        form{
            p('Which User?')
            input(type:'text', name:'WHO', value:name)
            input(type:'submit')
        }
        if (name) {
            h1('Results')
            lines = fakedWhoInput.grep(~/^$name\s.*/)
            if (lines) message = lines.join('\n')
            else message = "$name is not logged in"
            pre(message)
        }
    }
}
println writer.toString()
// if you need to escape special symbols, e.g. '<' or '>' use commons lang StringEscapeUtils
//----------------------------------------------------------------------------------


// @@PLEAC@@_19.12
//----------------------------------------------------------------------------------
// frameworks typically do this for you, but shown here are the manual steps
// even when doing it manually, you would probably use session variables

// setting a hidden field
input(type:'hidden', value:'bacon')

// setting a value on the submit
input(type:'submit', name:".State", value:'Checkout')

// determining 'mode'
page = request.getParameter('.State')
if (!page) page = 'Default'

// forking with if chain
if (page == "Default") {
    frontPage()
} else if (page == "Checkout") {
    checkout()
} else {
    noSuchPage()
}

// forking with map
states = [
    Default:  this.&frontPage,
    Shirt:    this.&tShirt,
    Sweater:  this.&sweater,
    Checkout: this.&checkout,
    Card:     this.&creditCard,
    Order:    this.&order,
    Cancel:   this.&frontPage,
]

// calling each to allow hidden variable saving
states.each{ key, closure ->
    closure(page == key)
}

// exemplar method
def tShirt(active) {
    def sizes = ['XL', 'L', 'M', 'S']
    def colors = ['Black', 'White']
    if (!active) {
        hidden("size")
        hidden("color")
        return
    }
    p("You want to buy a t-shirt?");
    label("Size:  ");     dropDown("size", sizes)
    label("Color: ");     dropDown("color", colors)
    shopMenu()
}

// kicking off processing
html{
    head{ title('chemiserie store') }
    body {
        if (states[page]) process(page)
        else noSuchPage()
    }
}
//----------------------------------------------------------------------------------


// @@PLEAC@@_19.13
//----------------------------------------------------------------------------------
// get request parameters as map
map = request.parameterMap

// save to file
new File(filename).withOutputStream{ fos ->
    oos = new ObjectOutputStream(fos)
    oos.writeObject(map)
    oos.close()
}

// convert to text
sb = new StringBuffer()
map.each{ k,v -> sb << "$k=$v" }
text = sb.toString()
// to send text via email, see 18.3
//----------------------------------------------------------------------------------


// @@PLEAC@@_19.14
//----------------------------------------------------------------------------------
// you wouldn't normally do it this way, consider a framework like Grails
// even when doing it by hand, you would probably use session variables
import groovy.xml.MarkupBuilder

page = param('.State', 'Default')

states = [
    Default:  this.&frontPage,
    Shirt:    this.&shirt,
    Sweater:  this.&sweater,
    Checkout: this.&checkout,
    Card:     this.&creditCard,
    Order:    this.&order,
    Cancel:   this.&frontPage,
]

writer = new StringWriter()
b = new MarkupBuilder(writer)
b.html{
    head{ title('chemiserie store') }
    body {
        if (states[page]) process(page)
        else noSuchPage()
    }
}
println writer.toString()

def process(page) {
    b.form{
        states.each{ key, closure ->
            closure(page == key)
        }
    }
}

def noSuchPage() {
    b.p('Unknown request')
    reset('Click here to start over')
}

def shopMenu() {
    b.p()
    toPage("Shirt")
    toPage("Sweater")
    toPage("Checkout")
    reset('Empty My Shopping Cart')
}

def frontPage(active) {
    if (!active) return
    b.h1('Hi!')
    b.p('Welcome to our Shirt Shop! Please make your selection from the menu below.')
    shopMenu()
}

def shirt(active) {
    def sizes = ['XL', 'L', 'M', 'S']
    def colors = ['Black', 'White']
    def count = param('shirt_count',0)
    def color = param('shirt_color')
    def size = param('shirt_size')
    // sanity check
    if (count) {
        if (!(color in colors)) color = colors[0]
        if (!(size in sizes)) size = sizes[0]
    }
    if (!active) {
        if (size) hidden("shirt_size", size)
        if (color) hidden("shirt_color", color)
        if (count) hidden("shirt_count", count)
        return
    }
    b.h1 'T-Shirt'
    b.p '''What a shirt! This baby is decked out with all the options.
        It comes with full luxury interior, cotton trim, and a collar
        to make your eyes water! Unit price: $33.00'''
    b.h2 'Options'
    label("How Many?");  textfield("shirt_count")
    label("Size?");      dropDown("shirt_size", sizes)
    label("Color?");     dropDown("shirt_color", colors)
    shopMenu()
}

def sweater(active) {
    def sizes = ['XL', 'L', 'M']
    def colors = ['Chartreuse', 'Puce', 'Lavender']
    def count = param('sweater_count',0)
    def color = param('sweater_color')
    def size = param('sweater_size')
    // sanity check
    if (count) {
        if (!(color in colors)) color = colors[0]
        if (!(size in sizes)) size = sizes[0]
    }
    if (!active) {
        if (size) hidden("sweater_size", size)
        if (color) hidden("sweater_color", color)
        if (count) hidden("sweater_count", count)
        return
    }
    b.h1("Sweater")
    b.p("Nothing implies preppy elegance more than this fine " +
        "sweater. Made by peasant workers from black market silk, " +
        "it slides onto your lean form and cries out ``Take me, " +
        "for I am a god!''. Unit price: \$49.99.")
    b.h2("Options")
    label("How Many?"); textfield("sweater_count")
    label("Size?"); dropDown("sweater_size", sizes)
    label("Color?"); dropDown("sweater_color", colors)
    shopMenu()
}

def checkout(active) {
    if (!active) return
    b.h1("Order Confirmation")
    b.p("You ordered the following:")
    orderText()
    b.p("Is this right? Select 'Card' to pay for the items" +
        "or 'Shirt' or 'Sweater' to continue shopping.")
    toPage("Card")
    toPage("Shirt")
    toPage("Sweater")
}

def creditCard(active) {
    def widgets = 'Name Address1 Address2 City Zip State Phone Card Expiry'.split(' ')
    if (!active) {
        widgets.each{ hidden(it) }
        return
    }
    b.pre{
        label("Name: ");          textfield("Name")
        label("Address: ");       textfield("Address1")
        label(" ");               textfield("Address2")
        label("City: ");          textfield("City")
        label("Zip: ");           textfield("Zip")
        label("State: ");         textfield("State")
        label("Phone: ");         textfield("Phone")
        label("Credit Card #: "); textfield("Card")
        label("Expiry: ");        textfield("Expiry")
    }
    b.p("Click on 'Order' to order the items. Click on 'Cancel' to return shopping.")
    toPage("Order")
    toPage("Cancel")
}

def order(active) {
    if (!active) return
    b.h1("Ordered!")
    b.p("You have ordered the following items:")
    orderText()
    reset('Begin Again')
}

def orderText() {
    def shirts = param('shirt_count')
    def sweaters = param('sweater_count')
    if (shirts) {
        b.p("""You have ordered ${param('shirt_count')}
            shirts of size ${param('shirt_size')}
            and color ${param("shirt_color")}.""")
    }
    if (sweaters) {
        b.p("""You have ordered ${param('sweater_count')}
        sweaters of size ${param('sweater_size')}
        and color ${param('sweater_color')}.""")
    }
    if (!sweaters && !shirts) b.p("Nothing!")
    b.p("For a total cost of ${calcPrice()}")
}

def label(text) { b.span(text) }
def reset(text) { b.a(href:request.requestURI,text) }
def toPage(name) { b.input(type:'submit', name:'.State', value:name) }
def dropDown(name, values) {
    b.select(name:name){
        values.each{
            if (param(name)==it) option(value:it, selected:true, it)
            else option(value:it, it)
        }
    }
    b.br()
}
def hidden(name) {
    if (binding.variables.containsKey(name)) v = binding[name]
    else v = ''
    hidden(name, v)
}
def hidden(name, value) { b.input(type:'hidden', name:name, value:value) }
def textfield(name) { b.input(type:'text', name:name, value:param(name,'')); b.br() }
def param(name) { request.getParameter(name) }
def param(name, defValue) {
    def val = request.getParameter(name)
    if (val) return val else return defValue
}

def calcPrice() {
    def shirts = param('shirt_count', 0).toInteger()
    def sweaters = param('sweater_count', 0).toInteger()
    return (shirts * 33 + sweaters * 49.99).toString()
}
//----------------------------------------------------------------------------------


// @@PLEAC@@_20.0
//----------------------------------------------------------------------------------
// Many packages are available for simulating a browser. A good starting point:
// http://groovy.codehaus.org/Testing+Web+Applications
//----------------------------------------------------------------------------------


// @@PLEAC@@_20.1
//----------------------------------------------------------------------------------
// for non-binary content
urlStr = 'http://groovy.codehaus.org'
content = new URL(urlStr).text
println content.size() // => 34824

// for binary content
urlStr = 'http://groovy.codehaus.org/download/attachments/1871/gina_3d.gif'
bytes = new ByteArrayOutputStream()
bytes << new URL(urlStr).openStream()
println bytes.size() // => 6066

// various forms of potential error checking
try {
    new URL('x:y:z')
} catch (MalformedURLException ex) {
    println ex.message // => unknown protocol: x
}
try {
    new URL('cnn.com/not.there')
} catch (MalformedURLException ex) {
    println ex.message // => no protocol: cnn.com/not.there
}
try {
    content = new URL('http://cnn.com/not.there').text
} catch (FileNotFoundException ex) {
    println "Couldn't find: " + ex.message
    // => Couldn't find: http://www.cnn.com/not.there
}

// titleBytes example
def titleBytes(urlStr) {
    def lineCount = 0; def byteCount = 0
    new URL(urlStr).eachLine{ line ->
        lineCount++; byteCount += line.size()
    }
    println "$urlStr => ($lineCount lines, $byteCount bytes)"
}
titleBytes('http://www.tpj.com/')
// http://www.tpj.com/ => (677 lines, 25503 bytes)
//----------------------------------------------------------------------------------


// @@PLEAC@@_20.2
//----------------------------------------------------------------------------------
// using HtmlUnit (htmlunit.sf.net)
import com.gargoylesoftware.htmlunit.WebClient

def webClient = new WebClient()
def page = webClient.getPage('http://search.cpan.org/')
// check page title
assert page.titleText.startsWith('The CPAN Search Site')
// fill in form and submit it
def form = page.getFormByName('f')
def field = form.getInputByName('query')
field.setValueAttribute('DB_File')
def button = form.getInputByValue('CPAN Search')
def result = button.click()
// check search result has at least one link ending in DB_File.pm
assert result.anchors.any{ a -> a.hrefAttribute.endsWith('DB_File.pm') }

// fields must be properly escaped
println URLEncoder.encode(/"this isn't <EASY>&<FUN>"/, 'utf-8')
// => %22this+isn%27t+%3CEASY%3E%26%3CFUN%3E%22

// proxies can be taken from environment, or specified
//System.properties.putAll( ["http.proxyHost":"proxy-host", "http.proxyPort":"proxy-port",
//    "http.proxyUserName":"user-name", "http.proxyPassword":"proxy-passwd"] )
//----------------------------------------------------------------------------------


// @@PLEAC@@_20.3
//----------------------------------------------------------------------------------
// using HtmlUnit (htmlunit.sf.net)
import com.gargoylesoftware.htmlunit.WebClient

client = new WebClient()
html = client.getPage('http://www.perl.com/CPAN/')
println page.anchors.collect{ it.hrefAttribute }.sort().unique().join('\n')
// =>
// disclaimer.html
// http://bookmarks.cpan.org/
// http://faq.perl.org/
// mailto:cpan@perl.org
// ...
//----------------------------------------------------------------------------------


// @@PLEAC@@_20.4
//----------------------------------------------------------------------------------
// split paragraphs
LS = System.properties.'line.separator'
new File(args[0]).text.split("$LS$LS").each{ para ->
    if (para.startsWith(" ")) println "<pre>\n$para\n</pre>"
    else {
        para = para.replaceAll(/(?m)^(>.*?)$/, /$1<br \/>/)            // quoted text
        para = para.replaceAll(/<URL:(.*)>/, /<a href="$1">$1<\/a>/)   // embedded URL
        para = para.replaceAll(/(http:\S+)/, /<a href="$1">$1<\/a>/)   // guessed URL
        para = para.replaceAll('\\*(\\S+)\\*', /<strong>$1<\/strong>/) // this is *bold* here
        para = para.replaceAll(/\b_(\S+)_\b/, /<em>$1<\/em>/)          // this is _italic_ here
        println "<p>\n$para\n</p>"                                     // add paragraph tags
    }
}

def encodeEmail(email) {
    println "<table>"
    email = URLEncoder.encode(email)
    email = text.replaceAll(/(\n[ \t]+)/, / . /)   // continuation lines
    email = text.replaceAll(/(?m)^(\S+?:)\s*(.*?)$/,
                  /<tr><th align="left">$1<\/th><td>$2<\/td><\/tr>/);
    println email
    println "</table>"
}
//----------------------------------------------------------------------------------


// @@PLEAC@@_20.5
//----------------------------------------------------------------------------------
// using CyberNeko Parser (people.apache.org/~andyc/neko/doc)
parser = new org.cyberneko.html.parsers.SAXParser()
parser.setFeature('http://xml.org/sax/features/namespaces', false)
page = new XmlParser(parser).parse('http://www.perl.com/CPAN/')
page.depthFirst().each{ println it.text() }
//----------------------------------------------------------------------------------


// @@PLEAC@@_20.6
//----------------------------------------------------------------------------------
// removing tags, see 20.5

// extracting tags: htitle using cyberneko and XmlSlurper
parser = new org.cyberneko.html.parsers.SAXParser()
parser.setFeature('http://xml.org/sax/features/namespaces', false)
page = new XmlParser(parser).parse('http://www.perl.com/CPAN/')
println page.HEAD.TITLE[0].text()

// extracting tags: htitle using HtmlUnit
client = new WebClient()
html = client.getPage('http://www.perl.com/CPAN/')
println html.titleText
//----------------------------------------------------------------------------------


// @@PLEAC@@_20.7
//----------------------------------------------------------------------------------
import com.gargoylesoftware.htmlunit.WebClient

client = new WebClient()
page = client.getPage('http://www.perl.com/CPAN/')
page.anchors.each{
    checkUrl(page, it.hrefAttribute)
}

def checkUrl(page, url) {
    try {
        print "$url "
        qurl = page.getFullyQualifiedUrl(url)
        client.getPage(qurl)
        println 'OK'
    } catch (Exception ex) {
        println 'BAD'
    }
}
// =>
// modules/index.html OK
// RECENT.html OK
// http://search.cpan.org/recent OK
// http://mirrors.cpan.org/ OK
// http://perldoc.perl.org/ OK
// mailto:cpan@perl.org BAD
// http://www.csc.fi/suomi/funet/verkko.html.en/ BAD
// ...
//----------------------------------------------------------------------------------


// @@PLEAC@@_20.8
//----------------------------------------------------------------------------------
import org.apache.commons.httpclient.HttpClient
import org.apache.commons.httpclient.methods.HeadMethod
import java.text.DateFormat

urls = [
    "http://www.apache.org/",
    "http://www.perl.org/",
    "http://www.python.org/",
    "http://www.ora.com/",
    "http://jakarta.apache.org/",
    "http://www.w3.org/"
]

df = DateFormat.getDateTimeInstance(DateFormat.FULL, DateFormat.MEDIUM)
client = new HttpClient()
urlInfo = [:]
urls.each{ url ->
    head = new HeadMethod(url)
    client.executeMethod(head)
    lastModified = head.getResponseHeader("last-modified")?.value
    urlInfo[df.parse(lastModified)]=url
}

urlInfo.keySet().sort().each{ key ->
    println "$key ${urlInfo[key]}"
}
// =>
// Sun Jan 07 21:48:15 EST 2007 http://www.apache.org/
// Sat Jan 13 12:44:32 EST 2007 http://jakarta.apache.org/
// Fri Jan 19 14:50:13 EST 2007 http://www.w3.org/
// Fri Jan 19 19:28:35 EST 2007 http://www.python.org/
// Sat Jan 20 09:36:08 EST 2007 http://www.ora.com/
// Sat Jan 20 13:25:53 EST 2007 http://www.perl.org/
//----------------------------------------------------------------------------------


// @@PLEAC@@_20.9
//----------------------------------------------------------------------------------
// GString version (variables must be predefined):
username = 'Tom'
count = 99
total = 999
htmlStr = """
<!-- simple.template for internal template() function -->
<HTML><HEAD><TITLE>Report for $username</TITLE></HEAD>
<BODY><H1>Report for $username</H1>
$username logged in $count times, for a total of $total minutes.
"""
println htmlStr

// SimpleTemplateEngine version:
def html = '''
<!-- simple.template for internal template() function -->
<HTML><HEAD><TITLE>Report for $username</TITLE></HEAD>
<BODY><H1>Report for $username</H1>
$username logged in $count times, for a total of $total minutes.
'''

def engine = new groovy.text.SimpleTemplateEngine()
def reader = new StringReader(html)
def template = engine.createTemplate(reader)
println template.make(username:"Peter", count:"23", total: "1234")

// SQL version
import groovy.sql.Sql
user = 'Peter'
def sql = Sql.newInstance('jdbc:mysql://localhost:3306/mydb', 'dbuser',
                      'dbpass', 'com.mysql.jdbc.Driver')
sql.query("SELECT COUNT(duration),SUM(duration) FROM logins WHERE username='$user'") { answer ->
    println (template.make(username:user, count:answer[0], total:answer[1]))
}
//----------------------------------------------------------------------------------


// @@PLEAC@@_20.10
//----------------------------------------------------------------------------------
// using built-in connection features
urlStr = 'http://jakarta.apache.org/'
url = new URL(urlStr)
connection = url.openConnection()
connection.ifModifiedSince = new Date(2007,1,18).time
connection.connect()
println connection.responseCode

// manually setting header field
connection = url.openConnection()
df = new java.text.SimpleDateFormat ("EEE, dd MMM yyyy HH:mm:ss 'GMT'")
df.setTimeZone(TimeZone.getTimeZone('GMT'))
connection.setRequestProperty("If-Modified-Since",df.format(new Date(2007,1,18)));
connection.connect()
println connection.responseCode
//----------------------------------------------------------------------------------


// @@PLEAC@@_20.11
//----------------------------------------------------------------------------------
// The website http://www.robotstxt.org/wc/active/html/ lists many available robots
// including Java ones which can be used from Groovy. In particular, j-spider
// allows you to:
// + Check your site for errors (internal server errors, ...)
// + Outgoing and/or internal link checking
// + Analyze your site structure (creating a sitemap, ...)
// + Download complete web sites
// most of its functionality is available by tweaking appropriate configuration
// files and then running it as a standalone application but you can also write
// your own java classes.
//----------------------------------------------------------------------------------


// @@PLEAC@@_20.12
//----------------------------------------------------------------------------------
// sample data, use 'LOGFILE = new File(args[0]).text' or similar
LOGFILE = '''
127.0.0.1 - - [04/Sep/2005:20:50:31 +0200] "GET /bus HTTP/1.1" 301 303
127.0.0.1 - - [04/Sep/2005:20:50:31 +0200] "GET /bus HTTP/1.1" 301 303 "-" "Opera/8.02 (X11; Linux i686; U; en)"
192.168.0.1 - - [04/Sep/2005:20:50:36 +0200] "GET /bus/libjs/layersmenu-library.js HTTP/1.1" 200 6228
192.168.0.1 - - [04/Sep/2005:20:50:36 +0200] "GET /bus/libjs/layersmenu-library.js HTTP/1.1" 200 6228 "http://localhost/bus/" "Opera/8.02 (X11; Linux i686; U; en)"
'''

// similar to perl version:
fields = ['client','identuser','authuser','date','time','tz','method','url','protocol','status','bytes']
regex = /^(\S+) (\S+) (\S+) \[([^:]+):(\d+:\d+:\d+) ([^\]]+)\] "(\S+) (.*?) (\S+)" (\S+) (\S+).*$/

LOGFILE.trim().split('\n').each{ line ->
    m = line =~ regex
    if (m.matches()) {
        for (idx in 0..<fields.size()) { println "${fields[idx]}=${m[0][idx+1]}" }
        println()
    }
}
//----------------------------------------------------------------------------------


// @@PLEAC@@_20.13
//----------------------------------------------------------------------------------
// sample data, use 'LOGFILE = new File(args[0]).text' or similar
LOGFILE = '''
204.31.113.138 - - [03/Jul/1996:06:56:12 -0800] "POST /forms/login.jsp HTTP/1.0" 200 5593
fcrawler.looksmart.com - - [26/Apr/2000:00:00:12 -0400] "GET /contacts.html HTTP/1.0" 200 4595 "-" "FAST-WebCrawler/2.1-pre2 (ashen@looksmart.net)"
fcrawler.looksmart.com - - [26/Apr/2000:00:17:19 -0400] "GET /news/news.html HTTP/1.0" 200 16716 "-" "FAST-WebCrawler/2.1-pre2 (ashen@looksmart.net)"
ppp931.on.bellglobal.com - - [26/Apr/2000:00:16:12 -0400] "GET /download/windows/asctab31.zip HTTP/1.0" 200 1540096 "http://www.htmlgoodies.com/downloads/freeware/webdevelopment/15.html" "Mozilla/4.7 [en]C-SYMPA  (Win95; U)"
123.123.123.123 - - [26/Apr/2000:00:23:48 -0400] "GET /pics/wpaper.gif HTTP/1.0" 200 6248 "http://www.jafsoft.com/asctortf/" "Mozilla/4.05 (Macintosh; I; PPC)"
123.123.123.123 - - [26/Apr/2000:00:23:47 -0400] "GET /asctortf/ HTTP/1.0" 200 8130 "http://search.netscape.com/Computers/Data_Formats/Document/Text/RTF" "Mozilla/4.05 (Macintosh; I; PPC)"
123.123.123.123 - - [26/Apr/2000:00:23:48 -0400] "GET /pics/5star2000.gif HTTP/1.0" 200 4005 "http://www.jafsoft.com/asctortf/" "Mozilla/4.05 (Macintosh; I; PPC)"
123.123.123.123 - - [27/Apr/2000:00:23:50 -0400] "GET /pics/5star.gif HTTP/1.0" 200 1031 "http://www.jafsoft.com/asctortf/" "Mozilla/4.05 (Macintosh; I; PPC)"
123.123.123.123 - - [27/Apr/2000:00:23:51 -0400] "GET /pics/a2hlogo.jpg HTTP/1.0" 200 4282 "http://www.jafsoft.com/asctortf/" "Mozilla/4.05 (Macintosh; I; PPC)"
123.123.123.123 - - [27/Apr/2000:00:23:51 -0400] "GET /cgi-bin/newcount?jafsof3&width=4&font=digital&noshow HTTP/1.0" 200 36 "http://www.jafsoft.com/asctortf/" "Mozilla/4.05 (Macintosh; I; PPC)"
127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326
127.0.0.1 - - [04/Sep/2005:20:50:31 +0200] "GET / HTTP/1.1" 200 1927
127.0.0.1 - - [04/Sep/2005:20:50:31 +0200] "GET /bus HTTP/1.1" 301 303 "-" "Opera/8.02 (X11; Linux i686; U; en)"
192.168.0.1 - - [05/Sep/2005:20:50:36 +0200] "GET /bus/libjs/layersmenu-library.js HTTP/1.1" 200 6228
192.168.0.1 - - [05/Sep/2005:20:50:36 +0200] "GET /bus/libjs/layersmenu-library.js HTTP/1.1" 200 6228 "http://localhost/bus/" "Opera/8.02 (X11; Linux i686; U; en)"
'''

fields = ['client','identuser','authuser','date','time','tz','method','url','protocol','status','bytes']
regex = /^(\S+) (\S+) (\S+) \[([^:]+):(\d+:\d+:\d+) ([^\]]+)\] "(\S+) (.*?) (\S+)" (\S+) (\S+).*$/

class Summary {
    def hosts = [:]
    def what = [:]
    def accessCount = 0
    def postCount = 0
    def homeCount = 0
    def totalBytes = 0
}
totals = [:]
LOGFILE.trim().split('\n').each{ line ->
    m = line =~ regex
    if (m.matches()) {
        date = m[0][fields.indexOf('date')+1]
        s = totals.get(date, new Summary())
        s.accessCount++
        if (m[0][fields.indexOf('method')+1] == 'POST') s.postCount++
        s.totalBytes += (m[0][fields.indexOf('bytes')+1]).toInteger()
        def url = m[0][fields.indexOf('url')+1]
        if (url == '/') s.homeCount++
        s.what[url] = s.what.get(url, 0) + 1
        def host = m[0][fields.indexOf('client')+1]
        s.hosts[host] = s.hosts.get(host, 0) + 1
    }
}
report('Date','Hosts','Accesses','Unidocs','POST','Home','Bytes')
totals.each{ key, s ->
    report(key, s.hosts.size(), s.accessCount, s.what.size(), s.postCount, s.homeCount, s.totalBytes)
}
v = totals.values()
report('Grand Total', v.sum{it.hosts.size()}, v.sum{it.accessCount}, v.sum{it.what.size()},
        v.sum{it.postCount}, v.sum{it.homeCount}, v.sum{it.totalBytes} )

def report(a, b, c, d, e, f, g) {
    printf ("%12s %6s %8s %8s %8s %8s %10s\n", [a,b,c,d,e,f,g])
}
// =>
//         Date  Hosts Accesses  Unidocs     POST     Home      Bytes
//  03/Jul/1996      1        1        1        1        0       5593
//  10/Oct/2000      1        1        1        0        0       2326
//  04/Sep/2005      1        2        2        0        1       2230
//  05/Sep/2005      1        2        1        0        0      12456
//  26/Apr/2000      3        6        6        0        0    1579790
//  27/Apr/2000      1        3        3        0        0       5349
//  Grand Total      8       15       14        1        1    1607744


// Some open source log processing packages in Java:
// http://www.generationjava.com/projects/logview/index.shtml
// http://ostermiller.org/webalizer/
// http://jxla.nvdcms.org/en/index.xml
// http://polliwog.sourceforge.net/index.html
// as well as textual reports, most of these can produce graphical reports
// Most have their own configuration information and Java extension points.
//----------------------------------------------------------------------------------


// @@PLEAC@@_20.14
//----------------------------------------------------------------------------------
 import org.cyberneko.html.filters.Writer
 import org.cyberneko.html.filters.DefaultFilter
 import org.apache.xerces.xni.parser.XMLDocumentFilter
 import org.apache.xerces.xni.*
 import org.cyberneko.html.parsers.DOMParser
 import org.xml.sax.InputSource

 input = '''
 <HTML><HEAD><TITLE>Hi!</TITLE></HEAD><BODY>
 <H1>Welcome to Scooby World!</H1>
 I have <A HREF="pictures.html">pictures</A> of the crazy dog
 himself. Here's one!<P>
 <IMG SRC="scooby.jpg" ALT="Good doggy!"><P>
 <BLINK>He's my hero!</BLINK> I would like to meet him some day,
 and get my picture taken with him.<P>
 P.S. I am deathly ill. <A HREF="shergold.html">Please send
 cards</A>.
 </BODY></HTML>
 '''

 class WordReplaceFilter extends DefaultFilter {
     private before, after
     WordReplaceFilter(b, a) { before = b; after = a }
     void characters(XMLString text, Augmentations augs) {
         char[] c = text.toString().replaceAll(before, after)
         super.characters(new XMLString(c, 0, c.size()), augs)
     }
     void setProperty(String s, Object o){}
 }
 XMLDocumentFilter[] filters = [
     new WordReplaceFilter(/(?sm)picture/, /photo/),
     new Writer()
 ]
 parser = new DOMParser()
 parser.setProperty("http://cyberneko.org/html/properties/filters", filters)
 parser.parse(new InputSource(new StringReader(input)))
//----------------------------------------------------------------------------------


// @@PLEAC@@_20.15
//----------------------------------------------------------------------------------
import org.cyberneko.html.filters.Writer
import org.cyberneko.html.filters.DefaultFilter
import org.apache.xerces.xni.parser.XMLDocumentFilter
import org.apache.xerces.xni.*
import org.cyberneko.html.parsers.DOMParser
import org.xml.sax.InputSource

input = '''
<HTML><HEAD><TITLE>Hi!</TITLE></HEAD><BODY>
<H1>Welcome to Scooby World!</H1>
I have <A HREF="pictures.html">pictures</A> of the crazy dog
himself. Here's one!<P>
<IMG SRC="scooby.jpg" ALT="Good doggy!"><P>
<BLINK>He's my hero!</BLINK> I would like to meet him some day,
and get my picture taken with him.<P>
P.S. I am deathly ill. <A HREF="shergold.html">Please send
cards</A>.
</BODY></HTML>
'''

class HrefReplaceFilter extends DefaultFilter {
    private before, after
    HrefReplaceFilter(b, a) { before = b; after = a }
    void startElement(QName element, XMLAttributes attributes, Augmentations augs) {
        def idx = attributes.getIndex('href')
        if (idx != -1) {
            def newtext = attributes.getValue(idx).replaceAll(before, after)
            attributes.setValue(idx, URLEncoder.encode(newtext))
        }
        super.startElement(element, attributes, augs)
    }
    void setProperty(String s, Object o){}
}
XMLDocumentFilter[] myfilters = [
    new HrefReplaceFilter(/shergold.html/, /cards.html/),
    new Writer()
]
parser = new DOMParser()
parser.setProperty("http://cyberneko.org/html/properties/filters", myfilters)
parser.parse(new InputSource(new StringReader(input)))
//----------------------------------------------------------------------------------

