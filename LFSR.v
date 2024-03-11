module CRC
#(parameter N=8 , Tabs=8'b01000100 , Seed=8'hD8)
(
	input Clk,Rst,Data,
	input Active  ,       //to perform shifting & xoring
	output reg Valid,CRC      //serial output
	
);
wire feedback;
reg [4:0] counter;
wire counter_max;
reg [N-1:0] lfsr=8'hD8;  //8 bits register
integer i;


//combainational code 
assign feedback = Data ^  lfsr[0] ;
assign count_max = (counter == 5'd8);

//sequential code 
always@(posedge Clk or negedge Rst)
begin
    if(!Rst)
	    begin
	    lfsr<=Seed;
		Valid=1'b0;
		end
		
    else
	begin
	    if(Active)
	    begin
		    CRC<=lfsr[0];
		    lfsr[N-1]<=feedback;
		    for( i=N-2 ; i>=0 ; i=i-1)
		    begin
		        if( Tabs[i] )
			        lfsr[i]<=( lfsr[i+1] ^ feedback ) ;
		        else
			        lfsr[i]<= lfsr[i+1];
	        end
	    end
		
        else if(!count_max)   //serial output
	    begin
		    Valid=1'b1;
	        {lfsr[N-2:0],CRC}<=lfsr;
		end
	end
end

////////////// counter to control number of shift operations //////////////////////
always@(posedge Clk or negedge Rst)
begin
    if(!Rst)
	begin
	    counter<=5'd8;
		Valid<=1'b0;
	end

	else if(Active)
	    counter<=5'd0;
		
	else if(!count_max)
	    counter<=counter+1;
		
end
endmodule