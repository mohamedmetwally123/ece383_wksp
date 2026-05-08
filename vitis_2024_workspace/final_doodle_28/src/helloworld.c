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
#define score_reg                   countBase + 36 //slavereg[9]

/*
 * The following constants define the Counter commands
 */
#define DOODLE_WIDTH    25  //what we care about for collision detection
#define DOODLE_HEIGHT   39
#define PLATFORM_WIDTH  47
#define PLATFORM_HEIGHT 7
#define BROKEN_BROWN_BEAM_WIDTH   7
#define BROKEN_BROWN_BEAM_HEIGHT  24

#define BROWN_BEAM_WIDTH          47
#define BROWN_BEAM_HEIGHT         7

#define GAME_OVER_WIDTH           79
#define GAME_OVER_HEIGHT          13

#define PLAY_WIDTH                79
#define PLAY_HEIGHT               23

#define PLAYAGAIN_WIDTH           79
#define PLAYAGAIN_HEIGHT          33

#define JETPACK_WIDTH             21
#define JETPACK_HEIGHT            31

#define JETPACK_AND_DOODLE_WIDTH  54
#define JETPACK_AND_DOODLE_HEIGHT 42







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
static double vy = -280;
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

static uint16_t score = 0;

static sprite_t spriteArray[32] = {
		{71, 381, 0, 1, DOODLE_WIDTH, 0},
	    {0,  0,   1, 0, DOODLE_WIDTH, 0},   // left facing doodle
	    {0,  0,   2, 0, JETPACK_AND_DOODLE_WIDTH, 0}, // doodle with a jetpack
	    {0,  0,   3, 0, JETPACK_WIDTH, 0},   // jetpack
	    {0, 0, 0, 0, 0, 0},
	    {0, 0, 0, 0, 0, 0},
	    {0, 0,    6, 0, GAME_OVER_WIDTH, 0},   // game over
	    {320, 210,7, 1, PLAY_WIDTH, 0},   // play
	    {0, 0,    8, 0, PLAYAGAIN_WIDTH, 0},   // play again
	    {60, 420, 12, 1, PLATFORM_WIDTH, 0}, // grean beam
	    {60, 420, 12, 0, PLATFORM_WIDTH, 0}, // grean beam
	    {0, 0,     14, 0,BROWN_BEAM_WIDTH, 0}, // brown beam
	    {60, 420, 12, 1, PLATFORM_WIDTH, 0}, // grean beam
	    {0, 0,    13, 0, PLATFORM_WIDTH, 1},   // blue beam
	    {0, 0,    13, 0, PLATFORM_WIDTH, 1},   // blue beam
	    {60, 420, 12, 0, PLATFORM_WIDTH, 0}, // grean beam
	    {60, 420, 12, 0, PLATFORM_WIDTH, 0}, // grean beam
	    {0, 0,     14, 0,BROWN_BEAM_WIDTH, 0}, // brown beam
	    {60, 420, 12, 0, PLATFORM_WIDTH, 0}, // grean beam
	    {60, 420, 12, 0, PLATFORM_WIDTH, 0}, // grean beam
	    {0, 0,    13, 0, PLATFORM_WIDTH, 1},   // blue beam
	    {60, 420, 12, 0, PLATFORM_WIDTH, 0}, // grean beam
	    {60, 420, 12, 0, PLATFORM_WIDTH, 0}, // grean beam
	    {0, 0,     14, 0,BROWN_BEAM_WIDTH, 0}, // brown beam
	    {0, 0,    13, 0, PLATFORM_WIDTH, 1},   // blue beam
	    {0, 0,     29, 0,BROKEN_BROWN_BEAM_WIDTH, 0},   // broken brown beam
	    {0, 0,     29, 0,BROKEN_BROWN_BEAM_WIDTH, 0},   // broken brown beam
	    {0, 0,     29, 0,BROKEN_BROWN_BEAM_WIDTH, 0},   // broken brown beam
	    {0, 0,     29, 0,BROKEN_BROWN_BEAM_WIDTH, 0},   // broken brown beam
	    {0, 0,     29, 0,BROKEN_BROWN_BEAM_WIDTH, 0},   // broken brown beam
	    {0, 0,     29, 0,BROKEN_BROWN_BEAM_WIDTH, 0},   // broken brown beam
	    {0, 0,     31, 1,0, 0},   // background

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

    	for(int i = 0; i <= 30; i++) {
    		   if(spriteArray[i].row >= 0) {
    	 	   Xil_Out16(WrAddr_Reg,i);			// set BRAM address
    	 	   Xil_Out16(Sprite_Row_Reg,(uint16_t)spriteArray[i].row);			//Send left channel audio values
    	 	   Xil_Out16(Sprite_Col_Reg,(uint16_t)spriteArray[i].col);			//Send left channel audio values
    	 	   Xil_Out16(Sprite_Type_Reg,(spriteArray[i].sprite_type & 0x1F) |
    	 			    ((spriteArray[i].active & 0x1) << 5));				//Write data to the BRAM
    	 	   Xil_Out16(Wen_Reg, 1);				//Turn on right
    	 	   Xil_Out16(Wen_Reg, 0);				//Turn off right
    		   }
    		   else {
        	 	   Xil_Out16(WrAddr_Reg,i);			// set BRAM address
        	 	   Xil_Out16(Sprite_Type_Reg,(spriteArray[i].sprite_type & 0xF) |
        	 	   ((spriteArray[i].active & 0x0) << 5));				//If it's off the screen, set active to zero
        	 	   Xil_Out16(Wen_Reg, 1);				//Turn off right
        	 	   Xil_Out16(Wen_Reg, 0);				//Turn off right
    		   }
    	}
    	Xil_Out16(score_reg, score);

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
	        		vy =-400;
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
	        	for(int i = 9; i < 24; i++) {
				if(check_collision(i)) {
			                Next_State = DOODLE_UP;
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
        			//When it's game over, The doodle first rises up to half of the screen, then falls down
        			death_rising = 1;
    			}

    			break;
    		case WAIT_FOR_RESTART:
	        	if(NES_scan & (1<<3)) {
	        		init_screen();
	        		Next_State = DOODLE_UP;
	        		score = 0;
	        		vy =-400;
	        		//disable the game over and play again sprite
					spriteArray[6].active = 0;
					spriteArray[8].active = 0;
	        	}
    			break;
	        	}
    	    Current_State = Next_State;
    	    doodle_prev_bottom = doodle_current_bottom;
	    }
	void update_game_velocity_and_position() {

			//Use three equations of motion to update position and velocity
			delta_y = vy*elapsed_time+ 0.5*gravity*(elapsed_time)*(elapsed_time);
			vy = vy + gravity*elapsed_time;
			if(Current_State == WAIT_FOR_START) {
				//Game is not in interactive mode
				delta_x = 0;
			}
			else if(Current_State == GAME_OVER) {
				delta_x = 0;
				delta_y = 10;
			}

			//Change which way the doodle is facing based on whether the doodle moves left or right
			// Update delta x accordingly
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

	int check_collision(int num_sprite) {
    	double doodle_first_leg = spriteArray[0].col + 4;
    	if(vy > 0 && (doodle_first_leg + 25) >= spriteArray[num_sprite].col && doodle_first_leg <= (spriteArray[num_sprite].col + spriteArray[num_sprite].width)
    			&& doodle_prev_bottom <= spriteArray[num_sprite].row && doodle_current_bottom >= spriteArray[num_sprite].row) {

    			//Check if it's a broken beam
    			if(spriteArray[num_sprite].sprite_type == 14) {
    				//If yes, activate the assoicated broken beams at the same location
    				if(num_sprite == 11) {
    					spriteArray[25].active = 1;
    					spriteArray[26].active = 1;
    					spriteArray[25].row = spriteArray[num_sprite].row;
    					spriteArray[25].col = spriteArray[num_sprite].col;
    					spriteArray[26].row = spriteArray[num_sprite].row;
    					spriteArray[26].col = spriteArray[num_sprite].col+spriteArray[num_sprite].width;


    				}
    				else if(num_sprite == 17) {
    					spriteArray[27].active = 1;
    					spriteArray[28].active = 1;
    					spriteArray[27].row = spriteArray[num_sprite].row;
    					spriteArray[27].col = spriteArray[num_sprite].col;
    					spriteArray[28].row = spriteArray[num_sprite].row;
    					spriteArray[28].col = spriteArray[num_sprite].col+spriteArray[num_sprite].width;
    				}
    				else if(num_sprite == 23) {
    					spriteArray[29].active = 1;
    					spriteArray[30].active = 1;
    					spriteArray[29].row = spriteArray[num_sprite].row;
    					spriteArray[29].col = spriteArray[num_sprite].col;
    					spriteArray[30].row = spriteArray[num_sprite].row;
    					spriteArray[30].col = spriteArray[num_sprite].col+spriteArray[num_sprite].width;
    				}
    				//Disable the brown beam, and position it at a random place above the screen.
					spriteArray[num_sprite].row = highest_platform - (40 + rand() % (55 - (40) + 1));

					spriteArray[num_sprite].col = last_col_platform + (-200 + rand() % (200 - (-200) + 1));
					if(spriteArray[num_sprite].col > 590) {
						spriteArray[num_sprite].col = last_col_platform - 200;
					}
					else if(spriteArray[num_sprite].col < 70){
							spriteArray[num_sprite].col = last_col_platform + 200;
					}


					if(spriteArray[num_sprite].row > 0) {
						spriteArray[num_sprite].row = 0;
					}
//							}

				last_col_platform = spriteArray[num_sprite].col;

					//Emit a spring sound for now
	        		sound_type = 1;
	        		Xil_Out16(Audio_Type_Reg,sound_type);			//Send left channel audio values
	        		Xil_Out16(Audio_Play_Request_Reg,1);			//Send left channel audio values
	        		Xil_Out16(Audio_Play_Request_Reg,0);			//Send left channel audio values
					// Return 0, as if there is no collision happened because the doodle should
					// keep moving up
					return 0;
    			}
    			vy =-400;
        		sound_type = 0;
        		Xil_Out16(Audio_Type_Reg,sound_type);			//Send left channel audio values
        		Xil_Out16(Audio_Play_Request_Reg,1);			//Send left channel audio values
        		Xil_Out16(Audio_Play_Request_Reg,0);			//Send left channel audio values
			return 1;
    	}
		return 0;
	}
	void update_broken_beams() {
		for(int i = 25; i <= 30; i++) {
			if(spriteArray[i].active) {
				if(spriteArray[i].row > 480) {
					spriteArray[i].active = 0;
				}
				else {
					spriteArray[i].row += 5;
				}
			}
		}
	}
	void update_coordinates() {

		//Game is not interactive until the user press start
		if(Current_State == WAIT_FOR_START) {
			//Update doodle coordinates
			spriteArray[0].row = spriteArray[0].row + delta_y;
        	doodle_current_bottom = spriteArray[0].row + DOODLE_HEIGHT;
        	//Check collision with the initilized grean beam stored at position 9
        	check_collision(9);
        	//Update the doodle prev bottom after checking
        	doodle_prev_bottom = doodle_current_bottom;
		}
		else if(Current_State != WAIT_FOR_START) {
			//update x coordinates of the sprites
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
				// World shifts down
				if(spriteArray[0].row <= 240) {
					score += abs(delta_y);
					for(int i = 9; i < 24; i++) {
						spriteArray[i].row = spriteArray[i].row - delta_y;

						if(spriteArray[i].row > 480) {
							//force a different values for broken beams
//							if(spriteArray[i].sprite_type == 14) {
//			    				//Disable the brown beam, and position it at a random place above the screen.
//								spriteArray[i].row = highest_platform -  (120 + rand() % 61);
//								spriteArray[i].col = last_col_platform + (-150 + rand() % (150 - (-150) + 1));
//								if(spriteArray[i].col > 500) {
//									spriteArray[i].col = last_col_platform - 150;
//								}
//								else if(spriteArray[i].col < 100){
//										spriteArray[i].col = last_col_platform + 150;
//								}
//								if(spriteArray[i].row > 0) {
//									spriteArray[i].row = 0;
//								}
//							}
//							else {
								spriteArray[i].row = highest_platform - (40 + rand() % (55 - (40) + 1));

								spriteArray[i].col = last_col_platform + (-200 + rand() % (200 - (-200) + 1));
								if(spriteArray[i].col > 590) {
									spriteArray[i].col = last_col_platform - 200;
								}
								else if(spriteArray[i].col < 70){
										spriteArray[i].col = last_col_platform + 200;
								}


								if(spriteArray[i].row > 0) {
									spriteArray[i].row = 0;
								}
//							}

							last_col_platform = spriteArray[i].col;
						}
					}
				}
				//Doodle moves up
				else {
					spriteArray[0].row = spriteArray[0].row + delta_y;
				}

			}

			else if(Current_State == DOODLE_DOWN) {
				spriteArray[0].row = spriteArray[0].row + delta_y;
				//Place the doodle on the left of the screen if it exits from the right
				if(spriteArray[0].col >= 640) {
					spriteArray[0].col = 0;
				}
				//Place the doodle on the right of the screen if it exits from the left
				else if(spriteArray[0].col <= 0) {
					spriteArray[0].col = 640;
				}
			}
			else if(Current_State == GAME_OVER) {
				//The doodle rises up the screen until it gets to mid point
				if(spriteArray[0].row <= 240) {
					death_rising = 0;
					//Display game over and play again sprite. Smoothly enter the world from the bottom
					spriteArray[6].row = 480;
					spriteArray[6].col = 305;
					spriteArray[6].active = 1;

					spriteArray[8].row = 520;
					spriteArray[8].col = 305;
					spriteArray[8].active = 1;

				}
				//If not death rising, the doodle is falling down
				if(!death_rising) {
					spriteArray[0].row = spriteArray[0].row + delta_y;
					if(spriteArray[6].row > 200) {
					spriteArray[6].row -= delta_y;
					spriteArray[8].row -= delta_y;
					}

				}
				else {
					spriteArray[0].row = spriteArray[0].row - delta_y;
				}
				for(int i = 9; i < 24; i++) {
					spriteArray[i].row = spriteArray[i].row - 1*delta_y;
				}
			}
			//update the broken brown beams coordinates
			update_broken_beams();
			spriteArray[1].col = spriteArray[0].col;
			spriteArray[1].row = spriteArray[0].row;


		}
    	highest_platform = spriteArray[9].row;

    	for(int j = 10; j < 24; j++) {
    		//ignore the brown beams
    	    	if(spriteArray[j].row < highest_platform) {
    	        highest_platform = spriteArray[j].row;

    	    }
    	}

	}


//Initial state with the doodle jumping off of a platform waiting for the user to hit start
void init_screen() {
	spriteArray[0].col = 320;
    spriteArray[0].row = 352;

	spriteArray[9].col = 320;
    spriteArray[9].row = 352;

    spriteArray[10].col = 190;
    spriteArray[10].row = 310;

    spriteArray[11].col = 340;
    spriteArray[11].row = 267;

    spriteArray[12].col = 480;
    spriteArray[12].row = 224;

    spriteArray[13].col = 295;
    spriteArray[13].row = 181;

    spriteArray[14].col = 125;
    spriteArray[14].row = 137;

    spriteArray[15].col = 260;
    spriteArray[15].row = 94;

    spriteArray[16].col = 430;
    spriteArray[16].row = 51;

    spriteArray[17].col = 570;
    spriteArray[17].row = 8;

    spriteArray[18].col = 390;
    spriteArray[18].row = -39;

    spriteArray[19].col = 215;
    spriteArray[19].row = -86;

    spriteArray[20].col = 80;
    spriteArray[20].row = -132;

    spriteArray[21].col = 230;
    spriteArray[21].row = -178;

    spriteArray[22].col = 410;
    spriteArray[22].row = -223;

    spriteArray[23].col = 555;
    spriteArray[23].row = -269;

    spriteArray[24].col = 375;
    spriteArray[24].row = -314;

    highest_platform  =  -314;
    for(int i = 9; i < 24; i++) {
    	spriteArray[i].active = '1';
    }

    //disable the play sprite
    spriteArray[7].active = 0;

    vy = -400;
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
