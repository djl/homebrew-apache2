homebrew-apache2
----------------

[homebrew][h] + [Apache][a].

[h]: https://github.com/mxcl/homebrew
[a]: https://httpd.apache.org/

**Installation**

    brew tap djl/homebrew-apache2
    brew install djl/apache2/apache22 # OR
    brew install djl/apache2/apache24


**Caveats**

While it is possible to have both Apache 2.2 and Apache 2.4 installed
at the same time, it's not possible to have both linked at the same time.

If you want to switch between versions, you'll need to `brew unlink` the
currently linked version first.
