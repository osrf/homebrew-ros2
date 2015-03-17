require "formula"

class Opensplice < Formula
  homepage "http://www.prismtech.com/opensplice"
  url "https://github.com/osrf/opensplice/releases/download/6.4.0-0/opensplice-6.4.0-0.tar.gz"
  version "6.4.0"
  sha1 "f562f3507d6e80e4df1ac8252ac661e6e3142879"

  depends_on "cmake" => :build
  depends_on "gawk"
  depends_on "java" => :build

  option 'with-debug', 'Builds opensplice in debug mode'

  def patches
    if MacOS.version >= :mavericks
      DATA
    end
  end

  bottle do
    root_url 'https://github.com/osrf/opensplice/releases/download/6.4.0-0'
    cellar :any
    revision 0
    sha1 "af9b98efe3e10ad0f99b0916c2e9901b28a33edf" => :mavericks
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
diff --git a/src/api/dcps/isocpp/include/dds/pub/AnyDataWriter.hpp b/src/api/dcps/isocpp/include/dds/pub/AnyDataWriter.hpp
index 91f0269..8e8f9fd 100644
--- a/src/api/dcps/isocpp/include/dds/pub/AnyDataWriter.hpp
+++ b/src/api/dcps/isocpp/include/dds/pub/AnyDataWriter.hpp
@@ -33,6 +33,12 @@ inline AnyDataWriter::AnyDataWriter(const dds::core::null_type&)
 {
 }
 
+template <typename T> std::unique_ptr<AnyDataWriter>
+create_AnyDataWriter(const dds::pub::DataWriter<T>& dw)
+{
+    return std::unique_ptr<AnyDataWriter>(new AnyDataWriter(dw));
+}
+
 template <typename T>
 AnyDataWriter::AnyDataWriter(const dds::pub::DataWriter<T>& dw)
     : holder_(new dds::pub::detail::DWHolder<T>(dw)) { }
diff --git a/src/api/dcps/isocpp/include/dds/pub/DataWriter.hpp b/src/api/dcps/isocpp/include/dds/pub/DataWriter.hpp
index a197cf5..aa35949 100644
--- a/src/api/dcps/isocpp/include/dds/pub/DataWriter.hpp
+++ b/src/api/dcps/isocpp/include/dds/pub/DataWriter.hpp
@@ -32,6 +32,9 @@ namespace pub
 {
 
 class AnyDataWriter;
+template <typename T> std::unique_ptr<AnyDataWriter>
+create_AnyDataWriter(const dds::pub::DataWriter<T>& dw);
+
 #ifdef OSPL_2893_COMPILER_BUG
 #define DELEGATE dds::pub::detail::DataWriter
 template <typename T>
@@ -634,8 +637,8 @@ public:
     close()
     {
         this->delegate()->close();
-        dds::pub::AnyDataWriter adw(*this);
-        org::opensplice::core::retain_remove<dds::pub::AnyDataWriter>(adw);
+        std::unique_ptr<AnyDataWriter> adw = create_AnyDataWriter(*this);
+        org::opensplice::core::retain_remove<dds::pub::AnyDataWriter>(*adw);
     }
 
 #ifndef OSPL_2893_COMPILER_BUG
@@ -648,8 +651,8 @@ public:
     retain()
     {
         this->delegate()->retain();
-        dds::pub::AnyDataWriter adr(*this);
-        org::opensplice::core::retain_add<dds::pub::AnyDataWriter>(adr);
+        std::unique_ptr<AnyDataWriter> adw = create_AnyDataWriter(*this);
+        org::opensplice::core::retain_add<dds::pub::AnyDataWriter>(*adw);
     }
 
 #ifdef OSPL_2893_COMPILER_BUG
diff --git a/src/api/dcps/isocpp/include/dds/sub/AnyDataReader.hpp b/src/api/dcps/isocpp/include/dds/sub/AnyDataReader.hpp
index 2c24633..9f88ab0 100644
--- a/src/api/dcps/isocpp/include/dds/sub/AnyDataReader.hpp
+++ b/src/api/dcps/isocpp/include/dds/sub/AnyDataReader.hpp
@@ -32,6 +32,12 @@ inline AnyDataReader::AnyDataReader(const dds::core::null_type&)
 {
 }
 
+template <typename T> std::unique_ptr<AnyDataReader>
+create_AnyDataReader(const dds::sub::DataReader<T>& dr)
+{
+    return std::unique_ptr<AnyDataReader>(new AnyDataReader(dr));
+}
+
 template <typename T>
 AnyDataReader::AnyDataReader(const dds::sub::DataReader<T>& dr)
     : holder_(new detail::DRHolder<T>(dr)) { }
diff --git a/src/api/dcps/isocpp/include/dds/sub/TDataReader.hpp b/src/api/dcps/isocpp/include/dds/sub/TDataReader.hpp
index 856b7b4..8592ce0 100644
--- a/src/api/dcps/isocpp/include/dds/sub/TDataReader.hpp
+++ b/src/api/dcps/isocpp/include/dds/sub/TDataReader.hpp
@@ -32,6 +32,9 @@ namespace sub
 {
 
 class AnyDataReader;
+template <typename T> std::unique_ptr<AnyDataReader>
+create_AnyDataReader(const dds::sub::DataReader<T>& dr);
+
 //--------------------------------------------------------------------------------
 //  DATAREADER
 //--------------------------------------------------------------------------------
@@ -933,8 +936,8 @@ private:
         try
         {
             this->delegate()->close();
-            dds::sub::AnyDataReader adr(*this);
-            org::opensplice::core::retain_remove<dds::sub::AnyDataReader>(adr);
+            std::unique_ptr<AnyDataReader> adr = create_AnyDataReader(*this);
+            org::opensplice::core::retain_remove<dds::sub::AnyDataReader>(*adr);
         }
         catch(int i)
         {
@@ -952,8 +955,8 @@ private:
     retain()
     {
         this->delegate()->retain();
-        dds::sub::AnyDataReader adr(*this);
-        org::opensplice::core::retain_add<dds::sub::AnyDataReader>(adr);
+        std::unique_ptr<AnyDataReader> adr = create_AnyDataReader(*this);
+        org::opensplice::core::retain_add<dds::sub::AnyDataReader>(*adr);
     }
 #ifdef OSPL_2893_COMPILER_BUG
 public:
diff --git a/src/api/dcps/isocpp/include/dds/topic/AnyTopic.hpp b/src/api/dcps/isocpp/include/dds/topic/AnyTopic.hpp
index af87409..b740657 100644
--- a/src/api/dcps/isocpp/include/dds/topic/AnyTopic.hpp
+++ b/src/api/dcps/isocpp/include/dds/topic/AnyTopic.hpp
@@ -27,6 +27,12 @@ namespace dds
 namespace topic
 {
 
+template <typename T> std::unique_ptr<AnyTopic>
+create_AnyTopic(const dds::topic::Topic<T>& t)
+{
+  return std::unique_ptr<AnyTopic>(new AnyTopic(t));
+}
+
 template <typename T>
 AnyTopic::AnyTopic(const dds::topic::Topic<T>& t): holder_(new detail::THolder<T>(t)) { }
 
diff --git a/src/api/dcps/isocpp/include/dds/topic/TTopic.hpp b/src/api/dcps/isocpp/include/dds/topic/TTopic.hpp
index 1dc1555..56cb244 100644
--- a/src/api/dcps/isocpp/include/dds/topic/TTopic.hpp
+++ b/src/api/dcps/isocpp/include/dds/topic/TTopic.hpp
@@ -31,6 +31,8 @@ namespace topic
 {
 
 class AnyTopic;
+template <typename T> std::unique_ptr<AnyTopic>
+create_AnyTopic(const dds::topic::Topic<T>& t);
 
 template <typename T, template <typename Q> class DELEGATE>
 Topic<T, DELEGATE>::Topic(const dds::domain::DomainParticipant& dp,
@@ -180,8 +182,8 @@ void
 Topic<T, DELEGATE>::close()
 {
     this->delegate()->close();
-    dds::topic::AnyTopic at(*this);
-    org::opensplice::core::retain_remove<dds::topic::AnyTopic>(at);
+    std::unique_ptr<AnyTopic> at = create_AnyTopic(*this);
+    org::opensplice::core::retain_remove<dds::topic::AnyTopic>(*at);
 }
 
 template <typename T, template <typename Q> class DELEGATE>
@@ -189,8 +191,8 @@ void
 Topic<T, DELEGATE>::retain()
 {
     this->delegate()->retain();
-    dds::topic::AnyTopic at(*this);
-    org::opensplice::core::retain_add<dds::topic::AnyTopic>(at);
+    std::unique_ptr<AnyTopic> at = create_AnyTopic(*this);
+    org::opensplice::core::retain_add<dds::topic::AnyTopic>(*at);
 }
 
 }
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
