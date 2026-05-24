Проект для получения скриншотов схем через Quartus RTL Viewer.

Открывать:
  D:\git\sifovm\coursework_project\quartus_rtl_appendix\rtl_appendix.qpf

Что делать в Quartus:
  1. Processing -> Start -> Analysis & Elaboration
  2. Tools -> Netlist Viewers -> RTL Viewer
  3. В дереве слева раскрыть rtl_appendix_all_top.
  4. Для скринов приложений заходить внутрь нужного U_APP_* блока.

Главные блоки:
  U_APP_A_COMMAND_SYSTEM       - приложение А, система команд
  U_APP_B_MEMORY               - приложение Б, блок ЗУ
  U_APP_V_CONTROL_UNIT         - приложение В, устройство управления
  U_APP_G_SPECIAL_REGISTERS    - приложение Г, специальные регистры
  U_APP_D_RON                  - приложение Д, 12 регистров общего назначения
  U_APP_E_COMMON_OPERATIONS    - приложение Е, общие операции
  U_APP_ZH_JMP                 - приложение Ж, JMP
  U_APP_I_M_TO_R               - приложение И, M->R
  U_APP_K_R_TO_M               - приложение К, R->M
  U_APP_L_ALU                  - приложение Л, АЛУ
  U_APP_M_OR                   - приложение М, OR
  U_APP_N_NOR                  - приложение Н, NOR
  U_APP_P_SRA                  - приложение П, SRA
  U_APP_R_INCS                 - приложение Р, INCS
  U_APP_S_FLAGS                - приложение С, регистр флагов
  U_APP_T_STACK                - приложение Т, стек 7x16
  U_APP_U_STACK_EXEC           - приложение У, исполнительный блок стека
  U_APP_F_CACHE                - приложение Ф, кэш 4-way
  U_APP_H_CACHE_DATA           - приложение Х, блок данных кэша
  U_APP_TS_CACHE_FLAGS         - приложение Ц, флаги/AGE/VALID кэша
  U_APP_SH_MICRO_EVM           - приложение Ш, микро-ЭВМ
  U_APP_SHCH_BRANCH_PREDICTOR  - приложение Щ, предсказатель переходов

Важно:
  Это отдельный VHDL для красивого RTL Viewer, а не замена рабочей модели.
  Рабочие файлы CPU/кэша/стека остаются в ../src как были.
  Скринить лучше именно RTL Viewer, не Technology Map Viewer.
