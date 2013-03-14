require 'formula'

class Apache22 < Formula
  homepage 'https://httpd.apache.org/'
  url 'http://apache.mirror.anlx.net/httpd/httpd-2.2.24.tar.gz'
  sha1 'fc8a99946b1fab936a05c77abad050590a4deb82'
  version '2.2.24'

  skip_clean ['bin', 'sbin', 'logs']

  def install
    args = [
      "--prefix=#{prefix}",
      "--mandir=#{man}",
      "--disable-debug",
      "--disable-dependency-tracking",
      "--with-mpm=prefork",
      "--with-included-apr",
      "--enable-mods-shared=all",
      "--enable-proxy",
      "--enable-ssl",
    ]
    system './configure', *args
    system "make"
    system "make install"

    # create logs directory
    Dir.mkdir "#{prefix}/logs"
  end
end
