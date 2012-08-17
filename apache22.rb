require 'formula'

class Apache22 < Formula
  homepage 'https://httpd.apache.org/'
  url 'https://www.apache.org/dist/httpd/httpd-2.2.22.tar.gz'
  sha1 'bf3bbfda967ac900348e697f26fe86b25695efe9'
  version '2.2.22'

  skip_clean ['bin', 'sbin']

  def install
    args = [
      "--prefix=#{prefix}",
      "--mandir=#{man}",
      "--disable-debug",
      "--disable-dependency-tracking",
      "--with-mpm=prefork",
      "--with-included-apr",
      "--enable-mods-shared=all",
    ]
    system './configure', *args
    system "make"
    system "make install"
  end
end
