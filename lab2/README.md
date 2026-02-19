# Lab 2: VGA Synchronization

## Introduction:
The main goal of this lab is to integrate the video display controller module with the audo codec on the Nexys video board to read the incoming audio signal, digitilize it, and prints its waveform on the monitor. To do that, the signal passes through 
multiple interfaces. The input signal is passed through the Audio Codec interface, which digitize the signal into seperate 18-bit 2's complement. This audio sample is passed through sign2unsigned component, which shifts them upward so
they become positive and suitable for display and storage. The values coming out of the sign2unsigned component are stored in the BRAM, which is later grabbed by the video module and displayed on the screen. Additionally, a trigger voltage is implemented, 
which tells the system when to start capturing samples. This helps in displaying a stable waveform on the screen. The point at which the waverform intersects the left edge of the grid should changing by changing the position of the trigger. 
## Design Implementation: when 

### Block Diagram (Figure 1):
![Screenshot](images/Lab2_BlockDiagram.jpg)
The block diagram includes both the data path and the control unit. The flow in the diagram is as follows:
1- Audio_Codec_Wrapper receives audio signals from the blue line-in jack port. When data is ready, the ready signal goes high for a single clock cycle.
2- The system then checks for rising edge triggering, which means that it waits until the voltage crosses the trigger going upward. 
3- Afterwards, the audio samples are stored in the BRAM. 
4- We use a counter to store the audio samples at different addresses in the BRAM. The counter counts from 20 (First colum in the grid) up to 420(Last column in the grid)
5- The video module sends the column of the current pixel being displayed on the screen to the BRAM. The BRAM responds with the row value where the output signal should be displayed. If the response is equal to the row value of the pixel being displayed on the screen, the video module displays this pixel with the corresponding channel color. 
6- This cycle repeats every video frame.

### Finite State Machine(Figure 2):
![Screenshot](images/Lab2_cu.png)
The FSM represents the control unit in lab 2. In each video frame, The Wait_For_Trigger state waits for the voltage to cross the trigger volt upward. This is signaled by sw[2], which is tied directly to the output of the trigger_detector component. Upon detection, the Reset_Counter state resets the counter to the first column in our grid(20). This is down by setting cw(1 downto 0) <= "10". Afterwards, the system transitions to Wait_For_Ready state, where it waits until the converted data from the audio_codec is ready. This is signaled by sw[0], which is connected to the ready flag output from the audio_codec. Then, the system moves to the save_sample state, where the control unit infroms the data path that this is the time to store our sample in the BRAM. Then, the counter counts up, which moves the write address in the BRAM to the next memory location. If the system reached the last column in the grid(420), it transitions back to the Wait_For_Trigger, and repeats. Otherwise, it jumps back to the Wait_For_Ready state. 

### Output Equation Table(Figure 3):
![Screenshot](images/Output_EquationTable.png)
This screenshot shows the output of cw(2 downto 0). cw(1 downto 0) controls the counter, while cw(2) controls when the BRAM should store the audio samples. 
Counter:
	00 -> Hold
	01 -> Count Up
	11 -> Reset
	10 -> Load D (In this case, D = 20)


### Components: 
#### 1- BRAM_Counter:
This is a counter module built in previous labs. It counts form 20(beginning column) up unti 420(End column). In the datapath, the counter is used to control the write address of the BRAM. The FSM controls the states of the counter, including when to count up, hold, or reset. 

#### Inputs/outputs:
		clk     : Synchronizes the whole system
		reset   : Resets the counter
		ctrl    : controls the state of the counter
		00      -> Hold
		01      -> Count Up
		11      -> Reset
		10      -> Load D (In this case, D = 20)

		D       : The value loaded into the counter when ctrl => "10". 
		Q       : The output of the counter. In our case, the output is tied to the write address of the BRAM. 

#### 2- Flag Resister: 
The flag resgister will be used as a way of communication between lab2 components and the MicroBlaze processor in later labs. The lab2 will produce some data, put it on a data line to the MicroBlaze, and set the flag register using the READY signal . At some point, the MicroBlaze will read the data, and clear the bit. 

![Screenshot](images/FlagRegister_I&O_Table.png)



#### 3- : trigger_detector
The trigger detector watches the voltage and determine whether it has crossed the trigger volt value. It's instantiated in the datapath, enabling the system to capture and store audio samples that are above a certain threshold. It does so by comparing the previous and current sample to the threshold. If the previous sample is below the threshold while the current sample is above the threshold, the signal has crossed the trigger level, and systems begins capturing samples. This is used in the datapath to ensure a stable output signal on the screen

#### Inputs/outputs:
        clk              : Synchronizes the whole system
        reset_n          : Resets the register that is used to hold the previous value captured
        threshold        : The trigger level. The monitored signal and the previos signal are compared against this value to determine if the signal has crossed the trigger level
        ready            : Indicates that a new audio sample is ready. This port is tied to the ready signal coming out of the audio_codec
        monitored_signal : The current audio sample. 
        crossed_trigger  : Output a signal that notifies the control unit when the signal has crossed the trigger level


## Test/Debug:
In this lab, the instructor test benches and visual observation were primarily used to test/debug our VHDL design. 

### Counter Module
The first problem encountered was in the counter module. First, the counter rollover was off by one(It rolls over at max_value instead of max_value – 1). Second, the row counter was delayed by one clock cycle relative to the roll over for the col counter. We fixed these issues using a comprehensive test bench that tested the design against all the edge cases. After fixing these issues, the following waveforms were generated. 


This screenshot shows the col counter rolling back to zero after reaching its maximum value(Figure 3)

![Screenshot](images/col_rollover%20&%20row_increment.png)

This screenshot shows the row counter rolling back to zero after reaching its maximum value and at the same clock cycle that col counter rolls over: (Figure 4)
![Screenshot](images/row_rollover.png)

### vga_signal_generator
Next, the provided test bench was used to test the output of the vga_signal_generator. This test bench was mainly used to test the proper transitions of hsync, vsync, and blank signals. The following waveforms were generated: 

Blank going high after the last column in the grid: (Figure 5) 

![Screenshot](images/blank_go_high_with_last_col.png)

Blank goes low with the first column in the grid. (Figure 6)

![Screenshot](images/blank_go_low_with_first_col.png)

H_sync goes high at the correct col number (Figure 7)

![Screenshot](images/h_sync_go_high.png)

H_sync goes low at the correct col number (Figure 8)

![Screenshot](images/h_sync_go_low.png)

Vsync goes low at the correct row number (Figure 9)

![Screenshot](images/v_sync_go_low.png)

Vsync goes high at the correct row number (Figure 10)

![Screenshot](images/v_sync_go_up.png)

### Oscilliscope Visualization
Afterwards, The  provided test bench to generate a log file that can be used to visualize what the output would look like on the screen. This helped verify the behavior of our color mapper and vga_signal_generator, allowing us to fix small bugs early  without testing directly on the hardware. The generated display from the website is provided below: 
(Figure 11)
![Screenshot](images/Generated_Oscilliscope.png)

### numeric_stepper
The last component tested was the numeric_stepper. This was done using visual observation after implementing the design on the FPGA board. The triggers were tested by observing how they are being displayed at the corners of the grid. Visual observation was also used to ensure there are no debouncing issues. 

## Results:
All the lab objectives were met. The following section summarizes the results, including the date and time achieved, the level of achievement, and the evidence used to verify functionality. 

### CG1
Completed in Lesson 6. Implemented both row and col counter using the counter module developed in previous homeworks. The required functionality of the counters was verified, including the correct rollover behavior of both counters, and that col counter roll over increments the row counter. Evidence for correct functionality are provided in figure 3 and 4 of the test/debug section.

### GC2
Completed in Lesson 7. Implemented the vga_signal_generator and the color mapper. For the color mapper, the correct transition for vsync, hsync, and blank were verified. This was evident in figure 5 through 10 provided in the test/debug section.
 The color mapper along with the vga_signal_generator were verified that function properly by submitting the log_file generated by the instructor_tb to an online website. The corrected output was displayed, as shown in figure 11. 

### Oscilliscope display using physical hardware
Completed in Lesson 8. The oscilloscope grid, hash marks, triggers, and channel signals were successfully displayed. The channels' visibility were controlled using switches 0 and 1. The triggers were successfully controlled using the physical buttons on the boards, while ensuring that they remain within the grid boundaries. This was verified by a live demo to myself. 


## Conclusion: 
This lab builds the foundation of how video system design works. One big takeaway was the importance of modular design. Separating the system into submodules made it much easier to test/debug each component separately well before system integration. For future iterations of the lab, the provided submodules were organized and the instructor test benches were very helpful in validating each submodule. I would recommend giving some guidance on how the arrows should be drawn, as this aspect was challenging for most of us.   

