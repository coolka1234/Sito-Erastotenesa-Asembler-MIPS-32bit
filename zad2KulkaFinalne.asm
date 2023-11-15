.data
N:      .word 50000        # ile liczb bedziemy badac
numall: .space 2000000
primes: .space 2000000     # tablica do przechowania liczb pierwszych (*4 n)
nprimes: .word 0        # ile znaleziono pierwszych
space:  .asciiz " "
iloscPrime: .asciiz "Ilosc liczb pierwszych: "
.text
.globl main

main:
    # laduj n do t0
    lw $t0, N

    # kalkulujemy potrzebny rozmiar tablicy
    sll $t1, $t0, 2

    # alokacja pamieci dla tablicy
    li $v0, 9           # sbrk, funkcja syscall alokuje odpowiednia ilosc pamieci
    move $a0, $t1       # 
    syscall             # 
    move $s0, $v0       # adres tablicy w s0

    # inicjalizacja tablicy
    li $t2, 2           # zaczynamy od 2 (1 to zawsze pierwsza)
    li $t3, 0           # index tablic=0

init_loop:
    bgt $t2, $t0, end_init    # od t2 do n

    # dodaj prime do array
    add $t4, $s0, $t3   # policz adres tablicy
    sw $t2, ($t4)       # zachowaj wartosc w tablicy

    # zwieksz indekx i zmienna inkrementacji
    addi $t3, $t3, 4
    addi $t2, $t2, 1

    j init_loop         # powtorz

end_init:
    # kopiujemy wskaznik na poczatek tablic do s1
    move $s1, $s0
    li $t3, 0
    # inicjalizacja zmiennych, pierwsza petla do sqrt(n)
    li $t6,0
    li $t8,0
    li $t9,2
    sqrt:
    bgt $t8,$t0 go_loop #szukamy pieriwiastka, mnozymy liczby od 2 w gore az znajdziemy taka
    mul $t8, $t9,$t9	#ktora podniesiona do kwadratu jest wieksza niz n- to nasz pierwiastek n
    addi $t9,$t9,1
    j sqrt
    go_loop:
    move $s2, $s0
    li $t7,0       		# s2 kolejna kopia wskaznika do poczatku tablicy
    sqrt_loop:
        bgt $t3, $t9, end_sqrt_loop  # koniec petli jesli t3>sqrt(n)
	addi $t3,$t3, 1 	#zwiekszanie indeksu
	move $s2, $s1 		#bedziemy wykreslac od i
        lw $t6, ($s1)       	# ladujemy wykreslacza
        move $t7, $t6      	#t7=i
        sll $t7,$t6, 2		#mnozymy t7 razy 4, jako adres tablicy
        add $s2,$s2,$t7  	#j=i+i
        beqz $t6,end_mark_loop	#jak wykreslacz jest 0 to przechodzimy do nastepnej (nie dodane)
	add $t4,$t6,$t6 	#od j do n (gdzie j=i+i)
    mark_loop:
	bgt $t4,$t0, end_mark_loop   	# wyjdz jak przejechalismy wszystkie
	lw $t5,($s2) 			#ladujemy jakby i+j
        sw $zero, ($s2) 		#ustawiamy na 0

    not_multiple:
    	sll $t7,$t6, 2		#przeskakujemy na nastepny adres j*4
        add $s2, $s2, $t7    	# przesuwamy ofiare o 1
        add $t4,$t4,  $t6	#i++
        j mark_loop         	# i raz jeszcze

    end_mark_loop:
        addi $s1, $s1, 4	#przesuwamy indeks tablicy
        li $t7, 0
        j sqrt_loop         # powtorz

    end_sqrt_loop:
        # liczymy pierwsze liczby do nprimes
        li $t7, 0           #  inicjalizacje i ustawienie wskaznika
        move $s1, $s0       # 
        li $t5, 0           # 
        li $t9,0

    count_loop:
        lw $t6, ($s1)       # sprawdzamy czy liczba to nie 0, czyli prime i zwiekszamy t9
        bge $t5,$t0 end_count_loop   # 

        addi $t5, $t5, 1    # 
        addi $s1, $s1, 4    # przesuwanie adresu
	beqz $t6, count_loop
        addi $t9,$t9,1
        j count_loop        #

    end_count_loop:
        # wypisz spacje
        li $v0, 4           # syscall dla stringa
        la $a0, iloscPrime       # 
        syscall
        # ilosc zapisujemy do nprimes
        sw $t9, nprimes
        li $v0, 1           # syscall dla inta
        move $a0, $t9       
        syscall
        # wypisz spacje
        li $v0, 4           # syscall dla stringa
        la $a0, space       # 
        syscall

        # Print the primes
        move $s1, $s0       # s1 wskaznik do poczatku tablicy
        li $t5, 0           # inicjalizujemy indeks

    print_loop:
        lw $t6, ($s1)       # ladujemy element z tablicy
        bge $t5,$t0 end_print_loop   # jesli po wszystkim przejechane to koniec
        sw $t6, primes($s3)
	addi $t5, $t5, 1    # i++
        addi $s1, $s1, 4    # zwiekszanie adresu tablicy
        addi $s3, $s3, 4	#przesuwamy indeks primes
        # wypisz liczbe
        li $v0, 1           # syscall dla inta
        beqz  $t6,print_loop
        move $a0, $t6       
        syscall

        # wypisz spacje
        li $v0, 4           # syscall dla stringa
        la $a0, space       # 
        syscall

        j print_loop        # powtarzamy

    end_print_loop:
        li $v0, 10          # zakoncz program
        syscall






