%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from src.chat.chat import register, get_user

from tests.constants import (
    TEST_ACC1,
    TEST_ACC1_JOINED_TIMESTAMP,
    TEST_ACC1_NAME,
    TEST_ACC2,
    TEST_ACC2_NAME,
    TEST_ACC2_JOINED_TIMESTAMP,
)
@external
func test_register{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    %{ stop_prank_callable = start_prank(ids.TEST_ACC1) %}
    %{ stop_warp_1 = warp(ids.TEST_ACC1_JOINED_TIMESTAMP) %}

    register(TEST_ACC1_NAME);

    let (user) = get_user(TEST_ACC1);
    // %{ print(ids.user.joined_timestamp) %}
    assert user.joined_timestamp = TEST_ACC1_JOINED_TIMESTAMP;
    assert user.name = TEST_ACC1_NAME;

    // revert if duplicate account
    %{ expect_revert() %}
    register(TEST_ACC1_NAME);

    %{ stop_prank_callable() %}
    %{ stop_warp_1() %}

    return ();
}
