NVCC = /usr/local/cuda/bin/nvcc
NVCC_FLAGS = -g -G -Xcompiler -Wall

all:main.exe

main.exe: main.o test_lib.o trackfit.o 
   $(NVCC) $(NVCC_FLAGS) -c $< -o $@
   
main.o: main.cc HitTrk.h
   $(NVCC) $(NVCC_FLAGS) -c $< -o $@

test_lib.o: test_lib.cu
   $(NVCC) $(NVCC_FLAGS) -c $< -o $@
   
trackfit.o: trackfit.cu HitTrk.h trackfit_kernel.cu
   $(NVCC) $(NVCC_FLAGS) -c $< -o $@
