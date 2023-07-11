#!/bin/sh

OP_VERSION=2.18.0
curl -l https://cache.agilebits.com/dist/1P/op2/pkg/v$OP_VERSION/op_linux_amd64_v$OP_VERSION.zip  > /tmp/op-$OP_VERSION.zip && unzip /tmp/op-$OP_VERSION.zip -d /tmp/op-$OP_VERSION && mv /tmp/op-$OP_VERSION/op ~/.local/bin && chmod u+x ~/.local/bin/op && rm -rf /tmp/op-$OP_VERSION*

sh -c "$(curl -fsLS get.chezmoi.io)" -- init
