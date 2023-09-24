include macros.cbc     ; Incluye el archivo de macros predefinidas para el ensamblador.


SSeg Segment 
    pila db 0
         db 65535 dup (?)     
SSeg EndS

Datos Segment               ; Define un segmento llamado "Datos" para almacenar variables y datos.
    hAmanecer             dw 5 
    minAmanecer           dw 49
    AmanecerEnMinutos     dw 0
    hOcaso                dw 18 
    minOcaso              dw 22
    OcasoEnMinutos        dw 0
    diferenciaMin         dw ?
    valorHora_Entero      dw ?
    valorHora_Decimal     dw ?
    resHora               dw ?
    resMinutos            dw ?
    resSegundos           dw ?
Datos Ends                              ; Finaliza la definición del segmento "Datos".


Codigo Segment                          ; Define un segmento llamado "Codigo" para el código ensamblador.
assume cs:Codigo, ds:Datos, SS:SSeg              ; Asocia los registros de segmento CS (código) y DS (datos) a los segmentos definidos.
    Imprime Proc Far            
            mov ah, 09h                 ; paso parametro por registro ;mov dx, offset Mensaje
            int 21h
            ret 2*1
        Imprime Endp

    multiplicar Proc Far
            pop dx
            pop ax
            cmp ax, bx                ; Comprobar cuál número es mayor
            jae mayor_o_igual         ; Si son  AX >= BX, salta a mayor_o_igual

            xchg ax, bx               ; xchg intercambia los datos de los registros en cuestion

            mayor_o_igual:
                mov cx, bx            ; Cargar el número más pequeño en CX (contador)
                mov dx, 0             ; Inicializar DX (acumulador) a cero
    
            bucle:    
                add dx, ax            ; Sumar el número mayor a DX
                loop bucle            ; Decrementar CX y repetir el bucle hasta que CX sea cero

            push dx                   ; Paso el resultado por la pila
            ret                       
        multiplicar Endp

    dividir Proc Far
            pop bx
            pop ax
            cmp ax, 0                 ; Comprobar si el dividendo (ax) es cero
            je division_fin           ; Si es cero, el resultado es cero

            cmp bx, 0                 ; Comprobar si el divisor (bx) es cero
            je division_fin           ; Si es cero, el resultado es indefinido

            mov cx, 0                 ; Inicializar CX (parte decimal) a cero
            mov dx, 0                 ; Inicializar DX (parte entera) a cero

            division_loop:
                cmp ax, 0             ; Comprobar si el dividendo es cero
                je division_fin       ; Si es cero, salir del bucle
 
                cmp ax, bx            ; Comprobar si el dividendo es menor que el divisor
                jl division_fin       ; Si es menor, salir del bucle
 
                sub ax, bx            ; Restar el divisor al dividendo
                inc dx                ; Incrementar la parte entera
                add cx, 25            ; Sumar 25 a la parte decimal (ajusta según la precisión deseada)
                jmp division_loop     ; Repetir el bucle

            division_fin:
                ; El resultado de la parte decimal (con precisión de dos dígitos) se encuentra en CX
                push cx
                ; El resultado de la parte entera se encuentra en DX
                push dx
                ret                  ; Finaliza el procedimiento y regresa al punto de llamada
        dividir Endp

    convertir Proc Far
            ; Convertir la parte decimal (CX) a fracción de una hora en minutos
            mov bx, 60            ; 60 minutos en una hora
            mul bx                ; Multiplicar la parte decimal (CX) por 60 para obtener minutos
            add dx, ax            ; Sumar los minutos a la parte entera (DX)

            ; Convertir la parte entera (DX) a horas
            mov bx, 60            ; 60 minutos en una hora
            div bx                ; Dividir los minutos (DX) por 60 para obtener horas
            mov resHora, dx       ; El resultado en horas está en resHora

            ; El resto en DX ahora representa los minutos después de la conversión
            mov resMinutos, dx    ; Los minutos restantes están en resMinutos

            ; Convertir los minutos restantes a segundos
            mov bx, 60            ; 60 segundos en un minuto
            div bx                ; Dividir los minutos restantes (DX) por 60 para obtener segundos
            mov resSegundos, dx   ; El resultado en segundos está en resSegundos

            ; En resHora, resMinutos y resSegundos tienes el resultado en formato de hora, minutos y segundos
            ret
        convertir ENDP

    ;Procedimiento para sacar cuánto tiempo (en minutos) hay entre el amanecer y el ocaso
    Diferencia PROC Far
            ; Convertir horas a minutos y agregar minutos
            mov ax, hOcaso
            push ax                         ; Paso de parametros por pila
            mov bx, 60
            push bx                         ; Paso de parametros por pila
            call multiplicar                ; Pasamos la hora del Ocaso a minutos
            pop dx
            add sp, 6                       ; Limpia la pila
  
            xor ax, ax
            add ax, minOcaso
            add ax, dx                      ; Sumar minutos
            mov OcasoEnMinutos, ax          ; Se suma el resultado de la multiplicacion
            
            mov ax, hAmanecer
            push ax                         ; Paso de parametros por pila
            mov bx, 60
            push bx                         ; Paso de parametros por pila
            call multiplicar                ; Pasamos la hora del Amanecer a minutos
            pop dx
            add sp, 6                       ; Limpia la pila

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
            push ax
            mov bx, 12
            push bx
            call dividir                    ; Se divide la diferencia entre las horas dadas entre 12 para saber cuantos minutos tiene una hora
            pop dx                          ; Se saca la parte entera del resultado de la pila y se guarda enel dx
            mov valorHora_Entero, dx        ; Se guarda la parte entera del resultado en una variable
            pop cx                          ; Se saca la parte decimal del resultado de la pila y se guarda enel cx
            mov valorHora_Decimal, cx       ; Se guarda la parte decimal del resultado en una variable
            add sp, 8                       ; Limpia la pila
           
            ret
        ValorHora ENDP

inicio:
    mov     ax, Datos
    mov     ds,ax
    
    call Diferencia
    call ValorHora
   
    mov ax, 4c00h           ; Prepara una llamada a la interrupción 21h para terminar el programa.
    int 21h                 ; Llama a la interrupción 21h para terminar el programa.

Codigo Ends                 ; Finaliza la definición del segmento "Codigo".
end inicio                  ; Finaliza el programa.