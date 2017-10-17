////均采用CUDA7.5的函数编写；////////////
#include <stdio.h>
#include <assert.h>
#include <cuda_runtime.h>
#include <helper_cuda.h>
#include <helper_functions.h>
#include <math.h>
#include "HitTrk.h"
#include "trackfit_kernel.cu"

///////////////内核函数////////////
extern "C" void CircleFitG(double X[HIT], double Y[HIT], double Z[HIT], double Zerr[HIT], double *Mx, double *My, double *M0, double *result)
{
	////////////在设备段分配显存,d_表示device,////////
	double *d_X;
	double *d_Y;
	double *d_Z;
	double *d_Zerr;
	double *d_Mx;
	double *d_My;
	double *d_MO;
	double *d_result;

	cudaError_t cudaStatus; //状态监测；

	///////////////分配设备/////////////////
	cudaStatus = cudaSetDevice(0);
	if (cudaStatus != cudaSuccess)
	{
		fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");
		goto Error;
	}

	//////////分配内存/////////
	size_t size = sizeof(double);
	checkCudaErrors(cudaMalloc((void **)&d_X, size*HIT));
	checkCudaErrors(cudaMalloc((void **)&d_Y, size*HIT));
	checkCudaErrors(cudaMalloc((void **)&d_Z, size*HIT));
	checkCudaErrors(cudaMalloc((void **)&d_Zerr, size*HIT));
	checkCudaErrors(cudaMalloc((void **)&d_My, size));
	checkCudaErrors(cudaMalloc((void **)&d_MO, size));
	checkCudaErrors(cudaMalloc((void **)&d_Mx, size));
	checkCudaErrors(cudaMalloc((void **)&d_result, size * 8));

	//////将内存中的数据读入显存，完成主机即CPU对CUDA设备的数据写入/////
	checkCudaErrors(cudaMemcpy(d_X, X, size*HIT, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_Y, Y, size*HIT, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_Z, Z, size*HIT, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_Zerr, Zerr, size*HIT, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_Mx, Mx, size, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_My, My, size, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_MO, M0, size, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_result, result, size * 8, cudaMemcpyHostToDevice));

	////////设置运行参数，即网格的形状和线程块的形状///////
	//    unsigned int threads = HIT;
	//    unsigned int tracks = TRK;
	dim3 dimBlock2(HIT, 1);// HIT=20,此句表示每个block有20个线程；
	dim3 dimGrid2(1, 1); //表示1*1个block；

/*	/////////时间函数///////////
	cudaEvent_t start, stop;
	float time_kernel;
	checkCudaErrors(cudaEventRecord(start, 0));//开始计时；*/

	///////调用内核函数进行计算////////////////
	Fit <<< dimGrid2, dimBlock2 >>> (d_X, d_Y, d_Z, d_Zerr, d_Mx, d_My, d_MO, d_result);

/*	checkCudaErrors(cudaEventRecord(stop, 0));//结束计时；
	checkCudaErrors(cudaEventSynchronize(start));
	checkCudaErrors(cudaEventSynchronize(stop));

	checkCudaErrors(cudaEventElapsedTime(&time_kernel, start, stop));//计算时间差；

	checkCudaErrors(cudaEventDestroy(start));//destory the event
	checkCudaErrors(cudaEventDestroy(stop));*/

	printf("Fit的核函数kernel运行时间:\t\t%.2f\n", time_kernel);//输出内核函数运行时间；

	//////////////将结果从显存设备段写入内存主机端/////////////
	checkCudaErrors(cudaMemcpy(result, d_result, size * 8, cudaMemcpyDeviceToHost));

	/////////////打印结果/////////
	printf("Newton迭代法运行结果1: \n");
	printf("%f, %f, %f, %f, %f, %f, %f, %f,\n", result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7]);

	/////////////释放显存////////
Error:
	checkCudaErrors(cudaFree(d_X));
	checkCudaErrors(cudaFree(d_Y));
	checkCudaErrors(cudaFree(d_Z));
	checkCudaErrors(cudaFree(d_Zerr));
	checkCudaErrors(cudaFree(d_Mx));
	checkCudaErrors(cudaFree(d_My));
	checkCudaErrors(cudaFree(d_MO));
	checkCudaErrors(cudaFree(d_result));
}


/*
extern "C" void CircleFitGAllD(double X[TRK*HIT], double Y[TRK*HIT], double Z[TRK*HIT], double Zerr[TRK*HIT], double Mx[TRK], double My[TRK], double M0[TRK], double result[TRK * 8])
{
	double *d_X;
	double *d_Y;
	double *d_Z;
	double *d_Zerr;
	double *d_Mx;
	double *d_My;
	double *d_M0;
	double *d_result;

	cudaError_t cudaStatus;

	cudaStatus = cudaSetDevice(0);
	if (cudaStatus != cudaSuccess)
	{
		fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");
		goto Error;
	}

	/*   result[0]=1;
	result[1]=1;
	result[2]=1;*//*

	size_t size = sizeof(double);
	//allocate memory for arrays on device 
	checkCudaErrors(cudaMalloc((void **)&d_X, size*HIT*TRK));
	checkCudaErrors(cudaMalloc((void **)&d_Y, size*HIT*TRK));
	checkCudaErrors(cudaMalloc((void **)&d_Z, size*HIT*TRK));
	checkCudaErrors(cudaMalloc((void **)&d_Zerr, size*HIT*TRK));
	checkCudaErrors(cudaMalloc((void **)&d_Mx, size*TRK));
	checkCudaErrors(cudaMalloc((void **)&d_My, size*TRK));
	checkCudaErrors(cudaMalloc((void **)&d_M0, size*TRK));
	checkCudaErrors(cudaMalloc((void **)&d_result, size * 8 * TRK));

	checkCudaErrors(cudaMemcpy(d_X, X, size*HIT*TRK, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_Y, Y, size*HIT*TRK, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_Z, Z, size*HIT*TRK, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_Zerr, Zerr, size*HIT*TRK, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_Mx, Mx, size*TRK, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_My, My, size*TRK, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_M0, M0, size*TRK, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_result, result, size * 8 * TRK, cudaMemcpyHostToDevice));

	int threads = HIT;//HIT = 30;
	int tracks = TRK;// TRK = 2000;
	dim3 dimBlock2(threads, 1);
	dim3 dimGrid2(tracks, 1);

	cudaEvent_t start, stop;
	float time_kernel;
	checkCudaErrors(cudaEventRecord(start, 0));

	FitAllD << < dimGrid2, dimBlock2 >> > (d_X, d_Y, d_Z, d_Zerr, d_Mx, d_My, d_M0, d_result);

	checkCudaErrors(cudaEventRecord(stop, 0));
	checkCudaErrors(cudaEventSynchronize(start));
	checkCudaErrors(cudaEventSynchronize(stop));

	checkCudaErrors(cudaEventElapsedTime(&time_kernel, start, stop));
	checkCudaErrors(cudaEventDestroy(start));
	checkCudaErrors(cudaEventDestroy(stop));

	printf("FitALLD的核函数kernel运行时间:\t\t%.2f\n", time_kernel);

	checkCudaErrors(cudaMemcpy(result, d_result, size * 8 * TRK, cudaMemcpyDeviceToHost));

	printf("Newton迭代法运行结果2: \n");
	printf("%f, %f, %f, %f, %f, %f, %f, %f,\n", result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7]);
	// cudaThreadSynchronize();

	for (int j = 0; j<tracks; j++)
	{
		printf("%d   ", j);
		for (int i = 0; i<8; i++)
		{
			printf("  %f ", result[i + 8 * j]);
		}
		printf(" \n");
	}

Error:
	checkCudaErrors(cudaFree(d_X));
	checkCudaErrors(cudaFree(d_Y));
	checkCudaErrors(cudaFree(d_Z));
	checkCudaErrors(cudaFree(d_Zerr));
	checkCudaErrors(cudaFree(d_Mx));
	checkCudaErrors(cudaFree(d_My));
	checkCudaErrors(cudaFree(d_M0));
	checkCudaErrors(cudaFree(d_result));
}
*/

/*
extern "C" void CircleFitGAllF(float X[TRK*HIT], float Y[TRK*HIT], float Z[TRK*HIT], float Zerr[TRK*HIT], float Mx[TRK], float My[TRK], float M0[TRK], float result[8 * TRK])
{
	float *d_X;
	float *d_Y;
	float *d_Z;
	float *d_Zerr;
	float *d_Mx;
	float *d_My;
	float *d_M0;
	float *d_result;

	*//*   result[0]=1;
	result[1]=1;
	result[2]=1;

	cudaError_t cudaStatus;
	cudaStatus = cudaSetDevice(0);
	if (cudaStatus != cudaSuccess)
	{
		fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");
		goto Error;
	}

	size_t size = sizeof(float);
	checkCudaErrors(cudaMalloc((void **)&d_X, size*HIT*TRK));
	checkCudaErrors(cudaMalloc((void **)&d_Y, size*HIT*TRK));
	checkCudaErrors(cudaMalloc((void **)&d_Z, size*HIT*TRK));
	checkCudaErrors(cudaMalloc((void **)&d_Zerr, size*HIT*TRK));
	checkCudaErrors(cudaMalloc((void **)&d_Mx, size*TRK));
	checkCudaErrors(cudaMalloc((void **)&d_My, size*TRK));
	checkCudaErrors(cudaMalloc((void **)&d_M0, size*TRK));
	checkCudaErrors(cudaMalloc((void **)&d_result, size * 8 * TRK));

	checkCudaErrors(cudaMemcpy(d_X, X, size*HIT*TRK, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_Y, Y, size*HIT*TRK, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_Z, Z, size*HIT*TRK, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_Zerr, Zerr, size*HIT*TRK, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_Mx, Mx, size*TRK, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_My, My, size*TRK, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_M0, M0, size*TRK, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_result, result, size * 8 * TRK, cudaMemcpyHostToDevice));

	int threads = HIT;
	int tracks = TRK;
	dim3 dimBlock2(threads, 1);
	dim3 dimGrid2(tracks, 1);

	cudaEvent_t start, stop;
	float time_kernel;
	checkCudaErrors(cudaEventRecord(start, 0));

	FitAllF << < dimGrid2, dimBlock2 >> > (d_X, d_Y, d_Z, d_Zerr, d_Mx, d_My, d_M0, d_result);

	checkCudaErrors(cudaEventRecord(stop, 0));
	checkCudaErrors(cudaEventSynchronize(start));
	checkCudaErrors(cudaEventSynchronize(stop));

	checkCudaErrors(cudaEventElapsedTime(&time_kernel, start, stop));
	checkCudaErrors(cudaEventDestroy(start));
	checkCudaErrors(cudaEventDestroy(stop));

	printf("FitALLF的核函数kernel运行时间:\t\t%.2f\n", time_kernel);

	//cudaThreadSynchronize();

	checkCudaErrors(cudaMemcpy(result, d_result, size * 8 * TRK, cudaMemcpyDeviceToHost));

	printf("Newton迭代法运行结果3: \n");
	//	printf("%f, %f, %f, %f, %f, %f, %f, %f,\n",result[0],result[1],result[2],result[3],result[4],result[5],result[        6],result[7]);
	for (int j = 0; j<tracks; j++)
	{
		printf("%d", j);
		for (int i = 0; i<8; i++){
			printf("  %f ", result[i + 8 * j]);
		}
		printf(" \n");
	}

Error:
	checkCudaErrors(cudaFree(d_X));
	checkCudaErrors(cudaFree(d_Y));
	checkCudaErrors(cudaFree(d_Z));
	checkCudaErrors(cudaFree(d_Zerr));
	checkCudaErrors(cudaFree(d_Mx));
	checkCudaErrors(cudaFree(d_My));
	checkCudaErrors(cudaFree(d_M0));
	checkCudaErrors(cudaFree(d_result));
}

extern "C" void CircleFitGF(float X[HIT], float Y[HIT], float Z[HIT], float Zerr[HIT], float *Mx, float *My, float *M0, float *result)
{
	float *d_X;
	float *d_Y;
	float *d_Z;
	float *d_Zerr;
	float *d_Mx;
	float *d_My;
	float *d_M0;
	float *d_result;

	cudaError_t cudaStatus;
	cudaStatus = cudaSetDevice(0);
	if (cudaStatus != cudaSuccess)
	{
		fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");
		goto Error;
	}

	size_t size = sizeof(float);
	checkCudaErrors(cudaMalloc((void **)&d_X, size*HIT));
	checkCudaErrors(cudaMalloc((void **)&d_Y, size*HIT));
	checkCudaErrors(cudaMalloc((void **)&d_Z, size*HIT));
	checkCudaErrors(cudaMalloc((void **)&d_Zerr, size*HIT));
	checkCudaErrors(cudaMalloc((void **)&d_Mx, size));
	checkCudaErrors(cudaMalloc((void **)&d_My, size));
	checkCudaErrors(cudaMalloc((void **)&d_M0, size));
	checkCudaErrors(cudaMalloc((void **)&d_result, size * 8));

	checkCudaErrors(cudaMemcpy(d_X, X, size*HIT, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_Y, Y, size*HIT, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_Z, Z, size*HIT, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_Zerr, Zerr, size*HIT, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_Mx, Mx, size, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_My, My, size, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_M0, M0, size, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_result, result, size * 8, cudaMemcpyHostToDevice));

	dim3 dimBlock2(HIT, 1);
	dim3 dimGrid2(1, 1);
	cudaEvent_t start, stop;
	float time_kernel;
	checkCudaErrors(cudaEventRecord(start, 0));

	FitF <<< dimGrid2, dimBlock2 >>> (d_X, d_Y, d_Z, d_Zerr, d_Mx, d_My, d_M0, d_result);

	checkCudaErrors(cudaEventRecord(stop, 0));
	checkCudaErrors(cudaEventSynchronize(start));
	checkCudaErrors(cudaEventSynchronize(stop));

	checkCudaErrors(cudaEventElapsedTime(&time_kernel, start, stop));
	checkCudaErrors(cudaEventDestroy(start));
	checkCudaErrors(cudaEventDestroy(stop));

	printf("FitF的核函数kernel运行时间:\t\t%.2f\n", time_kernel);

	checkCudaErrors(cudaMemcpy(result, d_result, size * 8, cudaMemcpyDeviceToHost));

	printf("Newton迭代法运行结果4: \n");
	printf("%f, %f, %f, %f, %f, %f, %f, %f,\n", result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7]);

Error:
	checkCudaErrors(cudaFree(d_X));
	checkCudaErrors(cudaFree(d_Y));
	checkCudaErrors(cudaFree(d_Z));
	checkCudaErrors(cudaFree(d_Zerr));
	checkCudaErrors(cudaFree(d_Mx));
	checkCudaErrors(cudaFree(d_My));
	checkCudaErrors(cudaFree(d_M0));
	checkCudaErrors(cudaFree(d_result));
}
*/
