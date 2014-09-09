require "formula"

class Opensplice < Formula
  homepage "http://www.prismtech.com/opensplice"
  url "https://github.com/osrf/opensplice/releases/download/6.4.0-0/opensplice-6.4.0-0.tar.gz"
  version "6.4.0"
  sha1 "91693b152eb1d5c72589ab59104b4a80c0647f81"

  depends_on "cmake" => :build
  depends_on "gawk"

  option 'with-debug', 'Builds opensplice in debug mode'

  def patches
    if MacOS.version >= :mavericks
      DATA
    end
  end

  bottle do
    root_url 'https://github.com/osrf/opensplice/releases/download/6.4.0'
    cellar :any
    revision 0
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
