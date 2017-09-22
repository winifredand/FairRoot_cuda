#include <stdio.h>
#include <stdlib.h>
#include <windows.h> //windows下运行使用；

// Forward declare the function  
extern "C" void DeviceInfo();
//extern "C" void runTest(int argc);

int main(int argc, char **argv)
{
	DeviceInfo();

	system("pause"); //windows下运行使用；

}
#include <stdio.h>
#include <stdlib.h>
#include "HitTrk.h"

#include <windows.h> //windows下运行使用；

// Forward declare the function  
extern "C" void DeviceInfo();
extern "C" void CircleFitG(double X[HIT], double Y[HIT], double Z[HIT], double Zerr[HIT], double *Mx, double *My, double *M0, double *result);
extern "C" void CircleFitGAllD(double X[TRK*HIT], double Y[TRK*HIT], double Z[TRK*HIT], double Zerr[TRK*HIT], double Mx[TRK], double My[TRK], double M0[TRK], double result[TRK * 8]);
extern "C" void CircleFitGF(float X[HIT], float Y[HIT], float Z[HIT], float Zerr[HIT], float *Mx, float *My, float *M0, float *result);
//extern "C" void runTest(int argc);

int main(int argc, char **argv)
{
	DeviceInfo();

	printf("////////////////Fit函数的调用，请设置输入信息////////////////////////////////////\n");
	printf("Fit的形式为CircleFitG(double X[HIT], double Y[HIT], double Z[HIT], double Zerr[HIT], double *Mx, double *My, double *M0, double *result)\n");
	printf("其中HIT = 30，请设置相应的数组和指针变量输入;\n");

	//CircleFitG();

	printf("////////////////FitAllD函数的调用，请设置输入信息////////////////////////////////////\n");
	printf("FitAllD的形式为extern "C" void CircleFitGAllD(double X[TRK*HIT], double Y[TRK*HIT], double Z[TRK*HIT], double Zerr[TRK*HIT], double Mx[TRK], double My[TRK], double M0[TRK], double result[TRK * 8])\n");
	printf("其中HIT = 30，TRK = 2000,请设置相应的数组和指针变量输入;\n");

	//CircleFitGAllD();

	printf("////////////////FitAllF函数的调用，请设置输入信息////////////////////////////////////\n");
	printf("FitAllF的形式为extern "C" void CircleFitGAllF(float X[TRK*HIT], float Y[TRK*HIT], float Z[TRK*HIT], float Zerr[TRK*HIT], float Mx[TRK], float My[TRK], float M0[TRK], float result[8 * TRK])\n");
	printf("其中HIT = 30，TRK = 2000,请设置相应的数组和指针变量输入;\n");

	//CircleFitGAllF();

	printf("////////////////FitF函数的调用，请设置输入信息////////////////////////////////////\n");
	printf("FitF的形式为extern "C" void CircleFitGF(float X[HIT], float Y[HIT], float Z[HIT], float Zerr[HIT], float *Mx, float *My, float *M0, float *result)\n");
	printf("其中HIT = 30，TRK = 2000,请设置相应的数组和指针变量输入;\n");

	//CircleFitGF();

	system("pause"); //windows下运行使用；

}
