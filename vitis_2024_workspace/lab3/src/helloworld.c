/*--------------------------------------------------------------------
-- Name:	Mohamed Metwally
-- Date:	March 13, 2026
-- File:	Lab3
-- Event:	Lab3
-- Crs:		ECE 383
--
-- Purp:	MicroBlaze Tutorial that implements a custom IP with interrupt
--			to MicroBlaze.
--
-- Documentation:	MicroBlaze Tutorial
--
-- Academic Integrity Statement: I certify that, while others may have
-- assisted me in brain storming, debugging and validating this program,
-- the program itself is my own work. I understand that submitting code
-- which is the work of other individuals is a violation of the honor
-- code.  I also understand that if I knowingly give my original work to
-- another individual is also a violation of the honor code.
-------------------------------------------------------------------------*/
/***************************** Include Files ********************************/

#include "xparameters.h"
#include "stdio.h"
#include "xstatus.h"

#include "platform.h"
#include "xil_printf.h"						// Contains xil_printf
#include <xuartlite_l.h>					// Contains XUartLite_RecvByte
#include <xil_io.h>							// Contains Xil_Out8 and its variations
#include <xil_exception.h>

/************************** Constant Definitions ****************************/

/*
 * The following constants define the slave registers used for our Counter PCORE
 */
#define countBase		0x44a00000
#define exWrAddrReg		countBase
#define exWenReg		countBase + 4  //slavereg[1]
#define exLBusReg       countBase + 16 //slavereg[4]
#define exRBusReg       countBase + 20 //slavereg[5]
#define LBusOut  		countBase + 8  //slavereg[2]
#define RBusOut			countBase + 12 //slavereg[3]
#define flagClear		countBase + 28 //slavereg[7]
#define triggerTimeReg  countBase + 36 //slavereg[9]
#define triggerVoltReg  countBase + 32 //slavereg[8]

/*
 * The following constants define the Counter commands
 */
#define START_COLUMN    20
#define END_COLUMN      620




/************************** Variable Definitions **************************/
uint16_t array_L[1024]; //Stores channel 1 samples
uint16_t array_R[1024]; //Stores channel 2 samples
static uint16_t currentCol = 0;
static uint16_t ARRAY_FULL = 0; //Checks if the array is full
static uint16_t trigger_time_value = 0;
static uint16_t trigger_volt_value = 0;




/************************** Function Prototypes ****************************/
void myISR(void);



//Finds the column of the sample where the waveform crosses the trigger
void findTriggerLocation(uint16_t triggerT, uint16_t triggerV) {
	uint16_t currentTrigger = triggerT;
	//This Indicates whether or not the trigger location is found
	int locationFound = 0;
	while(!locationFound && currentTrigger <= 1022) {
		//The hardware manipulates the samples from the BRAM by taking the 9 MSBs and subtracting 36(offset)
		uint16_t currentValue = (array_L[currentTrigger] >> 7) - 36;
		uint16_t nextValue = (array_L[currentTrigger + 1] >> 7) - 36;
		//Checks if the waveform crosses the trigger value.
		if(nextValue < triggerV && currentValue >= triggerV){
			locationFound = 1;
		}
		else {
			currentTrigger++;
		}
	}

	//Don't send back the audio samples to the BRAM if the trigger location is not found
	if(!locationFound) {
		return;
	}
	else {
		//Calculate the offset
		uint16_t offset = currentTrigger - trigger_time_value ;
		//Send the audio samples to the BRAM
    	copyToBram(offset);
	}
}

// This function takes the offset calculated in findTriggerLocation function and use it
// to send the audio samples to the BRAM
void copyToBram(uint16_t offset) {
	for(int col = START_COLUMN; col < END_COLUMN; col++) {
       uint16_t  exLBus = array_L[col + offset];
       uint16_t  exRBus = array_R[col + offset];
 	   Xil_Out16(exWrAddrReg,col);			// set BRAM address
 	   Xil_Out16(exLBusReg,exLBus);			//Send left channel audio values
 	   Xil_Out16(exRBusReg,exRBus);			//Send left channel audio values
 	   Xil_Out16(exWenReg,1);				//Write data to the BRAM
 	   Xil_Out16(exWenReg,0);				//Turn off right
	}
}
int main(void) {



	init_platform();

	print("Welcome to Lab 3\n\r");

    microblaze_register_handler((XInterruptHandler) myISR, (void *) 0);
    microblaze_enable_interrupts();



    while(1) {
    	trigger_volt_value = Xil_In16(triggerVoltReg);  //Receive the current triggerV value
    	trigger_time_value = Xil_In16(triggerTimeReg);  //Receive the current triggerT value
    	while(!ARRAY_FULL); //Wait for array to be full
    	findTriggerLocation(trigger_time_value, trigger_volt_value);
    	ARRAY_FULL = 0;    //Set it to zero so the interrupt proceeds


    }

    cleanup_platform();

    return 0;
} // end main


void myISR(void) {
	//Stop receiving samples when the array is full + reset currentCol
	if(currentCol >= 1024) {
		ARRAY_FULL = 1;
		currentCol = 0;
	}
	if (ARRAY_FULL == 0) {
		//Receives audio samples
		array_L[currentCol] = Xil_In16(LBusOut);
		array_R[currentCol] = Xil_In16(RBusOut);
		currentCol++;
	}

	Xil_Out8(flagClear, 0x01);					// Clear the flag and then you MUST
	Xil_Out8(flagClear, 0x00);					// allow the flag to be reset later
}
