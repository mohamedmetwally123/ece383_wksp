

Doodle Jump Final Project
# 1 Proposal 
## 1.1 Objective Statement
This project implements a simple version of the Doodle Jump game using the Nexys Video board. It uses a Micro blaze processor to control the game logic and communicates with the custom hardware through slave registers. The custom hardware is responsible for rendering graphics on the screen, outputting game audio through the audio codec module, and receiving/processing user input from the NES controller. 
## 1.2 Requirements
### Minimum Functionality
1.	Implement a MicroBlaze-based system in Vivado. 
2.	Correctly interface with the NES controller so the system can translate user inputs into actual movements on the screen. 
3.	Display the basic graphics associated with the Doodle Jump game, including the background, doodle character, and static beams.
### B-Level Functionality
4.	Implement a data path to update the position of the doodle, platforms, and doodle velocity. The coordinates of all game entities shall be stored in registers.  
5.	Implement a system capable of generating the game audio playback
6.	Implement a control unit that controls game logic, audio output, graphics display, and game-over detection.
### A-Level Functionality
7.	Implement collision detection to detect the doodle’s interaction with platforms, monsters, and power-ups. Based on the type of collision, the control unit shall determine the appropriate response (game over, jump behavior, power-up activation, etc.). 
8.	Generate vertical scrolling by shifting existing platforms downward as the doodle moves upward, while also randomly generating new platforms that smoothly enter the world from the top of the screen.
1.3 Level-0 Description & Top Level Design 
1.3.1 Top Level Design

















## 1.3.2 Level-0 Description

### External I/O Signals  
[in = input to the custom hardware; out = output from the custom hardware]

| Signal | Description |
|---|---|
| NES_data(in) | Button data received from the NES controller |
| NES_latch(out) | Tell the NES controller when to latch the button states |
| NES_clk(out) | Synchronize the serial data being shifted out of the NES controller |
| FlagQ(out) | Used to notify the MicroBlaze when a frame is complete |
| Tmds/tmdsb | Transmit HDMI video data to the monitor |
| ac_mclk, ac_adc_sdata, ac_dac_sdata, ac_bclk, ac_lrclk, scl, sda | Signals used for communication between the FPGA and the audio codec for audio synchronization, audio data transfer, and codec configuration |

### MicroBlaze Registers
[in = read; out = write]
Signal	Direction	Register/Bits	Description

| Audio_type | out | slv_reg0[4:0] | Communicates the audio type to the custom hardware |
| Audio_playRequest | out | slv_reg1[0] | Requests audio playback from the custom hardware |
| sprite_row | out | slv_reg2[9:0] | Sends the sprite top-left y-coordinate for screen rendering |
| Sprite_col | out | slv_reg3[9:0] | Sends the sprite top-left x-coordinate for screen rendering |
| sprite_type | out | slv_reg4[4:0] | Send the sprite type to be drawn |
| sprite_active | out | slv_reg4[5] | Indicates whether the current sprite is active |
| WrAddr | out | slv_reg5[4:0] | Determines the write address into the 1-D sprite array stored in the custom hardware |
| NES_Scan | in | slv_reg6[7:0] | Receives the decoded user input from the NES controller |
| flagClear | out | slv_reg7[0] | Clear the flag after the interrupt is triggered |
| Wen | out | slv_reg8[0] | Enables writing into the 1-D sprite array stored in the custom hardware |
| score | out | slv_reg9[16:0] | Communicate the current game score |


# 2 Plan
## 2.2.1 Level-1 Design
This section describes the subsystems and modules included in the final project. More specifically, it explains how each module contributes to the overall functionality of the system while also including datapath and finite state machine (FSM) diagrams for visualization. It also includes the game logic FSM implemented in C on the MicroBlaze processor. Additionally, this section demonstrates the data communicated between the MicroBlaze and the custom hardware and provides an explanation for the three main subsystems in the custom hardware: doodle_audio, NES_controller, and the graphics datapath.
### Game Logic
#### 1-	FSM

#### 2-	Description:
##### Wait For Start State: 
In this state: 
•	The screen is initialized 
•	The “play” sprite is drawn in the middle of the screen
•	The game waits for the user to press the “start” button on the NES controller
 Once the user presses “Start,” the FSM transfers to the Doodle Up state.
##### Doodle Up State
In this state, 
•	The doodle moves upward.
•	A gravity constant updates the doodle velocity
When the doodle reaches the middle of the screen:
•	The world begins shifting downward instead of continuing to move the doodle upward. 
•	All sprites are shifted downward to create the illusion that the doodle is climbing upward.
•	The sprites leaving the bottom of the screen are repositioned above the screen to renter the world smoothly
When the doodle velocity becomes less than zero, the FSM transfers to the Doodle Down state.
##### Doodle Down State
In this state, the doodle falls downward due to gravity. The FSM checks for the following conditions: 
•	Grown or Blue Beam Collision: if the doodle collides with green or blue beams, its velocity is reinitialized to -400, and the doodle transfers back to the Doodle Up State. 
•	Brown beam Collision: If the doodle collides with a brown beam, the beam breaks and the doodle continue moving downard
•	Game over: The game continuously checks the doodle row position. If it moves past 480, the user loses and the FSM transfers to the Game Over state. 
##### Game Over State
In this state, 
•	The “Game Over” sprite enters from the bottom of the screen
•	and moves upward until it reaches the middle of the screen.
Once it arrives, the FSM transfers to Wait for Restart state. 
##### Wait for Restart State
In this state:
•	the game waits for the user to press the “Start” button again. 
•	Once “Start” is pressed, the FSM resets the gameplay variables, and transfers back to the Doodle Up state

### Final-Project Custom Hardware Data Path

### 1-	NES Controller
The NES Controller submodule constantly receive and processes inputs from the NES Controller, while also sending the processed data to the MicroBlaze for further use. This module is required because it captures the user input from the buttons and sends this data to the MicroBlaze. The MicroBlaze then process this data and determines whether the doodle should move to the right or left. It is further broken into two main modules: NES Control Unit, and NES Data Path
####	NES Control Unit
##### FSM



















The FSM starts by pulling the NES Controller latch high. This causes the controller to latch the current button states. It then performs the following loop:
-	Read the 1-bit data sent from the NES Controller.
-	Drives the clock high so the NES Controller sends the next bit. 
-	Increment the counter (which tells the system how many bits have been received)
-	Check the counter to determine if all the data has been received. 
-	If all data is received, it stores the output and pull the latch high again. Otherwise, repeat the loop.
The system receives 8 bits total, corresponding to the current state of the controller buttons.
Two bits are used in the status word:
•	Sw(0) notifies the control unit when the data path has received all data from the current sample.
•	 sw(1) notifies the control unit when the delay counter is finished.
The control word is shown in figure 3:
•	cw(0:1) controls the read counter
•	cw(2:3) controls the delay counter. A 10 microseconds delay is applied after toggling latch or clock signals to ensure stable data.
•	cw(4) commands the Datapath to read the 1-bit input into a shift register. 
•	cw(5) controls the clock signal sent to the controller.
•	cw(6) controls the latch signal.
•	 cw(7) stores the final data and updates it in the MicroBlaze
####	NES Data Path
The NES Data Path executes the operation commanded by the controller FSM. It sends the latch and the clock signal to the NES controller at the appropriate states and stores incoming data into a shift register by shifting bits into the MSB.
It also includes two counters:
•	A read counter that tracks how many bits have been read.
•	 A delay counter that implements a 10-microsecond delay. 
### 2-	Doodle Audio
The doodle audio submodule is responsible for producing three main sounds: 
•	Collision with a platform.
•	 Collision with a spring.
•	 Game over.
It receives an audio request from the MicroBlaze along with audio type. The audio samples are stored in BRAMs as 16-bit raw data sampled at 48 kHz. 
It’s further broken into three modules:
•	Audio Codec Wrapper.
•	Audio Codec Control Unit.
•	Audio Codec Data Path. 

####	Audio Codec Control Unit
##### FSM
This module includes FSM. A hand drawn FSM is shown in figure 4. 










The FSM starts in the idle state until an audio request is received from the MicroBlaze. It then transfers to the load sound state, where configurations are set, such as resetting the sample index and loading the audio size. Next, the FSM waits for the audio codec to be ready to process new samples. Once ready, it:
•	increments sample index, used to read the correct BRAM address 
•	checks if the full audio has been played. If the playback is completed, it returns back to idle; Otherwise, it repeats the loop. 

The FSM uses 3-bit status word:
•	Sw(0) Audio codec ready signal.
•	Sw(1) Audio request from MicroBlaze.
•	Sw(2) Audio playback complete.
It also uses 2-bit control word: 
•	Cw(0) Indicates audio is in progress.
•	cw(1) Increments sample index.
The control word output table is shown in figure 5









####	Audio Codec Data Path
The data path retrieves the correct audio sample from the pre-loaded BRAMs, based on the current sample index, and sends it to the audio codec. 
####	Read From Bram
This module helps retrieves the audio samples from the BRAMs. It contains 47 BRAMs storing the 16-bit samples at 48 kHz. It takes
•	Audio_type: selects which audio to play.
•	Is_playing:  indicates if audio is still active.
•	Sample_index: determines which sample to output. 
Since each BRAM stores 2048 samples: 
•	Sample_index / 2048: selects the correct BRAM.
•	Sample_index mod 2048: selects the local address within the BRAM.
It the playback is complete, indicated by comparing the sample index against the audio size, the output is (others => ‘0’), meaning silence.


####	Audio Codec Wrapper
The audio codec wrapper takes the selected sample and outputs it through the audio codex. 
### 3-	Graphics Data Path
The graphics data path is responsible for rendering graphics on the screen; both background and the game sprites. The main challenge of this module is to determine whether the current pixel belongs to a sprite or background. If it belongs to a sprite, the system determines which pixel within the sprite to draw based on the current row and column. This is done using the pixel classifier and scope face submodules. 
####	Pixel classifier
This receives the current row and column from the vga. It also receives a 32-sprite status array. Each array element includes: 
•	X & Y coordinates (top-left corner): received from the Micro Blaze.
•	Sprite type: including doodle, spring, green and blue platforms, etc.
•	Active flag: a 1-bit signal indicating whether the sprite should be rendered on the screen
The classifier loops through all sprites and determines whether the current pixel lies within any sprite’s boundaries. If not, it outputs a background pixel type.  
####	ScopeFace
The scope face determines the RGB values of the current pixel. It:
•	stores the sprite pixel data in separate 2-d arrays. 
•	Receives the current pixel type from the pixel classifier.
•	  Computes the offset from the sprite’s top-left corner 
•	Outputs the RGB value based on the offset

## 2.3	 Calculations/Analysis/Drawings
### 1-	Curren pixel:
To determine which pixel within the sprite is drawn:
•	Local row = row – y
•	Local col = col – x
Where row and column are the top left corner coordinates stored in the sprite status array. The local row and col used to index into sprite pixel arrays stored in the ScopeFace
### 2-	BRAM Access: 
In the audio codec module, the sample index determines both which BRAM to use and the local address within the BRAM:
2	local_address <= sample_index(10 downto 0): equivalenet to sample index mod 2048. 
3	BRAM_selection <= sample_index(16 downto 11): equivalent to sample index / 2048. 
### 2.5 Milestone I
All custom hardware will be implemented, including the NES Controller, graphics data path and audio codec. This will be tested using an FSM implemented in VHDL, which acts as a MicroBlaze. 
The NES Controller shall:
•	Interface with the NES Controller via GPIO pins. 
•	Receive button states from the NES Controller.
•	send the latch and clock signals to the NES Controller. 
•	Output data to LEDs for verification.
The audio codec shall:
•	Receives audio play request and type from the FSM. 
-	Read from the pre-loaded BRAMs
-	Output sound to speaker. 
The graphics data path shall: 
•	Receives sprite data from the FSM.
•	Determine pixel type
•	Render it to the screen 
## 2.6	 Milestone II
The custom hardware shall interface with MicroBlaze processer, and send data through 32*32 slave registers. Game logic shall be implemented in C, which includes the following:
•	Determines the doodle movement
•	Determines the world shifting
•	Implements a collision detection and play the correct audio accordingly
•	Sprite positioning on the screen
•	Reposition sprites above the screen when the world shifts down. They should re-enter the screen smoothly from the top. 
## 2.7 Updated Functionality and Requirements
### Minimum functionality:
To achieve minimum level functionality, the system shall:
1-	Implement graphics Datapath module responsible for rendering the game background and sprites. 
2-	Implement graphics control unit that controls the graphics data path. This module will initially be used for testing purposes to verify the custom hardware functionality. It will be replaced later by the micro blaze
3-	Render sprites on the screen based on the x and y coordinates passed to the graphics Datapath from the graphics control unit. 
4-	Implement a flag register that triggers whenever the graphics datapath finishes rendering a video frame. This flag will later be used as an interrupt signal for the MicroBlaze processor.
5-	Implement the Doodle Audio module to output the game audio through the audio_codec wrapper. The module outputs audio based on an audio type signal received from the micro blaze. For minimum level functionality, this signal will be generated by the graphics control unit instead of the MicroBlaze.

### B-Level Functionality
To achieve B-Level functionality, the system shall:
1-	Implement an NES controller module capable of interpreting signals sent from the NES controller. Functionality will initially be verified by outputting the interpreted button states to the LEDs. 
2-	Integrate the NES controller, doodle_audio, and graphics data path into a single top level module named “final_project”
3-	Package the final_project module as a custom AXI IP with 32 slave registers. This allows the custom hardware to communicate with the MicroBlaze processor through memory-mapped addresses.
4-	Create a block design that incorporates the custom IP, MicroBlaze, AXI infrastructure required for communication, UART, and DDR3 memory. 
5-	Connect the flag register to the micro blaze interrupt.
6-	Generate the bit stream and export the hardware platform to Vitis. 
7-	Ensure that the micro blaze is successfully communicating with the custom hardware through C code. This can be accomplished through the following incremental tests:
a.	Print a message to UART when the interrupt is triggered. 
b.	Render sprites on the screen through C code by sending the sprites coordinates and type through the slave registers to the custom hardware.
c.	Outputs game audio through C code by sending the audio type to the custom hardware
### A-Level Functionality
A-level functionality will include minimum functionality, B-functionality as well as game logic implemented in C. To achieve A-level functionality, the system shall:
1-	Renders the game’s initial screen. 
2-	Wait for the user to press the “start” button on the NES controller.
3-	Move the doodle horizontally using the NES controller input. 
4-	Implement a gravity-based system that controls the doodle velocity and acceleration
5-	Implement a collision detection to determine when jumps should occur.
6-	Output game audio, including collision and game over sounds.
7-	Implement world scrolling by shifting the world downward once the doodle reaches the midpoint of the screen.
8-	Render the current game score in the top left corner f the screen
9-	Detects when the user loses.

# 3  Milestone I
All deliverable obligations for milestone I were successfully accomplished. The system reads data from the NES controller and outputs the button states to the LEDs. Additionally, the system outputs game audio through speakers and renders sprites at the correct positions on the screen

# 4	Milestone II
All deliverable obligations for milestone II were successfully accomplished. The game custom hardware interfaced with the micro blaze through the AXI communication protocol. The bit stream was generated, and the hardware platform was exported to Vitis. Game logic was implemented in C; and included collision detection, sprite rendering, game audio playback, and vertical scrolling. 

# 5	Final Demonstration and Test Results
The final system successfully implemented a playable version of doodle jump game on the Nexys Video board. The system integrated custom hardware, the MicroBlaze processor, NES controller, graphics and audio playback. 
Overall, the system achieved A-level functionality. The custom hardware correctly rendered graphics on the screen, generated audio playback, and read user inputs from the NES controller. After interfacing the custom hardware with the MicroBlaze, the required game logic was successfully implemented in C.  
During the final demonstration: 
1-	The game sprites and background rendered correctly on the screen. 
2-	The NES controller controlled the doodle movement.
3-	Audio playback was generated correctly during collision and game over events 
4-	The Game over state correctly triggered when the doodle touched the bottom of the screen.
5-	The user was able to restart the game by pressing the “Start” button on the NES controller
6-	The score updated correctly throughout the game. 
7-	The movements of both the scrolling world and the doodle appeared smooth during the game play


# Appendix A: Running the Project
1-	Connect the NES controller to the Nexys Video board. 
2-	Connect an HDMI monitor to the HDMI out port on the board. 
3-	Connect a speaker to the audio output jack. 
4-	Open the application project in Vitis. 
5-	Hit run and you should be able to play the game. 
If another students wishes to build on my project by modifying the custom hardware, here is what you could do:
1-	Open my git hub repository: mohamedmetwally123/ece383_wksp
2-	Download the Doodle_Jump File. 
3-	Open doodle_jump.xpr
4-	You should now see the entire block design. Right click on the final project IP component and click “Edit in IP Packager”. 
5-	After you make the necessary changes, repackage the IP.
6-	Make sure to refresh the IP repo. Afterwards, generate the bit stream. 
7-	If it’s generated successfully, click “files”, export hardware. 
8-	In Vitis, click “File” -> “New” -> “Application project”. Once you have created the application project (see ICE 3 - Microblaze Interrupts - Part 2 for more setup details), you’ll need to copy and paste the C code in my git hub repo. 
