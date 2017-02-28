# wifibb
An easy-to-use 802.11 standard-compliant WiFi baseband implementation

## System requirements
MATLAB version R2014b or higher
MATLAB Communication Toolbox


## Package structure

<pre>
.
  |-examples: top-level example scripts showing the user of wifibb
  |-toplevel: top-level interfaces and chains assembling wifibb modules
  |-parambuilders: helper parameter builder scripts for quick start
  |-traces: trace folders used during wifibb execution (do not modify)
  |-wifi: wifi modules (blocks)
  |-util: utility modules
  |-unittests: unit tests for wifibb modules
  |-loc: modules for RF localization extension
  |-mimoch: modules for mimo channel model used with localization
  |-to_remove: deprecated code
  |-to_update: deprecated code
</pre>

## Standalone wifi tx/rx chains

```
>> setup_paths
>> test_wifi_chain
```


## Explicitly building parameters and running standalone test

```
>> setup_paths
>> cd parambuilders/wifi64
>> dp = default_sim_parameters();
>> tp = wifi_tx_parameters();
>> rp = wifi_rx_parameters();
>> cp = wifi_common_parameters();
>> cd ../..
>> test_wifi_chain(dp,tp,rp,cp);
```

## Decoding a sample wifi stream

```
>> [samples, n_samples] = load_samples('../wifibb-traces/traces54/usrp-1s.dat','cplx');
>> rx_sample_stream(samples)
```

## Logging trace files

Most trace logging has been setup to "append" the trace data. So upto the implementer to delete all *.c and *.dat and *.mdat and *.txt files 
in the trace directory before logging new traces
