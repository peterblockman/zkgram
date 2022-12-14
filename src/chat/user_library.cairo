%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_not_zero
from starkware.starknet.common.syscalls import get_block_timestamp
from starkware.cairo.common.bool import FALSE, TRUE

struct User {
    name: felt,
    joined_timestamp: felt,
}

@storage_var
func users(user_address: felt) -> (user: User) {
}

@storage_var
func users_count() -> (number_of_users: felt) {
}

@storage_var
func friends(user_address: felt, friend_index: felt) -> (friend: User) {
}

@storage_var
func friends_length(user_address: felt) -> (next_friend_index: felt) {
}

@storage_var
func friend_status(user_address: felt, friend_address: felt) -> (status: felt) {
}

namespace FriendStatus {
    const NOT_FRIEND = 1;
    const WAIT = 2;
    const FRIEND = 3;
}

namespace ChatUser {
    func assert_duplicate_user{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        user_address: felt
    ) -> () {
        let (user) = get_user(user_address);
        with_attr error_message("User: User {user_address} already registered") {
            assert user.joined_timestamp = 0;
        }
        return ();
    }

    func register{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(name: felt) -> (
        ) {
        alloc_locals;
        let (local user_address) = get_caller_address();

        assert_duplicate_user(user_address);

        let (joined_timestamp) = get_block_timestamp();

        let user = User(name, joined_timestamp);

        users.write(user_address, user);
        return ();
    }

    func get_user{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        user_address: felt
    ) -> (user: User) {
        let (user) = users.read(user_address);

        return (user=user);
    }

    func assert_not_registered{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        user_address: felt
    ) -> () {
        let (user) = get_user(user_address);

        with_attr error_message("User: User {user_address} not registered") {
            assert_not_zero(user.joined_timestamp);
        }

        return ();
    }

    func assert_valid_friend_status{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(_friend_status: felt) -> () {
        with_attr error_message("Friend: Invalid friend status") {
            assert (_friend_status - FriendStatus.NOT_FRIEND) * (_friend_status - FriendStatus.WAIT) * (_friend_status - FriendStatus.FRIEND) = 0;
        }

        return ();
    }

    func upsert_friend_status{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        user_address: felt, friend_address: felt, _friend_status: felt
    ) -> () {
        assert_valid_friend_status(_friend_status);
        friend_status.write(user_address, friend_address, _friend_status);
        return ();
    }

    func add_friend{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        friend_address: felt
    ) -> () {
        let (user_address) = get_caller_address();
        assert_not_registered(user_address);
        assert_not_registered(friend_address);

        let (user_friend_status) = friend_status.read(user_address, friend_address);
        let (friend_user_status) = friend_status.read(friend_address, user_address);

        with_attr error_message(
                "Friend: Friend status must be the default value 0 or 1 (NOT_FRIEND)") {
            assert user_friend_status * friend_user_status * (user_friend_status - FriendStatus.NOT_FRIEND) * (friend_user_status - FriendStatus.NOT_FRIEND) = 0;
        }

        upsert_friend_status(user_address, friend_address, FriendStatus.WAIT);
        upsert_friend_status(friend_address, user_address, FriendStatus.WAIT);

        return ();
    }

    func get_friend_status{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        user_address: felt, friend_address: felt
    ) -> (friend_status: felt) {
        let (_friend_status) = friend_status.read(user_address, friend_address);

        return (friend_status=_friend_status);
    }

    func is_friend{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        user_address: felt, friend_address: felt
    ) -> (_is_friend: felt) {
        let (_friend_status) = friend_status.read(user_address, friend_address);

        if (_friend_status == FriendStatus.FRIEND) {
            return (_is_friend=TRUE);
        }

        return (_is_friend=FALSE);
    }

    func assert_is_not_friend{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        user_address: felt, friend_address: felt
    ) -> () {
        let (_is_friend) = is_friend(user_address, friend_address);

        with_attr error_message("FRIEND: not friend") {
            assert _is_friend = TRUE;
        }
        return ();
    }

    func accept_friend{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        friend_address: felt
    ) -> () {
        let (user_address) = get_caller_address();
        assert_not_registered(user_address);
        assert_not_registered(friend_address);

        let (user_friend_status) = friend_status.read(user_address, friend_address);
        let (friend_user_status) = friend_status.read(friend_address, user_address);

        with_attr error_message("Friend: Friend status must be 2 (WAIT)") {
            assert (user_friend_status - FriendStatus.WAIT) * (friend_user_status - FriendStatus.WAIT) = 0;
        }
        upsert_friend_status(user_address, friend_address, FriendStatus.FRIEND);
        upsert_friend_status(friend_address, user_address, FriendStatus.FRIEND);

        let (next_friend_index) = friends_length.read(user_address);

        let (friend_user) = get_user(friend_address);

        friends.write(user_address, next_friend_index, friend_user);

        friends_length.write(user_address, next_friend_index + 1);

        return ();
    }
}
