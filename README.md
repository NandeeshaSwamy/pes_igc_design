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
  
  ![image](https://user-images.githubusercontent.com/67214592/187149282-80b98d3c-82d2-40b6-a752-f02be949f654.png)
  
> Step 2:Import openlane packages specifying its version and specify the design that we intend to work on, which is iiitb_icg
  
  ![pack and prep](https://user-images.githubusercontent.com/67214592/186325966-6d4f1763-9e81-469b-8054-e1b075e11b87.PNG)

> Step 3: Include the below command to include the additional lef into the flow:
  
  ![image](https://user-images.githubusercontent.com/67214592/187150066-0151166f-aa7f-4f3b-a766-41ba1b18122c.png)

This command merges two lefs and places it in a new folder which is named as date and time while running the command, inside directory designs/iiitb_icg/runs/.

### **3. Synthesis**

Synthesis is process of converting RTL (Synthesizable Verilog code) to technology specific gate level netlist (includes nets, sequential and combinational cells and their connectivity).

![Screenshot from 2023-11-03 12-59-04](https://github.com/PoojaR07/pes_lifo_buffer/assets/135737910/ade10fd3-09bb-4b9e-bfbf-aba48c41d906)

Synthesis report


![Screenshot from 2023-11-03 14-39-23](https://github.com/PoojaR07/pes_lifo_buffer/assets/135737910/e644eb2f-2a56-40b2-afc6-d8701c291951)

### **4. Floorplan**

![Screenshot from 2023-11-03 12-59-24](https://github.com/PoojaR07/pes_lifo_buffer/assets/135737910/17c94031-0316-479a-9633-0a312b04a978)

```
$ magic -T /home/poojar/OpenLane/vsdstdcelldesign/libs/sky130A.tech lef read /home/poojar/OpenLane/LIFO/runs/RUN_2023.11.03_07.14.55/tmp/merged.max.lef def lifo.def &
```
![Screenshot from 2023-11-03 13-04-15](https://github.com/PoojaR07/pes_lifo_buffer/assets/135737910/6eb03eea-0ec8-491c-a39c-1d8ad2e2b88a)

![Screenshot from 2023-11-03 13-04-37](https://github.com/PoojaR07/pes_lifo_buffer/assets/135737910/4e37b749-c731-413e-a825-4dbafebc4282)

### **5. Placement**

![Screenshot from 2023-11-03 13-05-49](https://github.com/PoojaR07/pes_lifo_buffer/assets/135737910/df657263-8147-4134-b355-ca2ad6e1b5d8)

```
$ magic -T /home/poojar/OpenLane/vsdstdcelldesign/libs/sky130A.tech lef read /home/poojar/OpenLane/LIFO/runs/RUN_2023.11.03_07.14.55/tmp/merged.max.lef def lifo.def &
```
![Screenshot from 2023-11-03 13-10-00](https://github.com/PoojaR07/pes_lifo_buffer/assets/135737910/032faf38-3aa3-40ef-aa1a-dc6bf7cb225e)

![Screenshot from 2023-11-03 13-10-13](https://github.com/PoojaR07/pes_lifo_buffer/assets/135737910/c1ae552e-d02b-4f1b-9a2b-fdd0c2a24b3a)


### **6. CTS**

![Screenshot from 2023-11-03 13-15-20](https://github.com/PoojaR07/pes_lifo_buffer/assets/135737910/eaa896f6-3d02-467c-aa60-2bf83f94f149)

#### **Reports Generated**

![Screenshot from 2023-11-03 13-22-23](https://github.com/PoojaR07/pes_lifo_buffer/assets/135737910/95b739e1-1c20-4f38-8ac9-4eae18d54ed3)

![Screenshot from 2023-11-03 13-27-46](https://github.com/PoojaR07/pes_lifo_buffer/assets/135737910/1bc3b90c-f5a2-49f9-a797-79f66b67561b)

![Screenshot from 2023-11-03 13-28-10](https://github.com/PoojaR07/pes_lifo_buffer/assets/135737910/4dbfa7cd-fd9f-4b4e-8d00-88c1576bb355)

![Screenshot from 2023-11-03 13-29-18](https://github.com/PoojaR07/pes_lifo_buffer/assets/135737910/4ad7363b-0337-40ed-b540-45a623443e1c)

![Screenshot from 2023-11-03 13-29-38](https://github.com/PoojaR07/pes_lifo_buffer/assets/135737910/f4ab2026-7521-4116-b3ca-17d72a2dff0b)

![Screenshot from 2023-11-03 13-32-09](https://github.com/PoojaR07/pes_lifo_buffer/assets/135737910/14c00ea5-ed40-44ae-b9d2-9eb6d3df27ae)

#### **Power Report**

![Screenshot from 2023-11-03 18-40-02](https://github.com/PoojaR07/pes_lifo_buffer/assets/135737910/402dd33a-66ca-4168-8e13-84d2095cd0cf)

#### **Skew Report**

![Screenshot from 2023-11-03 18-40-21](https://github.com/PoojaR07/pes_lifo_buffer/assets/135737910/0afe9cee-eedb-460d-8f3a-344ff2671bd6)

![Screenshot from 2023-11-03 18-40-47](https://github.com/PoojaR07/pes_lifo_buffer/assets/135737910/87025a9c-df60-4692-81dd-864631788c71)

#### **Area Report**

![Screenshot from 2023-11-03 18-41-11](https://github.com/PoojaR07/pes_lifo_buffer/assets/135737910/2a22fb80-e8c2-4eab-94dd-1b67fae247a9)


### **7. Routing**

![Screenshot from 2023-11-03 13-37-54](https://github.com/PoojaR07/pes_lifo_buffer/assets/135737910/2d6b010b-e8cc-4f09-9b7b-61fc6721f666)

```
$ magic -T /home/poojar/OpenLane/vsdstdcelldesign/libs/sky130A.tech lef read /home/poojar/OpenLane/LIFO/runs/RUN_2023.11.03_07.14.55/tmp/merged.max.lef def lifo.def &
```

![Screenshot from 2023-11-03 13-45-36](https://github.com/PoojaR07/pes_lifo_buffer/assets/135737910/45c002bb-d141-46bc-bc89-20c9d6edf705)

![Screenshot from 2023-11-03 13-45-55](https://github.com/PoojaR07/pes_lifo_buffer/assets/135737910/870df1bc-086f-429c-9f3b-dc759b56c8ce)
