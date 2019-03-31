section .bss
  Sem: resb N*N*8         ; 2dArray of semaphores
  Values: resb N*N*8      ; 2dArray of values

section .text
  global euron
  extern get_value
  extern put_value

euron:
  push rbx                ; Saving initial values of registers on stack
  push rsp
  push rbp
  push r12
  push r13
  push r14
  push r15

  mov r15, 0              ; How many on stack
  mov r12, rdi            ; Euron's number
  mov r13, rsi            ; Position in the string

read_one:                 ; Main loop for reading from the string
  mov r14b, [r13]         ; Current character in the string
  inc r13                 ; Incrementing position in the string

  cmp r14b, '0'           ; Testing character for beeing in range 0-9
  jl not_a_digit          ; If it is not a digit test next posibility
  cmp r14b, '9'
  jg not_a_digit
  xor r11, r11            ; In r11b I put current digit
  mov r11b, r14b
  sub r11, 48
  push r11                ; Pushing digit on the stack
  inc r15                 ; Extra value on stack
  jmp read_one            ; Character processed succesfully

not_a_digit:              ; Jump here if character is not a digit
  cmp r14b, 'n'
  jne not_euron           ; Test next posibility
  push r12                ; Add value of Euron on the stack
  inc r15                 ; Extra value on stack
  jmp read_one

not_euron:
  cmp r14b, '+'
  jne not_add             ; Test next posibility
  pop r11
  pop r10
  add r10, r11            ; Popping and adding two values from stack
  push r10                ; and placing sum on the stack
  dec r15                 ; One less value on the stack
  jmp read_one

not_add:
  cmp r14b, '-'
  jne not_sub
  pop r11
  neg r11                 ; Negating top of the stack
  push r11
  jmp read_one

not_sub:
  cmp r14b, '*'
  jne not_multi
  pop r11
  pop rax
  imul rax, r11           ; Poping two vaues from the stack and multiplying them
  push rax                ; Result placed on the stack
  dec r15                 ; One less value on the stack
  jmp read_one

not_multi:
  cmp r14b, 'B'
  jne not_opB
  dec r15                 ; One less value on the stack after this operation
  pop rax                 ; Top of the stack in rax
  pop r11                 ; Putting current top of the stack in r11
  push r11
  cmp r11, 0              ; If there is 0 below rax don't move rax positions
  jz read_one
  add r13, rax            ; Moving rax position in the string
  jmp read_one

not_opB:
  cmp r14b, 'C'
  jne not_opC
  pop rax
  dec r15
  jmp read_one

not_opC:
  cmp r14b, 'D'
  jne not_opD
  pop rax
  push rax
  push rax
  inc r15
  jmp read_one

not_opD:
  cmp r14b, 'E'
  jne not_opE
  pop rax
  pop r11
  push rax
  push r11
  jmp read_one

not_opE:
  cmp r14b, 'G'
  jne not_opG
  mov rdi, r12            ; Setting first function argument to Euron number
  align 16                ; Align before C call
  call get_value
  push rax
  inc r15
  jmp read_one

not_opG:
  cmp r14b, 'P'
  jne not_opP
  mov rdi, r12            ; Setting first function argument to Euron number
  pop rsi                 ; Setting second function argument to top of stack
  align 16                ; Align before C call
  call put_value
  dec r15
  jmp read_one

not_opP:
  cmp r14b, 'S'
  jne not_opS

  pop rdx                 ; Rdx holds who to trade with
  pop rcx                 ; Rcx holds value to trade

; Let n be eurons number and x number of euron to trade with

; Explanation of synchronization implemented below
; Semaphores are initialized with 0
; For euron to trade values it needs to put it's value in Values[x][n], but in
; order to do that Sem[x][n] needs to be 0, after setting value it is set to 1
; In order to get the value from other process Sem[n][x] needs to be equal to 1
; and after taking value from Values[n][x], Sem[n][x] is set back to 0

  mov r9, r12
  imul r9, N
  add r9, rdx
  shl r9, 3
  mov r8, r9              ; r8=r9= 8*(n*N+x)

  mov r10, rdx
  imul r10, N
  add r10, r12
  shl r10, 3
  mov r11, r10            ; r10=r11=8*(x*N+n) opposite side of array

  add r8, Sem             ; Position in Sem array for value setting
  add r9, Values          ; Position in Values array for value setting
  add r10, Sem            ; Position in Sem array for value getting
  add r11, Values         ; Position in Values array for value getting

wait_to_set_value:
  cmp qword [r8], 0
  jne wait_to_set_value   ; Wait until Sem is 0
  mov qword [r9], rcx
  mov qword [r8], 1

wait_to_get_value:
  cmp qword [r10], 1
  jne wait_to_get_value   ; Wait until Sem is 1
  push qword [r11]
  mov qword [r10], 0

  dec r15
  jmp read_one

not_opS:
  jmp done

done:
  pop rax                 ; Top of the stack is a return value of the program
  dec r15
  shl r15, 3              ; Returning previous stack position
  add rsp, r15            ; by rsp = rsp + (8 * #thingsOnStack)

  pop r15                 ; Restoring registers
  pop r14
  pop r13
  pop r12
  pop rbp
  pop rsp
  pop rbx
finish:
  ret
