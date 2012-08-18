require 'fileutils'
require 'formula'

class Apache24 < Formula
  homepage 'https://httpd.apache.org/'
  url 'https://www.apache.org/dist/httpd/httpd-2.4.2.tar.gz'
  sha1 'fc168decb5eb6f68d89601e9aa899fa46f355c1d'
  version '2.4.2'

  skip_clean ['bin', 'sbin']

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
    ]
    system './configure', *args
    system "make"
    system "make install"
  end
end
