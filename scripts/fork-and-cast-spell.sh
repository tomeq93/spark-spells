#!/usr/bin/env bash
set -e

trap "kill 0" EXIT

spell_path_or_address=$1
# default params for gnosis 
spell_executor=${2-0xc4218C1127cB24a0D6c1e7D25dc34e10f2625f5A}
anvil_fork_url=${3:-https://rpc.ankr.com/gnosis}
anvil_fork_block_number=${4:-30031699}
anvil_priv_key=${5-0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80}

anvil --fork-url $anvil_fork_url --fork-block-number $anvil_fork_block_number  &

sleep 3

if [[ $spell_path_or_address == 0x* && ${#spell_path_or_address} -eq 42 ]]; then
    spell_addr=$spell_path_or_address
else
    forge build
    spell_addr=$(forge create $spell_path_or_address --private-key $anvil_priv_key | grep "Deployed to:" | awk '{print $3}')
fi

cd "$(dirname "$0")"
sh ./cast-spell.sh $anvil_priv_key $spell_addr $spell_executor

wait