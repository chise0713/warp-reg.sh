// This is a Fork of [badafans/warp-reg`fd562791`#L185-L198](https://github.com/badafans/warp-reg/blob/fd5627911b53018287680e6672a47ad6927b118a/main.go#L185-L198)
// Thank you! [@badafans](https://github.com/badafans/)
package main

import (
	"crypto/rand"
	"encoding/base64"
	"fmt"

	"golang.org/x/crypto/curve25519"
)

func main() {
	var priv, pub [32]byte

	if _, err := rand.Read(priv[:]); err != nil {
		fmt.Printf("err: %v\n", err)
		return
	}

	priv[0] &= 248
	priv[31] &= 127 | 64

	curve25519.ScalarBaseMult(&pub, &priv)

	fmt.Printf("priv: %s\n", base64.StdEncoding.EncodeToString(priv[:]))
	fmt.Printf("pub: %s\n", base64.StdEncoding.EncodeToString(pub[:]))
}
