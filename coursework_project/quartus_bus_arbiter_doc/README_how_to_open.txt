Open in Quartus:

D:\git\sifovm\coursework_project\quartus_bus_arbiter_doc\bus_arbiter_doc.qpf

Then:

1. Processing -> Start -> Start Analysis & Elaboration
2. Tools -> Netlist Viewers -> RTL Viewer
3. Use top entity bus_arbiter_doc_full_top

This version contains:

grant_dma_o = dma_req_i
grant_cpu_o = cpu_req_i AND NOT(dma_req_i)
ram_en_o    = (cpu_req_i AND grant_cpu_o) OR (dma_we_i AND grant_dma_o)
ram_we_o    = dma_we_i when grant_dma_o = 1 else cpu_we_i
ram_addr_o  = dma_addr_i when grant_dma_o = 1 else cpu_addr_i
ram_wdata_o = dma_wdata_i when grant_dma_o = 1 else cpu_wdata_i
bus_busy_o  = grant_cpu_o OR grant_dma_o

This is the recommended version for the coursework drawing because it
shows not only grants, but also bus selection for RAM address/data/write.

If you need the strict version without bus_busy_o:

1. Assignments -> Settings -> General
2. Top-level entity: bus_arbiter_doc_compact_exact_top
3. Processing -> Start -> Start Analysis & Elaboration
4. Tools -> Netlist Viewers -> RTL Viewer

Old verbose versions are still in the source file:

- bus_arbiter_doc_top
- bus_arbiter_doc_exact_top

The source file is:

D:\git\sifovm\coursework_project\src\bus_arbiter_doc_quartus.vhd
