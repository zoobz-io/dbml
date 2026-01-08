.PHONY: test test-unit test-integration test-bench lint lint-fix coverage clean check ci install-tools install-hooks help

.DEFAULT_GOAL := help

## test: Run all tests with race detector
test:
	@go test -v -race ./...

## test-unit: Run unit tests only (short mode)
test-unit:
	@go test -v -short ./...

## test-integration: Run integration tests
test-integration:
	@go test -v -race -run Integration ./...

## test-bench: Run benchmarks
test-bench:
	@go test -bench=. -benchmem -benchtime=1s .

## lint: Run linters
lint:
	@golangci-lint run --config=.golangci.yml --timeout=5m

## lint-fix: Run linters with auto-fix
lint-fix:
	@golangci-lint run --config=.golangci.yml --fix

## coverage: Generate coverage report
coverage:
	@go test -coverprofile=coverage.out ./...
	@go tool cover -html=coverage.out -o coverage.html
	@go tool cover -func=coverage.out | tail -1
	@echo "Coverage report generated: coverage.html"

## clean: Remove generated files
clean:
	@rm -f coverage.out coverage.html coverage.txt
	@find . -name "*.test" -delete
	@find . -name "*.prof" -delete
	@find . -name "*.out" -delete

## check: Run tests and lint (quick validation)
check: test lint

## ci: Run full CI simulation
ci: clean lint test coverage test-bench

## install-tools: Install required development tools
install-tools:
	@go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.7.2

## install-hooks: Install git pre-commit hook
install-hooks:
	@mkdir -p .git/hooks
	@echo '#!/bin/sh' > .git/hooks/pre-commit
	@echo 'make check' >> .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "Pre-commit hook installed"

## help: Display available commands
help:
	@echo "dbml Development Commands"
	@echo "========================"
	@echo ""
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/## //' | column -t -s ':'
