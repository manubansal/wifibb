function tx_params = wifi_tx_parameters()
    %----- variable binary dumps ---------%
    tx_params.dumpVars_dataBits = false;
    tx_params.dumpVars_mappedSymbols = false;
    tx_params.dumpVars_ofdmMod = false;
    tx_params.dumpVars_preConvBits = false;
    tx_params.dumpVars_convBits = false;
    tx_params.dumpVars_interleavedBits = false;
    tx_params.dumpVars_stfLtf = false;

    tx_params.compare_tx_rx_pkts = false;
    tx_params.writeSamples = true;
    
    tx_params.scale = 4;
end
