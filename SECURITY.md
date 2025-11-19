# Security Policy

## Reporting a Vulnerability

**Do not** open public issues for security vulnerabilities. Instead, please email security@minionteechs.com with:

1. Description of the vulnerability
2. Steps to reproduce
3. Potential impact
4. Suggested fix (if any)

We will:
- Acknowledge your report within 48 hours
- Provide updates on our investigation
- Credit you for the discovery (if desired)

## Disclosure Timeline

- Day 1: Vulnerability report received and acknowledged
- Day 3-7: Investigation and patch development
- Day 7: Security advisory issued
- Day 14: Public disclosure (if applicable)

## Security Best Practices

When deploying this contract:

1. **Audit**: Have the contract audited by a reputable firm
2. **Testing**: Run the full test suite before deployment
3. **Testnet**: Deploy to testnet first
4. **Monitoring**: Set up alerts for contract activity
5. **Upgrades**: Plan for emergency pause mechanism
6. **Documentation**: Keep detailed deployment records

## Known Limitations

- Single-threaded reward calculation
- No automatic rebalancing
- Requires manual reward funding
- No slashing mechanism
- No delegation support (v1.0)

## Future Security Improvements

- Multi-signature admin functions
- Time-lock for critical changes
- Decentralized governance
- Upgrade proxy pattern
- Circuit breaker mechanism
