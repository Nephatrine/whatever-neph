# WhatEver CMake Helper Repository

This is just a repository that is shared among several projects so I don't have
to duplicate it elsewhere. I don't expect this to have any use to others, but if
you want to grab something go right ahead.

### Step 1: Add Submodule

from root of git repository:

```
git submodule add https://github.com/Nephatrine/whatever-neph.git config/CMake
```

### Step 2: Add To Project

in project `CMakeLists.txt`:

```
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/config/CMake")
```

### Step 3: Use It (Or Lose It)

to be written as functionality is added

