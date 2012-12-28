require 'fileutils'
require 'formula'

class Apache22 < Formula
  homepage 'https://httpd.apache.org/'
  url 'https://www.apache.org/dist/httpd/httpd-2.2.23.tar.gz'
  sha1 '966445d503ecb72e3eadf864cd21028d00d441a2'
  version '2.2.23'

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
      "--enable-proxy",
      "--enable-ssl",
    ]
    system './configure', *args
    system "make"
    system "make install"

    # create logs directory
    FileUtils.mkpath "#{prefix}/logs"
  end
end
