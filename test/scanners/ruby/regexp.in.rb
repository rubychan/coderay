# Regexp or division?
some_string.to_i /\s+/
some_string.split / +/  this is a regexp after a division /
some_string.split / + /  this one, too /
some_string.split /- /  # and this one is a regexp without division