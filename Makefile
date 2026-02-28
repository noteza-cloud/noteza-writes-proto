BUF ?= buf
AGAINST ?= .git#branch=main

.PHONY: generate lint breaking

generate:
	$(BUF) generate

lint:
	$(BUF) lint

breaking:
	$(BUF) breaking --against '$(AGAINST)'
