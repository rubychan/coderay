// -*- c++ -*-

// @@PLEAC@@_NAME
// @@SKIP@@ C++/STL/Boost


// @@PLEAC@@_WEB
// @@SKIP@@ http://www.research.att.com/~bs/C++.html
// @@SKIP@@ http://www.boost.org/


// @@PLEAC@@_1.0
// In C++, one can use the builtin 'char *' type or the 'string' type
// to represent strings.  In this section, we will work with the C++
// library 'string' class.

// Characteristics of 'string' types:
// - may be of any length
// - are defined within the std namespace
// - can be converted to a 'const char *' using std::string::c_str()
// - can be subscripted to access individual characters (e.g., str[3]
//   returns the 4th character of the string
// - memory associated with strings is reclaimed automatically as strings
//   go out of scope
// - strings cannot be used as true/false values (i.e., the following is not
//   allowed:  string s; if (s) {})

//-----------------------------
// Before using strings, you must include the <string> header file
#include <string>

//-----------------------------
// To create a literal strings, you must use double quotes (").  You cannot
// use single quotes. 

//-----------------------------
// String variables must be declared -- if no value is given it's
// value is the empty string (""). 
std::string s;

//-----------------------------
// To insert special characters, quote the character with \
std::string s1 = "\\n";                     // Two characters, \ and n
std::string s2 = "Jon \"Maddog\" Orwant";   // Literal double quotes

//-----------------------------
// Strings can be declared in one of two ways
std::string s1 = "assignment syntax";
std::string s2("constructor syntax");

//-----------------------------
// Multi-line strings.
// There is no equivalent to perl's "here" documents in c++
std::string s1 = "
This is a multiline string started and finished with double 
quotes that spans 4 lines (it contains 3 newline characters).
";

std::string s2 = "This is a multiline string started and finished with double 
quotes that spans 2 lines (it contains 1 newline character).";
//-----------------------------


// @@PLEAC@@_1.1
std::string s = "some string";

//-----------------------------
std::string value1 = s.substr(offset, length);  
std::string value2 = s.substr(offset);

// Unlike perl, the substr function returns a copy of the substring
// rather than a reference to the existing substring, thus using substr
// on the left hand side of an assignment statement will not modify 
// the original string.  To get this functionality, you can use the
// std::string::replace function.

// Using offsets and lengths
s.replace(offset, length, newstring);  
s.replace(offset, s.size()-offset, newtail);

//-----------------------------
// The C++ string class doesn't have anything equivalent to perl's unpack.
// Instead, one can use C structures to import/export binary data

//-----------------------------
#include <string>
string s = "This is what you have";

std::string first  = s.substr(0, 1);          // "T"
std::string second = s.substr(5, 2);          // "is"
std::string rest   = s.substr(13);            // "you have"

// C++ strings do not support backwards indexing as perl does but 
// you can fake it out by subtracting the negative index from the
// string length
std::string last   = s.substr(s.size()-1);    // "e"
std::string end    = s.substr(s.size()-4);    // "have"
std::string piece  = s.substr(s.size()-8, 3); // "you"

//-----------------------------
#include <string>
#include <iostream>

string s("This is what you have");
std::cout << s << std::endl; 
// This is what you have

s.replace(5,2,"wasn't");                // change "is to "wasn't"
// This wasn't what you have

s.replace(s.size()-12, 12, "ondrous"); // "This wasn't wondrous"
// This wasn't wonderous

s.replace(0, 1, "");                    // delete first character
// his wasn't wondrous

s.replace(s.size()-10, 10, "");        // delete last 10 characters
// his wasn'

//-----------------------------
// C++ does not have built-in support for the perl s///, m//, and tr/// 
// operators; however, similar results can be achieved in at least 
// two ways:
// - string operations such as string::find, string::rfind, etc.
// - the boost regular expression library (regex++) supports perl
//   regular expression syntax.
// TODO:  Add examples of each.

// MISSING: if (substr($string, -10) =~ /pattern/) {
//            print "Pattern matches in last 10 characters\n";
//          }

// MISSING: substr($string, 0, 5) =~ s/is/at/g;

//-----------------------------
// exchange the first and last letters in a string using substr and replace
string a = "make a hat";

std::string first = a.substr(0,1);
std::string last  = a.substr(a.size()-1);

a.replace(0,1, last);
a.replace(a.size()-1, 1, first);

// exchange the first and last letters in a string using indexing and swap
#include <algorithm>
std::swap(a[0], a[a.size()-1]);
//-----------------------------


// @@PLEAC@@_1.2
//-----------------------------
// C++ doesn't have functionality equivalent to the || and ||=.  
// If statements and trigraphs can be used instead.
//-----------------------------
// C++ doesn't have anything equivalent "defined".  C++ variables
// cannot be used at all if they have not previously been defined.

//-----------------------------
// Use b if b is not empty, else c
a = b.size() ? b : c;  

// Set x to y unless x is not empty
if (x.is_empty()) x = y;

//-----------------------------
foo = (!bar.is_empty()) ? bar : "DEFAULT VALUE";

//-----------------------------
// NOTE: argv is declared as char *argv[] in C/C++.  We assume
// the following code surrounds the following examples that deal
// with argv.  Also, arguments to a program start at argv[1] -- argv[0]
// is the name of the executable that's running.
#include <string.h>
int main(int argc, char *argv[]) {
   char **args = argv+1; // +1 skips argv[0], the name of the executable
   // examples
}

//-----------------------------
std::string dir = (*args) ? *argv++ : "/tmp";

//-----------------------------
std::string dir = argv[1] ? argv[1] : "/tmp";

//-----------------------------
std::string dir = (argc-1) ? argv[1] : "/tmp";

//-----------------------------
#include <map>
std::map<std::string,int> count;

count[shell.size() ? shell : "/bin/sh"]++; 

//-----------------------------
// find the user name on Unix systems
// TODO:  Simplify.  This is too ugly and complex
#include <sys/types.h>
#include <unistd.h>
#include <pwd.h>
#include "boost/lexical_cast.hpp"

std::string user;
char       *msg = 0;
passwd     *pwd = 0;

if ( (msg = getenv("USER"))    ||
     (msg = getenv("LOGNAME")) ||
     (msg = getlogin())        )
  user = msg;
else if (pwd = getpwuid(getuid()))
  user = pwd->pw_name;
else
  user = "Unknown uid number " + boost::lexical_cast<std::string>(getuid());

//-----------------------------
if (starting_point.is_empty()) starting_point = "Greenwich";

//-----------------------------
// Example using list.  Other C++ STL containers work similarly.
#include <list>
list<int> a, b;
if (a.is_empty()) a = b;     // copy only if a is empty
a = (!b.is_empty()) ? b : c; // asign b if b nonempty, else c
//-----------------------------


// @@PLEAC@@_1.3
//-----------------------------
#include <algorithm>
std::swap(a, b);  

//-----------------------------
temp = a;
a    = b;
b    = temp;

//-----------------------------
std::string a("alpha");
std::string b("omega");
std::swap(a,b);

//-----------------------------
// The ability to exchange more than two variables at once is not 
// built into the C++ language or C++ standard libraries.  However, you
// can use the boost tuple library to accomplish this.
#include <boost/tuple/tuple.hpp>

boost::tie(alpha,beta,production) 
          = boost::make_tuple("January", "March", "August");
// move beta       to alpha,
// move production to beta,
// move alpha      to production
boost::tie(alpha, beta, production) 
          = boost::make_tuple(beta, production, alpha);
//-----------------------------


// @@PLEAC@@_1.4
//-----------------------------
// There are several ways to convert between characters
// and integers.  The examples assume the following declarations:
char ch;
int  num;

//-----------------------------
// Using implicit conversion
num = ch;
ch  = num;

//-----------------------------
// New-style C++ casts
ch  = static_cast<char>(num);
num = static_cast<int>(ch);

//-----------------------------
// Old-style C casts
ch  = (char)num;
num = (int)ch;

//-----------------------------
// Using the C++ stringstream class
#include <sstream>       // On some older compilers, use <strstream>
std::stringstream a;     // On some older compilers, use std::strstream

a << ch;                 // Append character to a string
a >> num;                // Output character as a number

a << num;                // Append number to a string
a >> ch;                 // Output number as a character

//-----------------------------
// Using sprintf, printf
char str[2];             // Has to be length 2 to have room for NULL character
sprintf(str, "%c", num);
printf("Number %d is character %c\n", num, num);

//-----------------------------
int  ascii_value = 'e';   // now 101
char character   = 101;   // now 'e'

//-----------------------------
printf("Number %d is character %c\n", 101, 101);

//-----------------------------
// Convert from HAL to IBM, character by character
#include <string>
#include <iostream>

std::string ibm, hal = "HAL";
for (unsigned int i=0; i<hal.size(); ++i)
    ibm += hal[i]+1;          // Add one to each ascii value
std::cout << ibm << std::endl;          // prints "IBM"

//-----------------------------
// Convert hal from HAL to IBM
#include <string>
#include <iostream>
#include <functional>         // For bind1st and plus<>
#include <algorithm>          // For transform 

std::string hal = "HAL";   
transform(hal.begin(), hal.end(), hal.begin(),
          bind1st(plus<char>(),1));
std::cout << hal << std::endl;          // prints "IBM"
//-----------------------------


// @@PLEAC@@_1.5
//-----------------------------
// Since C++ strings can be accessed one character at a time,
// there's no need to do any processing on the string to convert
// it into an array of characters.  
#include <string>
std::string s;

// Accessing characters using for loop and integer offsets
for (unsigned int i=0; i<s.size(); ++i) {
    // do something with s[i]
}

// Accessing characters using iterators
for (std::string::iterator i=s.begin(); i!=s.end(); ++i) {
    // do something with *i
}

//-----------------------------
std::string        str  = "an apple a day";
std::map<char,int> seen;

for (std::string::iterator i=str.begin(); i!=str.end(); ++i)
   seen[*i]++;

std::cout << "unique chars are: ";
for (std::map<char,int>::iterator i=seen.begin(); i!=seen.end(); ++i)
    std::cout << i->first;
std::cout << std::endl;
// unique chars are:  adelnpy

//-----------------------------
int sum = 0;
for (std::string::iterator i=str.begin(); i!=str.end(); ++i)
    sum += *i;
std::cout << "sum is " << sum << std::endl;
// prints "sum is 1248" if str was "an appla a day"


//-----------------------------
// MISSING: sysv-like checksum program

//-----------------------------
// slowcat, emulate a slow line printer
#include <sys/time.h>
#include <iostream>
#include <fstream>

int main(int argc, char *argv[]) {
  timeval delay = { 0, 50000 };   // Delay in { seconds, nanoseconds }
  char **arg = argv+1;   
  while (*arg) {                  // For each file
    std::ifstream file(*arg++);
    char c;
    while (file.get(c)) {
      std::cout.put(c);
      std::cout.flush();
      select(0, 0, 0, 0, &delay); 
    }
  }
}
//-----------------------------


// @@PLEAC@@_1.6
//-----------------------------
#include <string>
#include <algorithm>                  // For reverse
std::string s;

reverse(s.begin(), s.end());

//-----------------------------
#include <vector>                    // For std::vector
#include <sstream>                   // On older compilers, use <strstream>
#include "boost/regex.hpp"           // For boost::regex_split

std::string str;
std::vector<std::string> words;
boost::regex_split(std::back_inserter(words), str);
reverse(words.begin(), words.end()); // Reverse the order of the words

std::stringstream revwords;          // On older compilers, use strstream
copy(words.begin(), words.end(), ostream_inserter<string>(revwords," ");
std::cout << revwards.str() << std::endl;

//-----------------------------
std::string rts = str;
reverse(rts.begin(), rts.end());     // Reverses letters in rts

//-----------------------------
std::vector<string> words;                  
reverse(words.begin(), words.end()); // Reverses words in container

//-----------------------------
// Reverse word order
std::string s = "Yoda said, 'can you see this?'";

std::vector<std::string> allwords;
boost::regex_split(std::back_inserter(allwords), s);

reverse(allwords.begin(), allwords.end());
    
std::stringstream revwords;          // On older compilers, use strstream
copy(allwords.begin(), allwords.end(), ostream_inserter<string>(revwords," "));
std::cout << revwards.str() << std::endl;
// this?' see you 'can said, Yoda

//-----------------------------
std::string word  = "reviver";
bool is_palindrome = equal(word.begin(), word.end(), word.rbegin());

//-----------------------------
#include <ifstream>

std::ifstream dict("/usr/dict/words");
std::string   word;
while(getline(dict,word)) {
    if (equal(word.begin(), word.end(), word.rbegin()) &&
        word.size() > 5)
        std::cout << word << std::endl;
}
//-----------------------------


// @@PLEAC@@_1.7
//-----------------------------
#include <string>

std::string::size_type pos;
while ((pos = str.find("\t")) != std::string::npos)
    str.replace(pos, 1, string(' ',8-pos%8));
//-----------------------------


// @@PLEAC@@_1.8
//-----------------------------
// Not applicable to C++
//-----------------------------


// @@PLEAC@@_1.9
//-----------------------------
// TODO:  Fix to be more like cookbook
// TODO:  Modify/add code to do this with locales
#include <string>
#include <algorithm>

std::string phrase = "bo peep";
transform(phrase.begin(), phrase.end(), phrase.begin(), toupper);
// "BO PEEP"
transform(phrase.begin(), phrase.end(), phrase.begin(), tolower);
// "bo peep"
//-----------------------------


// @@PLEAC@@_1.10
//-----------------------------
// C++ does not provide support for perl-like in-string interpolation,
// concatenation must be used instead.

#include <string>

std::string var1, var2;
std::string answer = var1 + func() + var2;  // func returns string or char *

//-----------------------------
#include "boost/lexical_cast.hpp"

int n = 4;
std::string phrase = "I have " + boost::lexical_cast<string>(n+1) + " guanacos.";

//-----------------------------
std::cout << "I have " + boost::lexical_cast<string>(n+1) + " guanacos." << std::endl;


// @@PLEAC@@_1.11
//-----------------------------
// C++ does not have "here documents".
// TODO: Lots more.
#include <string>
#include "boost/regex.hpp"

std::string var = "
   your text
   goes here.
";

boost::regex ex("^\\s+");
var = boost::regex_merge(var, ex, "");