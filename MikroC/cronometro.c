// Mapeamento dos números no display de 7 segmentos (comum cátodo)
char display7seg[10] = {0x6F, 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F};

unsigned char contador = 0;    // Contador de 0 a 9
unsigned int periodo = 1000;   // Período de 1 segundo (1000 ms)
unsigned char start_count = 0; // Flag para iniciar a contagem

// Configuração do Microcontrolador
void ConfigMCU()
{
    ADCON1 = 0x0F; // Configura todos os pinos como digitais

    TRISB.B0 = 1; // Configura RB0 como entrada (botão 1)
    TRISB.B1 = 1; // Configura RB1 como entrada (botão 2)
    TRISD = 0x00; // Configura PORTD como saída (display de 7 segmentos)
    PORTD = 0x00; // Display inicialmente desligado

    INTCON2.INTEDG0 = 1; // Interrupção na borda de subida para INT0 (RB0)
    INTCON2.INTEDG1 = 1; // Interrupção na borda de subida para INT1 (RB1)

    INTCON.INT0IF = 0;  // Zera a flag de interrupção INT0
    INTCON.INT0IE = 1;  // Habilita a interrupção INT0
    INTCON3.INT1IF = 0; // Zera a flag de interrupção INT1
    INTCON3.INT1IE = 1; // Habilita a interrupção INT1

    INTCON.GIE = 1; // Habilita interrupções globais
}

// Configuração do Timer0
void ConfigTIMER()
{
    T0CON = 0x87;                           // Timer0 ligado, 16 bits, prescaler 1:256
    TMR0H = (65536 - (periodo * 8)) >> 8;   // Carrega valor alto
    TMR0L = (65536 - (periodo * 8)) & 0xFF; // Carrega valor baixo
    INTCON.TMR0IF = 0;                      // Zera a flag de overflow do Timer0
    INTCON.TMR0IE = 1;                      // Habilita a interrupção do Timer0
}

// Função para exibir o número no display de 7 segmentos
void ExibirNumero(unsigned char numero)
{
    PORTD = display7seg[numero]; // Exibe o número no display
}

// Interrupção para o botão 1 (RB0 - INT0) e Timer0
void interrupt()
{
    // Verifica se a interrupção veio do botão 1 (RB0 - INT0)
    if (INTCON.INT0IF)
    {
        periodo = 1000;    // Define o período para 1 segundo
        start_count = 1;   // Inicia a contagem
        INTCON.INT0IF = 0; // Zera a flag de interrupção INT0
    }

    // Verifica se a interrupção veio do botão 2 (RB1 - INT1)
    if (INTCON3.INT1IF)
    {
        periodo = 250;     // Define o período para 0,25 segundos
        start_count = 1;    // Inicia a contagem
        INTCON3.INT1IF = 0; // Zera a flag de interrupção INT1
    }

    // Verifica se houve overflow no Timer0
    if (INTCON.TMR0IF)
    {
        if (start_count)
        {
            contador++; // Incrementa o contador
            if (contador > 9)
                contador = 0;       // Reinicia a contagem após 9
            ExibirNumero(contador); // Exibe o número no display
        }

        // Recarrega o Timer0 com o novo período
        TMR0H = (65536 - (periodo * 8)) >> 8;   // Carrega valor alto
        TMR0L = (65536 - (periodo * 8)) & 0xFF; // Carrega valor baixo

        INTCON.TMR0IF = 0; // Zera a flag de overflow do Timer0
    }
}

// Programa principal
void main()
{
    ConfigMCU();   // Configura o microcontrolador
    ConfigTIMER(); // Configura o Timer0

    while (1)
    {
        // Loop infinito, contagem controlada por interrupções
    }
}