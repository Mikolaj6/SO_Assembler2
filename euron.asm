Zero equ 48
Nine equ 57
EuronNum equ 110
OpAdd equ 43
OpSub equ 45
OpMulti equ 42

OpB equ 66
OpC equ 67
OpD equ 68
OpE equ 69

OpG equ 71
OpP equ 80

OpS equ 83

section .bss
  Sem: resb N*N*8
  Values: resb N*N*8

section .text
  global euron
  extern get_value
  extern put_value

euron:
  push rbx                ; Saving initial values of registers
  push rsp
  push rbp
  push r12
  push r13
  push r14
  push r15

  mov r15, 0              ; How many on stack
  mov r12, rdi            ; numer euronu
  mov r13, rsi

read_one:
  cmp byte [r13], Zero
  jl not_a_digit
  cmp byte [r13], Nine
  jg not_a_digit
  xor r11, r11
  mov r11b, byte [r13]
  sub r11, 48
  push r11
  inc r15
  inc r13
  jmp read_one

not_a_digit:
  cmp byte [r13], EuronNum
  jne not_euron_num
  push r12
  inc r15
  inc r13
  jmp read_one

not_euron_num:
  cmp byte [r13], OpAdd
  jne not_add
  pop r11
  pop r10
  add r10, r11
  push r10
  dec r15
  inc r13
  jmp read_one

not_add:
  cmp byte [r13], OpSub
  jne not_sub
  pop r11
  neg r11
  push r11
  inc r13
  jmp read_one

not_sub:
  cmp byte [r13], OpMulti
  jne not_multi
  pop r11
  pop rax
  imul rax, r11                                 ;IMUL?????
  push rax
  dec r15
  inc r13
  jmp read_one

not_multi:
  cmp byte [r13], OpB
  jne not_opB
  dec r15

  pop rax
  pop r11
  cmp r11, 0
  push r11
  jz increment
  add r13, rax
  inc r13
  jmp read_one
increment:
  inc r13
  jmp read_one

not_opB:
  cmp byte [r13], OpC
  jne not_opC
  pop rax
  dec r15
  inc r13
  jmp read_one

not_opC:
  cmp byte [r13], OpD
  jne not_opD
  pop rax
  push rax
  push rax
  inc r15
  inc r13
  jmp read_one

not_opD:
  cmp byte [r13], OpE
  jne not_opE
  pop rax
  pop r11
  push rax
  push r11
  inc r13
  jmp read_one

not_opE:
  cmp byte [r13], OpG
  jne not_opG
  mov rdi, r12
  align 16
  call get_value
  push rax
  inc r15
  inc r13
  jmp read_one

not_opG:
  cmp byte [r13], OpP
  jne not_opP
  mov rdi, r12
  pop rsi
  align 16
  call put_value
  dec r15
  inc r13
  jmp read_one

not_opP:
  cmp byte [r13], OpS
  jne not_opS
  pop r11               ; Do kogo
  pop rcx               ; Do zamiany


  mov r9, r12
  imul r9, N
  add r9, r11
  shl r9, 3

  mov r8, r9
  add r8, Sem          ; ostateczna pozycja w tablicy Sem
  add r9, Values        ; ostateczna pozycja w tablicy Values

  xor rbx, rbx
test_again_set:
  xor rax, rax
  lock cmpxchg [r8], rbx
  cmp rax, 0
  jne test_again_set
  mov qword [r9], rcx
  lock inc qword [r8]

  mov r9, r11
  imul r9, N
  add r9, r12
  shl r9, 3

  mov r8, r9
  add r8, Sem          ; ostateczna pozycja w tablicy Sem
  add r9, Values        ; ostateczna pozycja w tablicy Values

; 1 -(7)-> 3 ALe get więc chcemy z drugiej strony czyli, (8*r12 + r11*N*8)
  mov rbx, 1
test_again_get:
  mov rax, 1
  lock cmpxchg [r8], rbx
  cmp rax, 1
  jne test_again_get
  push qword [r9]
  lock dec qword [r8]
  dec r15
  inc r13
  jmp read_one

not_opS:
  jmp done

done:
  pop rax
  dec r15
  shl r15, 3
  add rsp, r15

  pop r15
  pop r14
  pop r13
  pop r12
  pop rbp
  pop rsp
  pop rbx
finish:
  ret
