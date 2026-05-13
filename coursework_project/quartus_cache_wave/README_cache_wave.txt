Проект только для временной диаграммы отдельного блока cache_4way_age.

Открывать:
  cache_wave.qpf

В Quartus:
  1. Processing -> Start -> Analysis & Elaboration
  2. File -> New -> Verification/Debugging Files -> Vector Waveform File
  3. File -> Save As -> cache_4way_age_wave.vwf
  4. Edit -> Insert -> Insert Node or Bus
  5. Node Finder -> Filter: Pins: all -> List
  6. Добавить сигналы:
     clk_i
     rst_i
     cpu_req_i
     cpu_we_i
     cpu_addr_i[15..0]
     cpu_wdata_i[15..0]
     cpu_rdata_o[15..0]
     cpu_ready_o
     hit_o
     miss_o
     ram_req_o
     ram_we_o
     ram_addr_o[15..0]
     ram_wdata_o[15..0]
     ram_rdata_i[15..0]
     ram_grant_i

Что показать:
  - первое чтение адреса 0020h: miss_o=1, ram_req_o=1;
  - ответ RAM: ram_grant_i=1, ram_rdata_i=8001h, затем cpu_ready_o=1;
  - повторное чтение 0020h: hit_o=1, ram_req_o=0;
  - запись 0020h или 0030h: ram_we_o=1, ram_wdata_o=C001h.

Если появляется ошибка:
  Error: Can't continue timing simulation because delay annotation information for design is missing

Значит Quartus пытается запустить Timing Simulation. Для этого проекта нужна Functional Simulation:
  1. Сохрани VWF, чтобы в заголовке вкладки не было звездочки (*).
  2. Assignments -> Settings -> Simulator Settings.
  3. Simulation mode: Functional.
  4. Simulation input: cache_4way_age_wave.vwf.
  5. Processing -> Generate Functional Simulation Netlist.
  6. Processing -> Start Simulation.

Timing Simulation для этой проверки не нужен. Он требует задержки после полного Fitter,
а для демонстрации miss/hit/write-through достаточно функционального моделирования.
