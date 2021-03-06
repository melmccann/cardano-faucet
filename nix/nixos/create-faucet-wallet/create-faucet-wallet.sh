#!/run/current-system/sw/bin/bash
set -euo pipefail

[ $# -eq 0 ] && { echo "No arguments provided.  Use -h for help."; exit 1; }

OUT="create-output.log"
ID="faucet.id"

while getopts 'm:p:h' c
do
  case "$c" in
    m) MNEMONIC_PATH="$OPTARG" ;;
    p) PASSPHRASE_PATH="$OPTARG" ;;
    *)
       echo "This command creates a faucet wallet from a 15 word mnemonic (Icarus style)."
       echo "usage: $0 -p [-m] [-o] [-h]"
       echo ""
       echo "  -m file path to the mnemonic set (autogenerated if not specified)"
       echo "  -p file path to the faucet passphrase"
       exit 0
       ;;
  esac
done

if [ -z "${PASSPHRASE_PATH:-}" ]; then
  echo "-p is a required parameter"
  exit 1
else
  PASSPHRASE="$(cat "$PASSPHRASE_PATH")"
fi

if [ -z "${MNEMONIC_PATH:-}" ]; then
  MNEMONIC="${MNEMONIC:-"$(@cardanoWalletByron@ mnemonic generate)"}"
else
  MNEMONIC="$(cat "$MNEMONIC_PATH")"
fi

[ -s "$ID" ] && { echo "A faucet wallet id already exists; delete the wallet and id file and retry as needed."; exit 0; }

MNEMONIC=$MNEMONIC PASSPHRASE=$PASSPHRASE OUT=$OUT @expect@ << 'END' > /dev/null
  set chan [open $::env(OUT) w]
  set timeout 10
  spawn @cardanoWalletByron@ wallet create from-mnemonic --wallet-style icarus IcarusFaucetWallet
  sleep 0.1
  expect "Please enter 15 mnemonic words : "
  send -- "$::env(MNEMONIC)\r"
  sleep 0.1
  expect "Please enter a passphrase: "
  send -- "$::env(PASSPHRASE)\r"
  sleep 0.1
  expect "Enter the passphrase a second time: "
  send -- "$::env(PASSPHRASE)\r"
  expect -re "{.*\n+}"
  set KEY $expect_out(0,string)
  puts $chan $KEY
  close $chan
  exit 0
END

if @jq@ -e '.id' < $OUT > /dev/null; then
  @jq@ -r '.id' < $OUT > "$ID"
else
  echo "Faucet wallet create failed."
  exit 1
fi
exit 0
