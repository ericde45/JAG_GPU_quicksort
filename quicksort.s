	.phrase
GPU_debut:

	.gpu
	.org	G_RAM
GPU_base_memoire:

; CPU interrupt
	.rept	8
		nop
	.endr
; DSP interrupt, the interrupt output from Jerry
	.rept	8
		nop
	.endr
; Timing generator
	.rept	8
		nop
	.endr
; Object Processor
	.rept	8
		nop
	.endr
; Blitter
	.rept	8
		nop
	.endr



GPU_init:
	movei	#GPU_ISP+(GPU_STACK_SIZE*4),r31			; init isp
	moveq	#0,r1
	moveta	r31,r31									; ISP (bank 0)
	nop
	movei	#GPU_USP+(GPU_STACK_SIZE*4),r31			; init usp



	movei	#dataXY,R0
	moveq	#6,R10					; nb valeurs
	shlq	#2,R10					; *4
		
	movei	#GPU_startqsort,R22
	movei	#GPU_qsort_retour_main,R13
	subq	#4,R31
	store	R13,(R31)
	jump	(R22)					; BL      qsort               // Sort first bucket
	nop
GPU_qsort_retour_main:

GPU_loop:
		jr		GPU_loop


;--------------- quick sort --------------------------
; du + au -
; R0=liste des valeurs X.L
; R10= nb valeurs * 4 
GPU_startqsort:
	subq		#4,R10
	move		R0,R1
	add			R10,R1
	movei		#GPU_quicksort,R6
	movei		#-4,R17
GPU_quicksort:
	move		R0,R2
	move		R1,R3
	move		R1,R10
	sub			R0,R10
	shrq		#1,R10					; /2
	and			R17,R10
	move		R0,R14
	add			R10,R14
	load		(R14),R10				; long = YX

GPU_quicksort_repeat:
	load		(R2),R11
	addq		#4,R2
	cmp			R10,R11
	jr			mi,GPU_quicksort_repeat
	nop
	subq		#4,R2
	
	load		(R3),R12
	cmp			R10,R12
	jr			eq,GPU_quicksort_fwhile2
	nop
	jr			mi,GPU_quicksort_fwhile2
	nop
GPU_quicksort_while2:
	subq		#4,R3
	load		(R3),R12
	cmp			R10,R12
	jr			hi,GPU_quicksort_while2
	nop
	
GPU_quicksort_fwhile2:
	cmp			R2,R3
	movei		#GPU_quicksort_twoegal,R22
	jr			mi,GPU_quicksort_jinfi
	nop
	jump		eq,(R22)
	nop
	store		R11,(R3)
	store		R12,(R2)
	addq		#4,R2
	subq		#4,R3
	cmp			R2,R3
GPU_quicksort_jinfi:
	movei		#GPU_quicksort_repeat,R22
	jump		hi,(R22)
	nop

	cmp			R0,R3
	movei		#GPU_quicksort_nosort1,R22
	jump		eq,(R22)
	nop
	jump		mi,(R22)
	nop
	
; recursivité
	subq	#4,R31
	store	R1,(R31)
	subq	#4,R31
	store	R2,(R31)
	move	R3,R1
	subq	#4,R31
	movei	#GPU_quicksort_retour1,R22
	store	R22,(R31)
	jump	(R6)
	nop
GPU_quicksort_retour1:
 	load	(r31),r2	; pop R2
	addq	#4,r31		; pop from stack
 	load	(r31),r1	; pop R1
	addq	#4,r31		; pop from stack

GPU_quicksort_nosort1:
	cmp		R2,R1
	jr			eq,GPU_quicksort_nosort2
	nop
	jr			mi,GPU_quicksort_nosort2
	nop
	move		R2,R0
	jump		(R6)				; boucle tout en haut
	nop

GPU_quicksort_nosort2:
 	load	(r31),r28	; return address
	addq	#4,r31		; pop from stack
	jump	t,(r28)		; return
	nop

GPU_quicksort_twoegal:
	addq	#4,R2
	subq	#4,R3
	cmp		R0,R3
	movei	#GPU_quicksort_enosort1,R22
	jump	eq,(R22)
	nop
	jump	mi,(R22)
	nop
	
; recursivité
	subq	#4,R31
	store	R1,(R31)
	subq	#4,R31
	store	R2,(R31)
	move	R3,R1
	subq	#4,R31
	movei	#GPU_quicksort_retour2,R22
	store	R22,(R31)
	jump	(R6)
	nop
GPU_quicksort_retour2:
 	load	(r31),r2	; pop R2
	addq	#4,r31		; pop from stack
 	load	(r31),r1	; pop R1
	addq	#4,r31		; pop from stack
	
GPU_quicksort_enosort1:
	cmp		R2,R1
	jr			eq,GPU_quicksort_enosort2
	nop
	jr			mi,GPU_quicksort_enosort2
	nop
	move		R2,R0
	jump		(R6)
	nop
	
GPU_quicksort_enosort2:
 	load	(r31),r28	; return address
	addq	#4,r31		; pop from stack
	jump	t,(r28)		; return
	nop



	.phrase

;---------------------
; FIN DE LA RAM GPU
GPU_fin:
;---------------------	

;------------------------------------
; object list
;------------------------------------
        .68000

dataXY:
		dc.l			8,2,6
		dc.l			4,5,3
