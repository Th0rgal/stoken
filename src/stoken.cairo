%lang starknet
from starkware.cairo.common.math import assert_nn
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp

@storage_var
func balances(address : felt) -> (amount : felt):
end

@storage_var
func allowances(address : felt, spender : felt) -> (amount : felt):
end

@view
func get_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt
) -> (amount : felt):
    let (amount) = balances.read(address)
    return (amount)
end

@external
func send{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    target : felt, amount : felt
) -> ():
    let (caller) = get_caller_address()
    _transfer(caller, target, amount)
    return ()
end

@external
func allow{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    spender : felt, amount : felt
) -> ():
    let (caller) = get_caller_address()
    allowances.write(caller, spender, amount)
    return ()
end

@external
func transfer_from{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    source : felt, target : felt, amount : felt
) -> ():
    let (caller) = get_caller_address()
    let (allowed_amount) = allowances.read(source, caller)
    # we will assert that amount >= 0 in _transfer
    # assert allowed_amount >= amount
    assert_nn(allowed_amount - amount)
    allowances.write(source, caller, allowed_amount - amount)
    _transfer(source, target, amount)
    return ()
end

func _transfer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    source : felt, target : felt, amount : felt
) -> ():
    # assert amount >= 0
    assert_nn(amount)

    let (source_amount) = balances.read(source)

    # assert source_amount-amount >= 0
    assert_nn(source_amount - amount)
    let (target_amount) = balances.read(target)

    balances.write(source, source_amount - amount)

    # target_amount+amount can overflow if total_supply > P
    balances.write(target, target_amount + amount)
    return ()
end
