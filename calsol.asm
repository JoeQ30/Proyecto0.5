include macros.cbc     ; Incluye el archivo de macros predefinidas para el ensamblador.


SSeg Segment 
    pila db 0
         db 65535 dup (?)     
SSeg EndS

Datos Segment               ; Define un segmento llamado "Datos" para almacenar variables y datos.
    hAmanecer           dw 5 
    minAmanecer         dw 49
    AmanecerEnMinutos   dw 0
    hOcaso              dw 18 
    minOcaso            dw 22
    OcasoEnMinutos      dw 0
    diferenciaHoras     dw ?
    diferenciaMin       dw ?
    valorPorHora        dw ?
Datos Ends                  ; Finaliza la definición del segmento "Datos".


Codigo Segment              ; Define un segmento llamado "Codigo" para el código ensamblador.
assume cs:Codigo, ds:Datos  ; Asocia los registros de segmento CS (código) y DS (datos) a los segmentos definidos.
    Imprime Proc Far
            mov ah, 09h     ; paso parametro por registro ;mov dx, offset Mensaje
            int 21h
            ret 2*1
        Imprime Endp

    multiplicar Proc Far
            cmp ax, bx         ; Comprobar cuál número es mayor
            jae mayor_o_igual  ; Si son  AX >= BX, salta a mayor_o_igual

            ; Si BX > AX, intercambiamos los registros para que AX contenga el número mayor
            xchg ax, bx

            mayor_o_igual:
                mov cx, bx        ; Cargar el número más pequeño en CX (contador)
                mov dx, 0         ; Inicializar DX (acumulador) a cero

            bucle:
                add dx, ax        ; Sumar el número mayor a DX
                loop bucle        ; Decrementar CX y repetir el bucle hasta que CX sea cero

            ret
        multiplicar Endp

    dividir Proc Far
            cmp ax, 0            ; Comprobar si el dividendo (ax) es cero
            je division_fin      ; Si es cero, el resultado es cero

            cmp bx, 0            ; Comprobar si el divisor (bx) es cero
            je division_fin      ; Si es cero, el resultado es indefinido

            mov cx, 0            ; Inicializar CX (contador) a cero
            mov dx, 0            ; Inicializar DX (acumulador) a cero

        division_loop:
            cmp ax, bx           ; Comprobar si el dividendo es menor que el divisor
            jl division_fin      ; Si es menor, salir del bucle

            sub ax, bx           ; Restar el divisor al dividendo
            inc cx               ; Incrementar el contador de restas
            jmp division_loop    ; Repetir el bucle

        division_fin:
            ; El resultado (cantidad de restas) se encuentra en CX
            ret          ; Finaliza el procedimiento y regresa al punto de llamada
        dividir Endp

    ;Procedimiento para sacar cuánto tiempo (en minutos) hay entre el amanecer y el ocaso
    Diferencia PROC Far
            ; Convertir horas a minutos y agregar minutos
            mov ax, hOcaso
            mov bx, 60
            call multiplicar    ;Procedimiento que hace la multplicacion, el resultado queda en el dx
            xor ax,ax
            add ax,minOcaso
            add ax, dx  ; Sumar minutos
            mov OcasoEnMinutos, ax      ;Se suma el resultado de la multiplicacion
            
            mov ax, hAmanecer
            mov bx, 60
            call multiplicar
            xor ax,ax
            add ax,minAmanecer
            add ax, dx  ; Sumar minutos
            mov AmanecerEnMinutos, ax      ;Se suma el resultado de la multiplicacion
            
            ;restar las horas previamente convertidas a minutos
            mov ax, OcasoEnMinutos
            sub ax, AmanecerEnMinutos
            mov diferenciaMin, ax  ; Aquí tienes la diferencia en horas
            ret
        Diferencia ENDP

    ValorHora Proc Far
            mov ax, diferenciaMin
            mov bx, 12
            call dividir
            mov valorPorHora, cx
        ValorHora ENDP

inicio:
    mov     ax, Datos
    mov     ds,ax
    
    call Diferencia
   
    mov ax, 4c00h           ; Prepara una llamada a la interrupción 21h para terminar el programa.
    int 21h                 ; Llama a la interrupción 21h para terminar el programa.

Codigo Ends                 ; Finaliza la definición del segmento "Codigo".
end inicio                  ; Finaliza el programa.