%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from src.message import send_msg, get_last_msg, get_last_idx

const TEST_ACC1 = 0x00348f5537be66815eb7de63295fcb5d8b8b2ffe09bb712af4966db7cbb04a95;
const TEST_ACC2 = 0x3fe90a1958bb8468fb1b62970747d8a00c435ef96cda708ae8de3d07f1bb56b;

@external
func test_send_message{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    %{ stop_prank_callable = start_prank(ids.TEST_ACC1) %}
    %{ stop_warp_1 = warp(1000) %}

    send_msg(TEST_ACC2, 310939249775);  // Hello
    let (sent_msg) = get_last_msg(TEST_ACC2);

    %{ print(ids.sent_msg.sender, ids.sent_msg.content, ids.sent_msg.timestamp) %}

    assert sent_msg.sender = TEST_ACC1;
    assert sent_msg.content = 310939249775;
    assert sent_msg.timestamp = 1000;

    %{ stop_warp_1() %}

    %{ stop_warp_2 = warp(1001) %}
    send_msg(TEST_ACC2, 18537);  // Hi
    let (another_sent_msg) = get_last_msg(TEST_ACC2);

    assert another_sent_msg.sender = TEST_ACC1;
    assert another_sent_msg.content = 18537;
    assert another_sent_msg.timestamp = 1001;
    %{ stop_warp_2() %}
    %{ stop_prank_callable() %}

    return ();
}
