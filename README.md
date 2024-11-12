# usdt.h: Single-header USDT triggering library

This single-header library is providing a set of macro-based APIs for user
space applications to define and trigger USDTs (User Statically-Defined
Tracepoints, or simply "user space tracepoints"). All the API documentation is
self-contained inside [usdt.h](https://github.com/libbpf/usdt/blob/master/usdt.h)
in the form of C comments, please read through them to understand three
different ways USDTs can be defined and used.

USDT semaphores are an important (though, optional) part of USDTs usage, and
are fully supported in two different modes: implicit semaphores meant for the
best possible usability, and explicit user-defined semaphores, meant for more
advanced use cases that require sharing common USDT semaphore across a few
related USDTs. Refer to documentation for an example scenario.

It is intentional that usdt.h has no dependencies and is single-file. It will
remain single-file library going forward. This is meant to cause minimal
hurdles in adoption inside applications. It is encouraged to just copy the
file into your project and bypass any sort of dependency management or
packaging issues.

usdt.h is versioned. Initial release is designated v0.1.0 version to give it
a bit of time to find any corner case bugs, but other than that it's fully
feature-complete version and is already used in production across variety of
applications. The changelog is embedded into the documentation comments. There
are also `USDT_{MAJOR,MINOR,PATCH}_VERSION` macros defined, if you need to
take that into account at compilation time.

There are a set of tests inside `tests/` subdirectory meant to validate
various aspects of the library implementation and end-to-end API usage. Feel
free to consult it for various API usage questions, but otherwise it's
completely stand-along from `usdt.h` itself and user applications are not
expected to copy tests over into their applications. [usdt.h](https://github.com/libbpf/usdt/blob/master/usdt.h)
is the only file you need to make use of USDTs in your application.

This library is released under BSD 2-Clause [license](https://github.com/libbpf/usdt/blob/master/LICENSE).
