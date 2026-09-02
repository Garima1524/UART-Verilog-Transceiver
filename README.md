# UART Verilog Transceiver

## Overview

A parameterized full-duplex UART transceiver designed and verified using Verilog HDL. The design supports 8-bit LSB-first serial communication with configurable baud-rate generation and 16× receiver oversampling for reliable asynchronous data reception.

The design is organized into transmitter, receiver, baud-generation, and top-level integration modules, with a self-checking testbench for end-to-end functional verification.

## Key Features

* Full-duplex UART TX/RX communication
* 8-bit LSB-first data transmission
* Configurable baud rate
* 16× RX oversampling
* Mid-bit sampling for reliable data reception
* 2-flop synchronizer for asynchronous RX input
* FSM-based transmitter and receiver
* TX/RX loopback architecture
* Self-checking testbench

## Architecture

```text
                    +----------------------+
                    |      UART TOP        |
                    |                      |
TX Data ---------->|   +-------------+    |--------> TX
                    |   |   UART TX   |    |
                    |   +-------------+    |
                    |          ^           |
                    |          |           |
                    |   +-------------+    |
                    |   | Baud Gen.   |    |
                    |   +-------------+    |
                    |          |           |
RX ---------------->|   +-------------+    |
                    |   |   UART RX   |    |
                    |   +-------------+    |
                    |          |           |
                    +----------|-----------+
                               v
                            RX Data
```

## UART Frame Format

The UART frame consists of one start bit, eight data bits, and one stop bit.

```text
Start | Data[0] | Data[1] | ... | Data[7] | Stop
  0       LSB                         MSB       1
```

Data is transmitted **LSB first**.

## Receiver Design

The receiver uses **16× oversampling** to improve the reliability of asynchronous serial-data reception.

A **2-flop synchronizer** is used at the RX input to reduce the probability of metastability propagation into the receiver logic.

After detecting the start bit, the receiver uses the oversampling clock to sample the incoming data near the center of each bit period and reconstruct the received 8-bit word.

## Module Description

| Module          | Description                                                               |
| --------------- | ------------------------------------------------------------------------- |
| `baud.v`        | Generates the sampling and baud timing signals                            |
| `tx.v`          | Implements UART transmission using an FSM                                 |
| `uart_rx.v`     | Implements UART reception with input synchronization and 16× oversampling |
| `uart_top.v`    | Integrates the transmitter, receiver, and baud generator                  |
| `uart_top_tb.v` | Top-level self-checking testbench for functional verification             |

## Verification

The UART was verified using a top-level testbench implementing end-to-end TX/RX loopback.

The verification environment checks:

* UART transmission
* UART reception
* TX/RX loopback operation
* Received-data correctness
* TX/RX completion signaling
* Multiple test cases

Simulation waveforms were analyzed to verify serial-data timing, baud/sample timing, transmitted data, and received data.

### Simulation Results

The following waveform demonstrates UART TX/RX loopback operation.

![UART Loopback Waveform](images/UART_Waveform.png)

## Tools Used

* **HDL:** Verilog
* **EDA:** Xilinx Vivado
* **Verification:** RTL simulation and waveform analysis
* **Version Control:** Git / GitHub

## Project Structure

```text
UART-Verilog-Transceiver/
│
├── rtl/
│   ├── baud.v
│   ├── tx.v
│   ├── uart_rx.v
│   └── uart_top.v
│
├── testbench/
│   └── uart_top_tb.v
│
├── README.md
└── .gitignore
```

## Future Improvements

* Parity-bit support
* Configurable data width
* Configurable stop-bit selection
* FPGA hardware implementation
* Hardware loopback demonstration
* Additional corner-case verification
