#include <stdint.h>

// ============================================================================
// MAPA DE MEMORIA DE PERIFERICOS (PicoSoC - DE2-115 @ 50 MHz)
// ============================================================================
#define REG_UART_CLKDIV (*(volatile uint32_t *)0x02000004) // Divisor de baudios UART
#define REG_UART_DAT    (*(volatile int32_t  *)0x02000008) // TX (escritura) / RX (lectura, -1 si vacio)
#define REG_LEDS        (*(volatile uint32_t *)0x03000000) // Salida LEDs rojos LEDR[3:0] (RW)
#define REG_SW          (*(volatile uint32_t *)0x03000004) // Entrada switches SW[3:0] (RO)

// 50,000,000 Hz / 115,200 baudios = 434.02 -> 434
#define UART_BAUD_DIV   434u

// Retardos aproximados por software para reloj de 50 MHz
#define DELAY_BLINK     400000u
#define DELAY_FAST      150000u
#define DELAY_SHOW_SOL  900000u

// Bandera global para filtrar pares CRLF (\r\n) enviados por PuTTY
static uint8_t g_last_was_cr = 0;

// ============================================================================
// UTILIDADES DE TIEMPO Y UART
// ============================================================================
static void delay_cycles(uint32_t count) {
    for (volatile uint32_t i = 0; i < count; i++) {
        __asm__ volatile ("nop");
    }
}

static void uart_putc(char c) {
    if (c == '\n') {
        REG_UART_DAT = '\r';
    }
    REG_UART_DAT = (uint8_t)c;
}

static void uart_puts(const char *s) {
    while (*s) {
        uart_putc(*s++);
    }
}

static void uart_print_int(int32_t val) {
    char buf[12];
    int idx = 0;
    uint32_t mag;

    if (val < 0) {
        uart_putc('-');
        mag = (uint32_t)(-(val + 1)) + 1u;
    } else {
        mag = (uint32_t)val;
    }

    if (mag == 0) {
        uart_putc('0');
        return;
    }

    while (mag > 0) {
        buf[idx++] = (char)('0' + (mag % 10u));
        mag /= 10u;
    }

    while (idx > 0) {
        uart_putc(buf[--idx]);
    }
}

static void uart_print_hex4(uint32_t val) {
    uint32_t nib = val & 0x0Fu;
    uart_puts("0x");
    uart_putc((nib < 10u) ? (char)('0' + nib) : (char)('A' + (nib - 10u)));
}

static void uart_print_bin4(uint32_t val) {
    uart_puts("0b");
    for (int i = 3; i >= 0; i--) {
        uart_putc(((val >> i) & 1u) ? '1' : '0');
    }
}

// ============================================================================
// PARSEO DE CADENAS Y NUMEROS (SIN LIBRERIA ESTANDAR)
// ============================================================================
static int str_eq(const char *a, const char *b) {
    while (*a && *b) {
        if (*a != *b) return 0;
        a++;
        b++;
    }
    return (*a == '\0' && *b == '\0');
}

// Parsea entero con signo en decimal (para calc)
static int parse_int(const char *s, int32_t *out) {
    int neg = 0;
    uint32_t acc = 0;

    if (!s || *s == '\0') return 0;
    if (*s == '-') {
        neg = 1;
        s++;
    } else if (*s == '+') {
        s++;
    }
    if (*s == '\0') return 0;

    while (*s) {
        if (*s < '0' || *s > '9') return 0;
        acc = (acc * 10u) + (uint32_t)(*s - '0');
        s++;
    }

    *out = neg ? -(int32_t)acc : (int32_t)acc;
    return 1;
}

// Parsea entero sin signo en decimal, hexadecimal (0x..) o binario (0b..)
static int parse_uint_auto(const char *s, uint32_t *out) {
    uint32_t acc = 0;

    if (!s || *s == '\0') return 0;

    if (s[0] == '0' && (s[1] == 'x' || s[1] == 'X')) {
        s += 2;
        if (*s == '\0') return 0;
        while (*s) {
            uint32_t d;
            if (*s >= '0' && *s <= '9')      d = (uint32_t)(*s - '0');
            else if (*s >= 'a' && *s <= 'f') d = (uint32_t)(*s - 'a' + 10);
            else if (*s >= 'A' && *s <= 'F') d = (uint32_t)(*s - 'A' + 10);
            else return 0;
            acc = (acc << 4) | d;
            s++;
        }
    } else if (s[0] == '0' && (s[1] == 'b' || s[1] == 'B')) {
        s += 2;
        if (*s == '\0') return 0;
        while (*s) {
            if (*s != '0' && *s != '1') return 0;
            acc = (acc << 1) | (uint32_t)(*s - '0');
            s++;
        }
    } else {
        while (*s) {
            if (*s < '0' || *s > '9') return 0;
            acc = (acc * 10u) + (uint32_t)(*s - '0');
            s++;
        }
    }

    *out = acc;
    return 1;
}

// Lee una linea por UART con eco y soporte de Backspace
static void read_line(char *buf, int max_len) {
    int len = 0;

    while (1) {
        int32_t c = REG_UART_DAT;
        if (c < 0) continue;

        if (c == '\r') {
            g_last_was_cr = 1;
            uart_putc('\n');
            buf[len] = '\0';
            return;
        }
        if (c == '\n') {
            if (g_last_was_cr) {
                g_last_was_cr = 0;
                continue;
            }
            uart_putc('\n');
            buf[len] = '\0';
            return;
        }
        g_last_was_cr = 0;

        // Backspace o DEL
        if (c == '\b' || c == 0x7F) {
            if (len > 0) {
                len--;
                uart_puts("\b \b");
            }
            continue;
        }

        // Caracteres imprimibles ASCII
        if (c >= 32 && c <= 126 && len < (max_len - 1)) {
            buf[len++] = (char)c;
            uart_putc((char)c);
        }
    }
}

// Divide una linea en tokens separados por espacios o tabulaciones
static int tokenize(char *line, char *argv[], int max_args) {
    int argc = 0;
    char *p = line;

    while (*p && argc < max_args) {
        while (*p == ' ' || *p == '\t') p++;
        if (*p == '\0') break;
        argv[argc++] = p;
        while (*p && *p != ' ' && *p != '\t') p++;
        if (*p) {
            *p = '\0';
            p++;
        }
    }
    return argc;
}

// ============================================================================
// IMPLEMENTACION DE LOS COMANDOS
// ============================================================================

// Comando 1: help
static void cmd_help(void) {
    uart_puts("Comandos disponibles:\n");
    uart_puts("  help               - Lista los comandos disponibles\n");
    uart_puts("  led <n> <on|off>   - Enciende o apaga el LED n (0..3)\n");
    uart_puts("  calc <a> <op> <b>  - Opera dos enteros (+ - * /)\n");
    uart_puts("  leds <valor>       - Escribe valor en LEDs (ej: 0x0A, 10, 0b1010)\n");
    uart_puts("  sw                 - Lee los switches SW3..SW0 y muestra su estado\n");
    uart_puts("  blink <n> <veces>  - Parpadea el LED n (0..3) las veces indicadas\n");
    uart_puts("  reto               - Comando propio: juego binario con SW y LEDs\n");
    uart_puts("  auto               - Extra: patron de luces Auto Fantastico\n");
}

// Comando 2: led <n> <on|off>
static void cmd_led(int argc, char *argv[]) {
    uint32_t n;

    if (argc != 3 || !parse_uint_auto(argv[1], &n) || n > 3u) {
        uart_puts("Uso: led <0..3> <on|off>\n");
        return;
    }

    uint32_t state = REG_LEDS & 0x0Fu;
    if (str_eq(argv[2], "on")) {
        state |= (1u << n);
    } else if (str_eq(argv[2], "off")) {
        state &= ~(1u << n);
    } else {
        uart_puts("Uso: led <0..3> <on|off>\n");
        return;
    }

    REG_LEDS = state;
    uart_puts("ok - leds = ");
    uart_print_bin4(state);
    uart_putc('\n');
}

// Comando 3: calc <a> <op> <b>
static void cmd_calc(int argc, char *argv[]) {
    int32_t a, b, res = 0;

    if (argc != 4 || !parse_int(argv[1], &a) || !parse_int(argv[3], &b) || argv[2][1] != '\0') {
        uart_puts("Uso: calc <a> <+|-|*|/> <b>\n");
        return;
    }

    char op = argv[2][0];
    if (op == '+') {
        res = a + b;
    } else if (op == '-') {
        res = a - b;
    } else if (op == '*') {
        res = a * b;
    } else if (op == '/') {
        if (b == 0) {
            uart_puts("Error: division por cero\n");
            return;
        }
        res = a / b;
    } else {
        uart_puts("Operador invalido. Use: + - * /\n");
        return;
    }

    uart_print_int(a);
    uart_putc(' ');
    uart_putc(op);
    uart_putc(' ');
    uart_print_int(b);
    uart_puts(" = ");
    uart_print_int(res);
    uart_putc('\n');
}

// Comando 4: leds <valor>
static void cmd_leds(int argc, char *argv[]) {
    uint32_t val;

    if (argc != 2 || !parse_uint_auto(argv[1], &val)) {
        uart_puts("Uso: leds <valor> (ej: leds 0x0A, leds 10, leds 0b1010)\n");
        return;
    }

    uint32_t masked = val & 0x0Fu;
    REG_LEDS = masked;

    uart_puts("ok - leds = ");
    uart_print_bin4(masked);
    uart_puts(" (");
    uart_print_hex4(masked);
    uart_puts(")\n");
}

// Comando 5: sw
static void cmd_sw(void) {
    uint32_t sw_val = REG_SW & 0x0Fu;

    uart_puts("switches = ");
    uart_print_bin4(sw_val);
    uart_puts(" (dec=");
    uart_print_int((int32_t)sw_val);
    uart_puts(", hex=");
    uart_print_hex4(sw_val);
    uart_puts(")\n");
}

// Comando 6: blink <n> <veces>
static void cmd_blink(int argc, char *argv[]) {
    uint32_t n, veces;

    if (argc != 3 || !parse_uint_auto(argv[1], &n) || !parse_uint_auto(argv[2], &veces) ||
        n > 3u || veces == 0u || veces > 50u) {
        uart_puts("Uso: blink <0..3> <1..50>\n");
        return;
    }

    uint32_t mask = (1u << n);
    uint32_t base = REG_LEDS & 0x0Fu;

    for (uint32_t i = 0; i < veces; i++) {
        REG_LEDS = base | mask;
        delay_cycles(DELAY_BLINK);
        REG_LEDS = base & ~mask;
        delay_cycles(DELAY_BLINK);
    }

    uart_puts("ok\n");
}

// Auxiliares para Comando 7 (reto)
static void wait_enter_entropy(uint32_t *seed) {
    while (1) {
        (*seed)++;
        int32_t c = REG_UART_DAT;
        if (c < 0) continue;

        if (c == '\r') {
            g_last_was_cr = 1;
            return;
        }
        if (c == '\n') {
            if (g_last_was_cr) {
                g_last_was_cr = 0;
                continue;
            }
            return;
        }
        g_last_was_cr = 0;
    }
}

static uint32_t lfsr_rand_1_15(uint32_t *seed, uint32_t prev) {
    uint32_t s = (*seed) & 0xFFFFu;
    if (s == 0u) s = 0xACE1u;

    uint32_t val = prev;
    while (val == prev || val == 0u) {
        uint32_t bit = ((s >> 0) ^ (s >> 2) ^ (s >> 3) ^ (s >> 5)) & 1u;
        s = (s >> 1) | (bit << 15);
        val = s & 0x0Fu;
    }
    *seed = s;
    return val;
}

// Comando 7 (Propio): reto - Juego interactivo UART + Switches + LEDs
static void cmd_reto(void) {
    uint32_t seed = 0x5A3Cu;
    uint32_t prev = 0u;
    uint32_t score = 0u;

    REG_LEDS = 0x00u;
    uart_puts("\n=== RETO BINARIO (3 rondas) ===\n");
    uart_puts("Forma el numero decimal en SW3..SW0 y presiona Enter.\n");
    uart_puts("Presiona Enter para comenzar...");
    wait_enter_entropy(&seed);
    uart_putc('\n');

    for (uint32_t ronda = 1u; ronda <= 3u; ronda++) {
        uint32_t target = lfsr_rand_1_15(&seed, prev);
        prev = target;

        uart_puts("\nRonda ");
        uart_print_int((int32_t)ronda);
        uart_puts("/3 -> Forma el numero decimal: ");
        uart_print_int((int32_t)target);
        uart_puts("\nAjusta SW3..SW0 y presiona Enter...");
        wait_enter_entropy(&seed);
        uart_putc('\n');

        uint32_t sw_val = REG_SW & 0x0Fu;

        if (sw_val == target) {
            score++;
            uart_puts("Correcto! Leido: ");
            uart_print_bin4(sw_val);
            uart_puts(" (");
            uart_print_int((int32_t)sw_val);
            uart_puts(")\n");

            // 3 destellos rapidos de acierto
            for (int k = 0; k < 3; k++) {
                REG_LEDS = 0x0Fu;
                delay_cycles(DELAY_FAST);
                REG_LEDS = 0x00u;
                delay_cycles(DELAY_FAST);
            }
        } else {
            uart_puts("Fallo! Leido: ");
            uart_print_bin4(sw_val);
            uart_puts(" (");
            uart_print_int((int32_t)sw_val);
            uart_puts(") | Esperado: ");
            uart_print_bin4(target);
            uart_puts(" (");
            uart_print_int((int32_t)target);
            uart_puts(")\nMostrando solucion en LEDR3..LEDR0...\n");

            REG_LEDS = target;
            delay_cycles(DELAY_SHOW_SOL);
            REG_LEDS = 0x00u;
        }
    }

    uart_puts("\nPuntaje final: ");
    uart_print_int((int32_t)score);
    uart_puts("/3\n");

    if (score == 3u) {
        uart_puts("Excelente! 3/3 aciertos.\n");
        for (int r = 0; r < 2; r++) {
            for (int i = 0; i < 4; i++) {
                REG_LEDS = (1u << i);
                delay_cycles(DELAY_FAST);
            }
            for (int i = 2; i >= 1; i--) {
                REG_LEDS = (1u << i);
                delay_cycles(DELAY_FAST);
            }
        }
    }
    REG_LEDS = 0x00u;
}

// Comando extra: auto - Patron Auto Fantastico (3 ciclos)
static void cmd_auto(void) {
    for (int ciclo = 0; ciclo < 3; ciclo++) {
        for (int i = 0; i < 4; i++) {
            REG_LEDS = (1u << i);
            delay_cycles(DELAY_FAST);
        }
        for (int i = 2; i >= 1; i--) {
            REG_LEDS = (1u << i);
            delay_cycles(DELAY_FAST);
        }
    }
    REG_LEDS = 0x00u;
    uart_puts("ok\n");
}

// ============================================================================
// DESPACHADOR DE COMANDOS Y BUCLE PRINCIPAL
// ============================================================================
static void process_command(char *line) {
    char *argv[6];
    int argc = tokenize(line, argv, 6);

    if (argc == 0) return;

    if (str_eq(argv[0], "help")) {
        cmd_help();
    } else if (str_eq(argv[0], "led")) {
        cmd_led(argc, argv);
    } else if (str_eq(argv[0], "calc")) {
        cmd_calc(argc, argv);
    } else if (str_eq(argv[0], "leds")) {
        cmd_leds(argc, argv);
    } else if (str_eq(argv[0], "sw")) {
        cmd_sw();
    } else if (str_eq(argv[0], "blink")) {
        cmd_blink(argc, argv);
    } else if (str_eq(argv[0], "reto")) {
        cmd_reto();
    } else if (str_eq(argv[0], "auto")) {
        cmd_auto();
    } else {
        uart_puts("Comando desconocido. Escriba 'help'.\n");
    }
}

int main(void) {
    static char line[64];

    // Inicializar UART a 115200 baudios y apagar LEDs
    REG_UART_CLKDIV = UART_BAUD_DIV;
    REG_LEDS = 0x00u;

    uart_puts("\n=== PicoSoC UART Console (DE2-115) ===\n");
    uart_puts("Escriba 'help' para ver los comandos.\n");

    while (1) {
        uart_puts("> ");
        read_line(line, (int)sizeof(line));
        process_command(line);
    }

    return 0;
}