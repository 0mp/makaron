#! /usr/bin/env atf-sh

set_up() {
	name="$(atf_get ident)"
	file="$(atf_get_srcdir)/test/${name}.actual"
	expected="$(atf_get_srcdir)/test/${name}.expected"
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
backup_block_head() { atf_set "descr" "Test "; }
backup_body() {
	set_up
	atf_check "$cmd" --backup yes --block "inserted line" --path "$file"
	atf_check -o "match:$file.[1-9][0-9]*.20[0-9][0-9].[01][0-9].[0-3][0-9]@[0-2][0-9]:[0-5][0-9]:[0-5][0-9]~" \
		find "$(atf_get_srcdir)" -path "${file}.*~"
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
}
