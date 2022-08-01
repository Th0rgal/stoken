%lang starknet
from src.stoken import balances, send, allow, transfer_from
from starkware.cairo.common.cairo_builtins import HashBuiltin

@external
func test_send{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    let thomas = 123
    balances.write(thomas, 1000)
    let ben = 456

    %{ stop_prank_callable = start_prank(ids.thomas) %}
    send(ben, 400)
    %{ stop_prank_callable() %}
    let (ben_balance) = balances.read(ben)
    assert 400 = ben_balance
    let (thomas_balance) = balances.read(thomas)
    assert 600 = thomas_balance

    return ()
end

@external
func test_transfer_from{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    let thomas = 123
    balances.write(thomas, 1000)
    let ben = 456

    %{ stop_prank_callable = start_prank(ids.thomas) %}
    allow(ben, 400)
    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(ids.ben) %}
    transfer_from(thomas, ben, 400)
    %{ stop_prank_callable() %}

    let (ben_balance) = balances.read(ben)
    assert 400 = ben_balance
    let (thomas_balance) = balances.read(thomas)
    assert 600 = thomas_balance

    return ()
end
