# WhatEver CMake Helper Repository

This is just a repository that is shared among several projects so I don't have
to duplicate it elsewhere. I don't expect this to have any use to others, but if
you want to grab something go right ahead.

**Copyright Information:**

WhatEver was written by [Daniel Wolf](https://github.com/Nephatrine) <<nephatrine@gmail.com>>.

* WhatEver is published under the [MIT license](LICENSE.md).
* The Python script required for downloading the Unicode files is licensed under
  the [PSF license](Tools/PYTHON-LICENSE).

## Using WhatEver

### Step 1: Add Submodule

from root of git repository:

```
git submodule add https://github.com/Nephatrine/whatever-neph.git config/CMake
git submodule update --init --recursive
```

### Step 2: Add To Project

in project `CMakeLists.txt`:

```
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/config/CMake")
```

### Step 3: Use It (Or Lose It)

to be written as functionality is added

## Unofficial Conversions

These are conversions I have made of other projects to use WhatEver. These are
unsuitable for general use as they have been customized to fit into my personal
build process and use cases. However, they might be a good reference for how to
actually use WhatEver until proper documentation is added here.

* [UCDN - Unicode Database & Normalization (Nephatrine Fork)](https://github.com/Nephatrine/ucdn-neph)

