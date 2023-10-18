<h1 align="center">RTL to GDSII using SKY130nm Technology node</h1>

<h1 align="center">Integrated Clock Gating (ICG) Design</h1>

## TABLE OF CONTENT

I. [**Introduction to Integrated Clock Gating**](https://github.com/drvasanthi/iiitb_cg/blob/main/README.md#introduction)    

II. [**RTL Design and Synthesis**](https://github.com/drvasanthi/iiitb_cg#ii-rtl-design-and-synthesis)  
  1. [Icarus Verilog (iverilog) & Yosys Installation on Ubuntu](https://github.com/drvasanthi/iiitb_cg#1-icarus-verilog-iverilog--yosys-installation-on-ubuntu)  
  2. [RTL Pre-Simulation](https://github.com/drvasanthi/iiitb_cg#rtl-pre-simulation)  
  3. [Synthesis](https://github.com/drvasanthi/iiitb_cg#icg---synthesis)  
  4. [GLS Post-simulation](https://github.com/drvasanthi/iiitb_cg#gls-post-simulation)  

## **I. Introduction**

The project design is based on Integrated Clock Gating using SKY 130nm technology node. 

  In current VLSI design, the power dissipation is the most important parameter that signifies the need of low power circuits. In most of the ICs clock consumes 30-40 % of total power. So the integrated clock gating logic is used in many synchronous circuits for reducing dynamic power dissipation, by removing the clock signal when the circuit is not in use. 

**Block Diagram and Circuit Diagram**

![blockdiagram](https://user-images.githubusercontent.com/67214592/183288720-9af6827a-cbfa-4f47-8b24-2172c4f7ea01.PNG)

Clock gating is a prevailing technique for lowering clock power is done with help of clock enable signal by powering off the module by a clock. Clock gating functionally requires only an AND gate. The former using of AND gate with clock, the high EN edge may arrive at any time and may not coincide with a clock edge. In that case the output of the AND gate will be a logic ‘1’ for less time than the clock’s duty cycle, in turn end up with a glitch in the clock signal.
To avoid this, a special kind of clock gating cells are used, that synchronizes the EN with a clock edge. These are called as integrated clock gating cells or ICG. In the design gclk is available only when the latch output is high and gclk is held low when en is low as shown in the circuit diagram. Therefore, target the design very close by meeting the PPA (Power, Performance, Area).

![circuitdiagram](https://user-images.githubusercontent.com/67214592/183288729-cf1af368-8624-45e7-b864-e66ad3e6ef99.PNG)

## **II. RTL Design and Synthesis**

### **1. Icarus Verilog (iverilog) & Yosys Installation on Ubuntu**
  //_Icarus Verilog is an open-source EDA tool for implementing verilog hardware description language_//
  
 In the context menu, right click on an empty space, you’ll see the option of ‘Open in Terminal’
 
  * Type the following command to install `iverilog & gtkwave`
 ```
$ sudo apt-get update

$ sudo apt-get install iverilog gtkwave
 ```
 
  * Type the following command to install `yosys`
 ```
 $ git clone https://github.com/YosysHQ/yosys.git
 
 $ sudo apt install make
 
 $ sudo apt-get install build-essential clang bison flex \
	libreadline-dev gawk tcl-dev libffi-dev git \
	graphviz xdot pkg-config python3 libboost-system-dev \
	libboost-python-dev libboost-filesystem-dev zlib1g-dev
  
 $ sudo make install

 ```
 
## RTL Pre-Simulation

1. To clone the Repository, type the following commands in your terminal.

```html
$ git clone https://github.com/drvasanthi/iiitb_cg

$ cd /home/vasanthidr11/Desktop/iiitb_cg/
```

2. To Run the .v file, type the following commands

```html
$ iverilog iiitb_icg.v iiitb_icg_tb.v

$ ./a.out
$VCD info: dumpfile iiitb_icg_tb.vcd opened for output.

$ gtkwave iiitb_icg_tb
```
![Screenshot from 2023-10-18 01-11-30](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/c00c42f4-2304-4afa-a20b-881db83cfcf5)

## ICG - Synthesis

1. Invoke the yosys using following commands


```
// reads the library file from sky130//

yosys> read_liberty -lib ../lib/sky130_fd_sc_hd__tt_025C_1v80.lib
```
![Screenshot from 2023-10-17 23-53-39](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/34f8bcb8-ab8f-454d-8a9e-28227b270f0d)

```
// reads the verilog files//

yosys> read_verilog iiitb_icg.v dff.v
```

```
//synthesize the top module of verilog file//  

yosys> synth -top iiitb_icg
```

```
//map the FF library file//

yosys> dfflibmap -liberty ../lib/sky130_fd_sc_hd__tt_025C_1v80.lib

```

```
//Generates netlist//

yosys> abc -liberty ../lib/sky130_fd_sc_hd__tt_025C_1v80.lib
yosys> stat
```
![Screenshot from 2023-10-17 23-58-13](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/bfe07d99-9cba-4e59-a924-60e0ea02292b)
![Screenshot from 2023-10-17 23-58-32](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/da0afeb5-8e69-4bdf-9d19-6473dd596448)

```
//Simplified netlist//

yosys> flatten
```

```
//Displays the Netlist circuit//

yosys> show
```

**Synthesized Circuit**

![Screenshot from 2023-10-17 23-50-29](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/22b4d079-1ab8-4d32-9d8c-2bca16344016)

```
//Writing Netlist//

yosys> write_verilog -noattr iiitb_icg_netlist.v
yosys> stat
```
![Screenshot from 2023-10-17 23-58-54](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/c2b7ffc1-d218-4490-9288-28a5435f4c33)

```
//Simplified Netlist - As code dwells with additional switch//

yosys> !gvim iiitb_icg_netlist.v
```

## GLS Post-Simulation

Commands to Invoke GLS

```
$ iverilog -DFUNCTIONAL -DUNIT_DELAY=#1 ../verilog_model/primitives.v ../verilog_model/sky130_fd_sc_hd.v iiitb_icg_synth.v iiitb_icg_tb.v
$ ./a.out
$ gtkwave pes.icg_tb.v
```

**Gate Level Simulation**

![Screenshot from 2023-10-17 23-43-27](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/b6c27e18-17a0-4ba2-9ae1-c54b2fa3e255)
