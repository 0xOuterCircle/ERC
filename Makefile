ifneq (,$(wildcard ./.env))
    include .env
    export
endif

deploy_factory:
	forge create \
	--use 0.8.15 \
	--verify \
	--chain 5 \
	--etherscan-api-key $ETHERSCAN_KEY \
	--rpc-url $GOERLI_RPC_URL \
	--private-key $PRIVATE_KEY \
	contracts/DaoFactory.sol:DaoFactory
