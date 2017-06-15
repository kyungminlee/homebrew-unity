class Mkl < Formula
  desc "Intel Math Kernel Library"
  homepage "https://software.intel.com/en-us/intel-mkl"
  url "https://gist.githubusercontent.com/kyungminlee/6f1e34bc1da03838f085bdb3db114628/raw/211b76f4bf5f7a9e8e93ef0ccf4c9f20c9fa035f/empty"
  version "11.0.1"
  sha256 "32c4858e22cc2c967b42150fa550562a2c839c2cebcaab91cabdf6f4da020022"

  def install
    intel_root = "/opt/intel/compilers_and_libraries/linux"
    mkl_root = "#{intel_root}/mkl"

    mkdir include
    Dir["#{mkl_root}/include/*.h"].each do |filepath|
      filename = File.basename(filepath)
      ln_s filepath, "#{include}/#{filename}"
    end

    mkdir lib
    ["#{mkl_root}/lib/intel64_lin/*.so", 
     "#{mkl_root}/lib/intel64_lin/*.a",
     "#{intel_root}/lib/intel64_lin/libiomp*.so"].each do |filepattern|
      Dir[filepattern].each do |filepath|
	filename = File.basename(filepath)
	ln_s filepath, "#{lib}/#{filename}"
      end
    end
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <mkl.h>
      #include <stdio.h>

      int main(void) {
        int i=0;
        double A[6] = {1.0, 2.0, 1.0, -3.0, 4.0, -1.0};
        double B[6] = {1.0, 2.0, 1.0, -3.0, 4.0, -1.0};
        double C[9] = {.5, .5, .5, .5, .5, .5, .5, .5, .5};
        cblas_dgemm(CblasColMajor, CblasNoTrans, CblasTrans,
                    3, 3, 2, 1, A, 3, B, 3, 2, C, 3);

        for (i = 0; i < 9; i++)
          printf("%lf ", C[i]);
        printf("\\n");
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lmkl_rt", "-liomp5", "-o", "test"
    system "./test"
  end
end
