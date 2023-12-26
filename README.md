# Info

基本目录就是这个了

按助教所说，在vivado导入`inst52`文件夹的所有内容，并且去掉（copy sources into project）的勾选

开发放在其它分支里面，主分支一般不动，提交用pull request

# Milestone

更详细的见[milestones](docs/milestones.md)

- [ ] 搭建环境

`inst52` 部分

- [x] 完成逻辑运算指令
- [ ] 完成移位指令
- [ ] 完成*简单*算数指令（不包括乘除法，现在先不考虑溢出产生的异常处理）
- [ ] 完成数据移动指令（HI，LO是为乘除法做准备，32位的乘除法需要共64位；HI，LO会涉及hazard）
- [ ] 完成乘除法（乘除法用时太长，也会涉及hazard stall）
- [ ] 完成*简单*分支跳转指令（BEQ，BNE，BGEZ，BGTZ，BLEZ,BLTZ都只是改条件）
- [ ] 完成剩余分支跳转指令（如JR，JALR，BLTZAL，BGEZAL会涉及保存寄存器）
- [ ] 完成访存指令（半字读写好像要多做一些判断）

- [ ] 完成异常处理

`inst57` 部分

...
