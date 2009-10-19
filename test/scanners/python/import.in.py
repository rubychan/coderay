import YourModule             # Import the module into my package
                              #  (does not import any of its symbols)

import YourModule as Module   # Use a different name for the module

from YourModule import *      # Import all module symbols not starting
                              #  with an underscore (default); if __all__
                              #  is defined, only imports those symbols.
                              # Using this is discouraged unless the 
                              #  module is specifically designed for it.

from YourModule import name1, name2, xxx
                              # Import the named symbols from the module

from YourModule import name1 as name2
                              # Import the named object, but use a
                              #  different name to access it locally.

#-----------------------------
__all__ = ["F1", "F2", "List"]
#-----------------------------
__all__ = ["Op_Func", "Table"]
#-----------------------------
from YourModule import Op_Func, Table, F1
#-----------------------------
from YourModule import Functions, Table