test-classic:
	carton exec -- prove -Ilib-classic -v t

test-modern:
	carton exec -- prove -Ilib-modern -v t

clean:
	rm -f log.txt
