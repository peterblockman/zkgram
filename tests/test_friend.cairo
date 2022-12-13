%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from src.chat.chat import register, add_friend, get_friend_status, accept_friend
from src.chat.user_library import FriendStatus

from tests.constants import (
    TEST_ACC1,
    TEST_ACC1_JOINED_TIMESTAMP,
    TEST_ACC1_NAME,
    TEST_ACC1_DEC,
    TEST_ACC2,
    TEST_ACC2_NAME,
    TEST_ACC2_JOINED_TIMESTAMP,
    TEST_ACC2_DEC,
)

@external
func test_add_friend{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    // Register TEST_ACC2
    %{ stop_prank_callable_2 = start_prank(ids.TEST_ACC2) %}
    %{ stop_warp_2 = warp(ids.TEST_ACC2_JOINED_TIMESTAMP) %}
    register(TEST_ACC2_NAME);

    %{ stop_prank_callable_2() %}
    %{ stop_warp_2() %}

    // Register TEST_ACC1 and add friend
    %{ stop_prank_callable = start_prank(ids.TEST_ACC1) %}
    %{ stop_warp_1 = warp(ids.TEST_ACC1_JOINED_TIMESTAMP) %}

    register(TEST_ACC1_NAME);

    let (friend_status_before) = get_friend_status(TEST_ACC1, TEST_ACC2);
    assert friend_status_before = 0;

    add_friend(TEST_ACC2);

    let (friend_status_after_add_friend) = get_friend_status(TEST_ACC1, TEST_ACC2);
    assert friend_status_after_add_friend = FriendStatus.WAIT;
    // %{ print(ids.friend_status_after_add_friend) %}

    %{ stop_prank_callable() %}
    %{ stop_warp_1() %}

    return ();
}

@external
func test_accept_friend{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    %{ stop_prank_callable_2 = start_prank(ids.TEST_ACC2) %}
    %{ stop_warp_2 = warp(ids.TEST_ACC2_JOINED_TIMESTAMP) %}
    register(TEST_ACC2_NAME);

    %{ stop_prank_callable_2() %}
    %{ stop_warp_2() %}

    %{ stop_prank_callable = start_prank(ids.TEST_ACC1) %}
    %{ stop_warp_1 = warp(ids.TEST_ACC1_JOINED_TIMESTAMP) %}

    register(TEST_ACC1_NAME);

    add_friend(TEST_ACC2);

    let (friend_status_after_add_friend) = get_friend_status(TEST_ACC1, TEST_ACC2);
    assert friend_status_after_add_friend = FriendStatus.WAIT;
    // %{ print(ids.friend_status_after_add_friend) %}

    accept_friend(TEST_ACC2);
    let (friend_status_after_accept_friend) = get_friend_status(TEST_ACC1, TEST_ACC2);
    assert friend_status_after_accept_friend = FriendStatus.FRIEND;

    %{ stop_prank_callable() %}
    %{ stop_warp_1() %}

    return ();
}

@external
func test_accept_friend_revert_if_user_not_registered{
    syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*
}() {
    // revert if TEST_ACC1  not registed
    %{ stop_prank_callable = start_prank(ids.TEST_ACC1) %}
    %{ stop_warp_1 = warp(ids.TEST_ACC1_JOINED_TIMESTAMP) %}
    %{ expect_revert(error_message = f"User: User {ids.TEST_ACC1_DEC} not registered") %}
    accept_friend(TEST_ACC2);

    %{ stop_prank_callable() %}
    %{ stop_warp_1() %}

    return ();
}

@external
func test_accept_friend_revert_if_friend_not_registered{
    syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*
}() {
    %{ stop_prank_callable_1 = start_prank(ids.TEST_ACC1) %}
    %{ stop_warp_1 = warp(ids.TEST_ACC1_JOINED_TIMESTAMP) %}

    register(TEST_ACC1_NAME);

    %{ stop_prank_callable_1() %}
    %{ stop_warp_1() %}
    // revert if TEST_ACC2  not registed
    %{ stop_prank_callable_2 = start_prank(ids.TEST_ACC2) %}
    %{ stop_warp_2 = warp(ids.TEST_ACC2_JOINED_TIMESTAMP) %}
    %{ expect_revert(error_message = f"User: User {ids.TEST_ACC2_DEC} not registered") %}
    accept_friend(TEST_ACC2);

    %{ stop_prank_callable_2() %}
    %{ stop_warp_2() %}

    return ();
}
