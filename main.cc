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
