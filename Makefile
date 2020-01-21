check: clean .WAIT ansible .WAIT kyua

ansible: .PHONY
	find test -name '*.input' -exec sh -c 'cp -a $$1 $${1%.input}.expected' _ {} \;
	ansible-playbook --diff blockinfile.yml

kyua: .PHONY
	find test -name '*.input' -exec sh -c 'cp -a $$1 $${1%.input}.actual' _ {} \;
	kyua test || kyua report --verbose

ci: .PHONY
	while :; do find . | entr -c -d -s "make kyua" || [ $$? -eq 0 ] && break; done

clean: .PHONY
	find test -name '*.actual' -print -delete
	find test -name '*.expected' -print -delete
	find . -name 'tmp.*' -print -delete
	find test -name '*~' -print -delete
	find test -name 'create_path' -delete
	find test -name '*.actual' -delete
