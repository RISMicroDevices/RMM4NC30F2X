# Gemini 30F2
> RMM4NC30F2X  
> 单发射 乱序 长流水 高频率优化 MIPS处理器  

&emsp;&emsp;Gemini 30F2是针对“龙芯杯”计算机系统能力培养大赛设计的一款MIPS32-R2、无中断、无异常的处理器核，支持大赛技术手册中的全部指令。  
&emsp;&emsp;该处理器核心为单发射、乱序执行10~12级流水线，采用ROB内的寄存器重命名，且有8KB的指令缓存、8KB的数据缓存，使用两位饱和计数器作为分支预测器。  
&emsp;&emsp;目标设计频率150MHz，Vivado时序分析报告频率160MHz，**性能测试阶段成功运行在200MHz**（基本上达到是此类设计在Artix-7 FPGA器件上的频率极限了），决赛阶段更改流水线及总线结构后成功运行在180MHz。移植至Zynq Ultrascale+器件后可运行在480MHz。

## 一、性能测试成绩
|STREAM|MATRIX|CRYPTONIGHT|
|--|--|--|
| 0.083s | **0.095s** | 0.413s |


## 二、决赛成绩（未提交）
|SQRT|
|--|
| 0.150s |

&emsp;&emsp;利用了本处理器直接支持 AXI-4 总线的特点，使用了 Xilinx 的 CORDIC IP，将其挂载在 AXI-4 总线的MMU上，并分配虚拟寄存器地址，最终得到了一个非常不错的运行时间。（遗憾未能在决赛答题时间内提交正确结果）

## 三、架构细节
![Gemini30F2处理器核整体架构图](http://git.rismd.cn/rismd/assets/-/raw/master/RMM4NC30F2X/Gemini30F2-Global.png "Gemini30F2处理器核整体架构图")  
&emsp;&emsp;Gemini30F2核心的整体架构图如上图所示。其中2级为取指令，2级为解码与寄存器重命名、重排序缓存，2级为发射队列，1级为指令分发，1~3级为执行，1级为写回，1级为提交。  

### **1. 取指令**
![Gemini30F2处理器取指令部分架构设计](http://git.rismd.cn/rismd/assets/-/raw/master/RMM4NC30F2X/Gemini30F2-Fetch.png "Gemini30F2处理器取指令部分架构设计")  
&emsp;&emsp;取指令部分的详细设计架构如上图所示。其中PC队列（PC Queue）用以处理正确的PC迭代过程，处理延迟槽、以及分支恢复等。  
&emsp;&emsp;分支目标缓存（BTB）与跳转记录表（PHT）则用以实现两位饱和计数预测器的功能，其中BTB为1K条记录，PHT为8K条记录，都使用BRAM实现，也意味着分支预测的结果要在取指令的第二个周期才能得到（这对于有延迟槽的MIPS架构来说似乎可以是一种自然而然的设计），且在120MHz的频率下还可以进一步增大容量，并使用了一个4位的全局历史寄存器（GHR）对PC值进行索引哈希。  
&emsp;&emsp;取指令部分还包含了一个8KB的单路指令缓存，缓存每行可容纳16条指令，一共128行，指令数据缓存使用BRAM实现，指令Tag则由Distributed RAM实现。  
&emsp;&emsp;取指令部分通过一个只读的AXI总线与内存设备连接，并且在指令数据缓存与AXI总线间插入了缓冲器（Buffer），支持关键字优先读取。  

### **2. 指令解码与寄存器**
![Gemini30F2处理器解码与寄存器部分架构设计](http://git.rismd.cn/rismd/assets/-/raw/master/RMM4NC30F2X/Gemini30F2-DecReg.png "Gemini30F2处理器解码与寄存器部分架构设计")  
&emsp;&emsp;其中Alloc为队列余量计算，为了控制流水级数并改善时序，各级之间没有采用显式的握手方式，而是提前计算ROB、发射队列等的余量，使用这些已有的部件来充当指令缓冲队列，将后续流水线中的各个缓冲器（发射队列、ROB、StoreBuffer等）作为分布式的缓冲区。  
&emsp;&emsp;寄存器重命名表（RAT）中记录着当前某一个寄存器对应的ROB槽位，指令在提交（退休）之前，会将计算完毕的值存储到ROB中，并借此来完成乱序发射要求的寄存器重命名。所有的结果值直到指令在ROB尾端被提交（退休）之后，才会被写入到架构寄存器之中去。  

### **3. 指令发射**
![Gemini30F2处理器发射部分架构设计](http://git.rismd.cn/rismd/assets/-/raw/master/RMM4NC30F2X/Gemini30F2-Issue.png "Gemini30F2处理器发射部分架构设计")  
&emsp;&emsp;发射阶段使用一个发射队列来完成指令的发射。指令在完成计算，写回ROB的过程中会唤醒发射队列中的指令。并且对于这些准备好的指令，最老的指令总是被最先发射。没有准备好的指令则在队列中原位等待。发射队列使用一个压缩移位FIFO来实现。  
&emsp;&emsp;本乱序发射设计中，分支之间不可乱序，写内存指令后的所有访存指令不可在其之前执行。  
&emsp;&emsp;其中写回历史表（WHT）是为了解决指令还在流水线中飞行而还没有被写入发射队列时，不能被唤醒的设计，防止指令在发射队列中形成死锁。  

### **4. 执行阶段**
&emsp;&emsp;普通的整数计算通过ALU完成，整数计算部分的基本运算器件（ADD、SUB、SLT、XOR、OR等）针对FPGA中的LUT5器件进行了特殊的优化，提高布线密度，将基本逻辑运算的数据通路合并到了一起，并且仅使用单个加法器，以此保证在高频率下的直接结果前递（Direct Forward）可以实现，使得相互依赖的基本运算指令也可以在流水线中背靠背地执行。  
&emsp;&emsp;分支计算通过BRU完成，并在BRU中判断分支预测结果是否正确，分支恢复与流水线刷新则在ROB提交阶段完成。  
&emsp;&emsp;乘法运算通过MUL完成，乘法运算使用的Xilinx提供的乘法IP，并且划分了三级流水线。  
&emsp;&emsp;访存部分设有一个8KB的数据缓存，共256行，每行32个字节。缓存策略采用写穿（Write Through）与读时分配（Load Allocation）策略，可通过AXI总线与二级缓存配合工作（本设计中尚未实现二级缓存）。并且有两级写缓冲（Store Buffer），第一级保存尚未提交的写内存指令，第二级已经保存但尚未写回的写内存指令，并且其值可以被之后的读内存指令查询，并实现了多行之间的字节合并查询。二级写缓冲直接与AXI总线控制器相连，一旦缓存非空就向总线发送写请求。  

### **5. 分支恢复**
&emsp;&emsp;分支恢复在ROB阶段完成，分支延迟较大但设计相对简单，不需要设计检查点（由于赛程中Debug时间不足，Gemini 30F2 为 Gemini 30F3 删除了检查点恢复的设计）。  

### **6. 总线结构**
![Gemini30F2总线设计](http://git.rismd.cn/rismd/assets/-/raw/master/RMM4NC30F2X/Gemini30F2-SoC.png "Gemini30F2总线设计")  
&emsp;&emsp;Gemini30F2核心使用AXI4接口与外设、内存设备连接。本次大赛中的设计的总线结构如上图所示。  
&emsp;&emsp;访存速率（对SRAM控制器）为总线频率的三倍分频，例如在180MHz的频率下，访存速率为60MT/s。  


## 四、文件目录说明
|路径|描述|
|--|--|
|main/amba/|一些AXI基础设施
|main/constrains/|基本约束文件
|main/core/|核心设计文件
|main/core/commit/|提交阶段Verilog源代码
|main/core/decode/|解码与寄存器阶段Verilog代码
|main/core/def/|公用定义
|main/core/dispatch/|分发阶段Verilog源代码（仅DFF构成）
|main/core/execute/|执行阶段Verilog源代码
|main/core/fetch/|取指令阶段Verilog源代码
|main/core/issue/|发射阶段Verilog源代码
|main/core/misc/|杂项
|main/soc/|顶层文件与部分外设
