check: clean .WAIT ansible .WAIT kyua

ansible: .PHONY
	find test/blockinfile_compat -name '*.input' -exec sh -c 'cp -a $$1 $${1%.input}.expected' _ {} \;
	ansible-playbook --diff blockinfile.yml

kyua: .PHONY
	find test -name '*.input' -exec sh -c 'cp -a $$1 $${1%.input}.actual' _ {} \;
	kyua test || kyua report --verbose

ci: .PHONY
	while :; do find . | entr -c -d -s "make kyua" || [ $$? -eq 0 ] && break; done

clean: .PHONY
	find test -name '*.actual' -print -delete

	find . -name 'tmp.*' -print -delete

	find test/blockinfile_compat -name '*.expected' -print -delete
	find test/blockinfile_compat -name '*~' -print -delete
	find test/blockinfile_compat -name 'create_path' -print -delete
