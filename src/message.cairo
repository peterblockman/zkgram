%lang starknet
from starkware.cairo.common.math import assert_nn
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.starknet.common.syscalls import get_block_timestamp
from starkware.cairo.common.math import assert_not_zero

// struct Friend {
//     pubkey: felt,
//     name: felt,
// }

// //
// struct User {
//     name: felt,
//     friends: Friend*,
// }

struct Message {
    sender: felt,
    content: felt,
    timestamp: felt,
}

@storage_var
func last_msg_idx(reciever: felt) -> (msg_index: felt) {
}

@storage_var
func messages(reciever: felt, msg_index: felt) -> (msg: Message) {
}

@external
func send_msg{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    reciever: felt, content: felt
) -> (msg: Message) {
    let (sender) = get_caller_address();
    let (_last_msg_idx) = last_msg_idx.read(reciever);

    let (timestamp) = get_block_timestamp();

    let new_msg = Message(sender=sender, content=content, timestamp=timestamp);
    messages.write(reciever, _last_msg_idx, new_msg);
    let new_last_msg_idx = _last_msg_idx + 1;

    last_msg_idx.write(reciever, new_last_msg_idx);
    return (msg=new_msg);
}

@view
func get_last_msg{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    account: felt
) -> (msg: Message) {
    let (_last_msg_idx) = last_msg_idx.read(account);

    with_attr error_message("Index: last message index is 0") {
        assert_not_zero(_last_msg_idx);
    }

    let (msg) = messages.read(account, _last_msg_idx - 1);

    return (msg=msg);
}

@view
func get_last_idx{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    account: felt
) -> (last_msg_idx: felt) {
    let (_last_msg_idx) = last_msg_idx.read(account);
    return (last_msg_idx=_last_msg_idx);
}
