module voting_machine (


    input clk,							
    input rst,							
    input i_candidate_1,				
    input i_candidate_2,				
    input i_candidate_3,				
    input i_voting_over,				

    output reg [31:0] o_count1,			
    output reg [31:0] o_count2,			
    output reg [31:0] o_count3			

);	 
parameter idle =  2'b00;				
parameter vote =  2'b01;
parameter hold =  2'b10;
parameter finish = 2'b11 ;

reg [31:0] r_cand1_prev;				
reg [31:0] r_cand2_prev;				
reg [31:0] r_cand3_prev;				

reg [31:0] r_counter_1;					
reg [31:0] r_counter_2;					
reg [31:0] r_counter_3;					

reg [1:0] r_present_state, r_next_state;
				   
reg [3:0] r_hold_count;                 


always @(posedge clk or negedge rst)
	begin
		case (r_present_state)														

			idle: if (!rst)												
						begin
							r_next_state <= vote;									
							
						end	

					else
						begin
														
							r_counter_1 <= 32'b0;									
							r_counter_2 <= 32'b0;
							r_counter_3 <= 32'b0;
							r_hold_count <= 4'b0000;

							r_next_state <= idle;									
							
						end
				

			vote: if (i_voting_over == 1'b1)									
						begin
							r_next_state <= finish;								
							
						end
					else if (i_candidate_1 == 1'b0 && r_cand1_prev == 1'b1)     
						begin
							r_counter_1 <= r_counter_1 + 1'b1;									

							r_next_state <= hold;								
							
						end

					else if (i_candidate_2 == 1'b0 && r_cand2_prev == 1'b1) 	
						begin
											
							r_counter_2 <= r_counter_2 + 1'b1;					
												

							r_next_state <= hold;								
					
						end

					else if (i_candidate_3 == 1'b0 && r_cand3_prev == 1'b1) 	
						begin
												
							r_counter_3 <= r_counter_3 + 1'b1;					

							r_next_state <= hold;								
						
						end
					else														
						begin
							r_counter_1 <= r_counter_1;							
							r_counter_2 <= r_counter_2;							
							r_counter_3 <= r_counter_3;

							r_next_state <= vote;
							
						end

			hold: if (i_voting_over == 1'b1)									
						begin
							r_next_state <= finish;								
							
						end

					else 
						begin
							if (r_hold_count != 4'b1111) begin
								r_hold_count = r_hold_count + 1'b1;
							end
							else begin
							    r_next_state <= vote;							
							end
							
						end

			finish: if (i_voting_over == 1'b0)									
						begin
							r_next_state <= idle;								
							
						end

					else
						begin
							r_next_state <= finish;								
							
						end

			default: 
				begin 
					r_counter_1 <= 32'b0;										
					r_counter_2 <= 32'b0;
					r_counter_3 <= 32'b0;
					r_hold_count <= 4'b0000;

					r_next_state <= idle;										
					
				end
		endcase
	end	  


always @(posedge clk or negedge rst)											
	begin				

      if (rst == 1'b1)
			begin
				 r_present_state <= idle;										
													
				 o_count1 <= 32'b0; 											
				 o_count2 <= 32'b0;
				 o_count3 <= 32'b0;
				 r_hold_count <= 4'b0000;
			end 
			
		else if (rst == 1'b0 && i_voting_over == 1'b1)							
			begin
				 o_count1 <= r_counter_1; 										
				 o_count2 <= r_counter_2;
				 o_count3 <= r_counter_3;
			end
		
		else
			begin
				r_present_state <= r_next_state;								
				r_cand1_prev <= i_candidate_1;									
				r_cand2_prev <= i_candidate_2;
				r_cand3_prev <= i_candidate_3;
			end
	
	end	

endmodule