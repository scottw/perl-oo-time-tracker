test-coupled: LIB=lib-coupled
test-coupled: TESTS=t/Timer.pm.t t/Tracker-coupled.pm.t

test-classic: LIB=lib-classic
test-classic: TESTS=t/Timer.pm.t t/Tracker.pm.t

test-modern: LIB=lib-modern
test-modern: TESTS=t/Timer.pm.t t/Tracker.pm.t

test-%:
	carton exec -- prove -I$(LIB) -v $(TESTS)

clean:
	rm -f log.txt
