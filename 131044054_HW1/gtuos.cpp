#include <iostream>
#include <ctime>
#include "8080emuCPP.h"
#include "gtuos.h"

using namespace std;

uint64_t GTUOS::handleCall(const CPU8080 & cpu){

	int cycles=0,i=0,randomNumber=0;
    uint16_t address;
    string str,readStr;


	switch (cpu.state->a){
		case 1 ://PRINT_B
			cout<<"\nSystem Call PRINT_B"<<endl;
            cout<<int(cpu.state->b)<<endl;
            cycles=10;
			break;


		case 2 ://PRINT_MEM
			cout<<"\nSystem Call PRINT_MEM"<<endl;
            address = (cpu.state->b << 8) | cpu.state->c;//bit wise OR
            cout<<(int)cpu.memory->at(address)<<endl;
            cycles=10;
			break;


		case 3 ://READ_B
            int newCpuStateB;
			cout<<"\nSystem Call READ_B"<<endl;
            cout<<"Write the integer number (0-255) for register B: "<<endl;
            cin>>newCpuStateB;

            if(newCpuStateB<0 || newCpuStateB>255){
                cout<<"!!! Bound error. So B register assigned to zero."<<endl;
                cpu.state->b=0;
            }else{
                cpu.state->b=newCpuStateB;}
            cycles=10;
            break;


		case 4 ://READ_MEM
            int bc;
			cout<<"\nSystem Call READ_MEM"<<endl;
            cout<<"Write the integer number (0-255) for memory[BC] : "<<endl;
            cin>>bc;

            address = (cpu.state->b << 8) | cpu.state->c;//bit wise OR
            if(bc<0 || bc>255){
                cout<<"!!! Bound error. So memory[BC] assigned to zero."<<endl;
                cpu.memory->at(address)=0;
            }else{
                cpu.memory->at(address)=bc;}
            cycles=10;
			break;


		case 5 ://PRINT_STR
            i=0;
			cout<<"\nSystem Call PRINT_STR"<<endl;
            address = (cpu.state->b << 8) | cpu.state->c;//bit wise OR

            while(cpu.memory->at(address+i)!='\0'){
                str+=cpu.memory->at(address+i);
                i++;}

            cout<< str<<endl;
            cycles=100;
			break;


		case 6 ://READ_STR
			cout<<"\nSystem Call READ_STR"<<endl;
            cout<<"Write the string here :"<<endl;
            cin>>readStr;
            address = (cpu.state->b<<8) | cpu.state->c;

            for(i=0;i<readStr.length();i++)
                cpu.memory->at(address+i)=readStr[i];
			cpu.memory->at(address+i)='\0';
            cycles=100;
			break;


		case 7 ://GET_RND
			cout<<"\nSystem Call GET_RND"<<endl;
            randomNumber= rand()%255;
            cout<<"Random Number : "<<randomNumber<<endl;
            cpu.state->b=randomNumber;
            cycles=5;
			break;


		default:
			cout <<"\nUnimplemented OS call";
			cycles=0;
			break;
	}

	return cycles;
}




void GTUOS::printFileMemory(const CPU8080& cpu,char fileName[]) {

    int i=0,lineAdress=0;
    FILE* file;
    file=fopen(fileName,"w");


    for(i=0;i<=65535;i++){
        if(i%16==0){
            fprintf(file,"\n");
            fprintf(file,"0x%.4X ",lineAdress);
        }

        fprintf(file,"%.2X ",cpu.memory->at(i));
        lineAdress+=16;}
    fclose(file);
}