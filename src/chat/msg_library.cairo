%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.starknet.common.syscalls import get_block_timestamp
from starkware.cairo.common.math import assert_not_zero

struct Msg {
    sender: felt,
    content: felt,
    timestamp: felt,
}

@storage_var
func next_msg_idx(reciever: felt) -> (msg_index: felt) {
}

@storage_var
func messages(reciever: felt, msg_index: felt) -> (msg: Msg) {
}

namespace Message {
    func send_msg{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        reciever: felt, content: felt
    ) -> (msg: Msg) {
        let (sender) = get_caller_address();
        let (_next_msg_idx) = next_msg_idx.read(reciever);

        let (timestamp) = get_block_timestamp();

        let new_msg = Msg(sender=sender, content=content, timestamp=timestamp);
        messages.write(reciever, _next_msg_idx, new_msg);
        let new_next_msg_idx = _next_msg_idx + 1;

        next_msg_idx.write(reciever, new_next_msg_idx);
        return (msg=new_msg);
    }

    func get_last_msg{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        reciever: felt
    ) -> (msg: Msg) {
        let (_next_msg_idx) = next_msg_idx.read(reciever);

        with_attr error_message("Index: last message index is 0") {
            assert_not_zero(_next_msg_idx);
        }

        let (msg) = messages.read(reciever, _next_msg_idx - 1);

        return (msg=msg);
    }

    func get_last_idx{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        reciever: felt
    ) -> (next_msg_idx: felt) {
        let (_next_msg_idx) = next_msg_idx.read(reciever);
        return (next_msg_idx=_next_msg_idx);
    }

    func get_msg_by_idx{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        reciever: felt, msg_idx: felt
    ) -> (msg: Msg) {
        let (msg) = messages.read(reciever, msg_idx);

        return (msg=msg);
    }
}
