//=====================================================================
//  Controller FSM for 8-bit Microprocessor
//=====================================================================
//  Architecture Assumptions:
//  -------------------------
//  ? CPI = 2 ? every instruction takes exactly 2 cycles:
//        Cycle 1: FETCH
//        Cycle 2: EXECUTE
//
//  ? Instruction format:
//        [7:4] = opcode
//        [3:0] = operand (register index or immediate)
//
//  ? Controller role:
//        - Fetch instruction (loadIR + incPC)
//        - Decode opcode
//        - Select ALU function
//        - Select where ACC loads from (ALU / reg / immediate)
//        - Select where PC loads from (reg / imm)
//        - Assert load signals at the right time
//        - Handle HALT state
//
//=====================================================================

module controller_fsm (
    input        clk,
    input  [7:0] instr,   // Instruction from IR
    input        flagZ,   // ALU zero flag
    input        flagN,   // ALU negative flag (ACC[7] == 1)

    // ---- Control signals to datapath ----
    output reg   loadIR,  // Writes instruction memory output ? IR
    output reg   incPC,   // PC = PC + 1
    output reg   loadPC,  // Loads PC with selected value (reg/imm)
    output reg   loadAcc, // Loads ACC with selected value (ALU/reg/imm)
    output reg   loadReg, // Loads Register File[operand] with ACC
    output reg   selPC,   // 1 = Reg ? PC, 0 = Imm ? PC
    output reg [1:0] selACC, // 00 = ALU ? ACC, 10 = Reg ? ACC, 11 = Imm ? ACC
    output reg [3:0] aluOp,  // ALU opcode (ADD, SUB, NOR, SHL, SHR)
    output reg   halt     // HALT state indicator
);

    //=================================================================
    // FSM STATE ENCODING
    //=================================================================
    localparam FETCH      = 2'b00;
    localparam EXEC       = 2'b01;
    localparam HALT_STATE = 2'b10;

    reg [1:0] state = FETCH;

    //Flag registers to latch flag values only for ALU Operation
    //Without latching, ALU constantly updates flags even without ALU operation being executed
    reg Z_reg = 1'b0;
    reg N_reg = 1'b0;

    // Instruction field extraction
    wire [3:0] opcode  = instr[7:4];
    wire [3:0] operand = instr[3:0];

    //=================================================================
    // STATE TRANSITIONS (Sequential)
    //=================================================================
    always @(posedge clk) begin
        case (state)

            // ----------------------------
            // FETCH always transitions to EXEC
            // ----------------------------
            FETCH: begin
                state <= EXEC;
            end

            // ----------------------------
            // EXEC transitions either to:
            //   - FETCH (normal)
            //   - HALT_STATE (if HALT instruction)
            // ----------------------------
            EXEC: begin
                if (opcode == 4'b1111)    // HALT instruction
                    state <= HALT_STATE;
                else
                    state <= FETCH;
            end

            // ----------------------------
            // HALT_STATE loops forever
            // ----------------------------
            HALT_STATE: begin
                state <= HALT_STATE;
            end
        endcase
        //Only update flag registers when performing an ALU operation
        if(state == EXEC) begin
            case (opcode)
                4'b0001, // ADD
                4'b0010, // SUB
                4'b0011, // NOR
                4'b1011, // ShiftLeft
                4'b1100: // ShiftRight
                begin
                    Z_reg <= flagZ;
                    N_reg <= flagN;
                end
                default: begin
                    // If ALU operation not performed, do nothing
                end
            endcase
        end
    end

    //=================================================================
    // OUTPUT LOGIC (Combinational)
    //=================================================================
    // Produces control signals based on:
    //     - Current FSM state
    //     - Instruction opcode
    //     - ALU flags (Z/N)
    //=================================================================
    always @(*) begin

        //-----------------------------------------------------------------
        // DEFAULT VALUES (Safe Defaults)
        //
        // Setting defaults ensures only instructions that explicitly need
        // a signal will activate it, preventing ?latching? or accidental
        // persistence of control signals.
        //-----------------------------------------------------------------
        loadIR  = 0;
        incPC   = 0;
        loadPC  = 0;
        loadAcc = 0;
        loadReg = 0;
        selPC   = 0;
        selACC  = 2'b00;     // ALU ? ACC (default path)
        halt    = 0;

        //-----------------------------------------------------------------
        // FETCH CYCLE: Load IR and increment PC
        //
        // - loadIR = 1    ? IR ? instruction memory[PC]
        // - incPC  = 1    ? PC ? PC + 1
        //
        // No other signals should activate during FETCH.
        //-----------------------------------------------------------------
        case (state)
            FETCH: begin
                loadIR = 1;
                incPC  = 1;
            end

            //-----------------------------------------------------------------
            // EXECUTE CYCLE: Decode opcode and assert control signals
            //-----------------------------------------------------------------
            EXEC: begin

                case (opcode)

                    //=========================================================
                    // 0000 xxxx   NOP ? No Operation
                    //=========================================================
                    4'b0000: begin
                        // All signals remain default (do nothing)
                    end

                    //=========================================================
                    // 0001 rrrr   ADD   ACC = RF[reg] + ACC
                    //=========================================================
                    4'b0001: begin
                        aluOp   = 4'b0001; // ALU = ADD
                        selACC  = 2'b00;   // ACC ? ALU output
                        loadAcc = 1;
                    end

                    //=========================================================
                    // 0010 rrrr   SUB   ACC = RF[reg] - ACC
                    //=========================================================
                    4'b0010: begin
                        aluOp   = 4'b0010; // ALU = SUB
                        selACC  = 2'b00;
                        loadAcc = 1;
                    end

                    //=========================================================
                    // 0011 rrrr   NOR   ACC = ~(RF | ACC)
                    //=========================================================
                    4'b0011: begin
                        aluOp   = 4'b0011; // ALU = NOR
                        selACC  = 2'b00;
                        loadAcc = 1;
                    end

                    //=========================================================
                    // 0100 rrrr   Register ? ACC
                    //=========================================================
                    4'b0100: begin
                        selACC  = 2'b10;   // ACC = regOut
                        loadAcc = 1;
                    end

                    //=========================================================
                    // 0101 rrrr   ACC ? Register File
                    //=========================================================
                    4'b0101: begin
                        loadReg = 1;       // RF[reg] = ACC
                    end

                    //=========================================================
                    // 0110 rrrr   Branch if Zero, Reg ? PC
                    //=========================================================
                    4'b0110: begin
                        if (Z_reg) begin
                            selPC  = 1;    // PC = Register File output
                            loadPC = 1;
                        end
                    end

                    //=========================================================
                    // 0111 iiii   Branch if Zero, Immediate ? PC
                    //=========================================================
                    4'b0111: begin
                        if (Z_reg) begin
                            selPC  = 0;    // PC = Immediate (zero-extended)
                            loadPC = 1;
                        end
                    end

                    //=========================================================
                    // 1000 rrrr   Branch if Negative, Reg ? PC
                    //=========================================================
                    4'b1000: begin
                        if (N_reg) begin
                            selPC  = 1;
                            loadPC = 1;
                        end
                    end

                    //=========================================================
                    // 1010 iiii   Branch if Negative, Imm ? PC
                    //=========================================================
                    4'b1010: begin
                        if (N_reg) begin
                            selPC  = 0;
                            loadPC = 1;
                        end
                    end

                    //=========================================================
                    // 1011 xxxx   Shift Left  (ACC << 1)
                    //=========================================================
                    4'b1011: begin
                        aluOp   = 4'b1011; // ALU = SHIFT LEFT
                        selACC  = 2'b00;
                        loadAcc = 1;
                    end

                    //=========================================================
                    // 1100 xxxx   Shift Right (ACC >> 1)
                    //=========================================================
                    4'b1100: begin
                        aluOp   = 4'b1100; // ALU = SHIFT RIGHT
                        selACC  = 2'b00;
                        loadAcc = 1;
                    end

                    //=========================================================
                    // 1101 iiii   Immediate ? ACC
                    //
                    // ACC = Zero-Extended Immediate (IR[3:0])
                    //
                    //=========================================================
                    4'b1101: begin
                        selACC  = 2'b11;   // Select immediate
                        loadAcc = 1;
                    end

                    //=========================================================
                    // 1111 xxxx   HALT ? Stop CPU
                    //
                    // Transition to HALT_STATE on next clock
                    //=========================================================
                    4'b1111: begin
                        halt = 1;
                    end

                    //=========================================================
                    // Undefined Opcode ? Treat as NOP
                    //=========================================================
                    default: begin
                        // Do nothing
                    end

                endcase
            end // EXEC

            //-----------------------------------------------------------------
            // HALT_STATE ? Freeze CPU forever
            //-----------------------------------------------------------------
            HALT_STATE: begin
                halt = 1;
            end

        endcase
    end

endmodule