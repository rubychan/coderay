# CodeRay [![Build Status](https://travis-ci.org/rubychan/coderay.png)](https://travis-ci.org/rubychan/coderay) [![Gem Version](https://badge.fury.io/rb/coderay.png)](http://badge.fury.io/rb/coderay) [![Dependency Status](https://gemnasium.com/rubychan/coderay.png)](https://gemnasium.com/rubychan/coderay)

## About

CodeRay is a Ruby library for syntax highlighting.

You put your code in, and you get it back colored; Keywords, strings, floats, comments - all in different colors. And with line numbers.

## Installation

`gem install coderay`

### Dependencies

CodeRay needs Ruby 1.8.7+ or 1.9.2+. It also runs on Rubinius and JRuby.

## Example Usage

```ruby
require 'coderay'

html = CodeRay.scan("puts 'Hello, world!'", :ruby).div(:line_numbers => :table)
````

## Documentation

See [http://coderay.rubychan.de/doc/](http://coderay.rubychan.de/doc/).
