# cardano-faucet

A simple faucet API server for cardano wallet.

## Running

* To run locally, make sure you have [cardano-wallet](https://github.com/input-output-hk/cardano-wallet/) and [cardano-node](https://github.com/input-output-hk/cardano-node) and configured appropriately.
* After that, you can run the server, the easiest way for which is to use the nix modules system and a nix cardano-faucet role, such as:
  * [cardano-ops faucet role](https://github.com/input-output-hk/cardano-ops/tree/master/roles/faucet.nix)

## Usage

Now we can test sending some funds to the new account from our faucet:

```shell-session
$ curl -XPOST localhost:8091/send-money/37btjrVyb4KAo443bvsk2FkEanKrLShXY9MAy7BeuW8iKnbKRZWvgJo1dRP5WmJbpDwqVyxLjuyxLfUuwFRWb9HdW2dH3PUyznWPPDS2buK4g7tov4
{"success":true,"amount":1000000000,"fee":171334,"txid":"bbe3514818c490b661546f83e1a2ac4ec51180ca9d1f4731642923f447b445b7"}
```

Optionally, an api key can be provided to bypass the rate limiter:

```shell-session
$ curl -XPOST localhost:8091/send-money/37btjrVyb4KAo443bvsk2FkEanKrLShXY9MAy7BeuW8iKnbKRZWvgJo1dRP5WmJbpDwqVyxLjuyxLfUuwFRWb9HdW2dH3PUyznWPPDS2buK4g7tov4?apiKey=$APIKEY
```

* Check the network's explorer for the transaction to post, or,
* Use the cardano-byron-wallet cli to query your wallet

```shell-session
$ cardano-wallet-byron wallet list
```

##Building from scratch
If you choose to use `nix build` to compile the code, be aware that it will take quite a bit of time. 
Using this method means that you will also be missing some configuration files are are required to start the server.
These are:
- faucet.apikey
- faucet.passphrase
- wallet.id  
These dont need to be named exactly as above but you will need to set certain environment variables when running the server.

The file `faucet.apikey` will contain a 32 digit alphanumeric key that will be used if we want to override the restrictions on the number of requests to the faucet. 

E.g. 0029afa75548cac2d5612af6997021a8

That can be appended to the url as follows, or just set the environment variable APIKEY and you can append ?apiKey=$APIKEY instead.

```console
$ curl -X POST localhost:8091/send-money/37btjrVyb4KDe1hN9ZVgDTMwYxA9dVVW7VDzTeqbrx6naN27EUUoFnGQRtDpfhGathRkEZiBiMnCfPxsjPFex1Ke2STxsRWGqcGaappMBnFBGnbRs4?apiKey=0029afa75548cac2d5612af6997021a8?apiKey=0029afa75548cac2d5612af6997021a8
```

The file `faucet.passphrase` will contain the secret passphrase that you need to access the wallet via cardano-wallet. You will also need to pass the wallet id too, this is taken from `wallet.id` as I have named the files. 

To run the faucet:
```console
$ FAUCET_API_KEY_PATH="./faucet.apikey" FAUCET_WALLET_ID_PATH=./wallet.id LOVELACES_TO_GIVE=100000000 FAUCET_SECRET_PASSPHRASE_PATH=./faucet.passphrase ./result/bin/server
```
