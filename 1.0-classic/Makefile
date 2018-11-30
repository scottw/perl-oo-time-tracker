.PHONY: clean test

clean:
	-@rm ledger.txt

test:
	carton exec -- prove -lv t

../work:
	mkdir ../work

next: ../work
	rsync -aivHS --delete ./ ../work/
