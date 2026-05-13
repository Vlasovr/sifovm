Проект только для получения красивой структурной схемы кэша.

Открывать:
  cache_schematic.qpf

В Quartus:
  1. Processing -> Start -> Analysis & Elaboration
  2. Tools -> Netlist Viewers -> RTL Viewer
  3. В дереве выбрать cache_4way_structural_doc

Для отчета использовать RTL Viewer, а не Technology Map Viewer.
Technology Map Viewer специально разворачивает VHDL в регистры, LUT и мультиплексоры,
поэтому там снова получится много страниц.

На верхнем уровне должны быть видны смысловые блоки:
  U_ADDRESS_SPLIT_TAG_SET        - разбиение адреса на TAG=A[15..4] и SET=A[3..0]
  U_DATA_WAY0..U_DATA_WAY3       - 4 банка данных кэша
  U_TAG_WAY0..U_TAG_WAY3         - 4 банка тегов
  U_VALID_WAY0..U_VALID_WAY3     - признаки достоверности строк
  U_AGE_WAY0..U_AGE_WAY3         - счетчики AGE для выбора замещения
  U_TAG_COMPARE0..U_TAG_COMPARE3 - сравнение TAG запроса с TAG way
  U_HIT_MISS_LOGIC_AND_OR_NOT    - AND/OR/NOT: valid & tag_equal -> hit/miss
  U_DATA_MUX                     - мультиплексор данных 4:1
  U_VICTIM_SELECT                - выбор way для замещения
  U_CACHE_CONTROL                - управляющий автомат кэша
  U_RAM_INTERFACE                - интерфейс к ОЗУ, write-through

Рабочая реализация кэша остается в:
  ../src/cache_4way_age.vhd

Этот проект нужен только как структурное представление: 4 way, tag/data/valid/age,
сравнение тегов, выбор жертвы, мультиплексор данных и интерфейс к RAM.
