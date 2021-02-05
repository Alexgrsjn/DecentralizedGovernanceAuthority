# DecentralizedGovernanceAuthority

# OverView
This plans to verify validators on the Registry Which will in turn send them a nonfungible token giving them access
to certain functionalities within contracts for exampl submitting something for vote or voting themselves, depending on how the contract is written.

The Validator will Be able to verify a web wallet account as his and send the authority token to the web wallet, 
allowing him to vote from outside his validator address, thus not having him need to import his Validator Private Keys on a web wallet, provide better overall security to the network, 
in the eventual case a vulnerability is found on the web wallet. The user will also be able to revoke the Token's "active" status. so if his wallet is compromised,
the network will not suffer from abusive usage of the token where permitted.

# Vulnerabilities

This requires to have at least 51% of Registered Validators to be Truthful and not have malicious intent.
(there are 2 othervulnnerabilities right now (more like bugs that need to be fixed)) <- easily fixed

# Todo

Write ERC721 Token to give validator the access they need on the contracts implementing this protocol.
Verify and adjust Validator Registry contact.
Verify and modify wallet ownership contract to fit the needsd of this particular protocol.
Link contracts together.
Intensive testing with at least 15 Validators.
Write UI.

# Other

This is in developpement so chill.
