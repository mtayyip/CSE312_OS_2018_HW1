#include <iostream>
#include "8080emuCPP.h"
#include "gtuos.h"
#include "memory.h"

using namespace std;

// This is just a sample main function, you should rewrite this file to handle problems
// with new multitasking and virtual memory additions.
int main (int argc, char**argv)
{
	int totalCycles=0;

	if (argc != 3){
		cerr << "Usage: prog exeFile debugOption\n";
		exit(1); }
	int DEBUG = atoi(argv[2]);

    char fileName[]="exe.mem";

	memory mem;
	CPU8080 theCPU(&mem);
	GTUOS	theOS;

    srand(time(NULL));

	theCPU.ReadFileIntoMemoryAt(argv[1], 0x0000);	

	do	
	{
        totalCycles+=theCPU.Emulate8080p(DEBUG);

		if(DEBUG==2)
			cin.get();

		if(theCPU.isSystemCall())
			totalCycles+=theOS.handleCall(theCPU);

	}while (!theCPU.isHalted());


    theOS.printFileMemory(theCPU,fileName);
	cout<<"\nTotal Number of Cycles : "<<totalCycles<<endl;
	return 0;
}

