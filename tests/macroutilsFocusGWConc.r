
library( "macroutils2" ) 

#   Maximum differences acceptable in conc
maxConcDif <- c( "raw" = 1e-04, "gui" = 1e-08 ) 
maxPercDif <- 1e-03 # 1/1000th of a mm of water



#   Examples
#   
#   MACRO In FOCUS Chateaudun scenario, winter cereals or 
#   potatoes, dummy substance GW-D applied at 1kg/ha on 
#   julian day 298 or 119, 1 day before emergence, 
#   applications every year, every other year or every 
#   third year.
#   
#   The same scenario are included in MACRO In FOCUS 
#   version control.

examples <- list(
    "gw_D_annual" = list(
        "bin"      = "bintest/chat_winCer_GW-D_1kgHa_d298_annual_output.bin", 
        "conc_dat" = "bintest/chat_winCer_GW-D_1kgHa_d298_annual_conc.dat", 
        "perc_dat" = "bintest/chat_winCer_GW-D_1kgHa_d298_annual_perc.dat", 
        "warm_up_index" = 1:6, 
        "FOCUS_PEC" = 0.154, 
        "FOCUS_periods" = c( 7, 10 ) ),  
    "gw_D_biennial" = list(
        "bin"      = "bintest/chat_pot_GW-D_1kgHa_d119_biennial_output.bin", 
        "conc_dat" = "bintest/chat_pot_GW-D_1kgHa_d119_biennial_conc.dat", 
        "perc_dat" = "bintest/chat_pot_GW-D_1kgHa_d119_biennial_perc.dat", 
        "warm_up_index" = 1:3, 
        "FOCUS_PEC" = 0.0254, 
        "FOCUS_periods" = c( 19, 2 ) ), 
    "gw_D_triennial" = list(
            "bin"      = "bintest/chat_pot_GW-D_1kgHa_d119_triennial_output.bin", 
            "conc_dat" = "bintest/chat_pot_GW-D_1kgHa_d119_triennial_conc.dat", 
            "perc_dat" = "bintest/chat_pot_GW-D_1kgHa_d119_triennial_perc.dat", 
            "warm_up_index" = 1:2, 
            "FOCUS_PEC" = 0.0174, 
            "FOCUS_periods" = c( 2, 13 ) ) )   

for( i in 1:length( examples ) ){
    #   i <- 2L
    
    #   Path to the file to be read:
    ( filenm <- system.file( 
        examples[[ i ]][[ "bin" ]], 
        package = "macroutils2", mustWork = TRUE ) )

    res <- macroutilsFocusGWConc( x = filenm, quiet = TRUE ) 

    res 

    # attr( res, "more" ) 



    # Compare concentrations from all periods
    # +--------------------------+

    #   Import the corresponding file produced by MACROInFOCUS
    datConc <- system.file( 
        examples[[ i ]][[ "conc_dat" ]], 
        package = "macroutils2", mustWork = TRUE ) 

    #   Format the name of the expected dat files
    conc <- read.table( file = datConc, sep = "", header = TRUE )

    #   Eliminate warm-up
    conc <- conc[ -c(1:6), ]

    #   Calculate the absolute differences
    # CONC_TLAYER <- attr( res, "more" )[, "CONC_TLAYER" ] 
    CONC_TLAYER <- res[["solute_target_layer_by_period"]][, "ug_per_L" ]

    concDiffs <- conc[, "Av_FluxConc_at_reporting_depth" ] - 
        CONC_TLAYER

    concDiffs <- abs( concDiffs ) 

    xyRange <- range( c( CONC_TLAYER, 
        conc[, "Av_FluxConc_at_reporting_depth" ] ) )
    
    if( i > 1L ){ dev.new() }
    
    plot( CONC_TLAYER ~ 
        conc[, "Av_FluxConc_at_reporting_depth" ], xlim = xyRange, 
        ylim = xyRange, 
        main = sprintf( "%s: concentration", names( examples )[ i ] ) ) 
    abline( a = 0, b = 1, col = "red" ) 

    #   Compare the two side by side
    cbind( CONC_TLAYER, conc[, "Av_FluxConc_at_reporting_depth" ] )

    # #   Calculate the absolute differences again
    # concDiffs <- conc[, "Av_FluxConc_at_reporting_depth" ] - 
        # CONC_TLAYER
    
    # concDiffs <- abs( concDiffs ) 

    #   Test that the differences are not too big
    if( any( concDiffs > maxConcDif[ "raw" ] ) ){
        stop( sprintf( 
            "%s: Some diffs in period-concentration are bigger than the max acceptable diff: %s > %s.", 
            names( examples )[ i ], 
            max( concDiffs ), 
            maxConcDif[ "raw" ] 
        ) ) 
    }   
    
    
    
    # Compare PEC between MACRO In FOCUS version control and 
    # macroutils2
    # +--------------------------+
    
    if( abs(examples[[ i ]][[ "FOCUS_PEC" ]] - res[["conc_target_layer"]][ 1L, "ug_per_L_rnd" ]) > maxConcDif[ "gui" ] ){
        stop( sprintf( 
            "%s: The diff in PEC is bigger than the max acceptable diff: %s > %s (PECgw: MACRO In FOCUS %s; macroutils2 %s).", 
            names( examples )[ i ], 
            abs(examples[[ i ]][[ "FOCUS_PEC" ]] - res[["conc_target_layer"]][ 1L, "ug_per_L_rnd" ]), 
            maxConcDif[ "gui" ], 
            examples[[ i ]][[ "FOCUS_PEC" ]], 
            res[["conc_target_layer"]][ 1L, "ug_per_L_rnd" ]
        ) ) 
    }   
    
    #   Periods selected (MACRO In FOCUS version control)
    # mu2_periods <- res[, c( "tLayerAvgPerFrom", "tLayerAvgPerTo" )]
    mu2_periods <- res[["conc_target_layer"]][ 1L, c( "index_period1", "index_period2" ) ]
    mu2_periods <- as.integer( mu2_periods )

    if( !all( examples[[ i ]][[ "FOCUS_periods" ]] %in% mu2_periods ) ){
        stop( sprintf( "%s: Some periods in FOCUS version control are not in macroutils2 periods: %s vs %s", 
            names( examples )[ i ], 
            paste( examples[[ i ]][[ "FOCUS_periods" ]], collapse = ", " ), 
            paste( mu2_periods, collapse = ", " ) 
        ) ) 
    }   


    # Compare percolation from all years
    # +--------------------------+

    #   Import the corresponding file produced by MACROInFOCUS
    datPerc <- system.file( 
        examples[[ i ]][[ "perc_dat" ]], 
        package = "macroutils2", mustWork = TRUE ) 
    
    #   Format the name of the expected dat files
    perc <- read.table( file = datPerc, sep = "", header = TRUE )

    #   Eliminate warm-up
    perc <- perc[ -c(1:6), ]
    
    # acc_WFLOWTOT <- attr( res, "more" )[, "acc_WFLOWTOT" ]
    acc_WFLOWTOT <- res[["water_target_layer_by_period"]][, "mm_tot" ]
    
    #   Calculate the absolute differences
    percDiffs <- perc[, "Percolation_at_reporting_depth" ] - 
        acc_WFLOWTOT
    
    percDiffs <- abs( percDiffs ) 
    
    xyRange <- range( c( acc_WFLOWTOT, 
        perc[, "Percolation_at_reporting_depth" ] ) )
    
    dev.new()
    
    plot( acc_WFLOWTOT ~ 
        perc[, "Percolation_at_reporting_depth" ], xlim = xyRange, 
        ylim = xyRange, 
        main = sprintf( "%s: percolation", names( examples )[ i ] ) ) 
    abline( a = 0, b = 1, col = "red" ) 
    
    #   Test that the differences are not too big
    if( any( percDiffs > maxPercDif ) ){
        stop( sprintf( 
            "%s: Some diffs in period-perc are bigger than the maximum acceptable difference: %s > %s.", 
            names( examples )[ i ], 
            max( percDiffs ), 
            maxPercDif 
        ) ) 
    }   

}   
