test-classic:
	carton exec -- prove -Ilib1 -v t

test-modern:
	carton exec -- prove -Ilib2 -v t

clean:
	rm -f log.txt
