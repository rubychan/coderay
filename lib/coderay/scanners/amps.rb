module CodeRay
module Scanners

load :html

class Amps < Scanner

  register_for :amps
  title 'Amps Template'

  KINDS_NOT_LOC = HTML::KINDS_NOT_LOC

  AMPS_BLOCK = /
    ({[{|%])
    (.*?)
    ([%|}]})
  /xm

  AMPS_COMMENT_BLOCK = /
    {%\s#
    (.*?)
     
