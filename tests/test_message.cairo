%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from src.chat.chat import (
    send_msg,
    get_last_msg,
    get_last_msg_idx,
    get_msg_by_idx,
    register,
    add_friend,
    get_friend_status,
    accept_friend,
)

from tests.constants import (
    TEST_ACC1,
    TEST_ACC1_NAME,
    TEST_ACC1_JOINED_TIMESTAMP,
    TEST_ACC2,
    TEST_ACC2_JOINED_TIMESTAMP,
    TEST_ACC2_NAME,
    HELLO,
    HI,
)

@external
func __setup__{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() -> () {
    %{ stop_prank_callable_2 = start_prank(ids.TEST_ACC2) %}
    %{ stop_warp_2 = warp(ids.TEST_ACC2_JOINED_TIMESTAMP) %}
    register(TEST_ACC2_NAME);

    %{ stop_prank_callable_2() %}
    %{ stop_warp_2() %}

    // Register TEST_ACC1 and add friend
    %{ stop_prank_callable = start_prank(ids.TEST_ACC1) %}
    %{ stop_warp_1 = warp(ids.TEST_ACC1_JOINED_TIMESTAMP) %}

    register(TEST_ACC1_NAME);

    add_friend(TEST_ACC2);

    %{ stop_prank_callable() %}
    %{ stop_warp_1() %}

    %{ stop_prank_callable_2_1 = start_prank(ids.TEST_ACC2) %}
    %{ stop_warp_2_1 = warp(ids.TEST_ACC2_JOINED_TIMESTAMP) %}
    accept_friend(TEST_ACC1);

    %{ stop_prank_callable_2_1() %}
    %{ stop_warp_2_1() %}

    return ();
}

@external
func test_send_message{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    %{ stop_prank_callable = start_prank(ids.TEST_ACC1) %}
    %{ stop_warp_1 = warp(1670919936) %}

    send_msg(TEST_ACC2, HELLO);  // Hello
    let (sent_msg) = get_last_msg(TEST_ACC2);

    // %{ print(ids.sent_msg.sender, ids.sent_msg.content, ids.sent_msg.timestamp) %}

    assert sent_msg.sender = TEST_ACC1;
    assert sent_msg.content = HELLO;
    assert sent_msg.timestamp = 1670919936;

    %{ stop_warp_1() %}

    %{ stop_warp_2 = warp(1670919937) %}
    send_msg(TEST_ACC2, HI);  // Hi
    let (another_sent_msg) = get_last_msg(TEST_ACC2);

    assert another_sent_msg.sender = TEST_ACC1;
    assert another_sent_msg.content = HI;
    assert another_sent_msg.timestamp = 1670919937;
    %{ stop_warp_2() %}
    %{ stop_prank_callable() %}

    return ();
}

@external
func test_get_msg_by_idx{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    %{ stop_prank_callable = start_prank(ids.TEST_ACC1) %}
    %{ stop_warp_1 = warp(1000) %}

    send_msg(TEST_ACC2, HELLO);  // Hello
    let (sent_msg) = get_msg_by_idx(TEST_ACC2, 0);
    assert sent_msg.sender = TEST_ACC1;
    assert sent_msg.content = HELLO;
    assert sent_msg.timestamp = 1000;
    %{ stop_warp_1() %}

    %{ stop_warp_2 = warp(1001) %}
    send_msg(TEST_ACC2, HI);  // Hi
    let (another_sent_msg) = get_msg_by_idx(TEST_ACC2, 1);

    assert another_sent_msg.sender = TEST_ACC1;
    assert another_sent_msg.content = HI;
    assert another_sent_msg.timestamp = 1001;
    %{ stop_warp_2() %}
    %{ stop_prank_callable() %}

    return ();
}
