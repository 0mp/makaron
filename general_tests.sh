#! /usr/bin/env atf-sh
#
# SPDX-License-Identifier: BSD-2-Clause
#
# Copyright (c) 2021 Mateusz Piotrowski <0mp@FreeBSD.org>
#

set_up() {
	name="$(atf_get ident)"
	test_dir="$(atf_get_srcdir)/test/general"
	file="${test_dir}/${name}.actual"
	expected="${test_dir}/${name}.expected"
}

verify() {
	atf_check sdiff -s "$expected" "$file"
}

atf_test_case in_flag_no_block
in_flag_no_block_head() { atf_set "descr" "Test adding a block from stdin"; }
in_flag_no_block_body() {
	set_up
	printf '%s\n' "" "new block" "" | atf_check "$cmd" --path "$file" --in
	verify
}

atf_test_case in_flag_with_block
in_flag_with_block_head() { atf_set "descr" "Test modifying a block from stdin"; }
in_flag_with_block_body() {
	set_up
	printf '%s\n' "modified block" | atf_check "$cmd" --path "$file" --in
	verify
}

atf_test_case invalid_flag
invalid_flag_head() {
	atf_set "descr" "Test that invalid flags are handled"
	atf_set "timeout" "1"
}
invalid_flag_body() {
	atf_check -s exit:64 -e "inline:ERROR: Invalid flag: -path\n" \
		"$cmd" -path "$file"
}

atf_init_test_cases()
{
	cmd="$(atf_get_srcdir)/makaron"

	atf_add_test_case in_flag_no_block
	atf_add_test_case in_flag_with_block
	atf_add_test_case invalid_flag
}
