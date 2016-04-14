#!/bin/bash
go test -race -cpu 4 -coverprofile /tmp/cover.out . && go tool cover -html=/tmp/cover.out -o /tmp/cover.html
