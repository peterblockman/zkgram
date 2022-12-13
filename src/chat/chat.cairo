%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin

from src.chat.msg_library import Message, Msg
from src.chat.user_library import ChatUser, User

@external
func register{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(name: felt) -> () {
    ChatUser.register(name);
    return ();
}

@external
func add_friend{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    friend_address: felt
) -> () {
    ChatUser.add_friend(friend_address);
    return ();
}

@external
func accept_friend{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    friend_address: felt
) -> () {
    ChatUser.accept_friend(friend_address);
    return ();
}

@external
func send_msg{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    reciever: felt, content: felt
) -> (msg: Msg) {
    let (new_msg) = Message.send_msg(reciever, content);
    return (msg=new_msg);
}

// VIEW

@view
func get_user{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    user_address: felt
) -> (user: User) {
    let (user) = ChatUser.get_user(user_address);

    return (user=user);
}
@view
func get_friend_status{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    user_address: felt, friend_address: felt
) -> (friend_status: felt) {
    let (friend_status) = ChatUser.get_friend_status(user_address, friend_address);

    return (friend_status=friend_status);
}

@view
func get_last_msg{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    reciever: felt
) -> (msg: Msg) {
    let (msg) = Message.get_last_msg(reciever);

    return (msg=msg);
}

@view
func get_last_idx{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    reciever: felt
) -> (next_msg_idx: felt) {
    let (_next_msg_idx) = Message.get_last_idx(reciever);

    return (next_msg_idx=_next_msg_idx);
}

@view
func get_msg_by_idx{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    reciever: felt, msg_idx: felt
) -> (msg: Msg) {
    let (msg) = Message.get_msg_by_idx(reciever, msg_idx);

    return (msg=msg);
}
