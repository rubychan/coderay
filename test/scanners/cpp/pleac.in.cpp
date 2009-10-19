// -*- c++ -*-

// @@PLEAC@@_NAME
// @@SKIP@@ C++/STL/Boost


// @@PLEAC@@_WEB
// @@SKIP@@ http://www.research.att.com/~bs/C++.html
// @@SKIP@@ http://www.boost.org/


// @@PLEAC@@_1.0
// NOTE: Whilst it is perfectly valid to use Standard C Library, or GNU
// C Library, routines in C++ programs, the code examples here will, as
// far as possible, avoid doing so, instead using C++-specific functionality
// and idioms. In general:
// * I/O will be iostream-based [i.e. no 'scanf', 'printf', 'fgets' etc]
// * Container / iterator idioms based on the Standard Template Library [STL]
//   will replace the built-in array / raw pointer idioms typically used in C
// * Boost Library functionality utilised wherever possible [the reason for
//   this is that much of this functionality is likely to appear in the next
//   C++ standard]
// * Error detection/handling will generally be exception-based [this is done
//   to keep examples simple. Exception use is optional in C++, and is not as
//   pervasive as it is in other languages like Java or C#]
// C-based solution(s) to problem(s) will be found in the corresponding section
// of PLEAC-C/Posix/GNU.
 
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

// @@PLEAC@@_10.0
// NOTE: Whilst it is perfectly valid to use Standard C Library, or GNU C Library, routines in
// C++ programs, the code examples here will, as far as possible, avoid doing so, instead using
// C++-specific functionality and idioms. In general:
// * I/O will be iostream-based [i.e. no 'scanf', 'printf', 'fgets' etc]
// * Container / iterator idioms based on the Standard Template Library [STL]
//   will replace the built-in array / raw pointer idioms typically used in C
// * Boost Library functionality utilised wherever possible [the reason for
//   this is that much of this functionality is likely to appear in the next
//   C++ standard]
// * Error detection/handling will generally be exception-based [this is done
//   to keep examples simple. Exception use is optional in C++, and is not as
//   pervasive as it is in other languages like Java or C#]
// C-based solution(s) to problem(s) will be found in the corresponding section of PLEAC-C/Posix/GNU.

#include <iostream>

// 'greeted' defined outside of any namespace, class or function, so is part of the
// global namespace, and will be visible throughout the entire executable. Should it
// be necessary to restrict the visibility of this global identifier to the current
// 'compilation unit' [i.e. current source file] then the following may be used:
//
//     namespace { int greeted = 0; }
//
// The effect is similar to using the 'static' keyword, in this same context, in the C
// language.

int greeted = 0;

int howManyGreetings();
void hello();

// ----

int main()
{
  hello();

  int greetings = howManyGreetings();

  std::cout << "bye there!, there have been "
            << greetings
            << " greetings so far"
            << std::endl;
}

// ----

int howManyGreetings()
{
  // Access 'greeted' identifier in the global namespace using the scope resolution
  // operator. Use of this operator is only necessary if a similarly-named identifier
  // exists in a 
  return ::greeted;
}

void hello()
{
  // Here 'greeted' is accessed without additional qualification. Since a 'greeted' identifier
  // exists only in the global namespace, it is that identifier that is used
  std::cout << "high there!, this function has been called "
            << ++greeted
            << " times"
            << std::endl;
}

// @@PLEAC@@_10.1
// Standard C++ requires that a function be prototyped, hence the name and type of parameters
// must be specified, and the argumemt list in any calls to that function must match the
// parameter list, as shown here 

#include <cmath>

double hypotenuse(double side1, double side2);

// ----

int main()
{
  double diag = hypotenuse(3.0, 4.0);
}

// ----

double hypotenuse(double side1, double side2)
{
  return std::sqrt(std::pow(side1, 2.0) + std::pow(side2, 2.0));
}

// ----------------------------

// Variable length argument list functions, via the C Language derived 'va_...' macros,
// are also supported. However use of this facility is particularly discouraged in C++
// because:
// * It is an inherently type-unsafe facility; type safety is a core C++ concern
// * Other facilities, such as overloaded functions, and default arguments [neither of which
//   are available in C] can sometimes obviate the need for variable length argument lists
// * OOP techniques can also lessen the need for variable length argument lists. The most
//   obvious example here is the Iostream library where repeated calls of I/O operators replace
//   the format string / variable arguments of 'printf'

#include <cmath>
#include <cstdarg>

double hypotenuse(double side1, ...);

// ----

int main()
{
  double diag = hypotenuse(3.0, 4.0);
}

// ----

double hypotenuse(double side1, ...)
{
  // More details available in the corresponding section of PLEAC-C/Posix/GNU
  va_list ap;
  va_start(ap, side1);
  double side2 = va_arg(ap, double);
  va_end(ap);

  return std::sqrt(std::pow(side1, 2.0) + std::pow(side2, 2.0));
}

// ----------------------------

// An example using default arguments appears below

#include <cmath>

// Specify default argument values in declaration
// Note: This may be done in either of the declaration or the definition [not both], but it
// makes more sense to do so in the declaration since these are usually placed in header files
// which may be included in several source files. The default argument values would need to be
// known in all those locations
double hypotenuse(double side1 = 3.0, double side2 = 4.0);

// ----

int main()
{
  // All arguments specified
  double diag = hypotenuse(3.0, 4.0);

  // Both calls utilise default argument value(s)
  diag = hypotenuse(3.0);

  diag = hypotenuse();
}

// ----

double hypotenuse(double side1, double side2)
{
  return std::sqrt(std::pow(side1, 2.0) + std::pow(side2, 2.0));
}

// ----------------------------

// A [very contrived, not very practical] example using function overloading appears below

#include <cmath>

double hypotenuse(double side1, double side2);
double hypotenuse(double side1);
double hypotenuse();

// ----

int main()
{
  // Call version (1)
  double diag = hypotenuse(3.0, 4.0);

  // Call version (2)
  diag = hypotenuse(3.0);

  // Call version (3)
  diag = hypotenuse();
}

// ----

// (1)
double hypotenuse(double side1, double side2)
{
  return std::sqrt(std::pow(side1, 2.0) + std::pow(side2, 2.0));
}

// (2)
double hypotenuse(double side1)
{
  return std::sqrt(std::pow(side1, 2.0) + std::pow(4.0, 2.0));
}

// (3)
double hypotenuse()
{
  return std::sqrt(std::pow(3.0, 2.0) + std::pow(4.0, 2.0));
}

// ----------------------------

#include <cstddef>
#include <vector>

std::vector<int> int_all(const double arr[], size_t arrsize);
std::vector<int> int_all(const std::vector<double>& arr);

// ----

int main()
{
  // Load vectors from built-in arrays, or use Boost 'assign' library
  const double nums[] = {1.4, 3.5, 6.7};
  const size_t arrsize = sizeof(nums) / sizeof(nums[0]);

  // Conversion effected at vector creation time
  std::vector<int> ints = int_all(nums, arrsize);

  // Vector -> vector copy / conversion 
  ints = int_all(std::vector<double>(nums, nums + arrsize));
}

// ----

std::vector<int> int_all(const double arr[], size_t arrsize)
{
  return std::vector<int>(arr, arr + arrsize);
}

std::vector<int> int_all(const std::vector<double>& arr)
{
  std::vector<int> r;
  r.assign(arr.begin(), arr.end());  // Type safe element copying 
  return r;
}

// ----------------------------

#include <algorithm>
#include <vector>

#include <cmath>
#include <cstddef>

void trunc_em(std::vector<double>& arr);

// ----

int main()
{
  // Load vectors from built-in arrays, or use Boost 'assign' library
  const double nums[] = {1.4, 3.5, 6.7};
  const size_t arrsize = sizeof(nums) / sizeof(nums[0]);

  std::vector<double> numsv(nums, nums + arrsize);

  trunc_em(numsv);
}

// ----

void trunc_em(std::vector<double>& arr)
{
  // Replace each element with the value returned by applying 'floor' to that element
  std::transform(arr.begin(), arr.end(), arr.begin(), floor);
}

// @@PLEAC@@_10.2
// Variables declared within a function body are local to that function, and those declared
// outside a function body [and not as part of a class / struct definition, or enclosed within
// a namespace] are global, that is, are visible throughout the executable unless their
// visibility has been restricted to the source file in which they are defined via enclosing
// them within an anonymous namespace [which has the same effect as using the 'static' keyword,
// in this same context, in the C language]

#include <vector>

void somefunc()
{
  // All these variables are local to this function
  int variable, another;

  std::vector<int> vec(5);

  ; // ...
}

// ----------------------------

// A couple of generic, type-safe type conversion helpers. The Boost Library sports a conversion
// library at: http://www.boost.org/libs/conversion/index.html

#include <sstream>
#include <string>

class bad_conversion {};

template<typename T> T fromString(const std::string& s)
{
  std::istringstream iss(s);
  T t; iss >> t;
  if (!iss) throw bad_conversion();
  return t;
}

template<typename T> std::string toString(const T& t)
{
  std::ostringstream oss;
  oss << t << std::ends;
  if (!oss) throw bad_conversion();
  return std::string(oss.str());
}

// ------------

#include <string>

// File scope variables
namespace 
{
  std::string name;
  int age, c, condition;
}

void run_check();
void check_x(int x);

// ----

// An alternative, C++-specific approach, to command-line handling and type conversion
// may be seen at: http://www.boost.org/libs/conversion/lexical_cast.htm

int main(int argc, char* argv[])
{
  name.assign(argv[1]);

  try
  {  
    age = fromString<int>(argv[2]);
  }

  catch (const bad_conversion& e)
  {
    ; // ... handle conversion error ...
  }

  check_x(age);
}

// ------------

void run_check()
{
  // Full access to file scope variables
  condition = 1;
  // ...
}

void check_x(int x)
{
  // Full access to file scope variables
  std::string y("whatever");

  run_check();

  // 'condition' updated by 'run_check'
  if (condition)
  {
    ; // ...
  }
}

// @@PLEAC@@_10.3
// Standard C++, owing to its C heritage, allows the creation of 'persistent private variables',
// via use of the 'static' keyword. For more details about this, and illustrative code examples,
// refer to this same section in PLEAC-C/Posix/GNU. Standard C++-specific methods of perfoming
// this task involve use of the 'namespace' facility, or creating a class containing 'static'
// members and using access specifiers to restrict access

// This example replaces the 'static' keyword with use of an anonymous namespace to force
// 'variable' to have file scope, and be visible only within the 'mysubs.cpp file. It is
// therefore both persistant [because it is a global variable] and private [because it is
// visible only to functions defined within the same source file]

// File: 'mysubs.h'
void mysub(void);
void reset(void);

// ----

// File: 'mysubs.cpp'
namespace
{
  int variable = 1;
}

void mysub(void)
{
  ; // ... do something with 'variable' ...
}
 
void reset(void) { variable = 1; }

// ----

// File: 'test.cpp'
#include "mysubs.h"

int main()
{
  // 'variable' is not accessable here

  // Call 'mysub', which can access 'variable'
  mysub();

  // Call 'reset' which sets 'variable' to 1  
  reset();
}

// ------------

// This example is similar to the previous one in using an anonymous namespace to restrict
// variable visibility. It goes further, hoewever, grouping logically related items within
// a named namespace, thus ensuring access to those items is controlled [i.e. requires
// qualification, or a 'using' declaration or directive]

// File: 'counter.h'
namespace cnt
{
  int increment();
  int decrement();
}

// ----

// File: 'counter.cpp'
namespace cnt
{
  // Ensures 'counter' is visible only within the current source file
  namespace { int counter = 0; }

  void reset(int v = 0) { counter = v; }

  int increment() { return ++counter; }
  int decrement() { return --counter; }
}

// ----

// File: 'test.cpp'
#include <iostream>
#include "counter.h"

int main()
{
  // Following line is illegal because 'cnt::counter' is private to the 'counter.cpp' file
  // int c = cnt::counter;
  
  int a = cnt::increment();
  std::cout << a << std::endl;

  a = cnt::decrement();
  std::cout << a << std::endl;
}

// ------------

// This example sees a class containing 'static' members and using access specifiers to
// restrict access to those members. Since all the members are static, this class is not
// meant to be instantiated [i.e. objects created from it - it can be done, but they would
// all be the exact same object :)], but merely uses the 'class' facility to encapsulate
// [i.e. group together] and allow selective access [i.e. hide some parts, allow access to
// others]. For Design Pattern afficiandos, this is a crude example of the Singleton Pattern

// File: 'counter.h'
class Counter
{
public:
  static int increment();
  static int decrement();
private:
  static int counter;
};

// ----

// File: 'counter.cpp'
#include "counter.h"

int Counter::increment() { return ++counter; }
int Counter::decrement() { return --counter; }

int Counter::counter = 0;

// ----

// File: 'test.cpp'
#include <iostream>
#include "counter.h"

int main()
{
  int a = Counter::increment();
  std::cout << a << std::endl;

  a = Counter::decrement();
  std::cout << a << std::endl;
}

// @@PLEAC@@_10.4
// Standard C++ offers no facility for performing adhoc, runtime stack inspection; therefore,
// information such as the currently-executing function name, cannot be obtained. Now, this
// isn't to say that such facilities don't exist [since, after all, a symbolic debugger works
// by doing just this - stack inspection, among other things], but that such features are, for
// native code compiled languages like C++, 'extra-language' and development tool-specific

// @@PLEAC@@_10.5
// Standard C++ supports both
// * 'pass-by-value': a copy of an argument is passed when calling a function; in this way
//   the original is safe from modification, but a copying overhead is incurred which may
//   adversely affect performance
// * 'pass-by-reference': the address of an argument is passed when calling a function;
//   allows the original to be modified, and incurrs no performance penalty from copying
//
// The 'pass-by-value' mechanism works in the same way as in the Standard C language [see
// corresponding section in PLEAC-C/Posix/GNU]. The 'pass-by-reference' mechanism provides
// the same functionality as passing a pointer-to-a-pointer-to-an-argument, but without the
// complications arising from having to correctly dereference. Using a reference to a non-const
// item allows:
// * The item's state to be modified i.e. if an object was passed, it can be mutated [effect
//   can be mimiced by passing a pointer to the item]
// * The item, itself, can be replaced with a new item i.e. the memory location to which the
//   reference refers is updated [effect can be mimiced by passing a pointer-to-a-pointer to
//   the item]

#include <cstddef>
#include <vector>

// 'pass-by-value': a copy of each vector is passed as an argument
// void array_diff(const std::vector<int> arr1, const std::vector<int> arr2);

// 'pass-by-reference': the address of each vector is passed as an argument. Some variants:
// * Disallow both vector replacement and alteration of its contents
//     void array_diff(const std::vector<const int>& arr1, const std::vector<const int>& arr2);
// * Disallow vector replacement only
//     void array_diff(const std::vector<int>& arr1, const std::vector<int>& arr2);
// * Disallow alteration of vector contents only
//     void array_diff(std::vector<const int>& arr1, std::vector<const int>& arr2);
// * Allow replacement / alteration
//     void array_diff(std::vector<int>& arr1, std::vector<int>& arr2);

void array_diff(const std::vector<int>& arr1, const std::vector<int>& arr2);

// ----

int main()
{
  // Load vectors from built-in arrays, or use Boost 'assign' library
  const int arr1[] = {1, 2, 3}, arr2[] = {4, 5, 6};
  const size_t arrsize = 3;

  // Function call is the same whether 'array_diff' is declared to be 'pass-by-value'
  // or 'pass-by-reference'
  array_diff(std::vector<int>(arr1, arr1 + arrsize), std::vector<int>(arr2, arr2 + arrsize));
}

// ----

// void array_diff(const std::vector<int> arr1, const std::vector<int> arr2)
// {
//  ; // 'arr1' and 'arr2' are copies of the originals
// }

void array_diff(const std::vector<int>& arr1, const std::vector<int>& arr2)
{
  ; // 'arr1' and 'arr2' are references to the originals
}

// ----------------------------

#include <cstddef>

#include <algorithm>
#include <functional>
#include <vector>

std::vector<int> add_vecpair(const std::vector<int>& arr1, const std::vector<int>& arr2);

// ----

int main()
{
  // Load vectors from built-in arrays, or use Boost 'assign' library
  const int aa[] = {1, 2}, ba[] = {5, 8};
  size_t arrsize = 2;

  const std::vector<int> a(aa, aa + arrsize), b(ba, ba + arrsize);  

  std::vector<int> c = add_vecpair(a, b);
}

// ----

std::vector<int> add_vecpair(const std::vector<int>& arr1, const std::vector<int>& arr2)
{
  std::vector<int> retvec; retvec.reserve(arr1.size());
  std::transform(arr1.begin(), arr1.end(), arr2.begin(), back_inserter(retvec), std::plus<int>());
  return retvec;
}

// @@PLEAC@@_10.6
// Please refer to the corresponding section in PLEAC-C/Posix/GNU since the points raised there
// apply to C++ also. Examples here don't so much illustrate C++'s handling of 'return context'
// as much as how disparate types might be handled in a reasonably uniform manner

// Here, 'mysub' is implemented as a function template, and its return type varies with the
// argument type. In most cases the compiler is able to infer the return type from the 
// argument, however, it is possible to pass the type as a template parameter. Note this
// code operates at compile-time, as does any template-only code

#include <cstddef>

#include <string>
#include <vector>

template <typename T> T mysub(const T& t) { return t; }

// ----

int main()
{
  // 1. Type information inferred by compiler
  int i = mysub(5);

  double d = mysub(7.6);

  const int arr[] = {1, 2, 3};
  const size_t arrsize = sizeof(arr) / sizeof(arr[0]);

  std::vector<int> v = mysub(std::vector<int>(arr, arr + arrsize));

  // 2. Type information provided by user
  // Pass a 'const char*' argument and specify type information in the call
  std::string s = mysub<std::string>("xyz");

  // Could avoid specifying type information by passing a 'std::string' argument  
  // std::string s = mysub(std::string("xyz"));
}

// ----------------------------

// This is a variant on the previous example that uses the Boost Library's 'any' type as a
// generic 'stub' type

#include <string>
#include <vector>

#include <boost/any.hpp>

template <typename T> boost::any mysub(const T& t) { return boost::any(t); }

// ----

int main()
{
  std::vector<boost::any> any;

  // Add various types [encapsulated in 'any' objects] to the container
  any.push_back(mysub(5));
  any.push_back(mysub(7.6));
  any.push_back(mysub(std::vector<int>(5, 5)));
  any.push_back(mysub(std::string("xyz")));

  // Extract the various types from the container by appropriately casting the relevant
  // 'any' object
  int i = boost::any_cast<int>(any[0]);
  double d = boost::any_cast<double>(any[1]);
  std::vector<int> v = boost::any_cast< std::vector<int> >(any[2]);
  std::string s = boost::any_cast<std::string>(any[3]);
}

// @@PLEAC@@_10.7
// Just like the C language, C++ offers no support for named / keyword parameters. It is of
// course possible to mimic such functionality the same way it is done in C [see corresponding
// section in PLEAC-C/Posix/GNU], the most obvious means being by passing a set of key/value
// pairs in a std::map. This will not be shown here. Instead, two quite C++-specific examples
// will be provided, based on:
//
// * Named Parameter Idiom [see: http://www.parashift.com/c++-faq-lite/ctors.html#faq-10.18]
// * Boost 'parameter' Library [see: http://www.boost.org/libs/parameter/doc/html/index.html]

#include <iostream>
#include <map>

class TimeEntry
{
public:
  explicit TimeEntry(int value = 0, char dim = 's');

  bool operator<(const TimeEntry& right) const;

  friend std::ostream& operator<<(std::ostream& out, const TimeEntry& t);

private:
  int value_;
  char dim_;
};

typedef std::pair<const int, TimeEntry> TENTRY;
typedef std::map<const int, TimeEntry> TIMETBL;

class RaceTime
{
public:
  const static int START_TIME, FINISH_TIME, INCR_TIME;

public:
  explicit RaceTime();

  RaceTime& start_time(const TimeEntry& time);
  RaceTime& finish_time(const TimeEntry& time);
  RaceTime& incr_time(const TimeEntry& time);

  friend std::ostream& operator<<(std::ostream& out, const RaceTime& r);

private:
  TIMETBL timetbl_;
};

const int RaceTime::START_TIME = 0, RaceTime::FINISH_TIME = 1, RaceTime::INCR_TIME = 2;

void the_func(const RaceTime& r);

// ----

int main()
{
  the_func(RaceTime().start_time(TimeEntry(20, 's')).finish_time(TimeEntry(5, 'm')).incr_time(TimeEntry(5, 's')));

  the_func(RaceTime().start_time(TimeEntry(5, 'm')).finish_time(TimeEntry(30, 'm')));

  the_func(RaceTime().start_time(TimeEntry(30, 'm')));
}

// ----

std::ostream& operator<<(std::ostream& out, const TimeEntry& t)
{
  out << t.value_ << t.dim_; return out;
}

std::ostream& operator<<(std::ostream& out, const RaceTime& r)
{
  RaceTime& r_ = const_cast<RaceTime&>(r);

  out << "start_time:  " << r_.timetbl_[RaceTime::START_TIME]
      << "\nfinish_time: " << r_.timetbl_[RaceTime::FINISH_TIME]
      << "\nincr_time:   " << r_.timetbl_[RaceTime::INCR_TIME];

  return out;
}

TimeEntry::TimeEntry(int value, char dim) : value_(value), dim_(dim) {}

bool TimeEntry::operator<(const TimeEntry& right) const
{
  return (dim_ == right.dim_) ? (value_ < right.value_) : !(dim_ < right.dim_);
}

RaceTime::RaceTime()
{
  timetbl_.insert(TENTRY(START_TIME, TimeEntry(0, 's')));
  timetbl_.insert(TENTRY(FINISH_TIME, TimeEntry(0, 's')));
  timetbl_.insert(TENTRY(INCR_TIME, TimeEntry(0, 's')));
}

RaceTime& RaceTime::start_time(const TimeEntry& time)
{
  timetbl_[START_TIME] = time; return *this;
}

RaceTime& RaceTime::finish_time(const TimeEntry& time)
{
  timetbl_[FINISH_TIME] = time; return *this;
}

RaceTime& RaceTime::incr_time(const TimeEntry& time)
{
  timetbl_[INCR_TIME] = time; return *this;
}

void the_func(const RaceTime& r)
{
  std::cout << r << std::endl;
}

// ----------------------------

// The Boost 'parameter' library requires a significant amount of setup code to be written,
// much more than this section warrants. My recommendation is to read carefully through the
// tutorial to determine whether a problem for which it is being considered justifies all
// the setup.

// @@PLEAC@@_10.8
// The Boost 'tuple' Library also allows multiple assignment to variables, including the
// selective skipping of return values

#include <iostream>

#include <boost/tuple/tuple.hpp>

typedef boost::tuple<int, int, int> T3;

T3 func();

// ----

int main()
{
  int a = 6, b = 7, c = 8;
  std::cout << a << ',' << b << ',' << c << std::endl;

  // A tuple of references to the referred variables is created; the values
  // captured from the returned tuple are thus multiply-assigned to them
  boost::tie(a, b, c) = func();
  std::cout << a << ',' << b << ',' << c << std::endl;

  // Variables can still be individually referenced
  a = 11; b = 23; c = 56; 
  std::cout << a << ',' << b << ',' << c << std::endl;

  // Return values may be ignored; affected variables retain existing values
  boost::tie(a, boost::tuples::ignore, c) = func();
  std::cout << a << ',' << b << ',' << c << std::endl;
}

// ----

T3 func() { return T3(3, 6, 9); }

// @@PLEAC@@_10.9
// Like Standard C, C++ allows only the return of a single value. The return of multiple values
// *can*, however, be simulated by packaging them within an aggregate type [as in C], or a
// custom class, or one of the STL containers like std::vector. Probably the most robust, and
// [pseudo]-standardised, approach is to use the Boost 'tuple' Library, as will be done in this
// section. Notes:
// * Use made of Boost 'assign' Library to simplify container loading; this is a *very* handy
//   library
// * Use made of Boost 'any' Library to make containers heterogenous; 'variant' Library is
//   similar, and is more appropriate where type-safe container traversal is envisaged e.g.
//   for printing  

#include <string>
#include <vector>
#include <map>

#include <boost/any.hpp>
#include <boost/tuple/tuple.hpp>

#include <boost/assign/std/vector.hpp>
#include <boost/assign/list_inserter.hpp>

typedef std::vector<boost::any> ARRAY;
typedef std::map<std::string, boost::any> HASH;
typedef boost::tuple<ARRAY, HASH> ARRAY_HASH;

ARRAY_HASH some_func(const ARRAY& array, const HASH& hash);

// ----

int main()
{
  // Load containers using Boost 'assign' Library 
  using namespace boost::assign;
  ARRAY array; array += 1, 2, 3, 4, 5;
  HASH hash; insert(hash) ("k1", 1) ("k2", 2) ("k3", 3);

  // Pass arguments to 'somefunc' and retrieve them as members of a tuple
  ARRAY_HASH refs = some_func(array, hash);

  // Retrieve copy of 'array' from tuple
  ARRAY ret_array = boost::get<0>(refs);

  // Retrieve copy of 'hash' from tuple
  HASH ret_hash = boost::get<1>(refs);
}

// ----

ARRAY_HASH some_func(const ARRAY& array, const HASH& hash)
{
  ; // ... do something with 'array' and 'hash'

  return ARRAY_HASH(array, hash);
}

// @@PLEAC@@_10.10
// Like function calls in Standard C, function calls in C++ need to conform to signature
// requirements; a function call must match its declaration with the same number, and type,
// of arguments passed [includes implicitly-passed default arguments], and the same return
// value type. Thus, unlike Perl, a function declared to return a value *must* do so, thus
// cannot 'return nothing' to indicate failure. 
// Whilst in Standard C certain conventions like returning NULL pointers, or returning -1, to
// indicate the 'failure' of a task [i.e. function return codes are checked, and control
// proceeds conditionally] are used, Standard C++ sports facilities which lessen the need for
// dong the same. Specifically, C++ offers:
// * Built-in exception handling which can be used to detect [and perhaps recover from],
//   all manner of unusual, or erroneous / problematic situations. One recommended use is
//   to avoid writing code that performs a lot of return code checking
// * Native OOP support allows use of the Null Object Design Pattern. Put simply, rather than
//   than checking return codes then deciding on an action, an object with some predefined
//   default behaviour is returned / used where an unusual / erroneous / problematic situation
//   is encountered. This approach could be as simple as having some sort of default base
//   class member function behaviour, or as complex as having a diagnostic-laden object created
// * Functions can still return 'error-indicating entities', but rather than primitive types
//   like 'int's or NULL pointers, complex objects can be returned. For example, the Boost
//   Library sports a number of such types:
//   - 'tuple'
//   - 'any', 'variant' and 'optional'
//   - 'tribool' [true, false, indeterminate]

// Exception Handling Example

class XYZ_exception {};

int func();

// ----

int main()
{
  int valid_value = 0;

  try
  {
    ; // ...

    valid_value = func();

    ; // ...
  }

  catch(const XYZ_exception& e)
  {
    ; // ...
  }
}

// ----

int func()
{
  bool error_detected = false;
  int valid_value;

  ; // ...

  if (error_detected) throw XYZ_exception();

  ; // ...
  
  return valid_value;
}

// ------------

// Null Object Design Pattern Example

#include <iostream>

class Value
{
public:
  virtual void do_something() = 0;
};

class NullValue : public Value
{
public:
  virtual void do_something();
};

class ValidValue : public Value
{
public:
  virtual void do_something();
};

Value* func();

// ----

int main()
{
  // Error checking is performed within 'func'. However, regardless of the outcome, an
  // object of 'Value' type is returned which possesses similar behaviour, though appropriate
  // to whether processing was successful or not. In this way no error checking is needed
  // outside of 'func'
  Value* v = func();

  v->do_something();

  delete v;
}

// ----

void NullValue::do_something()
{
  std::cout << "*null*" << std::endl;
}

void ValidValue::do_something()
{
  std::cout << "valid" << std::endl;
}

Value* func()
{
  bool error_detected = true;

  ; // ...

  if (error_detected) return new NullValue;

  ; // ...
  
  return new ValidValue;
}

// ----------------------------

// The Boost 'optional' library has many uses, but in the current context, one is of particular
// use: returning a specified type [thus satisfying language requirements], but whose value
// may be 'set' [if the function succeeded] or 'unset' [if it failed], and this condition very
// easily checked

#include <iostream>

#include <cstdlib>

#include <string>
#include <vector>
#include <map>

#include <boost/optional/optional.hpp>

class func_fail
{
public:
  explicit func_fail(const std::string& msg) : msg_(msg) {}
  const std::string& msg() const { return msg_; } 
private:
  const std::string msg_;
};

// ----

void die(const std::string& msg);

boost::optional<int> sfunc();
boost::optional< std::vector<int> > afunc();
boost::optional< std::map<std::string, int> > hfunc();

// ------------

int main()
{
  try
  {
    boost::optional<int> s;
    boost::optional< std::vector<int> > a;
    boost::optional< std::map<std::string, int> > h;

    if (!(s = sfunc())) throw func_fail("'sfunc' failed");
    if (!(a = afunc())) throw func_fail("'afunc' failed");
    if (!(h = hfunc())) throw func_fail("'hfunc' failed");

    ; // ... do stuff with 's', 'a', and 'h' ...
    int scalar = *s;

    ; // ...
  }

  catch (const func_fail& e)
  {
    die(e.msg());   
  }

  ; // ... other code executed if no error above ...
}

// ------------

void die(const std::string& msg)
{
  std::cerr << msg << std::endl;

  // Should only be used if all objects in the originating local scope have been destroyed
  std::exit(EXIT_FAILURE);
}

// ----

boost::optional<int> sfunc()
{
  bool error_detected = true;

  int valid_int_value;

  ; // ...

  if (error_detected) return boost::optional<int>();

  ; // ...
  
  return boost::optional<int>(valid_int_value);
}

boost::optional< std::vector<int> > afunc()
{
  // ... code not shown ...
 
  return boost::optional< std::vector<int> >();

  // ... code not shown
}

boost::optional< std::map<std::string, int> > hfunc()
{
  // ... code not shown ...

  return boost::optional< std::map<std::string, int> >();

  // ... code not shown ...
}

// @@PLEAC@@_10.11
// Whilst in Perl function prototyping is optional, this is not the case in C++, where it is
// necessary to:
// * Declare a function before use; this could either be a function declaration separate from
//   the function definition, or the function definition itself which serves as its own
//   declaration
// * Specify both parameter positional and type information; parameter names are optional in
//   declarations, mandatory in definitions
// * Specify return type

#include <iostream>
#include <vector>

// Function Declaration
std::vector<int> myfunc(int arg1, int arg2); // Also possible: std::vector<int> myfunc(int, int);

// ----

int main()
{
  // Call function with all required arguments; this is the only calling method
  // [except for calling via function pointer which still needs all arguments supplied]
  std::vector<int> results = myfunc(3, 5);

  // Let's look at our return array's contents
  std::cout << results[0] << ':' << results[1] << std::endl;
}

// ----

// Function Definition
std::vector<int> myfunc(int arg1, int arg2)
{
  std::vector<int> r;

  std::back_inserter(r) = arg1;
  std::back_inserter(r) = arg2;

  return r;
}

// ------------

// A version on the above code that is generic, that is, making use of the C++ template
// mechanism to work with any type

#include <iostream>
#include <vector>

// Function Declaration
template <class T> std::vector<T> myfunc(const T& arg1, const T& arg2);

// ----

int main()
{
  std::vector<int> results = myfunc(3, 5);

  std::cout << results[0] << ':' << results[1] << std::endl;
}

// ----

// Function Definition
template <class T> std::vector<T> myfunc(const T& arg1, const T& arg2)
{
  std::vector<T> r;

  std::back_inserter(r) = arg1;
  std::back_inserter(r) = arg2;

  return r;
}

// ------------

// Other Perl examples are omitted since there is no variation in C++ function calling or
// parameter handling

// @@PLEAC@@_10.12
// One of the key, non-object oriented features of Standard C++ is its built-in support for
// exceptions / exception handling. The feature is well-integrated into the language, including
// a set of predefined exception classes included in, and used by, the Standard Library, is
// quite easy to use, and helps the programmer write robust code provided certain conventions
// are followed. On the downside, the C++ exception handling system is criticised for imposing
// significant runtime overhead, as well as increasing executable code size [though this
// varies considerably between CPU's, OS's, and compilers]. Please refer to the corresponding
// section in PLEAC-C/Posix/GNU for pertinent reading references.
//
// The example code below matches the PLEAC-C/Posix/GNU example rather than the Perl code. Note:
// * A very minimal, custom exception class is implemented; a more complex class, one richer in
//   diagnostic information, could have been implemented, or perhaps one based on a standard
//   exception class like 'std::exception'
// * Ordinarily error / exception messages are directed to 'std::cerr' or 'std::clog'
// * General recommendation is to throw 'temporaries' [via invoking a constructor],
//   and to 'catch' as const reference(s)
// * Proper 'cleanup' is very important; consult a suitable book for guidance on writing
//   'exception safe' code

#include <iostream>
#include <string>

class FullmoonException
{
public:
  explicit FullmoonException(const std::string& msg) : msg_(msg) {}

  friend std::ostream& operator<<(std::ostream& out, const FullmoonException& e)
  {
    out << e.msg_; return out;
  }
private:
  const std::string msg_;
};

// ----

int main()
{
  std::cout << "main - entry" << std::endl;

  try
  {
    std::cout << "try block - entry" << std::endl;
    std::cout << "... doing stuff ..." << std::endl;

    // if (... error condition detected ...)
         throw FullmoonException("... the problem description ...");

    // Control never gets here ...
    std::cout << "try block - end" << std::endl;
  }

  catch(const FullmoonException& e)
  {
    std::cout << "Caught a'Fullmoon' exception. Message: "
              << "[" << e << "]"
              << std::endl;
  }

  catch(...)
  {
    std::cout << "Caught an unknown exceptione" << std::endl;
  }

  // Control gets here regardless of whether an exception is thrown or not
  std::cout << "main - end" << std::endl;
}

// @@PLEAC@@_10.13
// Standard C++ sports a namespace facility which allows an application to be divided into
// logical sub-systems, each of which operates within its own scope. Put very simply, the same
// identifiers [i.e. name of types, objects, and functions] may be each used in a namespace
// without fear of a nameclash occurring when logical sub-systems are variously combined as
// an application. The name-clash problem is inherent in single-namespace languages like C; it
// often occurs when several third-party libraries are used [a common occurrence in C], or
// when an application scales up. The remedy is to rename identifiers, or, in the case of 
// functions that cannot be renamed, to wrap them up in other functions in a separate source
// file. Of course the problem may be minimised via strict adherence to naming conventions. 
//
// The C++ namespace facility is important, too, because it avoids the need to utilise certain
// C language practices, in particular:
// * Use of, possibly, 'clumsy' naming conventions [as described above]
// * Partition an application by separating logically-related items into separate source
//   files. Namespaces cross file boundaries, so items may reside in several source files
//   and still comprise a single, logical sub-system
// * Anonymous namespaces avoid use of the 'static' keyword in creating file scope globals

// Global variable
int age = 18;

// ----

void print_age()
{
  // Global value, 'age', is accessed
  std::cout << "Age is " << age << std::endl;
}

// ------------

int main()
{
  // A local variable named, 'age' will act to 'shadow' the globally
  // defined version, thus any changes to, 'age', will not affect
  // the global version
  int age = 5;

  // Prints 18, the current value of the global version
  print_age();

  // Local version is altered, *not* global version
  age = 23;

  // Prints 18, the current value of the global version
  print_age();
}

// ----------------------------

// Global variable
int age = 18;

// ----

void print_age()
{
  // Global value, 'age', is accessed
  std::cout << "Age is " << age << std::endl;
}

// ------------

int main()
{
  // Here no local version declared: any changes affect global version
  age = 5;

  // Prints 5, the new value of the global version
  print_age();

  // Global version again altered
  age = 23;

  // Prints 23, the new value of the global version
  print_age();
}

// ----------------------------

// Global variable
int age = 18;

// ----

void print_age()
{
  // Global value, 'age', is accessed
  std::cout << "Age is " << age << std::endl;
}

// ------------

int main()
{
  // Global version value saved into local version
  int age = ::age;

  // Prints 18, the new value of the global version
  print_age();

  // Global version this time altered
  ::age = 23;

  // Prints 23, the new value of the global version
  print_age();

  // Global version value restored from saved local version
  ::age = age;

  // Prints 18, the restored value of the global version
  print_age();
}

// @@PLEAC@@_10.14
// Please refer to the corresponding section in PLEAC-C/Posix/GNU since the points raised there
// about functions and function pointers apply equally to Standard C++ [briefly: functions
// cannot be redefined; several same-signature functions may be called via the same function
// pointer variable; code cannot be generated 'on-the-fly' (well, not without the use of
// several external tools, making it an extra-language, not integral, feature)].
// @@INCOMPLETE@@

// @@PLEAC@@_10.15
// Please refer to the corresponding section in PLEAC-C/Posix/GNU since all the points raised
// there apply equally to Standard C++ [briefly: undefined function calls are compiler-detected
// errors; function-pointer-based calls can't be checked for integrity].
// @@INCOMPLETE@@

// @@PLEAC@@_10.16
// Standard C++ does not support either simple nested functions or closures, therefore the
// example cannot be implemented exactly as per the Perl code

/* ===
int outer(int arg)
{
  int x = arg + 35;

  // *** wrong - illegal C++ ***
  int inner() { return x * 19; }

  return x + inner();
}
=== */

// The problem may, of course, be solved by defining two functions using parameter passing
// where appropriate, but this is contrary to the intent of the original Perl code
int inner(int x)
{
  return x * 19;
}

int outer(int arg)
{
  int x = arg + 35;
  return x + inner(x);
}

// An arguably better [but far more complicated] approach is to encapsulate all items within
// a namespace, but again, is an approach that is counter the intent of the original Perl code
#include <iostream>

namespace nst
{
  int x;
  int inner();
  int outer(int arg);
}

// ----

int main()
{
  std::cout << nst::outer(3) << std::endl;
}

// ----

int nst::inner()
{
  return nst::x * 19;
}

int nst::outer(int arg)
{
  nst::x = arg + 35;
  return nst::x + nst::inner();
}

// Another way to solve this problem and avoiding the use of an external function, is to
// create a local type and instantiate an object passing any required environment context
// to the constructor. Then, what appears as a parameterless nested function call, can be
// effected using 'operator()'. This approach most closely matches the original Perl code

int outer(int arg)
{
  int x = arg + 35;

  // 'Inner' is what is known as a Functor or Function Object [or Command Design Pattern]; it
  // allows objects that capture state / context to be instantiated, and that state / context
  // used / retained / altered at multiple future times. Both the STL and Boost Libraries
  // provide extensive support these constructs
  struct Inner
  {
    int n_;
    explicit Inner(int n) : n_(n) {}
    int operator()() const { return n_ * 19; }
  } inner(x);

  return x + inner();
}

// @@PLEAC@@_10.17
// @@INCOMPLETE@@
// @@INCOMPLETE@@

