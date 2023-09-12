include macros.cbc     ; Incluye el archivo de macros predefinidas para el ensamblador.


SSeg Segment 
  
SSeg EndS

Datos Segment               ; Define un segmento llamado "Datos" para almacenar variables y datos.
    hAmanecer       db 5 
    minAmanecer     db 49
    hOcaso          db 18 
    minOcaso        db 22
    diferenciaHoras db ?
    diferenciaMin   db ?
Datos Ends                  ; Finaliza la definición del segmento "Datos".


Codigo Segment              ; Define un segmento llamado "Codigo" para el código ensamblador.
assume cs:Codigo, ds:Datos  ; Asocia los registros de segmento CS (código) y DS (datos) a los segmentos definidos.
    Imprime Proc Far
            mov ah, 09h     ; paso parametro por registro ;mov dx, offset Mensaje
            int 21h
            ret 2*1
        Imprime Endp

    ;Procedimiento para sacar cuántas horas hay entre el amanecer y el ocaso
    Diferencia PROC Far
        mov ax, hOcaso
        sub ax, hAmanecer
        mov diferenciaHoras, ax
        mov ax, minOcaso
        sub ax, minAmanecer

        cmp ax, 60
        jg mayor

       mayor:
        add diferenciaHoras, 1
        sub ax, 60
        
    Diferencia ENDP

inicio:
    mov     ax, Datos
    mov     ds,ax
   
    mov ax, 4c00h           ; Prepara una llamada a la interrupción 21h para terminar el programa.
    int 21h                 ; Llama a la interrupción 21h para terminar el programa.

Codigo Ends                 ; Finaliza la definición del segmento "Codigo".
end inicio                  ; Finaliza el programa.