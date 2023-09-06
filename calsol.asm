include macros.cbc     ; Incluye el archivo de macros predefinidas para el ensamblador.


SSeg Segment 
  
SSeg EndS

Datos Segment               ; Define un segmento llamado "Datos" para almacenar variables y datos.
    Text  db "Hola buenas"
Datos Ends                  ; Finaliza la definición del segmento "Datos".


Codigo Segment              ; Define un segmento llamado "Codigo" para el código ensamblador.
assume cs:Codigo, ds:Datos  ; Asocia los registros de segmento CS (código) y DS (datos) a los segmentos definidos.
   

inicio:
    mov     ax, Datos
    mov     ds,ax
   
    mov ax, 4c00h           ; Prepara una llamada a la interrupción 21h para terminar el programa.
    int 21h                 ; Llama a la interrupción 21h para terminar el programa.

Codigo Ends                 ; Finaliza la definición del segmento "Codigo".
end inicio                  ; Finaliza el programa.