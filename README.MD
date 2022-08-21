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
![Gemini30F2处理器核整体架构图](https://github.com/RISMicroDevices/assets/blob/master/RMM4NC30F2X/Gemini30F2-Global.png "Gemini30F2处理器核整体架构图")  
&emsp;&emsp;Gemini30F2核心的整体架构图如上图所示。其中2级为取指令，2级为解码与寄存器重命名、重排序缓存，2级为发射队列，1级为指令分发，1~3级为执行，1级为写回，1级为提交。  


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
