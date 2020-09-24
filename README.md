# Coe 758 - Project-1 : VHDL cache

## Overview

- install docker
- to build the project and run tests , run the following in terminal
  
  ```bash
    make -j$(nproc) build
  ```
  
## Cache Controller State Machine

after running `sudo make build` in terminal, the simulation result of cache controller logic is stored in `test_results/cache_controller.txt` . You can confirm cache behaviour by serching for the following string in the output text file (`test_results/cache_controller.txt`) 

- **Behaviour Case #1** :  in the simulation output file, use `visual studio code` search (`ctrl+f`) and search for `state_sig [ 0001 ] wr_rd_sig [ '1' ] hit_sig [ '1' ] cpu_cs_sig [ '1' ] sram_wen_sig [ 1 ] valid_bit_sig [ '1' ] dirty_bit_sig [ '1' ] ready_sig [ '1' ]` and to confirm desired behaviour, values of  `sram_addr_sig` should be equal to the
appended values of `index_sig` and `offset_sig`. also, look at `cpu_dout_sig` and `sram_din_sig` should be equal which shows that the data is being written to sram successfully; 

- **Behaviour Case #2** :
  -  **ISSUE** in the simulation output file, use `visual studio code` search (`ctrl+f`) and search for `state_sig [ 0100 ] wr_rd_sig [ '0' ] hit_sig [ '1' ] cpu_cs_sig [ '1' ] sram_wen_sig [ 0 ]` 

- **Behaviour Case #3** : 
  -  **ISSUE** in the simulation output file, use `visual studio code` search (`ctrl+f`) and search for `state_sig [ 0010 ] wr_rd_sig [ '1' ] hit_sig [ '0' ] cpu_cs_sig [ '1' ] ` (write_). In case `dirty_bit_sig` is 0 then `offset_sig` must be `00000` which current implementation does not produce. another issue is that in this scenario, `dirty_bit_sig` is never 0.
- **Behaviour Case #4** : 

[fsm]: fixtures/mermaid/fsm.png "fsm"
