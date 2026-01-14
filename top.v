module smart_gate_controller (
    input wire clk_i,
    input wire reset_ni,
    input wire car_i,
    input wire pay_ok_i,
    input wire clear_i,
    input wire cnt_reset_i,
    output wire gate_open_o,
    output wire gate_close_o,
    output reg red_o,
    output reg yellow_o,
    output reg green_o,
    output reg[7:0] car_count_o
);

reg[2:0] counter;
reg[2:0] state;
reg[2:0] next_state;

localparam IDLE         = 3'b000;
localparam PRE_APERTURA = 3'b001;
localparam APERTURA     = 3'b010;
localparam VARCO_APERTO = 3'b011;
localparam CHIUSURA     = 3'b100;

always @(*) begin
    case (state)
        IDLE: begin
            if (car_i && pay_ok_i) next_state = PRE_APERTURA;
            else next_state = IDLE;
        end

        PRE_APERTURA: begin
            if (counter == 3'b001) next_state = APERTURA;
            else next_state = PRE_APERTURA;
        end

        APERTURA: begin
            if (clear_i == 1'b0) next_state = APERTURA;
            else next_state = VARCO_APERTO;              
        end

        VARCO_APERTO: begin
            if (counter == 3'b010) next_state = CHIUSURA;
            else next_state = VARCO_APERTO;
        end

        CHIUSURA: next_state = IDLE;             

        default: next_state = 3'bx;
    endcase
end


always @(posedge clk_i or negedge reset_ni) begin    
    if (!reset_ni) begin
        state <= IDLE;
        counter <= 3'b0;
        car_count_o <= 8'b0;
    end

    else begin
        if (state != next_state) counter <= 3'b0;
        else counter <= counter + 1'b1;

        state <= next_state;
    
        if (cnt_reset_i) car_count_o <= 0;
        else begin
            if(state == APERTURA && next_state == VARCO_APERTO) begin
                if (car_count_o == {8{1'b1}}) car_count_o <= car_count_o;
                else car_count_o <= car_count_o + 1'b1;
            end
        end 
    end


end

always @(*) begin
    case (state)
        IDLE: begin
            red_o = 1'b1;
            yellow_o = 1'b0;
            green_o = 1'b0;
            gate_open_o = 1'b0;
            gate_close_o = 1'b0;
        end

        PRE_APERTURA: begin
            red_o = 1'b0;
            yellow_o = 1'b1;
            green_o = 1'b0;
            gate_open_o = 1'b0;
            gate_close_o = 1'b0;
        end

        APERTURA: begin
            if (clear_i == 1'b0) begin
                red_o = 1'b0;
                yellow_o = 1'b1;
                green_o = 1'b0;
                gate_open_o = 1'b0;
                gate_close_o = 1'b0;
            end
            else begin
                red_o = 1'b0;
                yellow_o = 1'b0;
                green_o = 1'b1;
                gate_open_o = 1'b1;
                gate_close_o = 1'b0;  
            end
        end

        VARCO_APERTO: begin
            red_o = 1'b0;
            yellow_o = 1'b0;
            green_o = 1'b1;
            gate_open_o = 1'b0;
            gate_close_o = 1'b0;   
        end

        CHIUSURA: begin
            red_o = 1'b0;
            yellow_o = 1'b1;
            green_o = 1'b0;
            gate_open_o = 1'b0;
            gate_close_o = 1'b1;  
        end

        default: begin
            red_o = 1'bx;
            yellow_o = 1'bx;
            green_o = 1'bx;
            gate_open_o = 1'bx;
            gate_close_o = 1'bx;
        end
    endcase
end
endmodule