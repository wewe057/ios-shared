SetDirection's iOS-Shared
=========================

Usage
-----
To use iOS-Shared in your project, add the contents of ./Source as source code and #import "ios-shared.h" in your precompiled
header file. iOS-Shared uses strict warnings and warnings as errors. If you want to use the same level of warnings that iOS-Shared
uses, you can set your project to use the Xcode config files in your project. The configuration files live in ./Source/Configurations.

See an example of where in the Xcode UI to set this up:

![config file setup](https://github.com/setdirection/ios-shared/raw/master/config-files.png)


Purpose
-------
The intention of iOS-Shared is to serve as a repository for generic iOS code written by Set Direction and
it's clients, authorized external contributors, etc.  Its intent is NOT to be a dumping ground for random
code snippets found on the internet.


Adding 3rd party code
---------------------

iOS-Shared is licensed under the MIT license (see below).  When adding 3rd party code to this project, please
ensure the licenses are compatible.  3rd party code must be added as a sub-directory of /Externals.  In
instances where this is just a handful of source files, you may simply copy the code there and ensure the
license(s) remain intact.  When possible, it is preferrable to add 3rd party code as an external submodule
reference.

In cases where iOS-Shared doesn't actually reference any of the added external classes, you should add them
to your own project repository.


License
-------

Copyright (C) 2012-2014 Set Direction

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
