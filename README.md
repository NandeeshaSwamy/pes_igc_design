<h1 align="center">RTL to GDSII using SKY130nm Technology node</h1>

<h1 align="center">Integrated Clock Gating (ICG) Design</h1>


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

## **III. Physical Design from Netlist to GDSII**

Physical design is process of transforming netlist into layout which is manufacture-able [GDS]. Physical design process is often referred as PnR (Place and Route). Main steps in physical design are placement of all logical cells, clock tree synthesis & routing. During this process of physical design timing, power, design & technology constraints have to be met. Further design might require being optimized w.r.t power, performance and area.

### **1. Installation of ngspice magic and OpenLane**

**ngspice**
- Download the tarball from https://sourceforge.net/projects/ngspice/files/ to a local directory
```
cd $HOME
sudo apt-get install libxaw7-dev
tar -zxvf ngspice-41.tar.gz
cd ngspice-41
mkdir release
cd release
../configure  --with-x --with-readline=yes --disable-debug
sudo make
sudo make install
```

**magic**
```
sudo apt-get install m4
sudo apt-get install tcsh
sudo apt-get install csh
sudo apt-get install libx11-dev
sudo apt-get install tcl-dev tk-dev
sudo apt-get install libcairo2-dev
sudo apt-get install mesa-common-dev libglu1-mesa-dev
sudo apt-get install libncurses-dev
git clone https://github.com/RTimothyEdwards/magic
cd magic
./configure
sudo make
sudo make install
```

**OpenLANE**
```
sudo apt-get update
sudo apt-get upgrade
sudo apt install -y build-essential python3 python3-venv python3-pip make git

sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io
sudo docker run hello-world
sudo groupadd docker
sudo usermod -aG docker $USER
sudo reboot 
# After reboot
docker run hello-world (should show you the output under 'Example Output' in https://hub.docker.com/_/hello-world)

- To install the PDKs and Tools
cd $HOME
git clone https://github.com/The-OpenROAD-Project/OpenLane
cd OpenLane
make
make test
```

### **2. Invoke Openlane and prepare design**

> Step1: To start openlane, we open the shell in openLANE_flow(openlane) directory and run the command,

  ![Screenshot from 2023-11-04 15-43-43](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/c6078e29-9c16-4cba-aa28-348e8aee03fd)

  
> Step 2:Import openlane packages specifying its version and specify the design that we intend to work on, which is iiitb_icg

![Screenshot from 2023-11-04 16-21-09](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/2119109c-e31b-469c-b5bd-dc7c87aab53b)

> Step 3: Prepare design

![Screenshot from 2023-11-04 16-21-20](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/6ca40bf8-4d79-49e4-8dde-1a82489c867d)

> Step 4: Include the below command to include the additional lef into the flow:

![Screenshot from 2023-11-04 16-27-09](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/4c9e35f1-7876-4aed-bef2-47b997db2f09)

This command merges two lefs and places it in a new folder which is named as date and time while running the command, inside directory designs/iiitb_icg/runs/.

### **3. Synthesis**

Synthesis is process of converting RTL (Synthesizable Verilog code) to technology specific gate level netlist (includes nets, sequential and combinational cells and their connectivity).

![Screenshot from 2023-11-04 16-28-15](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/174236f2-115d-498f-8bcf-488f4005e47e)

Synthesis report

![Screenshot from 2023-11-05 00-00-30](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/68ac4ca2-9767-45c4-8c63-d6c394d8e675)

### **4. Floorplan**

![Screenshot from 2023-11-04 16-29-54](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/b046b61a-bb89-4bcb-a9be-2aa15863d5fc)

```
magic -T /home/my_ubuntu/OpenLane/vsdstdcelldesign/libs/sky130A.tech lef read /home/my_ubuntu/OpenLane/pes_icg/runs/RUN_2023.11.04_13.18.22/tmp/merged.max.lef def pes_icg.def &
```
![Screenshot from 2023-11-05 01-30-28](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/2ad821ce-9022-4b43-a3dd-6f5b2f3253dd)

![Screenshot from 2023-11-05 00-58-27](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/5f127518-5856-4ed7-a9b7-4d69d273dfee)

![Screenshot from 2023-11-05 00-59-57](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/b7e1980d-c5d3-47bf-aabc-22858fb05131)

### **5. Placement**

![Screenshot from 2023-11-04 18-51-35](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/e9fbbe2e-ae6d-40c1-8e8c-2ef8fd72830a)

```
magic -T /home/my_ubuntu/OpenLane/vsdstdcelldesign/libs/sky130A.tech lef read /home/my_ubuntu/OpenLane/pes_icg/runs/RUN_2023.11.04_13.18.22/tmp/merged.max.lef def pes_icg.def &
```
![Screenshot from 2023-11-05 01-30-49](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/0e3be562-fa01-46af-99b0-18fe019f5f1a)

![Screenshot from 2023-11-05 01-18-58](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/69693175-ab4f-45ca-b75f-d8415743d5f3)

![Screenshot from 2023-11-05 01-18-35](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/17a11280-d084-44cb-9820-2decf0016936)

![Screenshot from 2023-11-05 01-23-41](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/d9b49664-3729-48d1-84a1-989ac48748f1)

### **6. CTS**

![Screenshot from 2023-11-04 18-53-43](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/9569f3fb-68db-466a-8148-7121e6699568)

#### **Reports Generated**

![Screenshot from 2023-11-05 01-57-07](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/ddac2bac-5e28-4be1-898d-61c272602f9f)

![Screenshot from 2023-11-05 01-48-36](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/6f968405-81ab-4ef4-828a-418544396d43)

![Screenshot from 2023-11-05 01-52-14](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/b476e950-53ec-4771-9e6b-c57e1e58cec4)

![Screenshot from 2023-11-05 01-53-39](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/9fdef679-18e8-43fd-8741-7f63dfef77d9)

#### **Power Report**

![Screenshot from 2023-11-05 01-55-01](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/3695a8df-4b56-43d5-8bf5-7db3d0a2cf62)

#### **Skew Report**

![Screenshot from 2023-11-05 01-55-25](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/9951a358-674f-479a-9d19-eebabd7c6f4c)

### **Summary report**

![Screenshot from 2023-11-05 01-56-13](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/e744371b-fee8-4843-8bf4-926dccc67beb)

#### **Area Report**

![Screenshot from 2023-11-05 01-56-30](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/3d355344-ef76-4db8-8454-478d98d17e43)

### **7. Routing**

![Screenshot from 2023-11-04 18-55-16](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/956febf4-b967-4e69-9590-a73c669f887b)

```
magic -T /home/my_ubuntu/OpenLane/vsdstdcelldesign/libs/sky130A.tech lef read /home/my_ubuntu/OpenLane/pes_icg/runs/RUN_2023.11.04_13.18.22/tmp/merged.max.lef def pes_icg.def &
```
![Screenshot from 2023-11-05 01-31-10](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/d644f3fc-c03b-44ef-bdb0-2b78d204e597)

![Screenshot from 2023-11-05 01-19-47](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/1305e4a8-c8c5-4282-9ad7-8911e1f8121b)

![Screenshot from 2023-11-05 01-20-08](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/81b1b01d-021d-4284-8ada-ca6b8a983b6d)

![Screenshot from 2023-11-05 01-22-19](https://github.com/NandeeshaSwamy/pes_igc_design/assets/135755149/cdec18c3-18a9-4a98-b04e-969aee0e72c8)
