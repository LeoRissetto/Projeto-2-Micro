#line 1 "Z:/Users/leorissetto/Documents/GitHub/Projeto-2-Micro/MikroC/cronometro.c"

char display7seg[10] = {0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F};

unsigned char contador = 0;
unsigned int periodo = 4000;
unsigned char start_count = 0;


void ConfigMCU()
{
 ADCON1 = 0x0F;

 TRISB.B0 = 1;
 TRISB.B1 = 1;
 TRISD = 0x00;
 PORTD = 0x00;

 INTCON2.INTEDG0 = 1;
 INTCON2.INTEDG1 = 1;

 INTCON.INT0IF = 0;
 INTCON.INT0IE = 1;
 INTCON3.INT1IF = 0;
 INTCON3.INT1IE = 1;

 INTCON.GIE = 1;
}


void ConfigTIMER()
{
 T0CON = 0x87;
 TMR0H = (65536 - (periodo * 2)) >> 8;
 TMR0L = (65536 - (periodo * 2)) & 0xFF;
 INTCON.TMR0IF = 0;
 INTCON.TMR0IE = 1;
}


void ExibirNumero(unsigned char numero)
{
 PORTD = display7seg[numero];
}


void interrupt()
{

 if (INTCON.INT0IF)
 {
 periodo = 4000;
 start_count = 1;
 INTCON.INT0IF = 0;
 }


 if (INTCON3.INT1IF)
 {
 periodo = 1000;
 start_count = 1;
 INTCON3.INT1IF = 0;
 }


 if (INTCON.TMR0IF)
 {
 if (start_count)
 {
 contador++;
 if (contador > 9)
 contador = 0;
 ExibirNumero(contador);
 }


 TMR0H = (65536 - (periodo * 2)) >> 8;
 TMR0L = (65536 - (periodo * 2)) & 0xFF;

 INTCON.TMR0IF = 0;
 }
}


void main()
{
 ConfigMCU();
 ConfigTIMER();

 while (1)
 {

 }
}
