# CodeRay

[![Build Status](https://travis-ci.org/rubychan/coderay.svg?branch=master)](https://travis-ci.org/rubychan/coderay)
[![Gem Version](https://badge.fury.io/rb/coderay.svg)](https://badge.fury.io/rb/coderay) [![Maintainability](https://api.codeclimate.com/v1/badges/e015bbd5eab45d948b6b/maintainability)](https://codeclimate.com/github/rubychan/coderay/maintainability)

## About

CodeRay is a Ruby library for syntax highlighting.

You put your code in, and you get it back colored; Keywords, strings, floats, comments - all in different colors. And with line numbers.

## Installation

`gem install coderay`

### Dependencies

CodeRay needs Ruby 1.8.7, 1.9.3 or 2.0+. It also runs on JRuby.

## Example Usage

```ruby
require 'coderay'

html = CodeRay.scan("puts 'Hello, world!'", :ruby).div(:line_numbers => :table)
````

## Documentation

See [rubydoc](http://rubydoc.info/gems/coderay).
