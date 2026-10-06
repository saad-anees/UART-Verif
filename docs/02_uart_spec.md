# UART programming and timing specification

This is an original teaching peripheral, not 16550-compatible. It exposes APB3
with 16-bit **byte addresses** and 32-bit whole-register transfers. PREADY is
always high. There are no byte strobes, modem pins, DMA or transmit FIFO.

## Register map

All unlisted bits read as zero; reserved write bits are ignored, except BAUD
values outside the stated range are rejected as complete 32-bit values.

| Offset | Register | Access | Reset | Fields / effects |
| --- | --- | --- | --- | --- |
| 0x00 | CTRL | RW | 0 | bit 0 enable; 1 parity enable; 2 odd parity; 3 two stop bits |
| 0x04 | BAUD | RW | 16 | bits 15:0 clocks per bit; valid full write values 4..65535 |
| 0x08 | TXDATA | WO | — | bits 7:0 launch TX; rejected if disabled or busy |
| 0x0C | RXDATA | RO, pop | — | bits 7:0 oldest RX byte; successful read removes one entry |
| 0x10 | STATUS | RO | 0 | bit 0 TX busy; 1 RX nonempty; 2 parity; 3 framing; 4 overrun |
| 0x14 | IRQ_EN | RW | 0 | bit 0 RX-nonempty mask; bit 1 any-error mask |
| 0x18 | IRQ_STATUS | RO | 0 | bit 0 RX nonempty; bit 1 OR of sticky errors; independent of masks |
| 0x1C | ERR_CLEAR | WO/W1C | — | bits 2,3,4 clear corresponding sticky error flags |

RXDATA has no meaningful reset data; an empty read returns zero with PSLVERR.
ERR_CLEAR is a command port, not a readable copy of the error flags. A new error
on the same edge as a clear wins. W1C zero bits leave their flags unchanged.

IRQ is level-sensitive:

`IRQ = (IRQ_EN[0] && RX_nonempty) || (IRQ_EN[1] && any_sticky_error)`

Draining the FIFO removes the RX cause. Errors persist until W1C or reset.
Disabling a mask deasserts IRQ without clearing the underlying cause.

## Access errors

PSLVERR is asserted on the completing APB access for unmapped or misaligned
addresses, reads of write-only ports, writes of read-only registers, empty RX
reads, TX writes while disabled/busy, invalid BAUD values, and CTRL/BAUD writes
while TX or RX is active. Error accesses have no register or FIFO side effects.

Only idle reconfiguration is supported. Wait for TX_BUSY=0 and finish external
RX traffic before changing CTRL/BAUD. There is no RX_BUSY software bit in this
small example. Disabling the UART retains existing FIFO data and sticky flags.
Reset clears configuration, FIFO occupancy, error flags, masks and serializers.

## Frame format

| Segment | Length | Value |
| --- | --- | --- |
| Idle | Arbitrary | 1 |
| Start | 1 bit | 0 |
| Data | 8 bits | Least-significant bit first |
| Optional parity | 1 bit | XOR of data for even; its inverse for odd |
| Stop | 1 or 2 bits | 1 |

The parity bit makes the XOR of data plus parity zero for even parity or one for
odd parity. Parity is disabled when CTRL[1]=0, regardless of CTRL[2]. A frame is
10, 11 or 12 bits long. The TX format is constructed from the configuration when
TXDATA is accepted. Reconfiguration is rejected until it completes.

`baud_rate = peripheral_clock_hz / BAUD`

At the supplied 100 MHz clock, BAUD=16 means 6.25 Mbaud. Small divisors make the
teaching regression fast; they are not a default 115200-baud configuration.
BAUD=868 gives approximately 115207.4 baud at 100 MHz.

RX passes through a two-flop synchronizer, validates the start near its center,
and samples subsequent bits once per divisor. This is not a majority-voting
oversampling receiver. It stores bad frames and sets sticky flags. At a full
FIFO it discards the newly received byte, preserving the four old bytes.
A simultaneous valid RX completion and pop can replace an entry without overflow.

## APB transfer example

| Clock event | Master action / observation |
| --- | --- |
| Falling edge A | PSEL=1, PENABLE=0, stable address/direction/data (SETUP) |
| Rising edge A | Slave observes SETUP |
| Falling edge B | PENABLE=1 (ACCESS) |
| Rising edge B | With PREADY=1, both sides observe completion |
| Falling edge C | Driver returns bus to idle and completes the sequence item |

## Reset contract

The top holds reset for five clock cycles. UVM is the only runtime reset owner.
Reset may interrupt TX/RX; monitors and driver abandon partial frames and the
scoreboard clears corresponding expectations. APB reset is tested only while
idle. A reset during an APB transfer is explicitly fatal in the bus driver.
