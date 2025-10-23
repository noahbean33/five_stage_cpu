/* CPU Version 4.1
Support RV-32I extension only
Verified for synthesis in FPGA
FSM based design
R-type, I type and Branch instr included
Shift operator implemented (SLL/SLLI, SRL/SRLI)
Load and store implemented
Jump implementing

*/
module cpu(
    input rst, clk,
    input [31:0] mem_rdata,//8 bit data chunk from memory
    output [31:0] mem_addr,
    output [31:0] mem_wdata,
    output mem_rstrb,
    output reg [31:0] cycle,
    output [3:0] mem_wstrb //write strobe mask for writing data to mem
  );
  // Port summary:
  // - mem_addr/mem_rstrb: address and read strobe for instruction/data fetch
  // - mem_wdata/mem_wstrb: data and byte write enables for stores
  // - mem_rdata: synchronous read data from memory
  // - cycle: running cycle counter (halts increment in HLT)

  reg [31:0] regfile[0:31];//Register file with X0 to X31;
  reg [31:0] addr, data_rs1, data_rs2; //address bus
  reg [31:0] data; //data bus
  // reg [31:0] load_data_tmp;
  reg [3:0] state; //state register
  parameter RESET=0, WAIT=1, FETCH=2, DECODE=3, EXECUTE=4, BYTE=5, WAIT_LOADING=6, HLT=7; //Different states
  //********* Decoding of Instructions*******//
  wire [4:0] opcode = data[6:2];
  wire [4:0] rd = data[11:7];
  wire [2:0] funct3 = data[14:12];
  wire [6:0] funct7 = data[31:25];
  wire [31:0] I_data = {{21{data[31]}},data[30:20]}; //sign extended data
  wire [31:0] B_data = {{20{data[31]}},data[7],data[30:25],data[11:8],1'b0}; //sign extended branch data
  wire [31:0] S_data = {{21{data[31]}},data[30:25],data[11:7]};//sign extended imm data for S-type
  wire [31:0] J_data = {{12{data[31]}},data[19:12],data[20],data[30:21],1'b0};//sign extended jump data
  wire [31:0] U_data = {data[31],data[30:12],12'h000};//LUI, AUIPC , 12 bit shifted imm data

  // check whether opcode is for R type or I type  or B-type
  wire isRtype = (opcode == 5'b01100);
  wire isItype = (opcode == 5'b00100);
  wire isBtype = (opcode == 5'b11000);
  wire isSystype = (opcode == 5'b11100);
  wire isStype = (opcode == 5'b01000);
  wire isLtype = (opcode == 5'b00000);
  wire isJAL   = (opcode == 5'b11011);
  wire isJALR  = (opcode == 5'b11001);
  wire isLUI = (opcode == 5'b01101);
  wire isAUIPC = (opcode == 5'b00101);

  // flag to calculate mem location for load/store type

  // reg [7:0] tmp_stored_data;
  //  Design ALU using conditional operator
  wire [31:0] ADD = alu_in1 + alu_in2 ;
  wire [31:0] XOR = alu_in1 ^ alu_in2;
  wire [31:0] OR = alu_in1 | alu_in2;
  wire [31:0] AND = alu_in1 & alu_in2;
  wire [32:0] SUB = {1'b0,alu_in1} + {1'b1, ~alu_in2} + 1'b1; //2's comp additon=subtraction
  //shift operation(only SLL/SLLI and SRL/SRLI implemented)
  wire [31:0] shift_data_2 = isRtype ? alu_in2 : isItype ? {7'b0,alu_in2[4:0]}:0;//possible bug
  wire [31:0] SLL = alu_in1 << shift_data_2;//left shift
  wire [31:0] SRL = alu_in1 >> shift_data_2;//right shift
  wire [31:0] SRA = $signed(alu_in1) >>> shift_data_2;//right shift arithmetic(keep sign) BUG

  //branching
  wire EQUAL =  (SUB[31:0] == 0); //if A and B are same then Sub result is 0
  wire NEQUAL = !EQUAL;
  wire LESS_THAN = (alu_in1[31] ^ alu_in2[31])? alu_in1[31]:SUB[32];
  wire LESS_THAN_U = SUB[32];
  wire GREATER_THAN = !LESS_THAN;
  wire GREATER_THAN_U = !LESS_THAN_U;
  wire TAKE_BRANCH = ((funct3==3'b000) & EQUAL)  |
       ((funct3==3'b111) & GREATER_THAN_U)       |
       ((funct3==3'b001) & NEQUAL)               |
       ((funct3==3'b100) & LESS_THAN)            |
       ((funct3==3'b101) & GREATER_THAN)         |
       ((funct3==3'b110) & LESS_THAN_U) ;

  // Note : for ADD and SUB, funct3 is same but funct7[5] is different

  wire [31:0] alu_result = (funct3==3'b000) & isRtype & ~funct7[5]? ADD: //ADD
       (funct3==3'b000) & isItype  ? ADD: //ADD
       (funct3==3'b000) & ~(isStype|isLtype) & funct7[5]? SUB[31:0]: //SUB
       (funct3==3'b100)? XOR: //XOR
       (funct3==3'b110)? OR: //OR
       (funct3==3'b111)? AND: //AND
       (funct3==3'b010) & !(isStype|isLtype)? {31'b0, LESS_THAN}: //SLT chk
       (funct3==3'b011)? {31'b0, LESS_THAN_U}:
       (funct3==3'b001) &(!isStype)? SLL: //SLL,SLLI chk
       (funct3==3'b101) & (~funct7[5]) ? SRL: //SRL,SRLI
       (funct3==3'b101) & funct7[5]? SRA://Arithmetic right shift-sign extended(bug)
       (isStype | isLtype | isJALR) ? ADD:0; //S-type, L type, for mem location calc

  //source1 and source 2 data for ALU operation
  wire  [31:0] alu_in1 = data_rs1; //source is always rs1 for both type
  wire [31:0] alu_in2 = (isRtype | isBtype)? data_rs2 : (isItype | isLtype |isJALR)? I_data:S_data;//ALU req for comparison in Btype
  wire [31:0] pcplus4 = addr + 4;
  wire [31:0] pcplusimm = addr + (isBtype ? B_data: isJAL ? J_data:isAUIPC ? U_data: 0);
  /* LOAD STORE OPERATION
    Credit: FEMTORV32: https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV*/
  //Generate memory read/write strobe signal and address -bug in address calculation
  //wire load_store_state_flag = ((state==BYTE1)|(state==BYTE2)|(state==BYTE3)|(state==BYTE4));
  wire load_store_state_flag = (state==BYTE);
  // Load operation
  wire LOAD_sign = !data[14] & (mem_byteAccess ? LOAD_byte[7] : LOAD_halfword[15]); // load sign
  wire [31:0] load_data_tmp = mem_byteAccess ? {{24{LOAD_sign}}, LOAD_byte} : // load data (byte)
       mem_halfwordAccess ? {{16{LOAD_sign}}, LOAD_halfword} : mem_rdata; // load data (halfword or word)

  // Store operation
  wire [15:0] LOAD_halfword = load_store_addr[1] ? mem_rdata[31:16] : mem_rdata[15:0]; // load halfword
  wire [7:0] LOAD_byte = load_store_addr[0] ? LOAD_halfword[15:8] : LOAD_halfword[7:0]; // load byte

  // The mask for memory-write.
  wire [3:0] STORE_wmask = mem_byteAccess ? (load_store_addr[1] ? (load_store_addr[0] ? 4'b1000 : 4'b0100) : (load_store_addr[0] ? 4'b0010 : 4'b0001)) : // byte write mask
       mem_halfwordAccess ? (load_store_addr[1] ? 4'b1100 : 4'b0011) : 4'b1111; // halfword or word write mask

  // Assign memory write strobe
  assign mem_wstrb = {4{(state==WAIT_LOADING) & isStype}} & STORE_wmask; // memory write strobe

  // Generate memory address for load or store operation
  assign mem_addr = ((isStype | isLtype) & (load_store_state_flag |(state==WAIT_LOADING))) ? load_store_addr: addr; // memory address

  // Generate memory read strobe signal
  assign mem_rstrb = (state==WAIT) | (isLtype & load_store_state_flag); // memory read strobe

  // Store operation
  assign mem_wdata[7:0] = data_rs2[7:0]; // store byte
  assign mem_wdata[15:8] = load_store_addr[0] ? data_rs2[7:0] : data_rs2[15:8]; // store halfword
  assign mem_wdata[23:16] = load_store_addr[1] ? data_rs2[7:0] : data_rs2[23:16]; // store halfword
  assign mem_wdata[31:24] = load_store_addr[0] ? data_rs2[7:0] : load_store_addr[1] ? data_rs2[15:8] : data_rs2[31:24]; // store word

  initial
  begin
    cycle = 0;
    state = 0;
    addr = 0;
    regfile[0] = 0; // X0 register is always 0
  end

  // Clock-dependent operation
  always @(posedge clk)
  begin
    if (rst)
    begin
      addr <= 0;
      state <= RESET;
      data <= 32'h0;
    end
    else
    case (state)
      RESET: // If reset is pressed
      begin
        if (rst)
          state <= RESET;
        else
          state <= WAIT;
      end

      WAIT:
      begin
        state <= FETCH;
      end

      FETCH: // Fetch data from program memory
      begin
        data <= mem_rdata;
        state <= DECODE;
      end

      DECODE: // Decoding of different instruction and generate signal
      begin
        data_rs1 <= regfile[data[19:15]];
        data_rs2 <= regfile[data[24:20]];
        state <= ~isSystype ? EXECUTE : HLT;
      end

      EXECUTE:
      begin
        addr <= (isBtype & TAKE_BRANCH) | isJAL ? pcplusimm : isJALR ? alu_result : pcplus4;
        state <= !(isStype | isLtype | isJAL | isJALR) ? WAIT : BYTE;
      end

      BYTE: // State value is 5
      begin
        state <= WAIT_LOADING;
      end

      WAIT_LOADING:
      begin
        state <= WAIT;
      end
    endcase
  end

  // *** Clock cycle counter ***
  always @(posedge clk)
  begin
    if (rst)
      cycle <= 0;
    else
    begin
      if (state != HLT)
        cycle <= cycle + 1;
    end
  end

  // ** Register file write back data **
  wire write_reg_en = ((isItype | isRtype | isJAL | isJALR | isLUI | isAUIPC) & (state == EXECUTE)) | (isLtype & (state == WAIT_LOADING));
  wire [31:0] write_reg_data = (isItype | isRtype) ? alu_result : // ALU result
       isLtype ? load_data_tmp : // load data
       (isJAL | isJALR) ? pcplus4 : // JAL/JALR result
       isLUI ? U_data : // LUI result
       isAUIPC ? pcplusimm : 0; // AUIPC result
       isAUIPC?pcplusimm:0;



  always @(posedge clk)
  begin
    if (write_reg_en)
      if (rd != 0)
        regfile[rd] <= write_reg_data;
  end

endmodule
