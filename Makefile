ifneq (,$(wildcard ./.env))
    include .env
    export
endif

deploy:
	npx hardhat run scripts/deploy.js --network goerli --optimizer true

size:
	npx hardhat size-contracts
