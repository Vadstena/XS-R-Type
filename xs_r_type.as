;Joao Silva  79730

;###Constantes###

SP_INICIAL      EQU     FDFFh
INT_MASK_ADDR   EQU     FFFAh
INT_MASK        EQU     1100000000011111b
INT_MASK_START  EQU     0100000000000000b
INT_MASK_REST   EQU     0111111111111111b
MASCARA         EQU     1000000000010110b
DISPLAY_1       EQU     FFF0h
DISPLAY_2       EQU     FFF1h
DISPLAY_3       EQU     FFF2h
DISPLAY_4       EQU     FFF3h
LCD_CONTROL     EQU     FFF4h
LCD_WRITE       EQU     FFF5h
INTERV_TEMP     EQU     FFF6h
CONTROL_TEMP    EQU     FFF7h
LEDS            EQU     FFF8h
SWITCHES        EQU     FFF9h
JANELA_CTRL     EQU     FFFCh
JANELA_WRITE    EQU     FFFEh
CR              EQU     0Ah
FIM_TEXTO       EQU     '@'



;###Variaveis, Flags e outras Pos de memoria auxiliares###

                ORIG    8000h
                
Texto1          STR     'Prepare-se', FIM_TEXTO
Texto2          STR     'Prima o botao IE', FIM_TEXTO
Texto3          STR     'Fim do Jogo', FIM_TEXTO
Texto4          STR     'Pontos', FIM_TEXTO
                                                
NumAleat        WORD    0000h

Pont1           WORD    0000h
Pont2           WORD    0000h
Pont3           WORD    0000h
Pont4           WORD    0000h

FlagStart       WORD    0000h

FlagEndState    WORD    0000h

FlagBaixo       WORD    0000h
FlagCima        WORD    0000h
FlagDir         WORD    0000h
FlagEsq         WORD    0000h

NumTiros        WORD    0000h
FlagNovoTiro    WORD    0000h
FlagActTiros    WORD    0001h
TirosList       TAB     500

NumAst          WORD    0000h
NumBur          WORD    0000h
TipoObst        WORD    0003h              ;0 = buraco negro/ 1,2,3 = asteroide
FlagNovoObst    WORD    0000h
FlagActObst     WORD    0002h
AstList         TAB     15                 ;lista que guarda asteroides 
BurList         TAB     5                  ;lista que guarda buracos negros
                                                
                                                
                                                
;###Tabela de interrupcoes###

                ORIG    FE00h
INT0            WORD    BaixoINT
INT1            WORD    CimaINT
INT2            WORD    EsquerdaINT
INT3            WORD    DireitaINT
INT4            WORD    NovoTiroINT
INT5            WORD    StartINT
INT6            WORD    StartINT
INT7            WORD    StartINT
INT8            WORD    StartINT
INT9            WORD    StartINT
INT10           WORD    StartINT
INT11           WORD    StartINT
INT12           WORD    StartINT
INT13           WORD    StartINT
INT14           WORD    StartINT
INT15           WORD    TempINT  



;###Codigo###

                ORIG    0000h
                JMP     Inicio

                
;----------ROTINAS DE INTERRUPCAO----------                
                
BaixoINT:       INC     M[FlagBaixo]
                CMP     M[FlagEndState], R0
                BR.Z    BSkip
                INC     M[FlagStart]
BSkip:          RTI  
                
CimaINT:        INC     M[FlagCima]
                CMP     M[FlagEndState], R0
                BR.Z    CSkip
                INC     M[FlagStart]
CSkip:          RTI  
                
DireitaINT:     INC     M[FlagDir]
                CMP     M[FlagEndState], R0
                BR.Z    DSkip
                INC     M[FlagStart]
DSkip:          RTI  
                
EsquerdaINT:    INC     M[FlagEsq]
                CMP     M[FlagEndState], R0
                BR.Z    ESkip
                INC     M[FlagStart]
ESkip:          RTI               

NovoTiroINT:    INC     M[FlagNovoTiro]
                CMP     M[FlagEndState], R0
                BR.Z    NSkip
                INC     M[FlagStart]
NSkip:          RTI  
                
StartINT:       INC     M[FlagStart]
                RTI
                
TempINT:        DEC     M[FlagActObst]
                BR.NN   TempSkip
                MOV     M[FlagActObst], R0
TempSkip:       MOV     M[FlagActTiros], R0
                MOV     R7, 1
                MOV     M[INTERV_TEMP], R7
                MOV     R7, 1
                MOV     M[CONTROL_TEMP], R7
                RTI

                
;----------FUNCOES AUXILIARES----------

LigaLEDs:       PUSH    R1
                MOV     R1, M[NumAleat]
                MOV     M[LEDS], R1
                POP     R1
                RET

                
DesligaLEDs:    MOV     M[LEDS], R0
                RET
               
               
INCPontuacao:   PUSH    R1
                MOV     R1, 000Ah
                INC     M[Pont1]
                CMP     M[Pont1], R1
                BR.NZ   INCPontSkip
                MOV     M[Pont1], R0
                INC     M[Pont2]
                CMP     M[Pont2], R1
                BR.NZ   INCPontSkip
                MOV     M[Pont2], R0
                INC     M[Pont3]
                CMP     M[Pont3], R1
                BR.NZ   INCPontSkip
                MOV     M[Pont3], R0
                INC     M[Pont4]
INCPontSkip:    MOV     R1, M[Pont1]
                MOV     M[DISPLAY_1], R1
                MOV     R1, M[Pont2]
                MOV     M[DISPLAY_2], R1
                MOV     R1, M[Pont3]
                MOV     M[DISPLAY_3], R1
                MOV     R1, M[Pont4]
                MOv     M[DISPLAY_4], R1
                POP     R1
                RET

                
LimpaDisplay:   MOV     M[DISPLAY_1], R0
                MOV     M[DISPLAY_2], R0
                MOV     M[DISPLAY_3], R0
                MOV     M[DISPLAY_4], R0
                RET
                
                
LimpaJanela:    MOV     R2, 0000h
LimpJanCiclo:   CMP     R2, 1800h
                BR.Z    LimpJanSkip
                CALL    LimpaLinha
                ADD     R2, 0100h
                BR      LimpJanCiclo
LimpJanSkip:    RET

LimpaLinha:     MOV     R1, R0
                PUSH    R2
                MOV     R3, ' '
LimpLinCicl:    CMP     R1, 79
                BR.Z    LinhaLimpa
                MOV     M[JANELA_CTRL], R2
                MOV     M[JANELA_WRITE], R3
                INC     R2
                INC     R1
                BR      LimpLinCicl
LinhaLimpa:     POP     R2
                RET


EscString:      MOV     R1, M[R2]
                CMP     R1, FIM_TEXTO
                BR.Z    FimEsc
                MOV     M[JANELA_CTRL], R3
                MOV     M[JANELA_WRITE], R1
                INC     R2
                INC     R3
                BR      EscString
FimEsc:         RET


Intro:          DSI
                MOV     R3, FFFFh
                MOV     M[JANELA_CTRL], R3
                CALL    LimpaJanela
                MOV     R3, 0B23h
                MOV     R2, Texto1
                CALL    EscString
                MOV     R3, 0D20h
                MOV     R2, Texto2
                CALL    EscString
                CALL    DesligaLEDs
                CALL    LimpaDisplay
                MOV     M[NumAleat], R0
                MOV     M[Pont1], R0
                MOV     M[Pont2], R0
                MOV     M[Pont3], R0
                MOV     M[Pont4], R0
                MOV     M[FlagStart], R0
                MOV     M[FlagEndState], R0
                MOV     M[FlagBaixo], R0
                MOV     M[FlagCima], R0
                MOV     M[FlagDir], R0
                MOV     M[FlagEsq], R0
                MOV     R3, M[NumTiros]
                MOV     M[NumTiros], R0
                MOV     M[FlagNovoTiro], R0
                MOV     R3, 0001h
                MOV     M[FlagActTiros], R3
                MOV     M[NumAst], R0
                MOV     M[NumBur], R0
                MOV     R3, 0003h
                MOV     M[TipoObst], R3
                MOV     M[FlagNovoObst], R0
                MOV     R3, 0002h
                MOV     M[FlagActObst], R3
                ENI
IntroCiclo:     INC     M[NumAleat]
                CMP     M[FlagStart], R0
                BR.Z    IntroCiclo
                DSI
                MOV     R2, 0B00h
                CALL    LimpaLinha
                MOV     R2, 0D00h
                CALL    LimpaLinha
                RET
                
                
InitTerreno:    MOV     R7, '#'
                MOV     R6, 174Eh
Linha1:         MOV     M[JANELA_CTRL], R6
                MOV     M[JANELA_WRITE], R7
                DEC     R6
                CMP     R6, 1700h
                BR.NN   Linha1
                MOV     R6, 004Eh
Linha2:         MOV     M[JANELA_CTRL], R6
                MOV     M[JANELA_WRITE], R7
                DEC     R6
                BR.NN   Linha2
                RET
                
                
InitNave:       MOV     R1, 0503h          ;R1 >
                MOV     R2, 0402h          ;R2 \
                MOV     R3, 0602h          ;R3 /
                CALL    DesenhaNave
                RET
                
                
DesenhaNave:    MOV     M[JANELA_CTRL], R1
                MOV     R5, '>'
                MOV	    M[JANELA_WRITE], R5
                MOV     M[JANELA_CTRL], R2
                MOV     R5, '\'
                MOV	    M[JANELA_WRITE], R5
                MOV     M[JANELA_CTRL], R3
                MOV     R5, '/'
                MOV	    M[JANELA_WRITE], R5
                DEC     R1
                MOV     M[JANELA_CTRL], R1
                MOV     R5, '|'
                MOV	    M[JANELA_WRITE], R5
                INC     R1
                RET
                
                
ApagaNave:      MOV     R5, ' '
                MOV     M[JANELA_CTRL], R1
                MOV	    M[JANELA_WRITE], R5
                MOV     M[JANELA_CTRL], R2
                MOV	    M[JANELA_WRITE], R5
                MOV     M[JANELA_CTRL], R3
                MOV	    M[JANELA_WRITE], R5
                DEC     R1
                MOV     M[JANELA_CTRL], R1
                MOV	    M[JANELA_WRITE], R5
                INC     R1
                RET                

                
;----------FIM----------

FimJogo:        DSI
                MOV     R7, INT_MASK_REST
                MOV     M[INT_MASK_ADDR], R7
                MOV     R3, 0B23h
                MOV     R2, Texto3
                CALL    EscString
                MOV     R3, 0D23h
                MOV     R6, Pont4
                MOV     R5, 4
FJCiclPts:      CMP     R5, R0
                BR.Z    FimJogoSkip
                MOV     R7, M[R6]
                ADD     R7, '0'
                MOV     M[JANELA_CTRL], R3
                MOV     M[JANELA_WRITE], R7
                DEC     R6
                DEC     R5
                INC     R3
                BR      FJCiclPts
FimJogoSkip:    MOV     R3, 0D28h
                MOV     R2, Texto4
                CALL    EscString
                MOV     M[FlagStart], R0   
                INC     M[FlagEndState]
                ENI
FimJogoCicl:    CMP     M[SWITCHES], R0
                BR.NZ   RestartGame
                CMP     R0, M[FlagStart]
                BR.Z    FimJogoCicl
RestartGame:    MOV     M[FlagEndState], R0
                JMP     Inicio
                

;----------MOVIMENTO----------                
                
Baixo:          DSI
                MOV     R6, R0
                MVBH    R6, R1
                CMP     R6, 1500h
                JMP.Z   BaixoSkip
                CALL    ApagaNave
                ADD     R1,0100h
                ADD     R2,0100h
                ADD     R3,0100h
                MOV     R7, M[NumAst]
                MOV     R6, AstList
BaixoACiclo:    CMP     R7, R0             ;percorre os asteroides 
                BR.Z    BACSkip            ;para ver se ha colisao
                CMP     M[R6], R1
                CALL.Z  FimJogo
                CMP     M[R6], R3
                CALL.Z  FimJogo
                DEC     R7
                INC     R6
                BR      BaixoACiclo                  
BACSkip:        MOV     R7, M[NumBur]
                MOV     R6, BurList
BaixoBCiclo:    CMP     R7, R0             ;percorre os burac negros
                BR.Z    BBCSkip            ;para ver se ha colisao
                CMP     M[R6], R1
                CALL.Z  FimJogo
                CMP     M[R6], R3
                CALL.Z  FimJogo
                DEC     R7
                INC     R6
                BR      BaixoBCiclo                  
BBCSkip:        CALL    DesenhaNave
BaixoSkip:      DEC     M[FlagBaixo]
                ENI
                RET
               
                
Cima:           DSI
                MOV     R6, R0
                MVBH    R6, R1
                CMP     R6, 0200h
                JMP.Z   CimaSkip
                CALL    ApagaNave
                SUB     R1,0100h
                SUB     R2,0100h
                SUB     R3,0100h
                MOV     R7, M[NumAst]
                MOV     R6, AstList
CimaACiclo:     CMP     R7, R0             ;percorre os asteroides
                BR.Z    CACSkip            ;para ver se ha colisao
                CMP     M[R6], R1
                CALL.Z  FimJogo
                CMP     M[R6], R2
                CALL.Z  FimJogo
                DEC     R7
                INC     R6
                BR      CimaACiclo                  
CACSkip:        MOV     R7, M[NumBur]
                MOV     R6, BurList
CimaBCiclo:     CMP     R7, R0             ;percorre os burac negros
                BR.Z    CBCSkip            ;para ver se ha colisao
                CMP     M[R6], R1
                CALL.Z  FimJogo
                CMP     M[R6], R2
                CALL.Z  FimJogo
                DEC     R7
                INC     R6
                BR      CimaBCiclo
CBCSkip:        CALL    DesenhaNave
CimaSkip:       DEC     M[FlagCima]
                ENI
                RET
                
                
Direita:        DSI
                MOV     R6, R0
                MVBL    R6, R1
                CMP     R6, 004Eh
                JMP.Z    DirSkip
                CALL    ApagaNave
                INC     R1
                INC     R2
                INC     R3
                MOV     R7, M[NumAst]
                MOV     R6, AstList
DirACiclo:      CMP     R7, R0             ;percorre os asteroides
                BR.Z    DACSkip            ;para ver se ha colisao
                CMP     M[R6], R1
                CALL.Z  FimJogo
                CMP     M[R6], R2
                CALL.Z  FimJogo
                CMP     M[R6], R3
                CALL.Z  FimJogo
                DEC     R7
                INC     R6
                BR      DirACiclo                  
DACSkip:        MOV     R7, M[NumBur]
                MOV     R6, BurList
DirBCiclo:      CMP     R7, R0             ;percorre os burac negros
                BR.Z    DBCSkip            ;para ver se ha colisao
                CMP     M[R6], R1
                CALL.Z  FimJogo
                CMP     M[R6], R2
                CALL.Z  FimJogo
                CMP     M[R6], R3
                CALL.Z  FimJogo
                DEC     R7
                INC     R6
                BR      DirBCiclo
DBCSkip:        CALL    DesenhaNave
DirSkip:        DEC     M[FlagDir]
                ENI
                RET   
                
                
Esquerda:       DSI
                MOV     R6, R0
                MVBL    R6, R1
                CMP     R6, 0001h
                JMP.Z   EsqSkip
                CALL    ApagaNave
                DEC     R1
                DEC     R2
                DEC     R3
                MOV     R7, M[NumAst]
                MOV     R6, AstList
                DEC     R1                 ;R1 <-- pos da peca |
EsqACiclo:      CMP     R7, R0             ;percorre os asteroides
                BR.Z    EACSkip            ;para ver se ha colisao
                CMP     M[R6], R1
                CALL.Z  FimJogo
                CMP     M[R6], R2
                CALL.Z  FimJogo
                CMP     M[R6], R3
                CALL.Z  FimJogo
                DEC     R7
                INC     R6
                BR      EsqACiclo                  
EACSkip:        MOV     R7, M[NumBur]
                MOV     R6, BurList
EsqBCiclo:      CMP     R7, R0             ;percorre os burac negros
                BR.Z    EBCSkip            ;para ver se ha colisao
                CMP     M[R6], R1
                CALL.Z  FimJogo
                CMP     M[R6], R2
                CALL.Z  FimJogo
                CMP     M[R6], R3
                CALL.Z  FimJogo
                DEC     R7
                INC     R6
                BR      EsqBCiclo
EBCSkip:        INC     R1                 ;R1 <-- pos da peca >
                CALL    DesenhaNave
EsqSkip:        DEC     M[FlagEsq]
                ENI
                RET
                
                
;----------TIROS----------
;R5=pos do tiro
;R4=pos de memoria do tiro
;R6=pos de mem d bur/ast

RemTiro:        PUSH    R7
                PUSH    R6
                MOV     R6, M[R4]          ;R4=pos mem do tiro actual
                MOV     R7, ' '
                MOV     M[JANELA_CTRL], R6
                MOV     M[JANELA_WRITE], R7
                MOV     R7, TirosList
                ADD     R7, M[NumTiros]
                DEC     R7                 ;R7=pos mem d ultim tir d TirosList
                MOV     R6, M[R7]          ;R6<-pos do ultimo tiro
                MOV     M[R4], R6
                DEC     M[NumTiros]        
                POP     R6
                POP     R7
                RET
               
                
ActTiro:        PUSH    R7                 ;R4 = pos mem tiro actual
                MOV     R7, ' '
                MOV     M[JANELA_CTRL], R5 ;R5 = posicao do tiro actual
                MOV     M[JANELA_WRITE], R7
                MOV     R7, R0
                MVBL    R7, R5
                CMP     R7, 004Eh
                BR.NZ   MovTiro
                CALL    RemTiro
                DEC     R4                 ;para o ciclo passar outra
                JMP     ATFim              ;vez na msma pos mem
MovTiro:        INC     R5                 ;R5 <- nova posicao
                INC     M[R4]              ;actualiza nova pos
                MOV     R7, M[NumAst]
                MOV     R6, AstList
ATiroCiclAst:   CMP     R7, R0             ;percorr os ast para ver se ha colis
                BR.Z    ATirSkipAst        ;nao ha mais ast a percorrer
                CMP     M[R6], R5
                BR.NZ   ATNaoColAst
                CALL    LigaLEDs
                CALL    INCPontuacao
                CALL    RemTiro
                CALL    RemAst
                DEC     R4                 ;para o ciclo passar outr
                BR      ATFim              ;vez na msma pos mem
ATNaoColAst:    DEC     R7
                INC     R6
                BR      ATiroCiclAst
ATirSkipAst:    MOV     R7, M[NumBur]
                MOV     R6, BurList
ATiroCiclBur:   CMP     R7, R0
                BR.Z    ATirSkipBur
                CMP     M[R6], R5
                BR.NZ   ATNaoColBur
                CALL    RemTiro
                DEC     R4                 ;para o ciclo passar outr
                BR      ATFim              ;vez na msma pos mem
ATNaoColBur:    DEC     R7
                INC     R6
                BR      ATiroCiclBur
ATirSkipBur:    MOV     R7, '-'
                MOV     M[JANELA_CTRL], R5
                MOV     M[JANELA_WRITE], R7
ATFim:          POP     R7
                RET

                
ActTiros:       DSI
                MOV     R7, M[NumTiros]
                MOV     R4, TirosList
ActTirosCiclo:  CMP     R7, R0             ;ciclo que percorre todos os tiros
                BR.Z    ActTirosSkip       
                MOV     R5, M[R4]          
                CALL    ActTiro
                INC     R4
                DEC     R7
                BR      ActTirosCiclo
ActTirosSkip:   INC     M[FlagActTiros]
                ENI
                RET                
                
                
NovoTiro:       DSI
                MOV     R7,R1
                INC     R7
                MOV     R4, TirosList
                ADD     R4, M[NumTiros]
                MOV     M[R4], R7
                INC     M[NumTiros]             
                MOV     R5, '-'
                MOV     M[JANELA_CTRL], R7
                MOV     M[JANELA_WRITE], R5
                DEC     M[FlagNovoTiro]
                ENI
                RET
                                

;----------ASTEROIDES E BURACOS NEGROS----------
;R5=posicao ast/bur
;R4=pos de mem d ast/bur
;R6=pos de mem do tiro
                
PosAleat:       MOV     R6, M[NumAleat]    ;gera uma posicao pseudo aleatoria 
                ROR     R6, 1              ;para um novo obstaculo a inserir
                BR.NC   PosAleatSkip
                MOV     R6, M[NumAleat]
                XOR     R6, M[MASCARA]
                ROR     R6, 1                     
PosAleatSkip:   MOV     M[NumAleat], R6
                MOV     R5, 20
                DIV     R6, R5
                ADD     R5, 2              ;assim obst aparecem entr linhas 2 e 22
                SHL     R5, 8
                ADD     R5, 004Fh          ;R5 <- nova posicao
                RET

                
RemAst:         PUSH    R7                 ;R4 e R7 em uso em ActAst
                PUSH    R4 
                MOV     R4, M[R6]          ;R6=pos mem do ast actual
                MOV     R7, ' '
                MOV     M[JANELA_CTRL], R4
                MOV     M[JANELA_WRITE], R7
                MOV     R7, AstList
                ADD     R7, M[NumAst]
                DEC     R7                 ;R7=pos de mem do ultimo ast da AstList
                MOV     R4, M[R7]          ;MOV   R7, M[R7] possivel?
                MOV     M[R6], R4          
                DEC     M[NumAst]
                POP     R4
                POP     R7
                RET 
                
                
ActAst:         PUSH    R7                 ;R7 em uso em ActAsts
                MOV     R7, ' '            ;R6 = pos de mem do ast actual
                MOV     M[JANELA_CTRL], R5 ;R5 = posicao do ast actual
                MOV     M[JANELA_WRITE], R7
                MOV     R7, R0
                MVBL    R7, R5
                CMP     R7, R0
                BR.NZ   MovAst
                CALL    RemAst
                DEC     R6                 ;para o ciclo passar outr
                JMP     AAFim              ; vez na msma pos mem
MovAst:         DEC     R5                 ;R5 <- nova posicao
                DEC     M[R6]              ;actualiza nova pos
                CMP     R1, R5
                CALL.Z  FimJogo
                CMP     R2, R5
                CALL.Z  FimJogo
                CMP     R3, R5
                CALL.Z  FimJogo
                MOV     R7, M[NumTiros]
                MOV     R4, TirosList
ActAstCiclo:    CMP     R7, R0             ;percorr todos os tiros e ve s ha colis
                BR.Z    ActAstSkip         ;R4 = pos de mem do tiro actual
                CMP     M[R4], R5
                BR.NZ   AANaoCol           ;nao colide com tiro
                CALL    LigaLEDs
                CALL    INCPontuacao
                CALL    RemAst
                CALL    RemTiro
                DEC     R6                 ;para o ciclo passar outr
                BR      AAFim              ; vez na msma pos mem
AANaoCol:       DEC     R7
                INC     R4
                BR      ActAstCiclo
ActAstSkip:     MOV     R7, '*'
                MOV     M[JANELA_CTRL], R5
                MOV     M[JANELA_WRITE], R7
AAFim:          POP     R7
                RET
                
                
ActAsts:        MOV     R7, M[NumAst]
                MOV     R6, AstList        ;R6 = pos de mem do ast actual
ActAstsCiclo:   CMP     R7, R0
                BR.Z    ActAstsSkip        ;percorreu todos os ast/ nao ha ast
                MOV     R5, M[R6]          ;R5 = posicao do ast actual
                CALL    ActAst
                INC     R6
                DEC     R7
                BR      ActAstsCiclo
ActAstsSkip:    RET                

                
NovoAst:        CALL    PosAleat           ; pos fica em R5
                MOV     R6, M[NumAst]      ;R6 fica com o num antigo de asteroides
                INC     M[NumAst]          ;que somado a AstList e igual a posicao
                ADD     R6, AstList        ;de memoria onde se quer guardar o novo
                MOV     M[R6], R5          ;asteroide, que e a primeira entrada da 
                MOV     M[JANELA_CTRL], R5       ;lista que esteja vazia
                MOV     R5, '*'
                MOV     M[JANELA_WRITE], R5
                DEC     M[TipoObst]
                RET
 
 
RemBur:         PUSH    R7                 ;R7 em uso em ActBur
                MOV     R4, M[R6]          ;R6=pos mem do bur actual
                MOV     R7, ' '
                MOV     M[JANELA_CTRL], R4
                MOV     M[JANELA_WRITE], R7
                MOV     R7, BurList
                ADD     R7, M[NumBur]
                DEC     R7                 ;R7=pos de mem do ultimo bur da BurList
                MOV     R4, M[R7]
                MOV     M[R6], R4          
                DEC     M[NumBur]
                POP     R7
                RET 
 
                
ActBur:         PUSH    R7                 ;R7 em uso em ActBurs
                MOV     R7, ' '
                MOV     M[JANELA_CTRL], R5
                MOV     M[JANELA_WRITE], R7
                MOV     R7, R0
                MVBL    R7, R5
                CMP     R7, R0
                BR.NZ   MovBur
                CALL    RemBur
                DEC     R6                 ;para o ciclo passar outr
                JMP     ABFim              ; vez na msma pos mem
MovBur:         DEC     R5                 ;R5 <- nova posicao
                DEC     M[R6]              ;actualiza nova pos
                CMP     R1, R5
                CALL.Z  FimJogo
                CMP     R2, R5
                CALL.Z  FimJogo
                CMP     R3, R5
                CALL.Z  FimJogo
                MOV     R7, M[NumTiros]
                MOV     R4, TirosList
ActBurCiclo:    CMP     R7, R0             ;percorr todos os tiros e ve s ha colis
                BR.Z    ActBurSkip         ;R4 = pos de mem do tiro actual
                CMP     M[R4], R5
                BR.NZ   ABNaoCol           ;nao colide com tiro
                CALL    RemTiro
                DEC     R6                 ;para o ciclo passar outr
                BR      ABFim              ;vez na msma pos mem
ABNaoCol:       DEC     R7
                INC     R4
                BR      ActBurCiclo
ActBurSkip:     MOV     R7, 'O'
                MOV     M[JANELA_CTRL], R5
                MOV     M[JANELA_WRITE], R7
ABFim:          POP     R7
                RET                


ActBurs:        MOV     R7, M[NumBur]
                MOV     R6, BurList        ;R6=pos mem do burac negr actual
ActBursCiclo:   CMP     R7, R0
                BR.Z    ActBursSkip        ;percorreu tds os burac negros/nao ha bur
                MOV     R5, M[R6]          ;R5 = pos do buraco negro actual 
                CALL    ActBur
                DEC     R7
                INC     R6
                BR      ActBursCiclo
ActBursSkip:    RET    

 
NovoBur:        CALL    PosAleat           ;pos fica em R5
                MOV     R6, M[NumBur]      ;igual ao que acontece em NovoAst mas 
                INC     M[NumBur]          ;agora para buracos negros
                ADD     R6, BurList
                MOV     M[R6], R5
                MOV     M[JANELA_CTRL], R5
                MOV     R5, 'O'
                MOV     M[JANELA_WRITE], R5
                MOV     R5, 3
                MOV     M[TipoObst], R5
                RET
                
                
;----------Obstaculos----------
; (Asteroides + Buracos Negros)
                
ActObst:        DSI
                CMP     M[FlagNovoObst], R0
                BR.NZ   NaoCriaObst
                CMP     M[TipoObst], R0
                BR.Z    BuracNegr
                CALL    NovoAst
                BR      AOSkip
BuracNegr:      CALL    NovoBur
AOSkip:         MOV     R6, 6
                MOV     M[FlagNovoObst], R6
NaoCriaObst:    CALL    ActAsts
                CALL    ActBurs
                INC     M[FlagActObst]
                INC     M[FlagActObst]
                DEC     M[FlagNovoObst]
                ENI
                RET                
                

;----------INICIO----------                
                
Inicio:         MOV     R7, SP_INICIAL
                MOV     SP, R7
                MOV     R7, INT_MASK_START
                MOV     M[INT_MASK_ADDR], R7
                CALL    Intro
                MOV     R7, INT_MASK
                MOV     M[INT_MASK_ADDR], R7
                CALL    InitTerreno
                CALL	InitNave
                MOV     R7, 1
                MOV     M[INTERV_TEMP], R7
                MOV     R7, 1
                MOV     M[CONTROL_TEMP], R7
                MOV     M[FlagStart], R0
                ENI
Ciclo:          CMP     R0, M[FlagBaixo]
                CALL.NZ Baixo
                CMP     R0, M[FlagCima]
                CALL.NZ Cima
                CMP     R0, M[FlagDir]
                CALL.NZ Direita 
                CMP     R0, M[FlagEsq]
                CALL.NZ Esquerda
                CMP     R0, M[FlagNovoTiro]
                CALL.NZ NovoTiro
                CMP     R0, M[FlagActTiros]
                CALL.Z  ActTiros
                CMP     R0, M[FlagActObst]
                CALL.Z  ActObst
                CMP     R0, M[FlagStart]
                JMP.NZ  Inicio
                JMP     Ciclo
