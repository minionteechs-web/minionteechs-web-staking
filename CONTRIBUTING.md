# Contributing Guide

Thank you for your interest in contributing to MiniotechS Web Staking!

## Development Setup

1. Clone the repository:
```bash
git clone https://github.com/minionteechs-web/minionteechs-web-staking.git
cd minionteechs-web-staking
```

2. Install Foundry:
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

3. Install dependencies:
```bash
forge install
```

## Code Style

- Follow Solidity style guide
- Use `forge fmt` for formatting
- Maximum line length: 120 characters
- Use descriptive variable names

Format your code:
```bash
forge fmt
```

## Testing Requirements

All contributions must include:
- Unit tests for new functionality
- Tests for edge cases
- Gas-efficient implementation

Run tests:
```bash
forge test -vv
```

Check coverage:
```bash
forge coverage
```

## Pull Request Process

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes
4. Add tests for new functionality
5. Run tests and format code
6. Commit with clear messages
7. Push to your fork
8. Create a pull request with:
   - Description of changes
   - Why the change is needed
   - Test results
   - Any breaking changes

## Commit Messages

Use clear, descriptive commit messages:
```
feat: add tier-based staking rewards
fix: correct reward calculation overflow
docs: update API documentation
test: add fuzz tests for edge cases
refactor: optimize reward distribution
```

## Reporting Bugs

Create an issue with:
- Description of the bug
- Steps to reproduce
- Expected behavior
- Actual behavior
- Environment (OS, Foundry version)

## Feature Requests

Describe:
- Use case
- Proposed solution
- Alternative solutions
- Potential drawbacks

## Questions?

- Open a discussion on GitHub
- Email: dev@minionteechs.com
- Read existing issues and PRs

## Code Review

All contributions will be reviewed for:
- Correctness
- Security
- Gas efficiency
- Test coverage
- Code clarity

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
