#! /usr/bin/env atf-sh
#
# SPDX-License-Identifier: BSD-2-Clause
#
# Copyright (c) 2021 Mateusz Piotrowski <0mp@FreeBSD.org>
#

set_up() {
	name="$(atf_get ident)"
	test_dir="$(atf_get_srcdir)/test/blockinfile_compat"
	file="${test_dir}/${name}.actual"
	expected="${test_dir}/${name}.expected"
}

verify() {
	atf_check sdiff -s "$expected" "$file"
}

atf_test_case no_op
no_op_head() { atf_set "descr" "Test that other blocks are ignored"; }
no_op_body() {
	set_up
	atf_check "$cmd" --path "$file"
	verify
}

atf_test_case new_block_insertion
new_block_insertion_head() { atf_set "descr" "Test new block insertion"; }
new_block_insertion_body() {
	set_up
	atf_check "$cmd" --block "inserted block" --path "$file"
	verify
}

atf_test_case nested_block_update_logic
nested_block_update_logic_head() { atf_set "descr" "Test nested block update logic"; }
nested_block_update_logic_body() {
	set_up
	atf_check "$cmd" --block "modified block" --path "$file"
	verify
}

atf_test_case multiline_block
multiline_block_head() { atf_set "descr" "Test support for multiline blocks"; }
multiline_block_body() {
	set_up
	atf_check "$cmd" --block "$(cat <<EOF

line 2

line 4
EOF
	)" --path "$file"
	verify
}

atf_test_case backup
backup_block_head() { atf_set "descr" "Test the backup parameter support"; }
backup_body() {
	set_up
	atf_check "$cmd" --backup yes --block "inserted line" --path "$file"
	atf_check -o "match:$file.[1-9][0-9]*.20[0-9][0-9].[01][0-9].[0-3][0-9]@[0-2][0-9]:[0-5][0-9]:[0-5][0-9]~" \
		find "$(atf_get_srcdir)" -path "${file}.*~"
	verify
}

atf_test_case marker
marker_head() { atf_set "descr" "Test the marker parameter support"; }
marker_body() {
	set_up
	atf_check "$cmd" --block "inserted line" --marker "# {mark} CUSTOM MARKER" --path "$file"
	verify
}

atf_test_case mode_and_ownership_preservation
mode_and_ownership_preservation_head() { atf_set "descr" "Test the file mode, owner, and group preservation"; }
mode_and_ownership_preservation_body() {
	set_up
	atf_check -o save:stat.expected stat -f "%Sp %u %g" "$expected"
	atf_check "$cmd" --block "inserted line" --path "$file"
	atf_check -o save:stat.actual stat -f "%Sp %u %g" "$file"
	atf_check diff stat.expected stat.actual
}

atf_test_case create_file
create_file_head() { atf_set "descr" "Test the create parameter support for files"; }
create_file_body() {
	set_up
	atf_check -o save:stat.expected stat -f "%Sp %u %g" "$expected"
	atf_check "$cmd" --block "inserted line" --create yes --path "$file"
	atf_check -o save:stat.actual stat -f "%Sp %u %g" "$file"
	atf_check diff stat.expected stat.actual
}

atf_test_case create_path
create_path_head() { atf_set "descr" "Test the create parameter support for paths"; }
create_path_body() {
	set_up

	actual_dir="${test_dir}/${name}.dir.actual"
	file="${actual_dir}/${name}.actual"
	expected_dir="${test_dir}/${name}.dir.expected"
	expected="${expected_dir}/${name}.expected"

	atf_check -o save:dir-stat.expected stat -f "%Sp %u %g" "$expected_dir"
	atf_check -o save:file-stat.expected stat -f "%Sp %u %g" "$expected"
	atf_check "$cmd" --block "inserted line" --create yes --path "$file"
	atf_check -o save:file-stat.actual stat -f "%Sp %u %g" "$file"
	atf_check -o save:dir-stat.actual stat -f "%Sp %u %g" "$actual_dir"
	atf_check diff file-stat.expected file-stat.actual
	atf_check diff dir-stat.expected dir-stat.actual
}

atf_test_case backslashes_in_marker
backslashes_in_marker_head() { atf_set "descr" "Test proper handling of backslashes in markers"; }
backslashes_in_marker_body() {
	marker='# {mark} \#{}'
	set_up
	atf_check "$cmd" --block "modified line" --path "$file" --marker "$marker"
	atf_check "$cmd" --block "modified line" --path "$file" --marker "$marker"
	verify
}

atf_init_test_cases()
{
	cmd="$(atf_get_srcdir)/makaron"

	atf_add_test_case no_op
	atf_add_test_case new_block_insertion
	atf_add_test_case nested_block_update_logic
	atf_add_test_case multiline_block
	atf_add_test_case backup
	atf_add_test_case marker
	atf_add_test_case mode_and_ownership_preservation
	atf_add_test_case create_file
	atf_add_test_case create_path
	atf_add_test_case backslashes_in_marker
}
