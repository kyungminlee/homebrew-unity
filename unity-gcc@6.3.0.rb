class UnityGccAT630 < Formula
  desc "Unity GCC Compiler"
  homepage ""
  url "https://gist.githubusercontent.com/kyungminlee/6f1e34bc1da03838f085bdb3db114628/raw/211b76f4bf5f7a9e8e93ef0ccf4c9f20c9fa035f/empty"
  version "6.3.0"
  sha256 "32c4858e22cc2c967b42150fa550562a2c839c2cebcaab91cabdf6f4da020022"

  def install
    gcc_root = "/usr/local/gcc/6.3.0"
    mkdir "#{bin}"
    Dir["#{gcc_root}/bin/*"].each do |filepath|
      filename = File.basename(filepath)
      ln_s filepath, "#{bin}/#{filename}-6"
    end

    mkdir "#{lib}"
    Dir["#{gcc_root}/lib/*"].each do |filepath|
      filename = File.basename(filepath)
      ln_s filepath, "#{lib}/#{filename}"
    end

    mkdir "#{include}"
    Dir["#{gcc_root}/include/*"].each do |filepath|
      filename = File.basename(filepath)
      ln_s filepath, "#{include}/#{filename}"
    end

    mkdir "#{share}"
    Dir["#{gcc_root}/share/*"].each do |filepath|
      filename = File.basename(filepath)
      ln_s filepath, "#{share}/#{filename}"
    end

  end

  test do
    true
  end
end
