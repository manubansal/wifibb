# wifibb
An easy-to-use 802.11 standard-compliant WiFi baseband implementation

## System requirements
MATLAB version R2014b or higher
MATLAB Communication Toolbox


## Package structure

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

























-- old --
Code to generate ofdm-modulated WiFi-like data. It picks random constellation points to load onto ofdm data subcarriers and loads pilot subcarriers according to the standard. Preamble is generated and prefixed to the data sample sequence. Thus, the packet is reprensetative of a wifi packet except that the actual data content is random, and no channel coding, interleaving and scrambling are performed.


gen_wifi_stf.m : generates the stf portion and stores to a binary file (and text)

gen_wifi_pkt_random.m  : generates a packet as described above and stored to binary file (and text)


-------------------------
SNR-PER characterization
-------------------------
For spec testing, follow these steps:

== Get traces ==

Check out wifibb (the folder is pretty big - 14GB when last measured):

$ svn checkout svn+ssh://<username>@snsg.stanford.edu/home/svn/repos/vbase/wifibb-traces

== Run wifibb receiver ==

Start MATLAB in wifibb folder or start MATLAB and cd to wifibb folder, then:

1. Set up paths:

>> setup_paths

2. Load in samples from trace:

>> [samples, n_samples] = load_samples('<directory containing wifibb-traces>/wifibb-traces/traces54/spectesting-siggen-rhs/54Mbps_1000b_600frames_-30dBm_seq.complex.1ch.float32','float32');

3. Run wifibb receiver on the samples just loaded:

>> rx_sample_stream(samples)

4. Repeat steps 2 and 3 for all traces


---------------------------
To run the regression test
---------------------------

Check out the trace repository:

$ svn checkout svn+ssh://<username>@snsg.stanford.edu/home/svn/repos/vbase/wifibb-traces

Start MATLAB in wifibb folder or start MATLAB and cd to wifibb folder, then:

>> setup_paths
>> [samples, n_samples] = load_samples('../wifibb-traces/traces54/regression/regression_trace','float32');
>> rx_sample_stream(samples)


---------------------------
To decode a constellation
---------------------------

>> [constpoints, n_constpoints] = load_samples('/home/manub/workspace/orsys/app/wifi54/trace/debug/d54mOfdmEq.bho0.bufOutEqualizedPnts.ORILIB_t_Cplx16Buf48.dat', 'cplx');
>> constpoints_scaled = constpoints/95.7;	% example scaling factor
>> rx_constellation_stream(constpoints_scaled, 1016)

