require 'fileutils'
require 'formula'

class Apache24 < Formula
  homepage 'https://httpd.apache.org/'
  url 'http://mirror.lividpenguin.com/pub/apache/httpd/httpd-2.4.4.tar.bz2'
  sha1 '0c5ab7f876aa10fbe8bfab2c34f8dd3dc76db16c'
  version '2.4.4'

  skip_clean ['bin', 'sbin']

  depends_on 'pcre'

  # Apache 2.4 no longer bundles apr or apr-util so we have to fetch
  # it manually for each build
  def fetch_apr
    ["apr-1.4.6", "apr-util-1.4.1"].each do |tb|
      curl "-s", "-o", "#{tb}.tar.gz", "https://www.apache.org/dist/apr/#{tb}.tar.gz"
      system "tar -xzf #{tb}.tar.gz"
      dir = tb.reverse.split('-', 2).map(&:reverse).reverse[0]
      FileUtils.mv(tb, "srclib/#{dir}")
    end
  end

  def install
    fetch_apr

    args = [
      "--prefix=#{prefix}",
      "--mandir=#{man}",
      "--disable-debug",
      "--disable-dependency-tracking",
      "--with-mpm=prefork",
      "--with-included-apr",
      "--enable-mods-shared=all",
      "--with-pcre=#{Formula.factory('pcre').prefix}",
    ]
    system './configure', *args
    system "make"
    system "make install"

    # create logs directory
    FileUtils.mkpath "#{prefix}/logs"
  end
end
