.model tiny
.data
.code
.startup
	mov 	ax,00h
	mov 	bx,ax
	mov 	cx,ax
	mov 	dx,ax
	
	mov		al,10011000b
	out 	46h,al ; set to mode 0 for all the three ports
x4:	
	in 		al,40h ; get time
	and 	al,00011111b 
	.if		al >= 6 && al <= 10 ; @Peak
			mov ah,2
	.elseif	al >= 17 && al <= 19 ; @peak
			mov ah,2
	.elseif	al >= 0 && al <= 5 ; @low
			mov ah,0
	.else	
			mov ah,1
	.endif
	
	in		al,44h ; get status of sensors
	mov 	bh,al 
	and 	bh,10000000b ; @max.mainTank
	and 	al,01110000b
	cmp		al,01110000b
	jz		x3 ; @max.smart
	cmp		al,00110000b
	jz		x2 ; @mid.smart
	cmp		al,00010000b
	jz		x1 ; @min.smart
	cmp		al,00000000b
	jz		x0 ; @zero.smart
	jmp 	rt
	
x0:	call flowin ;when @zero
	jmp 	rt

x1: .if 	ah != 0 ; when @min
			call flowin 
	.else
			call flowout
	.endif
	jmp rt
	
x2: .if	  	ah == 2 ;when @mid
			call flowin
	.else 
			call flowout
	.endif
	jmp rt
	
x3:	call flowout ; when @max
	jmp rt

flowin: 
	.if 	bh != 80h ;check the level in main tank
			mov 	al,05h
			out 	42h,al
	.else	
			mov 	al,01h
			out		42,al
	.endif
	ret
flowout:
	mov 	al,02h
	out 	42h,al
	ret
rt:
	jmp x4
.exit
end

; PIN Configuration of 8255

; PA
; 0-4 : Input from binary clock
; 7 : Input from clock trigger

; PB
; 0: smart motor input
; 2: main motor
; 1: smart motor output

; PC
; 4: bottom
; 5: mid
; 6: top
; 7: mainTop
