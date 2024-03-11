`timescale 1ns/1ps

module CRC_tb
#(parameter TEST_CASES=10 , Width=8 , Clock_PERIOD=100)
();

///////////////// signals ////////////////

reg                 Clk_tb,Rst_tb,Data_tb;
reg                 Active_tb;         //to perform shifting & xoring
wire                Valid_tb,CRC_tb;      //serial output
integer             i;


//////////////// Memories ///////////////

reg    [Width-1:0]   Tests           [TEST_CASES-1 : 0] ;
reg    [Width-1:0]   Expec_Output    [TEST_CASES-1 : 0] ;


////////////// Module Instantiation ////////////
CRC
#(.N(Width)) DUT 
(
	.Clk(Clk_tb),
	.Rst(Rst_tb),
	.Data(Data_tb),
	.Active(Active_tb),        
	.Valid(Valid_tb),
	.CRC(CRC_tb)      
	
);



///////////////////// initial block    /////////////////

initial
    begin
	
	    $readmemh("DATA_h.txt" , Tests);
        $readmemh("Expec_Out_h.txt" , Expec_Output);
		
		initialize();
		for(i=0 ; i<TEST_CASES ; i=i+1)
		begin
		
		    do_oper (Tests[i]);
			check_out(Expec_Output[i] , i);
		end
		
		#Clock_PERIOD;
		$stop;
	end
	
	
	
	
///////////////////////////////////////////////////
///////////////////// Tasks //////////////////////
//////////////////////////////////////////////////

/////////////// Signals Initialization //////////////////

task initialize ;
 begin
  Clk_tb  = 'b0;
  Rst_tb  = 'b0;
  Active_tb = 'b0; 
 end  
endtask


///////////////////////// RESET /////////////////////////

task reset ;
 begin
  Rst_tb  = 'b1; 
   #(Clock_PERIOD)  
  Rst_tb  = 'b0;
  #(Clock_PERIOD)
  Rst_tb  = 'b1;
 end
endtask

////////////////// Do LFSR Operation ////////////////////

task do_oper ;
 input  [Width-1:0]     IN_Byte ;
 integer                j;

 begin
     
	reset () ;
	Active_tb=1'b1;
    Data_tb=IN_Byte[0];
    for (j=1 ; j<8 ; j=j+1)
	begin
		#(Clock_PERIOD)
		Data_tb=IN_Byte[j];
	end
	#(Clock_PERIOD)
    Active_tb=1'b0;
 end	
endtask

////////////////// Check Out Response  ////////////////////

task check_out ;
 input  reg     [Width-1:0]     expec_out ;
 input  integer                 Oper_Num ; 
 integer i ;
 
 reg    [Width-1:0]     gener_out ;

 begin
 
  Active_tb=1'b0;
 
  for(i=0; i<8; i=i+1)
   begin
    # Clock_PERIOD
      gener_out[i] = CRC_tb ;
   end
   
   if(gener_out == expec_out) 
    begin
     $display("Test Case %d is succeeded",Oper_Num);
    end
   else
    begin
     $display("Test Case %d is failed", Oper_Num);
    end
   end
endtask



////////////////// Clock Generator  ////////////////////

always #(Clock_PERIOD/2)  Clk_tb = ~(Clk_tb) ;


endmodule