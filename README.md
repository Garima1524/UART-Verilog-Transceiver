\# UART Verilog Transceiver



\## Overview



A parameterized full-duplex UART transceiver designed and verified using Verilog HDL. The design supports 8-bit LSB-first serial communication with configurable baud rate generation and 16× receiver oversampling for reliable asynchronous data reception.



The project includes separate transmitter, receiver, baud-generation, and top-level integration modules, along with a self-checking testbench for functional verification.



\## Features



\* Full-duplex UART TX/RX communication

\* 8-bit data transmission

\* LSB-first serial communication

\* Configurable baud rate

\* 16× RX oversampling

\* Mid-bit sampling for reliable data reception

\* 2-flop synchronizer for asynchronous RX input

\* FSM-based TX and RX logic

\* Loopback architecture for end-to-end verification

\* Self-checking testbench



\## Architecture



```text

&#x20;                +----------------------+

&#x20;                |      UART TOP        |

&#x20;                |                      |

&#x20;                |  +---------------+   |

TX Data -------->|  | UART TX       |---|----> TX

&#x20;                |  +---------------+   |

&#x20;                |          ^           |

&#x20;                |          |           |

&#x20;                |  +---------------+   |

&#x20;                |  | Baud Generator|   |

&#x20;                |  +---------------+   |

&#x20;                |          |           |

RX ------------->|  +---------------+   |

&#x20;                |  | UART RX       |   |

&#x20;                |  +---------------+   |

&#x20;                |          |           |

&#x20;                +----------|-----------+

&#x20;                           v

&#x20;                        RX Data

```



\## Module Description



| Module          | Description                                                         |

| --------------- | ------------------------------------------------------------------- |

| `baud.v`        | Generates the sampling/baud timing signals                          |

| `tx.v`          | Implements UART transmission using an FSM                           |

| `uart\_rx.v`     | Implements UART reception with synchronization and 16× oversampling |

| `uart\_top.v`    | Integrates the transmitter, receiver, and baud generator            |

| `uart\_top\_tb.v` | Top-level self-checking testbench for functional verification       |



\## UART Frame



The implemented UART frame consists of:



```text

Start | Data\[0] | Data\[1] | ... | Data\[7] | Stop

&#x20; 0       LSB                         MSB       1

```



The data is transmitted \*\*LSB first\*\*.



\## Receiver Design



The receiver uses \*\*16× oversampling\*\* of the incoming asynchronous serial signal.



A 2-flop synchronizer is used at the RX input to reduce the risk of metastability when sampling the asynchronous signal.



The receiver detects the start bit and samples the incoming data near the center of each bit period before reconstructing the 8-bit received data.



\## Verification



The design is verified using a top-level testbench that performs end-to-end UART communication.



The testbench verifies:



\* UART transmission

\* UART reception

\* TX/RX loopback operation

\* Received data correctness

\* Completion signaling

\* Multiple test cases



Simulation waveforms are used to examine the TX, RX, baud/sample timing, transmitted data, and received data.



\## Tools Used



\* Verilog HDL

\* Xilinx Vivado

\* Simulation and waveform analysis

\* Git / GitHub



\## Project Structure



```text

UART-Verilog-Transceiver/

│

├── rtl/

│   ├── baud.v

│   ├── tx.v

│   ├── uart\_rx.v

│   └── uart\_top.v

│

├── testbench/

│   └── uart\_top\_tb.v

│

├── README.md

└── .gitignore

```



\## Future Improvements



\* Parity-bit support

\* Configurable data width

\* Configurable stop-bit selection

\* FPGA hardware implementation

\* Hardware loopback demonstration

\* Additional corner-case verification



