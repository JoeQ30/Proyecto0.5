
SSeg Segment 
    pila db 0
         db 65535 dup (?)     
SSeg EndS

Datos Segment               ; Define un segmento llamado "Datos" para almacenar variables y datos.
    LineCommand db 0FFh dup (?)
    hAmanecer               dw 4 
    minAmanecer             dw 35
    AmanecerEnMinutos       dw 0
    hOcaso                  dw 20 
    minOcaso                dw 15
    OcasoEnMinutos          dw 0
    diferenciaMin           dw ?
    dividendo               dw ?
    divisor                 dw ?
    resultado               dw ?
    valorHora_Min           dw ?
    resHora                 dw 0
    resMinutos              dw 0
    sumHora                 dw ?
    sumMinutos              dw ?
    enumerador              dw 1
Datos Ends                              ; Finaliza la definición del segmento "Datos".


Codigo Segment                          ; Define un segmento llamado "Codigo" para el código ensamblador.
assume cs:Codigo, ds:Datos, SS:SSeg              ; Asocia los registros de segmento CS (código) y DS (datos) a los segmentos definidos.
    Imprime Proc Far            
            mov ah, 09h                 ; paso parametro por registro ;mov dx, offset Mensaje
            int 21h
            ret 2*1
        Imprime Endp

    multiplicar Proc Far
            ;pop dx
            ;pop ax
            cmp ax, bx                ; Comprobar cuál número es mayor
            jae mayor_o_igual         ; Si son  AX >= BX, salta a mayor_o_igual

            xchg ax, bx               ; xchg intercambia los datos de los registros en cuestion

            mayor_o_igual:
                mov cx, bx            ; Cargar el número más pequeño en CX (contador)
                mov dx, 0             ; Inicializar DX (acumulador) a cero
    
            bucle:    
                add dx, ax            ; Sumar el número mayor a DX
                loop bucle            ; Decrementar CX y repetir el bucle hasta que CX sea cero

            ;push dx                   ; Paso el resultado por la pila
            ret                       
        multiplicar Endp

    dividir Proc Far
            mov dx, ax
            mov dividendo, dx    ; Guarda una copia del dividendo que quedará intacta
            mov dx, bx
            mov divisor, dx    ; Guarda una copia del dividendo que quedará intacta

            cmp ax, 0            ; Comprobar si el dividendo (ax) es cero
            je division_fin      ; Si es cero, el resultado es cero

            cmp bx, 0            ; Comprobar si el divisor (bx) es cero
            je division_fin      ; Si es cero, el resultado es indefinido

            mov dx, 0            ; Inicializar DX (parte entera) a cero
            mov cx, 0            ; Inicializar CX (residuo) a cero

            division_loop:
                cmp ax, 0        ; Comprobar si el dividendo es cero
                je division_fin  ; Si es cero, salir del bucle

                cmp ax, bx       ; Comprobar si el dividendo es menor que el divisor
                jl division_fin  ; Si es menor, salir del bucle

                sub ax, bx       ; Restar el divisor al dividendo
                inc dx           ; Incrementar la parte entera
                jmp division_loop; Repetir el bucle

            division_fin:
                mov ax, dx
                mov resultado, ax     ; Se guarda una copia del resultado en una variable

                ; Calcula el residuo una vez que la división ha terminado
                mov ax, divisor       ; Mueve el divisor a AX
                mov bx, dx            ; Mueve resultado a BX
                call multiplicar      ; Se multipplica el divisor por el resultado de la division
                sub dividendo, dx     ; Al dividendo se le resta el resultado de la multiplicacion
                mov cx, dividendo     ; El reciduo se mueve al cx
                mov dx, resultado     ; El resultado se mueve al dx

            ret               ; Finaliza el procedimiento y regresa al punto de llamada
        dividir Endp

    convertir Proc Far
            mov ax, valorHora_Min
            mov bx, 60
            call dividir
            mov sumHora, dx             ; Se guarda la parte entera del resultado en una variable
            mov sumMinutos, cx          ; Se guarda el reciduo en el lado de minutos
            ret
        convertir ENDP

    ;Procedimiento para sacar cuánto tiempo (en minutos) hay entre el amanecer y el ocaso
    Diferencia PROC Far
            ; Convertir horas a minutos y agregar minutos
            mov ax, hOcaso
            ;push ax                         ; Paso de parametros por pila
            mov bx, 60
            ;push bx                         ; Paso de parametros por pila
            call multiplicar                ; Pasamos la hora del Ocaso a minutos
            ;pop dx
            ;add sp, 6                       ; Limpia la pila
  
            xor ax, ax
            add ax, minOcaso
            add ax, dx                      ; Sumar minutos
            mov OcasoEnMinutos, ax          ; Se suma el resultado de la multiplicacion
            
            mov ax, hAmanecer
            ;push ax                         ; Paso de parametros por pila
            mov bx, 60
            ;push bx                         ; Paso de parametros por pila
            call multiplicar                ; Pasamos la hora del Amanecer a minutos
            ;pop dx
            ;add sp, 6                       ; Limpia la pila

            xor ax,ax
            add ax,minAmanecer
            add ax, dx                       ; Sumar minutos
            mov AmanecerEnMinutos, ax       ; Se suma el resultado de la multiplicacion
            
            ;restar las horas previamente convertidas a minutos
            mov ax, OcasoEnMinutos
            sub ax, AmanecerEnMinutos       ; Se resta la hora en minutos del ocaso y del amanecer para saber cuantos minutos hay entre una y otra
            mov diferenciaMin, ax           ; Se guarda la diferencia en minutos en una variable para poder acceder a ella más adelante
            ret
        Diferencia ENDP

    ; Procedimiento para saber cual es el valor en minutos de una hora 
    ValorHora Proc Far
            mov ax, diferenciaMin
            mov bx, 12
            ;push bx
            call dividir                     ; Se divide la diferencia entre las horas dadas entre 12 para saber cuantos minutos tiene una hora
            ;div ax, bx
            ;pop dx                          ; Se saca la parte entera del resultado de la pila y se guarda enel dx
            mov valorHora_Min, dx           ; Se guarda la parte entera del resultado en una variable
            ;add sp, 6                      ; Limpia la pila
           
            ret
        ValorHora ENDP

    SumaHoras Proc Far
            mov ax, resHora
            mov bx, resMinutos
            add ax, sumHora   ; Suma las horas
            add bx, sumMinutos  ; Suma los minutos

            ; Verifica si resMinutos es mayor o igual a 60
            while_loop:
                cmp bx, 60
                jl no_carrea    ; Si resMinutos < 60, salta a no_carrea

                ; Si resMinutos >= 60, ajusta las horas y minutos
                add ax, 1     ; Suma 1 a las horas
                sub bx, 60 ; Resta 60 a los minutos
                jmp while_loop     ; Vuelve a verificar si resMinutos >= 60

            no_carrea:
            mov resHora, ax
            mov resMinutos, bx
            ret
        SumaHoras ENDP

    imprimirHora Proc Far
            ; Imprimir enumerador
            mov ax, enumerador
            mov bx, 10      ; En el DX queda las decenas y en el CX las unidades
            call dividir

            ; Imprimir las decenas de minutos (enumerador / 10)
            mov ah, 2     ; Cargar la función de servicio de DOS para imprimir un carácter
            add dx, '0'   ; Convertir las decenas en su equivalente ASCII
            int 21h       ; Llamar a la interrupción de DOS para imprimir

            ; Imprimir las unidades de minutos (enumerador  % 10)
            mov ah, 2     ; Cargar la función de servicio de DOS para imprimir un carácter
            mov dl, cl    ; Cargar las unidades en dl
            add dl, '0'   ; Convertir las unidades en su equivalente ASCII
            int 21h       ; Llamar a la interrupción de DOS para imprimir
            inc enumerador

            ; Imprimir un parentesis
            mov ah, 2     ; Cargar la función de servicio de DOS para imprimir un carácter
            mov dl, ')'   ; Cargar el carácter espacio
            int 21h       ; Llamar a la interrupción de DOS para imprimir

            ; Imprimir un espacio
            mov ah, 2     ; Cargar la función de servicio de DOS para imprimir un carácter
            mov dl, ' '   ; Cargar el carácter espacio
            int 21h       ; Llamar a la interrupción de DOS para imprimir
            
            mov ax, resHora
            mov bx, 10      ; En el DX queda las decenas y en el CX las unidades
            call dividir

            ; Imprimir las decenas de minutos (resHora / 10)
            mov ah, 2     ; Cargar la función de servicio de DOS para imprimir un carácter
            add dx, '0'   ; Convertir las decenas en su equivalente ASCII
            int 21h       ; Llamar a la interrupción de DOS para imprimir

            ; Imprimir las unidades de minutos (resHora  % 10)
            mov ah, 2     ; Cargar la función de servicio de DOS para imprimir un carácter
            mov dl, cl    ; Cargar las unidades en dl
            add dl, '0'   ; Convertir las unidades en su equivalente ASCII
            int 21h       ; Llamar a la interrupción de DOS para imprimir

            ; Imprimir el separador ":" entre horas y minutos
            mov ah, 2     ; Cargar la función de servicio de DOS para imprimir un carácter
            mov dl, ':'   ; Cargar el carácter ":"
            int 21h       ; Llamar a la interrupción de DOS para imprimir

            mov ax, resMinutos
            mov bx, 10      ; En el DX queda las decenas y en el CX las unidades
            call dividir

            ; Imprimir las decenas de minutos (resMinutos / 10)
            mov ah, 2     ; Cargar la función de servicio de DOS para imprimir un carácter
            add dx, '0'   ; Convertir las decenas en su equivalente ASCII
            int 21h       ; Llamar a la interrupción de DOS para imprimir

            ; Imprimir las unidades de minutos (resMinutos % 10)
            mov ah, 2     ; Cargar la función de servicio de DOS para imprimir un carácter
            mov dl, cl    ; Cargar las unidades en dl
            add dl, '0'   ; Convertir las unidades en su equivalente ASCII
            int 21h       ; Llamar a la interrupción de DOS para imprimir

            ; Imprimir un salto de línea para formatear la salida
            mov ah, 2     ; Cargar la función de servicio de DOS para imprimir un carácter
            mov dl, 13    ; Cargar el carácter de retorno de carro (CR)
            int 21h       ; Llamar a la interrupción de DOS para imprimir

            mov ah, 2     ; Cargar la función de servicio de DOS para imprimir un carácter
            mov dl, 10    ; Cargar el carácter de nueva línea (LF)
            int 21h       ; Llamar a la interrupción de DOS para imprimir

            ret

        imprimirHora ENDP

    GetCommanderLine Proc Near ;
        LongLC EQU 80h  ; Longitud de la linea de comandos ;constante ; macro ; cada que encuentre una palabra lo cambia por esto
        mov bp, sp      ; el sp se lo pongo al bp
        mov ax, es      ; es es un registro que contiene el segmento de datos ;
        mov ds, ax      ; ax al ds ; ds es un registro que contiene el segmento de datos
        mov di, 2[bp]   ; saco el desplazamiento de la linea de comandos
        mov ax, 4[bp]   ; saco el segmento de la linea de comandos
        mov es,ax       ; ax al es ;  el es se queda con el segmento de datos, el es se queda con el segmento de psp
        xor cx,cx       ; cx a cero
        mov cl,Byte Ptr Ds:[LongLC] ;Ds tiene el segmento de datos, y el longlc es la longitud de la linea de comandos, se lo pone al cx
        dec cl          ; decremente el cl en 1, por el espacio que se le da al enter
        mov si, 2[LongLC]  ; saco el desplazamiento de la linea de comandos
        cld                 ; limpio el bit de direccion
        rep Movsb           ; copia el contenido de si a di, cx veces
        ret 2*2             ;
    GetCommanderLine Endp

    ObtenerNumero Proc Far
    xor ax, ax  ; Inicializa ax a cero
    xor cx, cx  ; Inicializa cx a cero

        ; Bucle para obtener el número
        bucleConv:
            mov bx, 10  ; Cargar el divisor
            mul bx      ; Multiplicar ax por bx
            mov bx, si  ; Cargar el índice
            add bx, LineCommand ; Sumar el índice a la dirección de inicio de la línea de comandos
            mov bl, [bx] ; Cargar el caracter de la línea de comandos
            sub bl, '0' ; Convertir el caracter a su equivalente numérico
            add ax, bx  ; Sumar el caracter a ax
            inc si      ; Incrementar el índice
            cmp bl, 0dh ; Comprobar si el caracter es un retorno de carro
            jne bucleConv   ; Si no es un retorno de carro, repetir el bucle
        
        ; Devuelve el número en ax
        ret
    ObtenerNumero Endp

inicio:
    xor     ax, ax              
    mov     ax, Datos
    mov     ds,ax

    push ds
    push es
    mov ax, Seg LineCommand
    push ax
    lea ax, LineCommand
    push ax
    call GetCommanderLine
    pop es
    pop ds
    xor si, si

    ; Verifica que la entrada comience con '/'
    ;/03,21,12,23
    ; Incrementa el índice
    inc si
    ;03,21/12,23

    ; Obtiene la hora del amanecer
    call ObtenerNumero
    mov hAmanecer, ax
    ;,21/12,23

    ; Incrementa el índice
    inc si
    ;21,12,23

    ; Obtiene los minutos del amanecer
    call ObtenerNumero
    mov minAmanecer, ax
    ;,12,23

    ; Verifica que la entrada contenga '/'

    ; Incrementa el índice
    inc si
    ;12,23

    ; Obtiene la hora del ocaso
    call ObtenerNumero
    mov hOcaso, ax
    ;,23

    ; Verifica que la entrada contenga una coma

    ; Incrementa el índice
    inc si
    ;23

    ; Obtiene los minutos del ocaso
    call ObtenerNumero
    mov minOcaso, ax
    ;


    call Diferencia
    call ValorHora
    call convertir

    mov ax, hAmanecer
    mov resHora, ax
    mov bx, minAmanecer
    mov resMinutos, bx

    call SumaHoras
    call imprimirHora
    call SumaHoras
    call imprimirHora
    call SumaHoras
    call imprimirHora
    call SumaHoras
    call imprimirHora
    call SumaHoras
    call imprimirHora
    call SumaHoras
    call imprimirHora
    call SumaHoras
    call imprimirHora
    call SumaHoras
    call imprimirHora
    call SumaHoras
    call imprimirHora
    call SumaHoras
    call imprimirHora
    call SumaHoras
    call imprimirHora
    call SumaHoras
    call imprimirHora
    
    
    mov ax, 4c00h           ; Prepara una llamada a la interrupción 21h para terminar el programa.
    int 21h                 ; Llama a la interrupción 21h para terminar el programa.

Codigo Ends                 ; Finaliza la definición del segmento "Codigo".
end inicio                  ; Finaliza el programa.