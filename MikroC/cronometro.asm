
_ConfigMCU:

;cronometro.c,9 :: 		void ConfigMCU()
;cronometro.c,11 :: 		ADCON1 = 0x0F; // Configura todos os pinos como digitais
	MOVLW       15
	MOVWF       ADCON1+0 
;cronometro.c,13 :: 		TRISB.B0 = 1; // Configura RB0 como entrada (botão 1)
	BSF         TRISB+0, 0 
;cronometro.c,14 :: 		TRISB.B1 = 1; // Configura RB1 como entrada (botão 2)
	BSF         TRISB+0, 1 
;cronometro.c,15 :: 		TRISD = 0x00; // Configura PORTD como saída (display de 7 segmentos)
	CLRF        TRISD+0 
;cronometro.c,16 :: 		PORTD = 0x00; // Display inicialmente desligado
	CLRF        PORTD+0 
;cronometro.c,18 :: 		INTCON2.INTEDG0 = 1; // Interrupção na borda de subida para INT0 (RB0)
	BSF         INTCON2+0, 6 
;cronometro.c,19 :: 		INTCON2.INTEDG1 = 1; // Interrupção na borda de subida para INT1 (RB1)
	BSF         INTCON2+0, 5 
;cronometro.c,21 :: 		INTCON.INT0IF = 0;  // Zera a flag de interrupção INT0
	BCF         INTCON+0, 1 
;cronometro.c,22 :: 		INTCON.INT0IE = 1;  // Habilita a interrupção INT0
	BSF         INTCON+0, 4 
;cronometro.c,23 :: 		INTCON3.INT1IF = 0; // Zera a flag de interrupção INT1
	BCF         INTCON3+0, 0 
;cronometro.c,24 :: 		INTCON3.INT1IE = 1; // Habilita a interrupção INT1
	BSF         INTCON3+0, 3 
;cronometro.c,26 :: 		INTCON.GIE = 1; // Habilita interrupções globais
	BSF         INTCON+0, 7 
;cronometro.c,27 :: 		}
L_end_ConfigMCU:
	RETURN      0
; end of _ConfigMCU

_ConfigTIMER:

;cronometro.c,30 :: 		void ConfigTIMER()
;cronometro.c,32 :: 		T0CON = 0x87;                           // Timer0 ligado, 16 bits, prescaler 1:256
	MOVLW       135
	MOVWF       T0CON+0 
;cronometro.c,33 :: 		TMR0H = (65536 - (periodo * 8)) >> 8;   // Carrega valor alto
	MOVF        _periodo+0, 0 
	MOVWF       R0 
	MOVF        _periodo+1, 0 
	MOVWF       R1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	MOVLW       0
	MOVWF       R5 
	MOVLW       0
	MOVWF       R6 
	MOVLW       1
	MOVWF       R7 
	MOVLW       0
	MOVWF       R8 
	MOVF        R0, 0 
	SUBWF       R5, 1 
	MOVF        R1, 0 
	SUBWFB      R6, 1 
	MOVLW       0
	SUBWFB      R7, 1 
	SUBWFB      R8, 1 
	MOVF        R6, 0 
	MOVWF       R0 
	MOVF        R7, 0 
	MOVWF       R1 
	MOVF        R8, 0 
	MOVWF       R2 
	MOVLW       0
	BTFSC       R8, 7 
	MOVLW       255
	MOVWF       R3 
	MOVF        R0, 0 
	MOVWF       TMR0H+0 
;cronometro.c,34 :: 		TMR0L = (65536 - (periodo * 8)) & 0xFF; // Carrega valor baixo
	MOVLW       255
	ANDWF       R5, 0 
	MOVWF       TMR0L+0 
;cronometro.c,35 :: 		INTCON.TMR0IF = 0;                      // Zera a flag de overflow do Timer0
	BCF         INTCON+0, 2 
;cronometro.c,36 :: 		INTCON.TMR0IE = 1;                      // Habilita a interrupção do Timer0
	BSF         INTCON+0, 5 
;cronometro.c,37 :: 		}
L_end_ConfigTIMER:
	RETURN      0
; end of _ConfigTIMER

_ExibirNumero:

;cronometro.c,40 :: 		void ExibirNumero(unsigned char numero)
;cronometro.c,42 :: 		PORTD = display7seg[numero]; // Exibe o número no display
	MOVLW       _display7seg+0
	MOVWF       FSR0L+0 
	MOVLW       hi_addr(_display7seg+0)
	MOVWF       FSR0L+1 
	MOVF        FARG_ExibirNumero_numero+0, 0 
	ADDWF       FSR0L+0, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR0L+1, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       PORTD+0 
;cronometro.c,43 :: 		}
L_end_ExibirNumero:
	RETURN      0
; end of _ExibirNumero

_interrupt:

;cronometro.c,46 :: 		void interrupt()
;cronometro.c,49 :: 		if (INTCON.INT0IF)
	BTFSS       INTCON+0, 1 
	GOTO        L_interrupt0
;cronometro.c,51 :: 		periodo = 1000;    // Define o período para 1 segundo
	MOVLW       232
	MOVWF       _periodo+0 
	MOVLW       3
	MOVWF       _periodo+1 
;cronometro.c,52 :: 		start_count = 1;   // Inicia a contagem
	MOVLW       1
	MOVWF       _start_count+0 
;cronometro.c,53 :: 		INTCON.INT0IF = 0; // Zera a flag de interrupção INT0
	BCF         INTCON+0, 1 
;cronometro.c,54 :: 		}
L_interrupt0:
;cronometro.c,57 :: 		if (INTCON3.INT1IF)
	BTFSS       INTCON3+0, 0 
	GOTO        L_interrupt1
;cronometro.c,59 :: 		periodo = 250;     // Define o período para 0,25 segundos
	MOVLW       250
	MOVWF       _periodo+0 
	MOVLW       0
	MOVWF       _periodo+1 
;cronometro.c,60 :: 		start_count = 1;    // Inicia a contagem
	MOVLW       1
	MOVWF       _start_count+0 
;cronometro.c,61 :: 		INTCON3.INT1IF = 0; // Zera a flag de interrupção INT1
	BCF         INTCON3+0, 0 
;cronometro.c,62 :: 		}
L_interrupt1:
;cronometro.c,65 :: 		if (INTCON.TMR0IF)
	BTFSS       INTCON+0, 2 
	GOTO        L_interrupt2
;cronometro.c,67 :: 		if (start_count)
	MOVF        _start_count+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt3
;cronometro.c,69 :: 		contador++; // Incrementa o contador
	INCF        _contador+0, 1 
;cronometro.c,70 :: 		if (contador > 9)
	MOVF        _contador+0, 0 
	SUBLW       9
	BTFSC       STATUS+0, 0 
	GOTO        L_interrupt4
;cronometro.c,71 :: 		contador = 0;       // Reinicia a contagem após 9
	CLRF        _contador+0 
L_interrupt4:
;cronometro.c,72 :: 		ExibirNumero(contador); // Exibe o número no display
	MOVF        _contador+0, 0 
	MOVWF       FARG_ExibirNumero_numero+0 
	CALL        _ExibirNumero+0, 0
;cronometro.c,73 :: 		}
L_interrupt3:
;cronometro.c,76 :: 		TMR0H = (65536 - (periodo * 8)) >> 8;   // Carrega valor alto
	MOVF        _periodo+0, 0 
	MOVWF       R0 
	MOVF        _periodo+1, 0 
	MOVWF       R1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	MOVLW       0
	MOVWF       R5 
	MOVLW       0
	MOVWF       R6 
	MOVLW       1
	MOVWF       R7 
	MOVLW       0
	MOVWF       R8 
	MOVF        R0, 0 
	SUBWF       R5, 1 
	MOVF        R1, 0 
	SUBWFB      R6, 1 
	MOVLW       0
	SUBWFB      R7, 1 
	SUBWFB      R8, 1 
	MOVF        R6, 0 
	MOVWF       R0 
	MOVF        R7, 0 
	MOVWF       R1 
	MOVF        R8, 0 
	MOVWF       R2 
	MOVLW       0
	BTFSC       R8, 7 
	MOVLW       255
	MOVWF       R3 
	MOVF        R0, 0 
	MOVWF       TMR0H+0 
;cronometro.c,77 :: 		TMR0L = (65536 - (periodo * 8)) & 0xFF; // Carrega valor baixo
	MOVLW       255
	ANDWF       R5, 0 
	MOVWF       TMR0L+0 
;cronometro.c,79 :: 		INTCON.TMR0IF = 0; // Zera a flag de overflow do Timer0
	BCF         INTCON+0, 2 
;cronometro.c,80 :: 		}
L_interrupt2:
;cronometro.c,81 :: 		}
L_end_interrupt:
L__interrupt11:
	RETFIE      1
; end of _interrupt

_main:

;cronometro.c,84 :: 		void main()
;cronometro.c,86 :: 		ConfigMCU();   // Configura o microcontrolador
	CALL        _ConfigMCU+0, 0
;cronometro.c,87 :: 		ConfigTIMER(); // Configura o Timer0
	CALL        _ConfigTIMER+0, 0
;cronometro.c,89 :: 		while (1)
L_main5:
;cronometro.c,92 :: 		}
	GOTO        L_main5
;cronometro.c,93 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
