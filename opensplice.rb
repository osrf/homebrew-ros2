require "formula"

class Opensplice < Formula
  homepage "http://www.prismtech.com/opensplice"
  url "https://github.com/osrf/opensplice/releases/download/6.3.4/opensplice-6.3.4.tar.bz2"
  version "6.3.4"
  sha1 "ffd62de3778701aafe2b10939a15b6838c4a8405"

  depends_on "cmake" => :build
  depends_on "gawk"

  option 'with-debug', 'Builds opensplice in debug mode'

  def patches
    if MacOS.version >= :mavericks
      DATA
    end
  end

  bottle do
    root_url 'https://github.com/osrf/opensplice/releases/download/6.3.4'
    cellar :any
    revision 2
    sha1 "64f5aeece3d5c5cab7ab3d06bf15dea250baae7f" => :mavericks
    sha1 "945df81a1ba8f27ad6ec14d46643639d0200f4b5" => :mountain_lion
    sha1 "b86bb548334f632783cc9b0107cd48888eaf9db2" => :lion
  end

  head 'https://github.com/osrf/opensplice', :using => :git

  def install
    ENV.deparallelize
    ENV.no_optimization
    args = [".."] + std_cmake_args
    if build.with? 'debug'
      args << "-DCMAKE_BUILD_TYPE=Debug"
      inreplace 'CMakeLists.txt', 'x86_64.darwin10_clang-release', 'x86_64.darwin10_clang-dev'
    end
    mkdir "build_cmake" do
      system "cmake", *args
      system "make", "install"
    end
  end

  test do
    system "idlpp", "-h"
  end
end
__END__
diff --git a/src/api/dcps/isocpp/include/dds/core/detail/ref_traits.hpp b/src/api/dcps/isocpp/include/dds/core/detail/ref_traits.hpp
index 280a0fd..a93828c 100644
--- a/src/api/dcps/isocpp/include/dds/core/detail/ref_traits.hpp
+++ b/src/api/dcps/isocpp/include/dds/core/detail/ref_traits.hpp
@@ -21,6 +21,7 @@
 #include <dds/core/types.hpp>
 #include <dds/core/Exception.hpp>
 
+#define OSPL_USE_CXX11 1
 /* Compiling explicitly w/ C++ 11 support */
 #if defined(OSPL_USE_CXX11)
 #  include <memory>
