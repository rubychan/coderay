# Regexp or division?
some_string.to_i /\s+/
some_string.split / +/  this is a regexp after a division /
some_string.split / + /  this one, too /
some_string.split /- /  # and this one is a regexp without division

it "allows substitution to interact with other Regexp constructs" do
  str = "foo)|(bar"
  /(#{str})/.should == /(foo)|(bar)/
  
  str = "a"
  /[#{str}-z]/.should == /[a-z]/

  not_compliant_on(:ruby) do
    str = "J"
    re = /\c#{str}/.should == /\cJ/
  end
end