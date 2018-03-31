#ifndef H_GTUOS
#define H_GTUOS

#include "8080emuCPP.h"


class GTUOS{
	public:
		uint64_t handleCall(const CPU8080 & cpu);
		void printFileMemory(const CPU8080& cpu,char fileName[]);
};

#endif
