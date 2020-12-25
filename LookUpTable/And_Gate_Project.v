// Demo ANG gate with two inputs
module And_Gate_Project (
    input i_Swithc_1,
    input i_Swithc_2,
    output o_LED_1
);

assign o_LED_1 = i_Swithc_1 & i_Swithc_2;

endmodule