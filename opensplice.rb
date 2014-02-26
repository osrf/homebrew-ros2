require "formula"

class Opensplice < Formula
  homepage "http://www.prismtech.com/opensplice"
  url "https://github.com/osrf/opensplice/archive/6.3.3-1.tar.gz"
  sha1 "85fe898165c2c859f7def999ab1a36ca00501a2c"

  depends_on "cmake" => :build
  depends_on "gawk"

  bottle do
    root_url 'http://download.ros.org/bottles'
    cellar :any
    sha1 "088bd8fe15ddfcf6437eb6b25fd38e4b01b21b3d" => :mavericks
  end

  head 'https://github.com/osrf/opensplice', :using => :git

  def install
    ENV.deparallelize
    ENV.no_optimization
    mkdir "build_cmake" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    system "idlpp", "-h"
  end
end
