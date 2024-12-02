# editorconfig-core-test

This project is a series of tests for [EditorConfig][] cores.
Please have [cmake][] installed before using this project.

## Use editorconfig-core-test independently

After installing cmake, switch to the root dir of this project, and execute:

    cmake -DEDITORCONFIG_CMD=the_editorconfig_core_cmd_you_want_to_test .

After that, if the test files have been generated successfully, execute
`ctest .` to start testing.

## Use editorconfig-core-test in your project as a git submodule

If you are using [git][] and cmake to manage your project, this method should
be suitable for you.

Suppose that you will add editorconfig-core-test repo as a
submodule in your root directory. First add editorconfig-core-test as a
gitsubmodule in your repo by execute:

    git submodule add git://github.com/editorconfig/editorconfig-core-test.git tests

Then add the following lines to your project root `CMakeLists.txt`:

```cmake
enable_testing()
set(EDITORCONFIG_CMD the_editorconfig_core_path)
add_subdirectory(tests)
```

Now after executing `cmake .` in your project root dir, you should be able to
run the tests by executing `ctest .`.

## Versioning

The version of this repository matches the version of the EditorConfig
[specification][].

[cmake]: https://www.cmake.org
[EditorConfig]: https://editorconfig.org
[git]: https://git-scm.com
[specification]: https://editorconfig-specification.readthedocs.io/en/latest/
