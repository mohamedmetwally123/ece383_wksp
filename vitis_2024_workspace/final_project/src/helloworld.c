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
#include <stdlib.h>

#include "platform.h"
#include "xil_printf.h"						// Contains xil_printf
#include <xuartlite_l.h>					// Contains XUartLite_RecvByte
#include <xil_io.h>							// Contains Xil_Out8 and its variations
#include <xil_exception.h>

/************************** Constant Definitions ****************************/

/*
 * The following constants define the slave registers used for our Counter PCORE
 */
#define countBase				0x44a00000
#define Audio_Type_Reg				countBase
#define Audio_Play_Request_Reg		countBase + 4  //slavereg[1]
#define Sprite_Row_Reg       		countBase + 8 //slavereg[2]
#define Sprite_Col_Reg      		countBase + 12 //slavereg[3]
#define Sprite_Type_Reg  			countBase + 16  //slavereg[4]
#define Sprite_Active_Reg			countBase + 17 //slavereg[4]
#define WrAddr_Reg					countBase + 20        //slavereg[5]
#define NES_Scan_Reg			    countBase + 24        //slavereg[6]
#define FlagClear_Reg 				countBase + 28 //slavereg[7]
#define Wen_Reg  					countBase + 32 //slavereg[8]

/*
 * The following constants define the Counter commands
 */
#define DOODLE_WIDTH    25  //what we care about for collision detection
#define DOODLE_HEIGHT   39
#define PLATFORM_WIDTH  47
#define PLATFORM_HEIGHT 7



typedef struct{
    double col;
    double row;
    uint16_t sprite_type;
	uint16_t active;
	uint16_t width;
	uint16_t is_moving;
}sprite_t;

// is_moving
// 01 -> moving right
// 11 -> moving left
static double vy = -250;
static double vx = 0;
static double delta_y = 0;
static double delta_x = 0;
static double delta_x_moving_platforms = 1;
const double elapsed_time  = 0.0168;
const double gravity = 450;

static double doodle_prev_bottom = 410 + DOODLE_HEIGHT;
static double doodle_current_bottom = 410 + DOODLE_HEIGHT;
static uint16_t death_rising = 1;
uint16_t sound_type = 0;
/*
 green platform -> 1
 doodle facing right -> 2
 doodle facing left -> 3
 blue platform -> 4
 */


static sprite_t spriteArray[32] = {
		{71, 381, 2, 1, DOODLE_WIDTH, 0},
	    {0, 0, 3, 0, DOODLE_WIDTH, 0},   // left facing doodle
		{60, 420, 1, 1, PLATFORM_WIDTH, 0},
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	    {0, 0, 0, 0, 0, 0},   // blue platform
	};


/************************** Variable Definitions **************************/
uint16_t NES_scan = 0;

typedef enum {
    WAIT_FOR_START,
    DOODLE_UP,
    DOODLE_DOWN,
	GAME_OVER,
	WAIT_FOR_RESTART
} State;

State Current_State = WAIT_FOR_START;
State Next_State = WAIT_FOR_START;

static double highest_platform = 0;
static double last_col_platform = 24;
/************************** Function Prototypes ****************************/
void myISR(void);
void update_FSM();
void update_game_velocity_and_position();
void update_coordinates();
void init_screen();


int main(void) {


	srand(1);
	init_platform();

	print("Welcome to Lab 3\n\r");

    microblaze_register_handler((XInterruptHandler) myISR, (void *) 0);
    microblaze_enable_interrupts();



    while(1) {
    	NES_scan = Xil_In16(NES_Scan_Reg);
    	highest_platform = spriteArray[2].row;

    	for(int j = 3; j < 31; j++) {
    	    if(spriteArray[j].active && spriteArray[j].row < highest_platform) {
    	        highest_platform = spriteArray[j].row;
    	    }
    	}
    	for(int i = 0; i < 31; i++) {
    		   if(spriteArray[i].row >= 0) {
    	 	   Xil_Out16(WrAddr_Reg,i);			// set BRAM address
    	 	   Xil_Out16(Sprite_Row_Reg,(uint16_t)spriteArray[i].row);			//Send left channel audio values
    	 	   Xil_Out16(Sprite_Col_Reg,(uint16_t)spriteArray[i].col);			//Send left channel audio values
    	 	   Xil_Out16(Sprite_Type_Reg,(spriteArray[i].sprite_type & 0xF) |
    	 			    ((spriteArray[i].active & 0x1) << 4));				//Write data to the BRAM
    	 	   Xil_Out16(Wen_Reg, 1);				//Turn off right
    	 	   Xil_Out16(Wen_Reg, 0);				//Turn off right
    		   }
    		   else {
        	 	   Xil_Out16(WrAddr_Reg,i);			// set BRAM address
        	 	   Xil_Out16(Sprite_Type_Reg,(spriteArray[i].sprite_type & 0xF) |
        	 	   ((spriteArray[i].active & 0x0) << 4));				//Write data to the BRAM
        	 	   Xil_Out16(Wen_Reg, 1);				//Turn off right
        	 	   Xil_Out16(Wen_Reg, 0);				//Turn off right
    		   }
    	}
    }

    cleanup_platform();

    return 0;
} // end main
	void update_FSM(){
	    switch (Current_State) {

	        case WAIT_FOR_START:
	        	if(NES_scan & (1<<3)) {
	        		init_screen();
	        		Next_State = DOODLE_UP;
	        		vy =-350;
	        	}
	        	break;
	        case DOODLE_UP:
	        	if(vy > 0) {
	        		Next_State = DOODLE_DOWN;
	        	}
	        	break;
	        case DOODLE_DOWN:
	        	double doodle_first_leg = spriteArray[0].col + 4;
	        	doodle_current_bottom = spriteArray[0].row + DOODLE_HEIGHT;
	        	for(int i = 2; i < 31; i++) {
	        		if((doodle_first_leg + 25) >= spriteArray[i].col && doodle_first_leg <= (spriteArray[i].col + spriteArray[i].width)
	        			&& doodle_prev_bottom <= spriteArray[i].row && doodle_current_bottom >= spriteArray[i].row) {
		        		Next_State = DOODLE_UP;
		        		vy =-350;
		        		sound_type = 0;
		        		Xil_Out16(Audio_Type_Reg,sound_type);			//Send left channel audio values
		        		Xil_Out16(Audio_Play_Request_Reg,1);			//Send left channel audio values
		        		Xil_Out16(Audio_Play_Request_Reg,0);			//Send left channel audio values

		        		break;
	        		}
	        		}
	        	if(doodle_current_bottom >= 480) {
	        		Next_State = GAME_OVER;
	        		sound_type = 2;
	        		Xil_Out16(Audio_Type_Reg,sound_type);			//Send left channel audio values
	        		Xil_Out16(Audio_Play_Request_Reg,1);			//Send left channel audio values
	        		Xil_Out16(Audio_Play_Request_Reg,0);			//Send left channel audio values
	        	}
	        	break;
    		case GAME_OVER:
    			if(spriteArray[0].row > 1000) {
        			Next_State = WAIT_FOR_RESTART;
        			death_rising = 1;
    			}

    			break;
    		case WAIT_FOR_RESTART:
	        	if(NES_scan & (1<<3)) {
	        		init_screen();
	        		Next_State = DOODLE_UP;
	        		vy =-350;
	        	}
    			break;
	        	}
    	    Current_State = Next_State;
    	    doodle_prev_bottom = doodle_current_bottom;
	    }
	void update_game_velocity_and_position() {


			delta_y = vy*elapsed_time+ 0.5*gravity*(elapsed_time)*(elapsed_time);
			vy = vy + gravity*elapsed_time;
			if(Current_State == WAIT_FOR_START) {
				delta_x = 0;
			}
			else if(NES_scan & 1<<6) {
				spriteArray[1].active = 1;
				spriteArray[0].active = 0;
				delta_x = -5;
			}
			else if(NES_scan & 1<<7) {
				spriteArray[0].active = 1;
				spriteArray[1].active = 0;
				delta_x = +5;
			}
			else {

				delta_x = 0;
			}
		}
	void update_coordinates() {
		if(Current_State == WAIT_FOR_START) {
			spriteArray[0].row = spriteArray[0].row + delta_y;
        	double doodle_first_leg = spriteArray[0].col + 4;
        	doodle_current_bottom = spriteArray[0].row + DOODLE_HEIGHT;
        	if(vy > 0 && (doodle_first_leg + 25) >= spriteArray[2].col && doodle_first_leg <= (spriteArray[2].col + spriteArray[2].width)
        			&& doodle_prev_bottom <= spriteArray[2].row && doodle_current_bottom >= spriteArray[2].row) {
	        		vy =-350;
	        		sound_type = 0;
	        		Xil_Out16(Audio_Type_Reg,sound_type);			//Send left channel audio values
	        		Xil_Out16(Audio_Play_Request_Reg,1);			//Send left channel audio values
	        		Xil_Out16(Audio_Play_Request_Reg,0);			//Send left channel audio values
        		}
        	doodle_prev_bottom = doodle_current_bottom;
		}
		else if(Current_State != WAIT_FOR_START) {
			spriteArray[0].col = spriteArray[0].col + delta_x;
			for(int i = 2; i < 32; i++){
				//it's moving right
				if(spriteArray[i].is_moving == 1) {
					if((spriteArray[i].col +delta_x_moving_platforms + spriteArray[i].width) >= 635) {
						spriteArray[i].is_moving = 3;
					}
					else {
						spriteArray[i].col += delta_x_moving_platforms;
					}
				}
				else if(spriteArray[i].is_moving == 3) {
					if((spriteArray[i].col - delta_x_moving_platforms) <= 5) {
						spriteArray[i].is_moving = 1;
					}
					else {
						spriteArray[i].col -= delta_x_moving_platforms;
					}
				}
			}
			if(Current_State == DOODLE_UP) {
				if(spriteArray[0].row <= 240) {
					for(int i = 2; i < 31; i++) {
						spriteArray[i].row = spriteArray[i].row - delta_y;

						if(spriteArray[i].row > 480) {
							spriteArray[i].row = highest_platform - (60 + (rand() % 10));
							spriteArray[i].col = 50 + ((rand() % 540));
							if(abs(last_col_platform - spriteArray[i].col) > 200) {
								if(last_col_platform > 310) {
									spriteArray[i].col = last_col_platform - 200;
								}
								else {
									spriteArray[i].col = last_col_platform + 200;
								}

							}


							if(spriteArray[i].row > 0) {
								spriteArray[i].row = 0;
							}
							last_col_platform = spriteArray[i].col;
						}
					}
				}
				else {
					spriteArray[0].row = spriteArray[0].row + delta_y;
				}

			}
			else if(Current_State == DOODLE_DOWN) {
				spriteArray[0].row = spriteArray[0].row + delta_y;
				if(spriteArray[0].col >= 640) {
					spriteArray[0].col = 0;
				}
				else if(spriteArray[0].col <= 0) {
					spriteArray[0].col = 640;
				}
			}
			else if(Current_State == GAME_OVER) {
				if(spriteArray[0].row <= 240) {
					death_rising = 0;
				}
				if(!death_rising) {
					spriteArray[0].row = spriteArray[0].row + delta_y;

				}
				else {
					spriteArray[0].row = spriteArray[0].row - delta_y;
				}
				for(int i = 2; i < 31; i++) {
					spriteArray[i].row = spriteArray[i].row - 1*delta_y;
				}
			}
			spriteArray[1].col = spriteArray[0].col;
			spriteArray[1].row = spriteArray[0].row;


		}
	}


//Initial state with the doodle jumping off of a platform waiting for the user to hit start
void init_screen() {
	spriteArray[0] = (sprite_t){320, 352, 2, 1, DOODLE_WIDTH, 0};
	spriteArray[1] = (sprite_t){0, 0, 3, 0, DOODLE_WIDTH, 0};
	spriteArray[2] = (sprite_t){24, 0, 4, 1, PLATFORM_WIDTH, 1};
	spriteArray[3] = (sprite_t){190, 100, 4, 1, PLATFORM_WIDTH, 1};
	spriteArray[4] = (sprite_t){300, 400, 1, 1, PLATFORM_WIDTH, 0};
	spriteArray[5] = (sprite_t){210, 200, 1, 1, PLATFORM_WIDTH, 0};
	spriteArray[6] = (sprite_t){250, 300, 1, 1, PLATFORM_WIDTH, 0};

    vy = -250;
    doodle_prev_bottom = spriteArray[0].row + DOODLE_HEIGHT;
    doodle_current_bottom = doodle_prev_bottom;

}

void myISR(void) {
	update_game_velocity_and_position();
	update_FSM();
	update_coordinates();
	Xil_Out8(FlagClear_Reg , 0x01);					// Clear the flag and then you MUST
	Xil_Out8(FlagClear_Reg , 0x00);					// allow the flag to be reset later
}
